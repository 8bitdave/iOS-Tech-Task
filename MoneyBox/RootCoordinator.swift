//
//  RootCoordinator.swift
//  MoneyBox
//
//  Created by David Gray on 02/09/2023.
//

import Networking
import UIKit

final class RootCoordinator: Coordinator {
    
    // MARK: - Properties
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    var dataProvider: DataProviderLogic
    var user: Networking.LoginResponse.User?
    
    private var isLoggedIn = false // This would perform some auth checks in a full app
    
    // MARK: - Init
    init(navigationController: UINavigationController, dataProvider: DataProviderLogic) {
        self.navigationController = navigationController
        self.dataProvider = dataProvider
        
        navigationController.navigationBar.backgroundColor = UIColor.backgroundColor
        navigationController.navigationBar.tintColor = UIColor.lightDarkTealInverse
        navigationController.isNavigationBarHidden = false
    }
    
    func start() {
        if isLoggedIn {
            // Go to Accounts page OR Show quick pin page
        } else {
            // Go to Login page
            let loginCoordinator = LoginCoordinator(navigationController: navigationController, dataProvider: dataProvider)
            
            loginCoordinator.userDidLogInClosure = { [weak self] user in
                self?.user = user
                self?.navigateToMyAccount()
            }
            
            loginCoordinator.parentCoordinator = self
            
            loginCoordinator.start()
            childCoordinators.append(loginCoordinator)
        }
    }
    
    private func navigateToMyAccount() {
        guard let user = user else { return }
        
        let myAccountCoordinator = AccountsCoordinator(navigationController: navigationController, dataProvider: dataProvider, user: user)

        myAccountCoordinator.start()
        childCoordinators.append(myAccountCoordinator)
    }
    
}
