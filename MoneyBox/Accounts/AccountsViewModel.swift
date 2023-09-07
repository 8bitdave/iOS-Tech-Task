//
//  AccountsViewModel.swift
//  MoneyBox
//
//  Created by David Gray on 03/09/2023.
//

import Combine
import Networking
import Foundation

struct Account: Hashable {
    
    // MARK: - Properties
    let id = UUID()
    let investorID: Int
    let name: String
    let planValue: Double
    let moneyBoxValue: Double
    
    // MARK: - Init
    internal init(investorID: Int, name: String, planValue: Double, moneyBoxValue: Double) {
        self.investorID = investorID
        self.name = name
        self.planValue = planValue
        self.moneyBoxValue = moneyBoxValue
    }
    
}

struct AccountsModel {
    let totalPlanValue: Double
    let accounts: [Account]
}

final class AccountsViewModel {
    
    enum ViewState {
        case initialised
        case loading
        case loaded(AccountsModel)
        case error(String)
    }
    
    // MARK: - Properties
    
    // Public
    var viewState: CurrentValueSubject<ViewState, Never> = .init(.initialised)
    var shouldReload: Bool = false
    let refreshButtonTitle = "Refresh..."
    var totalPlanValue: String = ""
    var welcomeString: String
    
    // Private
    private let dataProvider: DataProviderLogic
    private var accounts: [Account] = []
    
    // MARK: - Coordinator Injection
    var navigateToAccountAction: ((Account) -> Void)?
    
    // MARK: - Init
    init(dataProvider: DataProviderLogic, user: Networking.LoginResponse.User) {
        self.dataProvider = dataProvider
        self.welcomeString = "Welcome " + (user.firstName ?? "")
    }
    
    // MARK: -
    func fetch() {
        // Fetch the Accounts data from the network using the users bearer token
        // If success, update the state so that the VC can subscribe to state changes
        // and get the
        viewState.send(.loading)
        
        dataProvider.fetchProducts { result in
            
            self.shouldReload = false
            
            switch result {
            case .success(let accountResponse):
                
                guard let accountModel = self.createAccountInfo(accountResponse: accountResponse) else {
                    self.viewState.send(.error("Parsing error"))
                    return
                }

                // Success
                self.totalPlanValue = String.createCurrencyString(from: accountResponse.totalPlanValue?.rounded(toPlaces: 2) ?? 0.00, currency: .GBP)
                self.accounts = accountModel.accounts
                self.viewState.send(.loaded(accountModel))
                
            case .failure(let error):
                // Show error UI on VC
                self.viewState.send(.error(error.localizedDescription))
            }
        }
    }
    
    func didSelectAccount(at index: Int) {
        // Guard that we have a valid account
        guard let account = accounts[safe: index] else { return }
        
        // Let the VC know it should request data when navigating back from the account detail view
        shouldReload = true
        
        // Tell coordinator to navigate us to the specified account.
        navigateToAccountAction?(account)
    }
    
    // MARK: - Helper function
    private func createAccountInfo(accountResponse: AccountResponse) -> AccountsModel? {
        
        guard let productResponses = accountResponse.productResponses else {
            return nil
        }
        
        let accounts: [Account] = productResponses.compactMap({ product in
            
            guard let investorID = product.id else {
                return nil
            }
            
            let account = Account(
                investorID: investorID,
                name: product.product?.friendlyName ?? "",
                planValue: product.planValue ?? 0.00,
                moneyBoxValue: product.moneybox ?? 0.00
            )
            
            return account
        })
        
        guard !accounts.isEmpty else { return nil }
        
        return AccountsModel(totalPlanValue: accountResponse.totalPlanValue ?? 0.00, accounts: accounts)
        
    }
    
}
