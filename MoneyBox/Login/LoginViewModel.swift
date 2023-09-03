//
//  LoginViewModel.swift
//  MoneyBox
//
//  Created by David Gray on 01/09/2023.
//

import Combine
import Foundation
import Networking

enum LoginViewState {
    case ready
    case loading
    case success
    case error(String)
}

final class LoginViewModel {
    
    // MARK: - Properties
    private var cancellables: Set<AnyCancellable> = []
    private let dataProvider: DataProviderLogic
    private let networkSession: SessionManager = SessionManager()
    
//    private let networkManager: NetworkManagable

    // MARK: - Coordinator Closures
    var loginAction: ((Networking.LoginResponse.User) -> Void)?
    
    // MARK: - Exposed API
    public var emailFieldText: CurrentValueSubject<String, Never> = .init("")
    public var passwordFieldText: CurrentValueSubject<String, Never> = .init("")
    public var loginButtonEnabled: CurrentValueSubject<Bool, Never> = .init(false)
    public var state: CurrentValueSubject<LoginViewState, Never> = .init(.ready)
    
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
        state.value = .loading
        
        // Create request
        let loginRequest = LoginRequest(email: emailFieldText.value, password: passwordFieldText.value)
        
        dataProvider.login(request: loginRequest) { [weak self] result in
            switch result {
            case .success(let response):
                self?.state.send(.success)
                self?.loginAction?(response.user)
            case .failure(let error):
                self?.state.send(.error(error.localizedDescription))
            }
        }
        
        // 1. Create network request
        // 2. Call network service with request
        // 3. Wait for response (update UI)
        // 4. Either log user in and communicate to coordinator OR present error message
    }
}
