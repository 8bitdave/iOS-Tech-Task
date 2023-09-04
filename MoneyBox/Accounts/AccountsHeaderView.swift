//
//  AccountsHeaderView.swift
//  MoneyBox
//
//  Created by David Gray on 04/09/2023.
//

import UIKit

final class AccountsHeaderView: UIView {
    
    // MARK: - Properties
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Your Accounts"
        label.font = UIFont.preferredFont(forTextStyle: .largeTitle)
        label.textColor = UIColor.lightDarkTealInverse
        return label
    }()
    
    lazy var welcomeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.preferredFont(forTextStyle: .title1)
        return label
    }()
    
    private var planValueTextLabel: UILabel = {
        let label = UILabel()
        label.text = "Total Plan Value:"
        return label
    }()
    
    lazy var totalValueLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "\(totalPlanValue)"
        label.font = UIFont.preferredFont(forTextStyle: .title2)
        return label
    }()
    
    
    // MARK: - Exposed Properties
    
    var name: String = "" {
        didSet {
            calculateWelcomeMessage()
        }
    }
    
    var totalPlanValue: Double = 0.00 {
        didSet {
            setTotalValueLabel()
        }
    }
    
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .clear
        
        addSubview(titleLabel)
        addSubview(welcomeLabel)
        addSubview(planValueTextLabel)
        addSubview(totalValueLabel)
        
        layoutViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - View Lifecycle
    
    
    // MARK: - Helper Functions
    private func layoutViews() {
        NSLayoutConstraint.activate([
            // Total Value Label
            totalValueLabel.topAnchor.constraint(equalTo: topAnchor, constant: 20),
            totalValueLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            totalValueLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            totalValueLabel.heightAnchor.constraint(equalToConstant: 200),
            
            // Title Label
            titleLabel.topAnchor.constraint(equalTo: totalValueLabel.bottomAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            
            // Plan Value Text Label
            planValueTextLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 40),
            planValueTextLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            planValueTextLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            
            // Total Value Label
            totalValueLabel.topAnchor.constraint(equalTo: planValueTextLabel.bottomAnchor, constant: 40),
            totalValueLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            totalValueLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            totalValueLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -40)
        ])
    }
    
    private func calculateWelcomeMessage() {
        DispatchQueue.main.async {
            self.titleLabel.text = "Hello, \(self.name)"
            self.setNeedsDisplay()
        }
    }
    
    private func setTotalValueLabel() {
        DispatchQueue.main.async {
            self.totalValueLabel.text = "£\(self.totalPlanValue)"
            self.setNeedsDisplay()
        }
    }
}
