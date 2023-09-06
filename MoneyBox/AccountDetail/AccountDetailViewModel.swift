//
//  File.swift
//  MoneyBox
//
//  Created by David Gray on 05/09/2023.
//

import Combine
import Foundation
import Networking


final class AccountDetailViewModel {
    
    enum ViewState {
        case initialised
        case loading
        case loaded
        case error(String)
    }
    
    // MARK: - Properties
    
    // MARK: Public
    var viewState: CurrentValueSubject<ViewState, Never> = .init(.initialised)
    var buttonTitle = "Add £\(Constants.incrementAmount)"
    let accountType = "Individual Savings"
    let accountName: String
    let planValue: String
    var moneyBoxValue: CurrentValueSubject<String, Never>
    
    // MARK: Private
    private var dataProvider: DataProviderLogic
    private var investorID: Int
    
    var shouldFail = true
    
    
    // MARK: - Init
    init(account: Account, dataProvider: DataProviderLogic) {
        self.accountName = account.name
        self.planValue = String.createCurrencyString(from: account.planValue, currency: .GBP)
        self.moneyBoxValue = .init(String.createCurrencyString(from: account.moneyBoxValue, currency: .GBP))
        self.dataProvider = dataProvider
        self.investorID = account.investorID
    }
    
    
    // MARK: - Helper Functions
    func didTapAddMoneyButton() {
        
        // Update UI to show loading state
        viewState.value = .loading
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            let request = OneOffPaymentRequest(amount: Constants.incrementAmount, investorProductID: self.shouldFail ? 12434 : self.investorID)
            self.dataProvider.addMoney(request: request) { result in
                switch result {
                case .success(let response):
                    guard let newMoneyBoxValue = response.moneybox else { return }
                    self.viewState.send(.loaded)
                    self.moneyBoxValue.value = String.createCurrencyString(from: newMoneyBoxValue, currency: .GBP)
                case .failure(let error):
                    let errorString = self.createErrorString(from: error)
                    self.shouldFail = false
                    self.viewState.send(.error(errorString))
                }
            }
        }
       
    }
    
    // MARK: - Error
    private func createErrorString(from error: Error) -> String {
        return "\(error.localizedDescription) Please try again."
        
    }
}

// MARK: - Constants
extension AccountDetailViewModel {
    enum Constants {
        static let incrementAmount = 10
    }
}
