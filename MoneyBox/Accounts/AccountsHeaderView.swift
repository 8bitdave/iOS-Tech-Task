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
    
    private let labelContainerStack: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.distribution = .equalSpacing
        stack.spacing = 15
        return stack
    }()
    
    private let planValueStack: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.distribution = .fillProportionally
        stack.spacing = 0
        return stack
    }()

    
    // MARK: - Exposed Properties
    
    var name: String = ""
    var totalPlanValue: Double = 0.00

    
    // MARK: - Init
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        
        addSubview(labelContainerStack)
        labelContainerStack.addArrangedSubview(titleLabel)
        labelContainerStack.addArrangedSubview(welcomeLabel)
        labelContainerStack.addArrangedSubview(planValueStack)
        
        planValueStack.addArrangedSubview(planValueTextLabel)
        planValueStack.addArrangedSubview(totalValueLabel)
        
        layoutViews()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func layoutViews() {
        NSLayoutConstraint.activate([
            labelContainerStack.topAnchor.constraint(equalTo: topAnchor, constant: 20),
            labelContainerStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            labelContainerStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            labelContainerStack.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }
}
