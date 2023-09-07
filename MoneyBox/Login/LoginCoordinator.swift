//
//  LoginCoordinator.swift
//  MoneyBox
//
//  Created by David Gray on 02/09/2023.
//

import Networking
import UIKit

final class LoginCoordinator: Coordinator {
    
    // MARK: - Properties
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    
    private var dataProvider: DataProviderLogic
    
    var userDidLogInClosure: ((Networking.LoginResponse.User) -> Void)?
 
    // MARK: - Init
    init(navigationController: UINavigationController, dataProvider: DataProviderLogic) {
        self.navigationController = navigationController
        self.dataProvider = dataProvider
    }
    
    func start() {
        let viewModel = LoginViewModel(dataProvider: dataProvider)
        
        viewModel.loginAction = { user in
            self.navigateToAccounts(user: user)
        }
        
        let viewController = LoginViewController(loginViewModel:
        viewModel)
        
        DispatchQueue.main.async {
            self.navigationController.pushViewController(viewController, animated: false)
        }
    }
    
    private func navigateToAccounts(user: Networking.LoginResponse.User) {
        userDidLogInClosure?(user)
    }
    
}
