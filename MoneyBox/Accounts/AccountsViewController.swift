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
    
    lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = UIColor.backgroundColor
        return tableView
    }()
    
    private var loadingView: UIActivityIndicatorView = {
        let activityView = UIActivityIndicatorView(style: .large)
        activityView.color = .gray
        activityView.translatesAutoresizingMaskIntoConstraints = false
        activityView.startAnimating()
        
        return activityView
    }()
    
    private var tableHeaderView: AccountsHeaderView = {
        let headerView = AccountsHeaderView(frame: CGRect(x: 0, y: 0, width: 375, height: 400))
        headerView.name = "David Gray"
        headerView.totalPlanValue = 7000.00
        headerView.layoutSubviews()
        return headerView
    }()
    
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
    
    private var cancellables: Set<AnyCancellable> = []
    
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
//        view.addSubview(loadingView)
        view.backgroundColor = .systemBackground
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.backgroundColor

        layoutViews()
        configureTableView()
        
        // Hook up subscriptions to listen to state changes from VM.
        subscribe()
        
        // Ask the VM to fetch the data for the accounts
        viewModel.fetch()
    }
    
    // MARK: - Subscriptions
    private func subscribe() {
        viewModel.state.sink { state in
            switch state {
            case .loading:
                print("show loading screen")
            case .loaded(let accountModel):
                self.reloadData(data: accountModel.accounts)
            case .error(let error):
                print("Got error! \(error)")
            }
        }.store(in: &cancellables)
    }
    
    // MARK: - Helper Functions
    
    private func configureTableView() {
        tableView.register(AccountCell.self, forCellReuseIdentifier: Constants.accountReuseIdentifier)
        tableView.dataSource = dataSource
        tableView.backgroundView = BackgroundCurveView()
        tableView.separatorStyle = .none
        tableView.tableHeaderView = tableHeaderView
    }
    
    func layoutViews() {
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }
    
    func reloadData(data: [Account]) {
        // Update the table view when the data is loaded
        var snapshot = NSDiffableDataSourceSnapshot<Section, Account>()
        snapshot.appendSections([.account])
        snapshot.appendItems(data)
        dataSource.apply(snapshot, animatingDifferences: true)
    }
}

extension AccountsViewController {
    enum Constants {
        static let accountReuseIdentifier = "AccountCell"
    }
}
