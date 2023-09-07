//
//  AccountsViewController.swift
//  MoneyBox
//
//  Created by David Gray on 03/09/2023.
//

import Combine
import UIKit

final class AccountsViewController: UIViewController {
    
    // MARK: - Diffable DataSource Logic
    typealias DataSource = UITableViewDiffableDataSource<Section, Account>
    
    enum Section: CaseIterable {
        case account
    }
    
    // MARK: - Properties
    private let viewModel: AccountsViewModel
    private var cancellables: Set<AnyCancellable> = []
    
    lazy var dataSource: DataSource = {
        let dataSource = DataSource(tableView: tableView) { (tableView, indexPath, account) -> UITableViewCell? in
            
            guard let cell = tableView.dequeueReusableCell(withIdentifier: Constants.accountReuseIdentifier, for: indexPath) as? AccountCell else {
                return UITableViewCell()
            }
            
            cell.contentView.backgroundColor = .clear
            cell.nameLabel.text = account.name
            cell.planValueLabel.text = "Plan Value: £\(account.planValue)"
            cell.moneyBoxLabel.text = "Moneybox: £\(account.moneyBoxValue)"
            return cell
        }
        
        return dataSource
    }()
    
    // MARK: - UI Properties
    lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = UIColor.backgroundColor
        tableView.delegate = self
        return tableView
    }()
    
    
    private var loadingView: UIActivityIndicatorView = {
        let activityView = UIActivityIndicatorView(style: .large)
        activityView.color = .gray
        activityView.translatesAutoresizingMaskIntoConstraints = false
        activityView.startAnimating()
        
        return activityView
    }()
    
    private let activityIndicator: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView(style: .large)
        spinner.color = .lightDarkTealInverse
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
    
    private lazy var refreshButton: UIButton = {
        let button = UIButton()
        button.setTitle(viewModel.refreshButtonTitle, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor.lightTeal
        button.setTitleColor(.darkTeal, for: .normal)
        button.layer.cornerCurve = .continuous
        button.layer.cornerRadius = 9
        button.setTitleColor(.gray, for: .selected)
        button.titleLabel?.adjustsFontForContentSizeCategory = true
        button.titleLabel?.font = UIFont.preferredFont(forTextStyle: .title1)
        button.contentEdgeInsets = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        button.isHidden = true
        return button
    }()
    
    // MARK: - Init
    init(accountsViewModel: AccountsViewModel) {
        self.viewModel = accountsViewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View Lifecycle
    override func loadView() {
        super.loadView()
        
        view = UIView()
        view.addSubview(tableView)
        view.addSubview(activityIndicator)
        view.backgroundColor = .systemBackground
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.backgroundColor
        view.addSubview(BackgroundCurveView())
        view.addSubview(alertView)
        view.addSubview(refreshButton)

        layoutViews()
        configureTableView()
        
        // Hook up subscriptions to listen to state changes from VM.
        subscribe()
        
        // Ask the VM to fetch the data for the accounts
        viewModel.fetch()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Refresh data if required.
        if viewModel.shouldReload {
            viewModel.fetch()
        }
    }
    
    // MARK: - Subscriptions
    private func subscribe() {
        viewModel.viewState
            .receive(on: DispatchQueue.main)
            .sink { state in
            switch state {
            case .loading:
                self.activityIndicator.startAnimating()
                self.updateRefreshButton(hidden: true)
                self.hideAlert()
                
            case .loaded(let accountModel):
                self.activityIndicator.stopAnimating()
                self.updateRefreshButton(hidden: true)
                self.tableView.isHidden = false
                self.reloadData(data: accountModel.accounts)
                
            case .error(let error):
                self.activityIndicator.stopAnimating()
                self.tableView.isHidden = true
                self.alertView.setAlert(alertType: .error, message: error)
                self.showAlert()
                self.updateRefreshButton(hidden: false)
                
            case .initialised:
                break
            }
        }.store(in: &cancellables)
        
        refreshButton.addTarget(self, action: #selector(refreshButtonTapped), for: .touchUpInside)
    }
    
    // MARK: - Helper Functions
    private func configureTableView() {
        tableView.register(AccountCell.self, forCellReuseIdentifier: Constants.accountReuseIdentifier)
        tableView.register(AccountsListHeader.self, forHeaderFooterViewReuseIdentifier: Constants.accountHeaderViewReuseIdentifier)
        tableView.dataSource = dataSource
        tableView.backgroundView = BackgroundCurveView()
        tableView.separatorStyle = .none
        tableView.sectionHeaderHeight = UITableView.automaticDimension
    }
    
    func layoutViews() {
        NSLayoutConstraint.activate([
            
            alertView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            alertView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            alertView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            alertView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            refreshButton.topAnchor.constraint(equalTo: alertView.bottomAnchor, constant: 20),
            refreshButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            refreshButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            // Table View
            tableView.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // Activity Indicator
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        ])
    }
    
    func reloadData(data: [Account]) {
        // Update the table view when the data is loaded
        var snapshot = NSDiffableDataSourceSnapshot<Section, Account>()
        snapshot.appendSections([.account])
        snapshot.appendItems(data)
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    // MARK: - Hide/Show UI Functions
    
    private func updateRefreshButton(hidden: Bool) {
        refreshButton.isHidden = hidden
    }
    
    private func showAlert() {
        alertView.isHidden = false
    }
    
    private func hideAlert() {
        alertView.isHidden = true
    }
    
    // MARK: - Objc Functions
    @objc
    private func refreshButtonTapped() {
        viewModel.fetch()
    }
}
// MARK: - Constants
extension AccountsViewController {
    enum Constants {
        static let accountReuseIdentifier = "AccountCell"
        static let accountHeaderViewReuseIdentifier = "AccountHeaderView"
    }
}

extension AccountsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.didSelectAccount(at: indexPath.row)
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: Constants.accountHeaderViewReuseIdentifier) as? AccountsListHeader
        view?.totalValueLabel.text = viewModel.totalPlanValue
        view?.welcomeLabel.text = viewModel.welcomeString
        
        return view
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        return 400
    }
}
