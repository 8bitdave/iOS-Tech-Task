//
//  AlertView.swift
//  MoneyBox
//
//  Created by David Gray on 06/09/2023.
//

import UIKit

final class AlertView: UIView {
    
    enum AlertType {
        case success
        case warning
        case error
    }
    
    // MARK: - Properties
    
    // MARK: Public
    var alertLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .title2)
        label.adjustsFontForContentSizeCategory = true
        label.textColor = .white
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        return label
    }()
    
    // MARK: Private
//    private let alertType: AlertType
    
    
    // MARK: - Init
    
    init() {
        super.init(frame: .zero)
        
        addSubview(alertLabel)
        
        layer.cornerCurve = .continuous
        layer.cornerRadius = 10
        clipsToBounds = true
        
        layoutViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - Layout Views
    private func layoutViews() {
        NSLayoutConstraint.activate([
            alertLabel.topAnchor.constraint(equalTo: topAnchor, constant: 20),
            alertLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            alertLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            alertLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -20),
            
        ])
    }
    
    // MARK: - Helpers
    
    func setAlert(alertType: AlertType, message: String) {
        
        alertLabel.text = message
        
        switch alertType {
        case .success:
            backgroundColor = .systemGreen
        case .warning:
            backgroundColor = .yellow
        case .error:
            backgroundColor = .systemRed
        }
    }
}
