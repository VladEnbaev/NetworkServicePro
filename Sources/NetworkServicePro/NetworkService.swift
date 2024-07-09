import Foundation

public typealias Headers = [String: String]
public typealias QueryParameters = [String: String?]
public typealias Body = Encodable

public protocol AnyNetworkService {
  @discardableResult
  func request<T: Decodable>(endpoint: AnyEndpoint, responseModel: T.Type) async throws -> T
  func setBearerToken(_ token: String)
}

public final class NetworkService: AnyNetworkService {
  
  
  // MARK: - Private Properties
  
  /// Основная сессия
  private var session: URLSession?
  
  /// Токен аутентификации
  private var bearerToken: String?
  
  
  // MARK: - Initialization
  
  public init() {
    self.session = URLSession(configuration: URLSessionConfiguration.default)
  }
  
  
  // MARK: - Public Methods
  
  public func setBearerToken(_ token: String) {
    self.bearerToken = token
  }
  
  public func request<T: Decodable>(endpoint: AnyEndpoint, responseModel: T.Type) async throws -> T {
    let request = try await buildRequest(endpoint: endpoint)
    try Task.checkCancellation()
    let result = try await execute(request: request)
    
    switch result.response.statusCode {
    case 200...299:
      let model = try JSONDecoder().decode(T.self, from: result.data)
      return model
      
    default:
      throw HTTPError(rawValue: result.response.statusCode) ?? .undefined
    }
  }
  
  
  // MARK: - Private methods
  
  private func buildRequest(endpoint: some AnyEndpoint) async throws -> URLRequest {
    var urlComponents = URLComponents()
    urlComponents.scheme      = "https"
    urlComponents.host        = endpoint.host
    urlComponents.path        = endpoint.path
    
    guard let url = urlComponents.url else {
      throw NetworkServiceError.invalidUrl
    }
    
    var request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData)
    request.httpMethod = endpoint.method.rawValue
    
    if let additionalHeaders = endpoint.additionalHeaders {
      additionalHeaders.forEach { (field, value) in
        request.addValue(value, forHTTPHeaderField: field)
      }
    }
    
    if let bearerToken, !bearerToken.isEmpty {
      let token = "Bearer \(bearerToken)"
      request.setValue(token, forHTTPHeaderField: "Authorization")
    }
    
    // Set request parameters
    if let queryParams = endpoint.queryParams {
      try EncoderUtils.urlEncode(request: &request, queryParams: queryParams)
    }
    
    switch endpoint.contentType {
    case .json:
      if let body = endpoint.body, endpoint.method != .get {
        try EncoderUtils.jsonEncode(request: &request, body: body)
      }
    case .formUrlEncoded:
      if let body = endpoint.body, endpoint.method != .get {
        try EncoderUtils.formUrlEncode(request: &request, body: body)
      }
    }
    
    return request
  }
  
  private func execute(request: URLRequest) async throws -> (data: Data, response: HTTPURLResponse) {
    guard let session else { throw NetworkServiceError.invalidSession }
    try Task.checkCancellation()
    let result: (data: Data, response: URLResponse) = try await session.data(for: request)
    
    guard let httpResponse = result.response as? HTTPURLResponse else {
      throw NetworkServiceError.invalidResponse
    }
    
    return (result.data, httpResponse)
  }
}
