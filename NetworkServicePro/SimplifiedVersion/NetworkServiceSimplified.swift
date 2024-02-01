import Foundation

class NetworkServiceSimplified {
    var tokenService: TokenService
    
    init() {
        tokenService = TokenService(baseURL: URL(string: "https://www.apple.com")!, initialToken: "InitialToken")
    }
    
    func request(path: String) async throws -> String{
        print("\(path): REQUEST_STARTED")
        do {
            let data = try await execute(path: path)
            return data
        } catch {
            print("\(path): ERROR_OCCURED - \(error)")
            guard let error = error as? NetworkServiceError,
                  error == .errorMessage(.unauthorized) else { throw error }
            
            await tokenService.createRefreshTokenTask()
            
            // еще раз вызываем этот же запрос, но в этот раз он будет ждать нового токена в execute
            return try await request(path: path + "/second-entry")
        }
    }
    
    private func execute(path: String) async throws -> String {
        // если ранее была получена ошибка "nonAuth", то ждем обновления токена
        if await tokenService.isRefreshing {
            print("\(path): AWAITING_FOR_REFRESHING")
        }
        
        let bearerToken = try await tokenService.token
        
        print("\(path): EXECUTE_STARTED...")
        let data = try await MocServer.shared.getData(path: path, token: bearerToken)
        print("\(path): EXECUTE_SUCCESFUL")
        return data
    }
}
