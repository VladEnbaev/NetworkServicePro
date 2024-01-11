//
//  NetworkService.swift
//  NetworkServicePro
//
//  Created by Влад Енбаев on 24.12.2023.
//

import Foundation

enum NetworkError: Error {
    case nonAuthorized
}

typealias BearearToken = String

// actor - решение data race на tokenRefreshingTask
actor TokenService {
    private var tokenRefreshingTask: Task<BearearToken, Error>? = nil
    
    private var savedToken: BearearToken
    // TokenService не может знать актуальность токена.
    // Если ему сказали, что токен не актуален, сервис будет ждать его обновления.
    var token: BearearToken {
        get async {
            if tokenRefreshingTask != nil {
                savedToken = try! await tokenRefreshingTask!.value
            }
            return savedToken
        }
    }
    
    var isRefreshing: Bool {
        tokenRefreshingTask != nil
    }
    
    init(initialToken: BearearToken) {
        savedToken = initialToken
    }
    
    func createRefreshTokenTask() async {
        guard !isRefreshing else { return }
        tokenRefreshingTask = Task {
            print("tokenService: REFRESHING...")
            let newToken = await refreshTokenRequest()
            tokenRefreshingTask = nil
            print("tokenService: REFRESHING_ENDED")
            return newToken
        }
    }
    
    private func refreshTokenRequest() async -> String {
        await ServerForTest.shared.refreshToken()
    }
}

class NetworkService {
    var tokenService = TokenService(initialToken: "InitialToken")
    
    init() { }
    
    func request(path: String) async throws -> String{
        print("\(path): REQUEST_STARTED")
        do {
            let data = try await execute(path: path)
            return data
        } catch {
            print("\(path): ERROR_OCCURED - \(error)")
            guard let error = error as? NetworkError,
                    error == .nonAuthorized else { throw error }
            
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
        let bearerToken = await tokenService.token
        
        print("\(path): EXECUTE_STARTED...")
        let data = try await ServerForTest.shared.getData(path: path, token: bearerToken)
        print("\(path): EXECUTE_SUCCESFUL")
        return data
    }
}


actor ServerForTest {
    
    static var shared = ServerForTest()
    var isNeedToRefreshToken = false
    private var hasThrownNonAuthorizedError = false
    
    private init() {}
    
    func getData(path: String, token: BearearToken) async throws -> String {
        guard !isNeedToRefreshToken else { throw NetworkError.nonAuthorized }
        if Int.random(in: 0...4) == 0 && !hasThrownNonAuthorizedError {
            isNeedToRefreshToken = true
            hasThrownNonAuthorizedError = true
            throw NetworkError.nonAuthorized
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
