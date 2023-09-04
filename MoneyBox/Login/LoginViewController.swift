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
    
    var loginButton: UIButton = {
        let button = UIButton()
        button.setTitle("Login", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor(red: 0.12, green: 0.82, blue: 0.63, alpha: 1.0)
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
        view.addSubview(backgroundCurveView)
        view.addSubview(loginTitle)
        view.addSubview(stackView)
        view.addSubview(moneyBoxLogo)
        
        stackView.addArrangedSubview(emailTextField)
        stackView.addArrangedSubview(passwordTextField)
        view.addSubview(loginButton)
        
        view.backgroundColor = UIColor(named: "background_color")
        
        subscribe()
        
        layoutViews()
    }
    
    private func layoutViews() {
        NSLayoutConstraint.activate([
            
            // MARK: Background View
            backgroundCurveView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundCurveView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundCurveView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundCurveView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // MARK: Moneybox Logo
            moneyBoxLogo.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 30),
            moneyBoxLogo.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            moneyBoxLogo.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            // MARK: Title Label
            loginTitle.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            loginTitle.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            loginTitle.bottomAnchor.constraint(equalTo: stackView.topAnchor, constant: -20),
            
            // MARK: Stack View Constraints
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            stackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -150),
            
            // MARK: Login Button Constraints
            loginButton.topAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 20),
            loginButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            loginButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
        ])
    }
    
    // MARK: Subscription Logic
    private func subscribe() {
        viewModel.loginButtonEnabled
            .receive(on: DispatchQueue.main)
            .sink { enabled in
                self.loginButton.isEnabled = enabled
                self.loginButton.backgroundColor = enabled ? UIColor(red: 0.12, green: 0.82, blue: 0.63, alpha: 1.0) : .systemGray
            }
            .store(in: &cancellables)
     
        loginButton.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
        
    }
    
    // MARK: - Target Action
    @objc private func loginButtonTapped() {
        viewModel.loginTapped()
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
