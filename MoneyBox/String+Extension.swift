//
//  String+Extension.swift
//  MoneyBox
//
//  Created by David Gray on 05/09/2023.
//

extension String {
    enum CurrencyType {
        case GBP
        case EUR
    }
    
    static func createCurrencyString(from number: Double, currency: CurrencyType = .GBP) -> String {
        switch currency {
        case .GBP:
            return "£\(number)"
        case .EUR:
            return "€\(number)"
        }
    }
}
