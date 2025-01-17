//
//  LoginViewModel.swift
//  MoneyBox
//
//  Created by David Gray on 01/09/2023.
//

import Combine
import Foundation
import Networking

final class LoginViewModel {
    
    enum ViewState {
        case initialised
        case loggingIn
        case loggedIn
        case error(String)
    }
    
    // MARK: - Properties
    
    // Public
    let loginButtonTitle = "Login"
    var emailFieldText: CurrentValueSubject<String, Never> = .init("")
    var passwordFieldText: CurrentValueSubject<String, Never> = .init("")
    var loginButtonEnabled: CurrentValueSubject<Bool, Never> = .init(false)
    var viewState: CurrentValueSubject<ViewState, Never> = .init(.initialised)
    
    // Private
    private var cancellables: Set<AnyCancellable> = []
    private let dataProvider: DataProviderLogic
    private let networkSession: SessionManager = SessionManager()

    // Coordinator Injection
    var loginAction: ((Networking.LoginResponse.User) -> Void)?
    
    // MARK: - Init
    init(dataProvider: DataProviderLogic) {
        self.dataProvider = dataProvider
        subscribe()
    }
    
    // MARK: Subscription Logic
    private func subscribe() {
        emailFieldText.combineLatest(passwordFieldText).sink { [weak self] (email, password) in
            
            guard !email.isEmpty && !password.isEmpty else {
                self?.loginButtonEnabled.send(false)
                return
            }
            
            self?.loginButtonEnabled.send(true)
        }
        .store(in: &cancellables)
    }
    
    // MARK: - Exposed Functions
    func loginTapped() {
        
        guard loginButtonEnabled.value else {
            return
        }
        
        // Set state to loading to lock UI.
        viewState.value = .loggingIn
        
        let loginRequest = LoginRequest(email: emailFieldText.value, password: passwordFieldText.value)
        
        dataProvider.login(request: loginRequest) { [weak self] result in
            switch result {
            case .success(let response):
                self?.viewState.send(.loggedIn)
                SessionManager().setUserToken(response.session.bearerToken) // Make injectable
                
                // Allow the success screen to show
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self?.loginAction?(response.user)
                }
            case .failure(let error):
                self?.viewState.send(.error(error.localizedDescription))
            }
        }
    }
}
