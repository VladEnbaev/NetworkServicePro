import Foundation

public protocol AnyTokenService: Actor {
  var accessToken: String? { get async throws }
  var isRefreshing: Bool { get }
  func createRefreshTokenTask()
}

// actor - решение data race на tokenRefreshingTask
public actor TokenService: AnyTokenService {
  
  
  // MARK: - Public properties
  
  // TokenService не может знать актуальность токена.
  // Если ему сказали, что токен не актуален, сервис будет ждать его обновления.
  public var accessToken: String? {
    get async throws {
      if tokenRefreshingTask != nil {
        savedAccessToken = try await tokenRefreshingTask!.value
      }
      return savedAccessToken
    }
  }
  
  public var isRefreshing: Bool {
    tokenRefreshingTask != nil
  }
  
  
  //MARK: - Private Properties
  
  private var refreshToken: String
  
  var savedAccessToken: String = UserDefaults.standard.string(forKey: "TokenService-AccessToken") ?? "" {
    didSet {
      UserDefaults.standard.setValue(savedAccessToken, forKey: "TokenService-AccessToken")
    }
  }
  
  private var tokenRefreshingTask: Task<String, Error>? = nil
  
  
  //MARK: - Initialization
  
  public init(
    initialAccessToken: String,
    refreshToken: String
  ) {
    self.savedAccessToken = initialAccessToken
    self.refreshToken = refreshToken
  }
  
  
  //MARK: - Public Methods
  
  public func createRefreshTokenTask() {
    guard !isRefreshing else { return }
    tokenRefreshingTask = Task {
      print("tokenService: REFRESHING...")
      let newToken = try await self.refreshTokenRequest()
      self.tokenRefreshingTask = nil
      print("tokenService: REFRESHING_ENDED")
      return newToken
    }
  }
  
  
  //MARK: - Private Methods
  
  private func refreshTokenRequest() async throws -> String {
    //TODO: - Create real request
    try await Task.sleep(for: .seconds(2))
    return "New token"
  }
}
