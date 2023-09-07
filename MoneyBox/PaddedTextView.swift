//
//  PaddedTextView.swift
//  MoneyBox
//
//  Created by David Gray on 01/09/2023.
//

import UIKit

// Used from: https://stackoverflow.com/a/6416234
final class PaddedTextField: UITextField {
    
    struct Constants {
        static let sidePadding: CGFloat = 20
        static let topPadding: CGFloat = 15
    }

    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return CGRect(
            x: bounds.origin.x + Constants.sidePadding,
            y: bounds.origin.y + Constants.topPadding,
            width: bounds.size.width - Constants.sidePadding * 2,
            height: bounds.size.height - Constants.topPadding * 2
        )
    }

    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return self.textRect(forBounds: bounds)
    }
    
}
