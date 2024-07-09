import Foundation

public typealias BearearToken = String

public protocol AnyTokenService: Actor {
    var accessToken: BearearToken? { get async throws }
    var isRefreshing: Bool { get }
    func createRefreshTokenTask()
}

// actor - решение data race на tokenRefreshingTask
public actor TokenService: AnyTokenService {
    
    
    // MARK: - Public properties
    
    // TokenService не может знать актуальность токена.
    // Если ему сказали, что токен не актуален, сервис будет ждать его обновления.
    public var accessToken: BearearToken? {
        get async throws {
            if tokenRefreshingTask != nil {
                refreshToken = try await tokenRefreshingTask!.value
            }
            return refreshToken
        }
    }
    
    public var isRefreshing: Bool {
        tokenRefreshingTask != nil
    }
    
    
    //MARK: - Private Properties
    
    private var baseURL: URL
    private var refreshToken: BearearToken?
    private var tokenRefreshingTask: Task<BearearToken, Error>? = nil
    
    
    //MARK: - Initialization
    
    public init(baseURL: URL, refreshToken: BearearToken) {
        self.refreshToken = refreshToken
        self.baseURL = baseURL
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
    
    private func refreshTokenRequest() async throws -> BearearToken {
        //TODO: - Create real request
        try await Task.sleep(for: .seconds(2))
        return "New token"
    }
}
