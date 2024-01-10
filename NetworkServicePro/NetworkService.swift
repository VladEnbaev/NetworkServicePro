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

actor TokenService {
    var tokenRefreshingTask: Task<BearearToken, Error>? = nil
    
    init() { }
    
    func createRefreshTokenTask() async {
        guard tokenRefreshingTask == nil else { return }
        tokenRefreshingTask = Task {
            print("tokenManager: REFRESHING...")
            let newToken = await refreshTokenRequest()
            tokenRefreshingTask = nil
            print("tokenManager: REFRESHING_ENDED")
            return newToken
        }
    }
    
    private func refreshTokenRequest() async -> String {
        await ServerForTest.shared.refreshToken()
    }
}

class NetworkService {
    var tokenService = TokenService()
    var token: BearearToken?
    
    init() { }
    
    func request(path: String) async throws -> String{
        print("\(path): REQUEST_STARTED")
        if let tokenRefreshingTask = await tokenService.tokenRefreshingTask {
            print("\(path): AWAITING_FOR_REFRESHING...")
            token = try! await tokenRefreshingTask.value
        }
        
        do {
            let data = try await execute(path: path)
            return data
        } catch {
            print("\(path): ERROR_OCCURED - \(error)")
            guard let error = error as? NetworkError,
                    error == .nonAuthorized else { throw error }
            
            if await tokenService.tokenRefreshingTask == nil {
                print("\(path) token: REFRESHING_INIT")
                await tokenService.createRefreshTokenTask()
            }
            
            return try await request(path: path + "/second-entry")
        }
    }
    
    private func execute(path: String) async throws -> String {
        print("\(path): EXECUTE_STARTED...")
        try await ServerForTest.shared.getData()
        print("\(path): EXECUTE_SUCCESFUL")
        return "ok"
    }
}


actor ServerForTest {
    
    static var shared = ServerForTest()
    var isNeedToRefreshToken = false
    private var hasThrownNonAuthorizedError = false
    
    private init() {}
    
    func getData() async throws {
        guard !isNeedToRefreshToken else { throw NetworkError.nonAuthorized }
        if Int.random(in: 0...3) == 0 && !hasThrownNonAuthorizedError {
            isNeedToRefreshToken = true
            hasThrownNonAuthorizedError = true
            throw NetworkError.nonAuthorized
        } else {
            try await Task.sleep(for: .seconds(2))
        }
    }
    
    func refreshToken() async -> BearearToken{
        try? await Task.sleep(for: .seconds(2))
        isNeedToRefreshToken = false
        return "Some New Token"
    }
}
