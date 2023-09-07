//
//  MockDataProvider.swift
//  MoneyBoxTests
//
//  Created by David Gray on 03/09/2023.
//

import Networking

final class MockDataProvider: DataProviderLogic {
    
    // MARK: - Mock Properties
    var loginCalledClosure: (() -> Void)?
    var mockLoginResponse: LoginResponse?
    var shouldFailLogin: Bool = false
    
    // Products
    var fetchAccountsCalledClosure: (() -> Void)?
    var mockFetchAccountsResponse: Networking.AccountResponse?
    var shouldFailFetchAccounts: Bool = false
    
    // MARK: - DataProviderLogic Functions
    func login(request: Networking.LoginRequest, completion: @escaping ((Result<Networking.LoginResponse, Error>) -> Void)) {
        
        loginCalledClosure?()
        
        guard let response = mockLoginResponse else {
            completion(.failure(DataProviderError.noMockedResponse))
            return
        }
        if shouldFailLogin {
            completion(.failure(DataProviderError.authFailed))
            return
        }
        
        completion(.success(response))
    }
    
    func fetchProducts(completion: @escaping ((Result<Networking.AccountResponse, Error>) -> Void)) {
        
        fetchAccountsCalledClosure?()
        
        guard let response = mockFetchAccountsResponse else {
            completion(.failure(DataProviderError.noMockedResponse))
            return
        }
        
        if shouldFailFetchAccounts {
            completion(.failure(DataProviderError.fetchAccountsFailed))
            return
        }
        
        completion(.success(response))
    }
    
    func addMoney(request: Networking.OneOffPaymentRequest, completion: @escaping ((Result<Networking.OneOffPaymentResponse, Error>) -> Void)) {
        fatalError("NOT IMPLETMENTED")
    }
    
    enum DataProviderError: Error {
        case fetchAccountsFailed
        case noMockedResponse
        case authFailed
    }
    
}
