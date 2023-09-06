//
//  AccountsHeaderView.swift
//  MoneyBox
//
//  Created by David Gray on 04/09/2023.
//

import UIKit

final class AccountsListHeader: UITableViewHeaderFooterView {
    
    // MARK: - Properties
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Your Accounts"
        label.font = UIFont.preferredFont(forTextStyle: .largeTitle)
        label.adjustsFontForContentSizeCategory = true
        label.textColor = .lightDarkTealInverse
        return label
    }()
    
    lazy var welcomeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.preferredFont(forTextStyle: .title2)
        label.adjustsFontForContentSizeCategory = true
        label.textColor = .lightDarkTealInverse
        return label
    }()

    private var planValueTextLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.preferredFont(forTextStyle: .headline)
        label.adjustsFontForContentSizeCategory = true
        label.textColor = .lightDarkTealInverse
        label.text = "Total Plan Value:"
        return label
    }()

    lazy var totalValueLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "\(totalPlanValue)"
        label.font = UIFont.preferredFont(forTextStyle: .largeTitle)
        label.adjustsFontForContentSizeCategory = true
        label.textColor = .lightDarkTealInverse
        return label
    }()

    
    // MARK: - Exposed Properties
    
    var name: String = ""
    var totalPlanValue: Double = 0.00

    
    // MARK: - Init
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        
        backgroundConfiguration = .listGroupedHeaderFooter()
        
        addSubview(titleLabel)
        addSubview(welcomeLabel)
        addSubview(planValueTextLabel)
        addSubview(totalValueLabel)
        layoutViews()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func layoutViews() {
        NSLayoutConstraint.activate([
            
            // Title Label
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            
            // Total Value Label
            welcomeLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            welcomeLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            welcomeLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            
            // Plan Value Text Label
            planValueTextLabel.topAnchor.constraint(equalTo: welcomeLabel.bottomAnchor, constant: 20),
            planValueTextLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            planValueTextLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),

            // Total Value Label
            totalValueLabel.topAnchor.constraint(equalTo: planValueTextLabel.bottomAnchor, constant: 5),
            totalValueLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            totalValueLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            totalValueLabel.bottomAnchor.constraint(equalTo: bottomAnchor),
            
        ])
    }
}
