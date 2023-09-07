//
//  AccountsListFooterView.swift
//  MoneyBox
//
//  Created by David Gray on 07/09/2023.
//

import UIKit

final class AccountsListFooter: UITableViewHeaderFooterView {
    
    // MARK: - Properties
    
    private var cashImage: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "moneybox_cash") ?? UIImage())
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    // MARK: - Init
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        
        addSubview(cashImage)
        
        layoutViews()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func layoutViews() {
        NSLayoutConstraint.activate([
            cashImage.topAnchor.constraint(equalTo: topAnchor, constant: 20),
            cashImage.centerXAnchor.constraint(equalTo: centerXAnchor),
            cashImage.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -20),
        ])
    }
}
