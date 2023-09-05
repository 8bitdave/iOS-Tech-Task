//
//  AccountsTableTableViewController.swift
//  MoneyBox
//
//  Created by David Gray on 04/09/2023.
//

import UIKit

final class AccountsTableViewDelegate: NSObject, UITableViewDelegate {
    
    // MARK: - Init
    init(viewModel: AccountsViewModel) {
        
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return AccountsHeaderView()
    }
    
}
