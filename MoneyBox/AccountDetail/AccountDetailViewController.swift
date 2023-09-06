//
//  AccountDetailViewController.swift
//  MoneyBox
//
//  Created by David Gray on 05/09/2023.
//

import Combine
import UIKit

final class AccountDetailViewController: UIViewController {
    
    // MARK: - Properties
    private let viewModel: AccountDetailViewModel
    private var cancellables: Set<AnyCancellable> = []
    
    // MARK: - UI Properties
    private lazy var addMoneyButton: UIButton = {
        let button = UIButton()
        button.setTitle(viewModel.buttonTitle, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor.lightTeal
        button.layer.cornerCurve = .continuous
        button.layer.cornerRadius = 9
        button.setTitleColor(.darkTeal, for: .normal)
        button.titleLabel?.adjustsFontForContentSizeCategory = true
        button.titleLabel?.font = UIFont.preferredFont(forTextStyle: .title1)
        button.contentEdgeInsets = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        button.accessibilityLabel = "Add £10 to your moneybox account"
        return button
    }()
    
    private lazy var accountNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "SF Pro Text Bold", size: 34)
        label.text = viewModel.accountName
        label.textColor = .lightDarkTealInverse
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isHidden = false
        return label
    }()
    
    private lazy var moneyBoxLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "SF Pro Text Bold", size: 34)
        label.text = viewModel.moneyBoxValue.value
        label.textColor = .lightDarkTealInverse
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isHidden = false
        return label
    }()
    
    private let backgroundCurveView: UIView = {
        let view = BackgroundCurveView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.shouldAnimate = true
        return view
    }()
    
    private let alertView: AlertView = {
        let alert = AlertView()
        alert.translatesAutoresizingMaskIntoConstraints = false
        return alert
    }()
    
    private let activityIndicator: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView(style: .large)
        spinner.color = .lightDarkTeal
        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.hidesWhenStopped = true
        spinner.stopAnimating()
        return spinner
    }()
    
    // MARK: - Init
    init(viewModel: AccountDetailViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
//        view.addSubview(backgroundCurveView)
        view.addSubview(accountNameLabel)
        view.addSubview(moneyBoxLabel)
        view.addSubview(alertView)
        view.addSubview(addMoneyButton)
        
        addMoneyButton.addSubview(activityIndicator)
        
        view.backgroundColor = UIColor(named: "background_color")
        
        subscribe()
        
        layoutViews()
    }
    
    private func subscribe() {
        
        // Subscribe to the view model state
        viewModel.viewState
            .receive(on: DispatchQueue.main)
            .sink { state in
                switch state {
                case .initialised:
                    // Show the account state, no updates yet.
                    self.addMoneyButton.isEnabled = true
                    self.hideAlert()
                    break
                case .loading:
                    self.disableButton()
                    self.hideAlert()
                    print("🛜 loading")
                case .loaded:
                    self.alertView.setAlert(alertType: .success, message: Constants.alertViewSuccessMessage)
                    self.showAlert()
                    self.enableButton()
                    print("✅ loaded!")
                case .error(let error):
                    self.alertView.setAlert(alertType: .error, message: error)
                    self.showAlert()
                    self.enableButton()
                    print("💥 \(error)!")
                }
            }.store(in: &cancellables)
        
        // Subscribe to the moneybox value being updated
        viewModel.moneyBoxValue
            .receive(on: DispatchQueue.main)
            .sink { moneyBox in
                self.moneyBoxLabel.text = moneyBox
            }.store(in: &cancellables)
        
        // Set up target action for button
        addMoneyButton.addTarget(self, action: #selector(addMoneyButtonTapped), for: .touchUpInside)
    }
    
    private func layoutViews() {
        NSLayoutConstraint.activate([
            
            // MARK: Background View
//            backgroundCurveView.topAnchor.constraint(equalTo: view.topAnchor),
//            backgroundCurveView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
//            backgroundCurveView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
//            backgroundCurveView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // MARK: Title Label
            accountNameLabel.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor, constant: 20),
            accountNameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            accountNameLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            moneyBoxLabel.topAnchor.constraint(equalTo: accountNameLabel.bottomAnchor, constant: 20),
            moneyBoxLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            moneyBoxLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            // MARK: Add Money Button Constraints
            addMoneyButton.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor, constant: -20),
            addMoneyButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            addMoneyButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            activityIndicator.centerYAnchor.constraint(equalTo: addMoneyButton.centerYAnchor),
            activityIndicator.centerXAnchor.constraint(equalTo: addMoneyButton.centerXAnchor),
            
            alertView.bottomAnchor.constraint(equalTo: addMoneyButton.topAnchor, constant: -20),
            alertView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            alertView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
        ])
    }
    
    // MARK: - Target Action
    @objc
    func addMoneyButtonTapped() {
        viewModel.didTapAddMoneyButton()
    }
    
    // MARK: - Helper Functions
    private func disableButton() {
        DispatchQueue.main.async {
            self.addMoneyButton.setTitle("", for: .normal)
            self.addMoneyButton.backgroundColor = UIColor.buttonDisabledColor
            self.activityIndicator.startAnimating()
        }
    }
    
    private func enableButton() {
        DispatchQueue.main.async {
            self.activityIndicator.stopAnimating()
            self.addMoneyButton.setTitle(self.viewModel.buttonTitle, for: .normal)
            self.addMoneyButton.backgroundColor = UIColor.lightTeal
        }
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

private extension AccountDetailViewController {
    enum Constants {
        static let alertViewSuccessMessage = "Money added!"
    }
}
