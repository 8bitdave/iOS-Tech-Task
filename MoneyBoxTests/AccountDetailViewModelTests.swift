//
//  AccountDetailViewModelTests.swift
//  MoneyBoxTests
//
//  Created by David Gray on 06/09/2023.
//

import Combine
import Networking
import XCTest
@testable import MoneyBox

final class AccountsViewModelTests: XCTestCase {
    
    // MARK: - Properties
    private var cancellables: Set<AnyCancellable> = []
    
    // MARK: - Happy Path
    func test_viewModel_fetchSuccess() {
        
        // Expectation
        let networkCalledExpectation = expectation(description: "Expected network to be called")
        let viewStateLoadedExpectation = expectation(description: "Expected viewState to be of case .loaded")
        
        // Mock
        let mockProvider = MockDataProvider()
        let mockResponse: Networking.AccountResponse = Bundle.main.decode(Networking.AccountResponse.self, from: "Accounts.json")
        
        mockProvider.mockFetchAccountsResponse = mockResponse
        mockProvider.fetchAccountsCalledClosure = {
            networkCalledExpectation.fulfill()
        }
        
        // Given
        let sut = AccountsViewModel(dataProvider: mockProvider)
        
        // Subscribe to the viewState changes so we can monitor them while
        // the networking is happening.
        // Ignore the first two states, as these are initialised and loading.
        sut.viewState.dropFirst(2).sink(receiveValue: { state in
            switch state {
            case .loaded(let accountResponse):
                XCTAssertEqual(accountResponse.accounts.count, 2)
                viewStateLoadedExpectation.fulfill()
            default:
                XCTFail("Expected viewState to be loaded")
            }
        }).store(in: &cancellables)
        
        // When
        sut.fetch()
        
        // Then
        waitForExpectations(timeout: 0.5)
    }
    
    func test_viewModel_navigatesToAccount() {
        
        let navigateToAccountActionExpectation = expectation(description: "Expect the navigate to account closure to be called")
        
        let mockProvider = MockDataProvider()
        let mockResponse: Networking.AccountResponse = Bundle.main.decode(Networking.AccountResponse.self, from: "Accounts.json")
        mockProvider.mockFetchAccountsResponse = mockResponse
        
        
        let sut = AccountsViewModel(dataProvider: mockProvider)
        sut.navigateToAccountAction = { account in
            navigateToAccountActionExpectation.fulfill()
        }
      
        
        sut.viewState.dropFirst(2).sink(receiveValue: { state in
            switch state {
            case .loaded:
                // When the user selects an account
                sut.didSelectAccount(at: 0)
            default:
                XCTFail("Expected viewState to be loaded")
            }
        }).store(in: &cancellables)
        
        sut.fetch()
        
        // Then I expect the navigateToAccountAction closure to be called.
        waitForExpectations(timeout: 1)
        
    }
    
    // MARK: - Sad Path
    
    func test_viewModel_doesNotNavigateToAccount_indexOutOfBounds() {
        
        let navigateToAccountActionExpectation = expectation(description: "Expect the navigate to account closure to be called")
        navigateToAccountActionExpectation.isInverted = true
        
        let mockProvider = MockDataProvider()
        let mockResponse: Networking.AccountResponse = Bundle.main.decode(Networking.AccountResponse.self, from: "Accounts.json")
        mockProvider.mockFetchAccountsResponse = mockResponse
        
        
        let sut = AccountsViewModel(dataProvider: mockProvider)
        sut.navigateToAccountAction = { account in
            navigateToAccountActionExpectation.fulfill()
        }
      
        
        sut.viewState.dropFirst(2).sink(receiveValue: { state in
            switch state {
            case .loaded:
                // When the user selects an account out of index bounds
                sut.didSelectAccount(at: 9)
            default:
                XCTFail("Expected viewState to be loaded")
            }
        }).store(in: &cancellables)
        
        sut.fetch()
        
        // Then I expect the navigateToAccountAction closure to be called.
        waitForExpectations(timeout: 1)
        
    }
    
    func test_viewModel_fetchError_invalidJson() {
        
        // Expect the viewState to be of case error because there is no investorID in
        // the response.
        let errorViewStateExpectation = expectation(description: "Expected network to be called")
        
        // Mock
        let mockProvider = MockDataProvider()
        mockProvider.shouldFailFetchAccounts = true
        
        // Given
        let sut = AccountsViewModel(dataProvider: mockProvider)
        
        // Subscribe to the viewState changes so we can monitor them while
        // the networking is happening.
        // Ignore the first two states, as these are initialised and loading.
        sut.viewState.dropFirst(2).sink(receiveValue: { state in
            switch state {
            case .error:
                errorViewStateExpectation.fulfill()
            default:
                XCTFail("Expected viewState to be loaded")
            }
        }).store(in: &cancellables)
        
        // When
        sut.fetch()
        
        // Then
        waitForExpectations(timeout: 1.0)
    }
    
    func test_viewModel_fetchError_noInvestorID() {
        
        // Expect the viewState to be of case error because there is no investorID in
        // the response.
        let errorViewStateExpectation = expectation(description: "Expected network to be called")
        
        // Mock
        let mockProvider = MockDataProvider()
        let mockResponse: Networking.AccountResponse = Bundle.main.decode(Networking.AccountResponse.self, from: "Accounts_Error_InvestorID.json")
        mockProvider.mockFetchAccountsResponse = mockResponse
        
        // Given
        let sut = AccountsViewModel(dataProvider: mockProvider)
        
        // Subscribe to the viewState changes so we can monitor them while
        // the networking is happening.
        // Ignore the first two states, as these are initialised and loading.
        sut.viewState.dropFirst(2).sink(receiveValue: { state in
            switch state {
            case .error(let error):
                XCTAssertEqual(error, "Parsing error")
                errorViewStateExpectation.fulfill()
            default:
                XCTFail("Expected viewState to be loaded")
            }
        }).store(in: &cancellables)
        
        // When
        sut.fetch()
        
        // Then
        waitForExpectations(timeout: 1.0)
    }
    
}
