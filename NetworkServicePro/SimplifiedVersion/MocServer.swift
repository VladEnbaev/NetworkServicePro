import Foundation

actor MocServer {
    
    static var shared = MocServer()
    var isNeedToRefreshToken = false
    private var hasThrownNonAuthorizedError = false
    
    private init() {}
    
    func getData(path: String, token: BearearToken?) async throws -> String {
        guard !isNeedToRefreshToken else { throw NetworkServiceError.errorMessage(.unauthorized) }
        if Int.random(in: 0...4) == 0 && !hasThrownNonAuthorizedError {
            isNeedToRefreshToken = true
            hasThrownNonAuthorizedError = true
            throw NetworkServiceError.errorMessage(.unauthorized)
        } else {
            try await Task.sleep(for: .seconds(2))
            return "Some Data for \(path) with token: \(token)"
        }
    }
    
    func refreshToken() async -> BearearToken{
        try? await Task.sleep(for: .seconds(2))
        isNeedToRefreshToken = false
        return "Some New Token"
    }
}
