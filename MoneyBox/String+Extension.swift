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
        
        let formatter = NumberFormatter()
             formatter.minimumFractionDigits = 2
             formatter.maximumFractionDigits = 2
             formatter.minimumIntegerDigits = 1
             formatter.paddingPosition = .afterPrefix
             formatter.paddingCharacter = "0"
         
        guard let formattedNumber = formatter.string(from: NSNumber.init(value: number)) else { return "" }
        
        switch currency {
        case .GBP:
            return "£\(formattedNumber)"
        case .EUR:
            return "€\(formattedNumber)"
        }
    }
}
