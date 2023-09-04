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
    
    enum AccountState {
        case loading
        case loaded(AccountsModel)
        case error(String)
    }
    
    // MARK: - Properties
    private let dataProvider: DataProviderLogic
    
    var accounts: CurrentValueSubject<[Account], Never> = .init([])
    
    var state: CurrentValueSubject<AccountState, Never> = .init(.loading)
    
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
                self.state.send(.loaded(accountModel))
                
            case .failure(let error):
                // Show error UI on VC
                self.state.send(.error(error.localizedDescription))
            }
        }
        
        print("Fetching data...")
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
