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

class NetworkService {
    private var tokenRefreshingTask: Task<Void, Error>? = nil
    
    init() { }
    
    func request(path: String) async throws -> String{
        print("\(path): REQUEST_STARTED")
        if let tokenRefreshingTask {
            print("\(path): AWAITING_FOR_REFRESHING...")
            try? await tokenRefreshingTask.value
        }
        
        do {
            let data = try await execute(path: path)
            return data
        } catch {
            print("\(path): ERROR_OCCURED - \(error)")
            guard let error = error as? NetworkError,
                    error == .nonAuthorized else { throw error }
            
            if tokenRefreshingTask == nil {
                print("\(path) token: REFRESHING_INIT")
                tokenRefreshingTask = createTokenRefreshingTask(for: path)
            }
            
            return try await request(path: path + "/second-entry")
        }
    }
    
    private func createTokenRefreshingTask(for path: String) -> Task<Void, Error> {
        Task {
            print("\(path) token: REFRESHING...")
            await refreshTokenRequest()
            tokenRefreshingTask = nil
            print("\(path) token: REFRESHING_ENDED")
            return
        }
    }
    
    private func execute(path: String) async throws -> String {
        print("\(path): EXECUTE_STARTED...")
        try await ServerForTest.shared.getData(for: path)
        print("\(path): EXECUTE_SUCCESFUL")
        return "ok"
    }
    
    private func refreshTokenRequest() async {
        try? await ServerForTest.shared.refreshToken()
    }
}


actor ServerForTest {
    
    static var shared = ServerForTest()
    var isNeedToRefreshToken = false
    private var hasThrownNonAuthorizedError = false
    
    private init() {}
    
    func getData(for path: String) async throws {
        guard !isNeedToRefreshToken else { throw NetworkError.nonAuthorized }
        if !hasThrownNonAuthorizedError && Int.random(in: 0...6) == 0 {
            isNeedToRefreshToken = true
            hasThrownNonAuthorizedError = true
            throw NetworkError.nonAuthorized
        } else {
            if Thread.current.qualityOfService == .default {
                print("\(path): GET_DATA_LONG")
                try await Task.sleep(for: .seconds(10))
            } else {
                print("\(path): GET_DATA_NORMAL")
                try await Task.sleep(for: .seconds(3))
            }
        }
    }
    
    func refreshToken() async throws {
        try await Task.sleep(for: .seconds(2))
        isNeedToRefreshToken = false
    }
}
