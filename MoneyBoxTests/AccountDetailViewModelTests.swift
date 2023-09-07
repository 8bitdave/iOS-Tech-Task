//
//  AccountsViewModelTests.swift
//  MoneyBoxTests
//
//  Created by David Gray on 06/09/2023.
//

import Combine
import Networking
import XCTest
@testable import MoneyBox

final class AccountDetailViewModelTests: XCTestCase {
    
    // MARK: - Properties
    private var cancellables: Set<AnyCancellable> = []
    
    private let account = Account(
        investorID: 123,
        name: "LISA Account",
        planValue: 4900.00,
        moneyBoxValue: 250.00
    )
    
    func test_accountViewModel_staticData() {
        
        let mockDataProvider = MockDataProvider()
        
        // Given
        let sut = AccountDetailViewModel(account: account, dataProvider: mockDataProvider)
        
        // Then
        XCTAssertEqual(sut.buttonTitle, "Add £10")
        XCTAssertEqual(sut.accountNameString, "LISA Account")
        XCTAssertEqual(sut.planValueString, "Plan value: £4900.00")
        XCTAssertEqual(sut.moneyBoxValueString.value, "Moneybox: £250.00")
    }
    
    func test_accountViewModel_didAddMoney() {
        
        // Expectation
        let networkCalledExpectation = expectation(description: "Expected the network to be called when add money button was tapped")
        
        // Mock
        let mockDataProvider = MockDataProvider()
        mockDataProvider.mockAddMoneyResponse = Bundle.test.decode(Networking.OneOffPaymentResponse.self, from: "AddMoneyResponse.json")
        
        mockDataProvider.addMoneyCalledClosure = {
            networkCalledExpectation.fulfill()
        }
        
        // Given
        let sut = AccountDetailViewModel(account: account, dataProvider: mockDataProvider)
        
        // Subscribe to the viewState changes so we can monitor them.
        // Ignore the first two states, as these are initialised and loading.
        sut.viewState.dropFirst(2).sink(receiveValue: { state in
            switch state {
            case .loaded:
                // Then I expect the money box property to be updated
                XCTAssertEqual(sut.moneyBoxValueString.value, "Moneybox: £400.00")
            default:
                XCTFail("Expected the third update to state to be loaded")
            }
        }).store(in: &cancellables)
        
        // When
        sut.didTapAddMoneyButton()

        waitForExpectations(timeout: 1.0)
    }
    
    func test_accountViewModel_didFailToAddMoney() {
        
        // Expectation
        let networkCalledExpectation = expectation(description: "Expected the network to be called when add money button was tapped")
        let errorViewStateSetExpectation = expectation(description: "Expected the viewState to be of case error")
        
        // Mock
        let mockDataProvider = MockDataProvider()
        mockDataProvider.mockAddMoneyResponse = Bundle.test.decode(Networking.OneOffPaymentResponse.self, from: "AddMoneyResponse.json")
        mockDataProvider.shouldFailAddMoney = true
        
        mockDataProvider.addMoneyCalledClosure = {
            networkCalledExpectation.fulfill()
        }
        
        // Given
        let sut = AccountDetailViewModel(account: account, dataProvider: mockDataProvider)
        
        // Subscribe to the viewState changes so we can monitor them.
        // Ignore the first two states, as these are initialised and loading.
        sut.viewState.dropFirst(2).sink(receiveValue: { state in
            switch state {
            case .error(let error):
                // Then I expect a service error
                XCTAssertEqual(error, "The operation couldn’t be completed. (MoneyBoxTests.MockDataProvider.DataProviderError error 3.) Please try again.")
                errorViewStateSetExpectation.fulfill()
            default:
                XCTFail("Expected the third update to state to be error")
            }
        }).store(in: &cancellables)
        
        // When
        sut.didTapAddMoneyButton()

        waitForExpectations(timeout: 1.0)
    }
    
}
