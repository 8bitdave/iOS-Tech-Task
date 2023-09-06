//
//  LoginViewController.swift
//  MoneyBox
//
//  Created by Zeynep Kara on 16.01.2022.
//

import Combine
import UIKit

final class LoginViewController: UIViewController {
    
    // MARK: - Properties
    var viewModel: LoginViewModel
    
    private var cancellables: Set<AnyCancellable> = []
    
    // MARK: UI Properties
    lazy var emailTextField: UITextField = {
        let textField = PaddedTextField()
        textField.borderStyle = .roundedRect
        textField.backgroundColor = .white
        textField.attributedPlaceholder = NSAttributedString(string: "Email Address", attributes: [NSAttributedString.Key.foregroundColor: UIColor.placeholderTextColor])
        textField.textContentType = .emailAddress
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.textColor = .black
        textField.delegate = self
        textField.font = UIFont.preferredFont(forTextStyle: .title3)
        textField.adjustsFontForContentSizeCategory = true
        return textField
    }()
    
    lazy var passwordTextField: UITextField = {
        let textField = PaddedTextField()
        textField.borderStyle = .roundedRect
        textField.backgroundColor = .white
        textField.attributedPlaceholder = NSAttributedString(string: "Password", attributes: [NSAttributedString.Key.foregroundColor: UIColor.placeholderTextColor])
        textField.textContentType = .password
        textField.isSecureTextEntry = true
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.textColor = .black
        textField.delegate = self
        textField.font = UIFont.preferredFont(forTextStyle: .title3)
        textField.adjustsFontForContentSizeCategory = true
        return textField
    }()
    
    private lazy var loginButton: UIButton = {
        let button = UIButton()
        button.setTitle(viewModel.loginButtonTitle, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor.lightTeal
        button.setTitleColor(.darkTeal, for: .normal)
        button.layer.cornerCurve = .continuous
        button.layer.cornerRadius = 9
        button.setTitleColor(.gray, for: .selected)
        button.titleLabel?.adjustsFontForContentSizeCategory = true
        button.titleLabel?.font = UIFont.preferredFont(forTextStyle: .title1)
        button.contentEdgeInsets = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        return button
    }()
    
    private var stackView: UIStackView = {
        var stack = UIStackView()
        stack.axis = .vertical
        stack.distribution = .fill
        stack.spacing = 8
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let loginTitle: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "SF Pro Text Bold", size: 34)
        label.text = "Login"
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isHidden = false
        return label
    }()
    
    private let moneyBoxLogo: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "moneybox"))
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let backgroundCurveView: UIView = {
        let view = BackgroundCurveView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.shouldAnimate = true
        return view
    }()
    
    private let activityIndicator: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView(style: .large)
        spinner.color = .lightDarkTeal
        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.hidesWhenStopped = true
        spinner.stopAnimating()
        return spinner
    }()
    
    private let alertView: AlertView = {
        let alert = AlertView()
        alert.translatesAutoresizingMaskIntoConstraints = false
        alert.isHidden = true
        return alert
    }()
    
    // MARK: - Init
    init(loginViewModel: LoginViewModel) {
        self.viewModel = loginViewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        
        // Add Subviews
        view.addSubview(backgroundCurveView)
        view.addSubview(loginTitle)
        view.addSubview(stackView)
        view.addSubview(moneyBoxLogo)
        
        stackView.addArrangedSubview(emailTextField)
        stackView.addArrangedSubview(passwordTextField)
        view.addSubview(alertView)
        view.addSubview(loginButton)

        loginButton.addSubview(activityIndicator)
        
        view.backgroundColor = UIColor(named: "background_color")
        
        subscribe()
        
        layoutViews()
    }
    
    // MARK: - Subscription Logic
    private func subscribe() {
        
        // Subscribe to overall view state
        viewModel.viewState
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { state in
                switch state {
                case .initialised:
                    self.enableButton()
                case .loggingIn:
                    self.hideAlert()
                    self.disableButton()
                case .loggedIn:
                    self.activityIndicator.stopAnimating()
                    self.alertView.setAlert(alertType: .success, message: Constants.alertViewSuccessMessage)
                    self.showAlert()
                case .error(let error):
                    self.enableButton()
                    self.alertView.setAlert(alertType: .error, message: error)
                    self.showAlert()
                }
                
            }).store(in: &cancellables)
        
        // Login button
        viewModel.loginButtonEnabled
            .receive(on: DispatchQueue.main)
            .sink { enabled in
                self.loginButton.isEnabled = enabled
                self.loginButton.backgroundColor = enabled ? .lightTeal : .systemGray
            }
            .store(in: &cancellables)
     
        loginButton.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
        
    }
    
    // MARK: - Layout Logic
    private func layoutViews() {
        NSLayoutConstraint.activate([
            
            // Background View
            backgroundCurveView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundCurveView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundCurveView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundCurveView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // Moneybox Logo
            moneyBoxLogo.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 30),
            moneyBoxLogo.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            moneyBoxLogo.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            // Title Label
//            loginTitle.topAnchor.constraint(equalTo: moneyBoxLogo.bottomAnchor, constant: 40),
            loginTitle.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            loginTitle.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            loginTitle.bottomAnchor.constraint(equalTo: stackView.topAnchor, constant: -20),
            
            // Stack View Constraints
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            stackView.bottomAnchor.constraint(equalTo: loginButton.topAnchor, constant: -20),
            
            // Alert View Constraints
            alertView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            alertView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            alertView.bottomAnchor.constraint(equalTo: loginTitle.topAnchor, constant: -20),
            
            // Login Button Constraints
//            loginButton.topAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 20),
            loginButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            loginButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            loginButton.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor, constant: -20),
            
            activityIndicator.centerYAnchor.constraint(equalTo: loginButton.centerYAnchor),
            activityIndicator.centerXAnchor.constraint(equalTo: loginButton.centerXAnchor),
            
        ])
    }
    
    // MARK: - Target Action
    @objc private func loginButtonTapped() {
        viewModel.loginTapped()
    }
    
    // MARK: - Helper Functions
    private func disableButton() {
        loginButton.setTitle("", for: .normal)
        loginButton.backgroundColor = UIColor.buttonDisabledColor
        activityIndicator.startAnimating()
    }
    
    private func enableButton() {
        activityIndicator.stopAnimating()
        loginButton.setTitle(self.viewModel.loginButtonTitle, for: .normal)
        loginButton.backgroundColor = UIColor.lightTeal
    }
    
    private func hideAlert() {
        DispatchQueue.main.async {
            self.alertView.isHidden = true
        }
    }
    
    private func showAlert() {
        DispatchQueue.main.async {
            self.alertView.isHidden = false
        }
    }
    
}

// MARK: - UITextFieldDelegate
extension LoginViewController: UITextFieldDelegate {
    
    // Having to use delegate instead of publisher updates
    // as publisher will not return per character change.
    func textFieldDidChangeSelection(_ textField: UITextField) {
        
        if textField === emailTextField {
            viewModel.emailFieldText.send(textField.text ?? "")
        } else if textField === passwordTextField {
            viewModel.passwordFieldText.send(textField.text ?? "")
        } else {
            print("⚠️ Unknown text field change...")
        }
        
    }
}

// MARK: - Constants
private extension LoginViewController {
    enum Constants {
        static let alertViewSuccessMessage = "Logged in!"
    }
}
