//
//  String+Extension.swift
//  MoneyBox
//
//  Created by David Gray on 05/09/2023.
//

import Foundation

extension String {
    enum CurrencyType {
        case GBP
        case EUR
    }
    
    static func createCurrencyString(from number: Double, currency: CurrencyType = .GBP) -> String {
        switch currency {
        case .GBP:
            return "£\(number.rounded(toPlaces: 2))"
        case .EUR:
            return "€\(number.rounded(toPlaces: 2))"
        }
    }
}
