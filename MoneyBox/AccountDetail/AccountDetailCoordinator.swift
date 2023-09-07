//
//  AccountDetailCoordinator.swift
//  MoneyBox
//
//  Created by David Gray on 05/09/2023.
//

import Networking
import UIKit

final class AccountDetailCoordinator: Coordinator {
    
    // MARK: - Properties
    
    // MARK: Public
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    weak var parentCoordinator: AccountsCoordinator?
    
    // MARK: Private
    private let dataProvider: DataProviderLogic
    private let account: Account
    
    
    // MARK: - Init
    init(navgationController: UINavigationController, dataProvider: DataProviderLogic, account: Account) {
        self.navigationController = navgationController
        self.dataProvider = dataProvider
        self.account = account
    }
    
    func start() {
        let viewModel = AccountDetailViewModel(account: account, dataProvider: dataProvider)
        viewModel.accountDetailDidCloseAction = {
            self.parentCoordinator?.childDidFinish(self)
        }
        
        let viewController = AccountDetailViewController(viewModel: viewModel)
        
        navigationController.pushViewController(viewController, animated: true)
    }
}
