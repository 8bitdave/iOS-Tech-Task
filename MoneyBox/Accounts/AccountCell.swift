//
//  AccountCell.swift
//  MoneyBox
//
//  Created by David Gray on 03/09/2023.
//

import UIKit

final class AccountCell: UITableViewCell {
    
    // MARK: - UI Properties
    let nameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.font = UIFont.preferredFont(forTextStyle: .largeTitle)
        label.adjustsFontForContentSizeCategory = true
        label.textColor = UIColor.lightDarkTealInverse
        
        return label
    }()
    
    let planValueLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.font = UIFont.preferredFont(forTextStyle: .headline)
        label.adjustsFontForContentSizeCategory = true
        label.textColor = UIColor.lightDarkTealInverse
        
        return label
    }()
    
    let moneyBoxLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.font = UIFont.preferredFont(forTextStyle: .headline)
        label.adjustsFontForContentSizeCategory = true
        label.textColor = UIColor.lightDarkTealInverse
        
        return label
    }()
    
    // MARK - Private
    private var containerStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.distribution = .equalSpacing
        return stackView
    }()
    
    private var backgroundColorView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.backgroundColor
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1.0).cgColor
        return view
    }()
    
    // MARK: - Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .none
        
        backgroundColor = .clear
        contentView.addSubview(backgroundColorView)
        
        backgroundColorView.addSubview(containerStackView)
        backgroundColorView.layer.cornerCurve = .continuous
        backgroundColorView.layer.cornerRadius = 10
        backgroundColorView.clipsToBounds = true
        
        // Add labels to stack
        backgroundColorView.addSubview(containerStackView)
        containerStackView.addArrangedSubview(nameLabel)
        containerStackView.addArrangedSubview(planValueLabel)
        containerStackView.addArrangedSubview(moneyBoxLabel)
        
        layoutViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Layout Functions
    private func layoutViews() {
        NSLayoutConstraint.activate([
            
            // Background Constraints
            backgroundColorView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            backgroundColorView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            backgroundColorView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            backgroundColorView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
            
            // Stack Constraints
            containerStackView.topAnchor.constraint(equalTo: backgroundColorView.topAnchor, constant: 20),
            containerStackView.bottomAnchor.constraint(equalTo: backgroundColorView.bottomAnchor, constant: -20),
            containerStackView.leadingAnchor.constraint(equalTo: backgroundColorView.leadingAnchor, constant: 20),
            containerStackView.trailingAnchor.constraint(equalTo: backgroundColorView.trailingAnchor, constant: -20)
        ])
    }
}
