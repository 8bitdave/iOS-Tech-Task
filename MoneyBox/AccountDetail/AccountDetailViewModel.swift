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
    let accountNameString: String
    let planValueString: String
    let moneyBoxValueString: CurrentValueSubject<String, Never> = .init("")
    
    // MARK: Private
    private var dataProvider: DataProviderLogic
    private var investorID: Int
    
    // MARK: Coordinator Injection
    var accountDetailDidCloseAction: (() -> Void)?
    
    
    // MARK: - Init
    init(account: Account, dataProvider: DataProviderLogic) {
        self.accountNameString = account.name
        self.planValueString = "Plan value: " + String.createCurrencyString(from: account.planValue, currency: .GBP)
        self.dataProvider = dataProvider
        self.investorID = account.investorID
        self.moneyBoxValueString.value = createMoneyBoxString(from: account.moneyBoxValue)
    }
    
    
    // MARK: - Helper Functions
    func didTapAddMoneyButton() {
        
        // Update UI to show loading state
        viewState.value = .loading
        
        
        let request = OneOffPaymentRequest(amount: Constants.incrementAmount, investorProductID: self.investorID)
        
        self.dataProvider.addMoney(request: request) { result in
            switch result {
            case .success(let response):
                guard let newMoneyBoxValue = response.moneybox else { return }
                self.moneyBoxValueString.value = self.createMoneyBoxString(from: newMoneyBoxValue)
                self.viewState.send(.loaded)
            case .failure(let error):
                let errorString = self.createErrorString(from: error)
                self.viewState.send(.error(errorString))
            }
        }
        
        
    }
    
    func viewWillClose() {
        accountDetailDidCloseAction?()
    }
    
    private func createMoneyBoxString(from value: Double) -> String {
        return "Moneybox: " + String.createCurrencyString(from: value, currency: .GBP)
    }
    
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
