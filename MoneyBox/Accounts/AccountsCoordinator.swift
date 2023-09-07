//
//  AccountsCoordinator.swift
//  MoneyBox
//
//  Created by David Gray on 03/09/2023.
//

import Networking
import UIKit

final class AccountsCoordinator: Coordinator {
    
    // MARK: - Properties
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    
    private let dataProvider: DataProviderLogic
    private let user: Networking.LoginResponse.User
    
    // MARK: - Init
    init(navigationController: UINavigationController, dataProvider: DataProviderLogic, user: Networking.LoginResponse.User) {
        self.navigationController = navigationController
        self.dataProvider = dataProvider
        self.user = user
    }
    
    func start() {
        let accountsViewModel = AccountsViewModel(dataProvider: dataProvider, user: user)
        let viewController = AccountsViewController(accountsViewModel: accountsViewModel)
        
        // Inject closure to handle callback for navigating to a specific account.
        accountsViewModel.navigateToAccountAction = { account in
            self.navigateToAccount(account: account)
        }
        
        DispatchQueue.main.async {
            self.navigationController.setViewControllers([viewController], animated: false)
        }
    }
    
    private func navigateToAccount(account: Account) {
        let coordinator = AccountDetailCoordinator(navgationController: navigationController, dataProvider: dataProvider, account: account)
        coordinator.parentCoordinator = self
        coordinator.start()
        childCoordinators.append(coordinator)
    }
}
