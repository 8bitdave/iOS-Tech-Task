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
    let id = UUID()
    let investorID: Int
    let name: String
    let planValue: Double
    let moneyBoxValue: Double
}

struct AccountsModel {
    let totalPlanValue: Double
    let accounts: [Account]
}

final class AccountsViewModel {
    
    enum ViewState {
        case loading
        case loaded(AccountsModel)
        case error(String)
    }
    
    // MARK: - Properties
    private let dataProvider: DataProviderLogic
    private var accounts: [Account] = []
    var state: CurrentValueSubject<ViewState, Never> = .init(.loading)
    
    // MARK: - Coordinator Injection
    var navigateToAccountAction: ((Account) -> Void)?
    
    // MARK: - Init
    init(dataProvider: DataProviderLogic) {
        self.dataProvider = dataProvider
    }
    
    // MARK: -
    func fetch() {
        // Fetch the Accounts data from the network using the users bearer token
        // If success, update the state so that the VC can subscribe to state changes
        // and get the
        state.send(.loading)
        
        dataProvider.fetchProducts { result in
            switch result {
            case .success(let accountResponse):
                print("🥶", accountResponse.accounts!)
                
                
                guard let accountModel = self.createAccountInfo(accountResponse: accountResponse) else {
                    self.state.send(.error("Parsing error"))
                    return
                }

                // Success
                self.accounts = accountModel.accounts
                self.state.send(.loaded(accountModel))
                
            case .failure(let error):
                // Show error UI on VC
                self.state.send(.error(error.localizedDescription))
            }
        }
        
        print("Fetching data...")
    }
    
    func didSelectAccount(at index: Int) {
        // Guard that we have a valid account
        guard let account = accounts[safe: index] else { return }
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
        
        return AccountsModel(totalPlanValue: accountResponse.totalPlanValue ?? 0.00, accounts: accounts)
        
    }
    
}
