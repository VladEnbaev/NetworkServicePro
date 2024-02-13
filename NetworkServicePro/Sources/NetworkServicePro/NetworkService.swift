import Foundation

import Foundation

public typealias Headers = [String: String]
public typealias QueryParameters = [String: String?]
public typealias Body = Encodable

public protocol AnyNetworkService {
    @discardableResult
    func request<T: AnyRequestPath>(path: T) async throws -> DataResponse<T.Model>
    func setBearerToken(_ token: String)
}

public final class NetworkService: AnyNetworkService {
    
    // MARK: - Private Properties
    private var session: URLSession?
    /// Основной урл адресс
    private let baseURL: URL
    ///  Сервис, который управляет токеном авторизации
    private var tokenService: AnyTokenService?
    
     
    // MARK: - Initialization
    public init(baseURL: URL) {
        self.baseURL = baseURL
        self.session = URLSession(configuration: URLSessionConfiguration.default)
    }

    // MARK: - Public Methods
    
    public func setBearerToken(_ token: String) {
        self.tokenService = TokenService(baseURL: baseURL, initialToken: token)
    }

    public func request<T: AnyRequestPath>(path: T) async throws -> DataResponse<T.Model> {
        let request = try await buildRequest(path: path)
        try Task.checkCancellation()
        let result = try await execute(request: request)

        switch result.response {
        case .ok, .accepted, .alreadyReported, .created:
            let model = try JSONDecoder().decode(T.Model.self, from: result.data)
            return DataResponse(model: model, status: result.response)
        case .unauthorized:
            if tokenService != nil {
                await tokenService?.createRefreshTokenTask()
                return try await self.request(path: path)
            } else {
                fallthrough
            }
        default:
            throw NetworkServiceError.errorMessage(result.response)
        }
    }

    // MARK: - Private methods

    private func buildRequest(path: some AnyRequestPath) async throws -> URLRequest {
        let url = baseURL.appendingPathComponent(path.urlPath)
        var request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData)
        request.httpMethod = path.method.rawValue
        if let bearerToken = try await tokenService?.token, !bearerToken.isEmpty {
            let token = "Bearer \(bearerToken)"
            request.setValue(token, forHTTPHeaderField: "Authorization")
        }
        
        // Set request parameters
        if let queryParams = path.queryParams {
            try EncoderUtils.urlEncode(request: &request, queryParams: queryParams)
        }

        if let body = path.body, path.method != .get {
            try EncoderUtils.jsonEncode(request: &request, body: body)
        }

        return request
    }

    private func execute(request: URLRequest) async throws -> (data: Data, response: HTTPStatus) {
        guard let session else { throw NetworkServiceError.invalidSession }
        try Task.checkCancellation()
        let result: (data: Data, response: URLResponse) = try await session.data(for: request)
        guard let httpResponse = result.response as? HTTPURLResponse else {
            throw NetworkServiceError.invalidResponse
        }
        let responseStatus = HTTPStatus(rawValue: httpResponse.statusCode) ?? .undefined
        return (result.data, responseStatus)
    }
}
