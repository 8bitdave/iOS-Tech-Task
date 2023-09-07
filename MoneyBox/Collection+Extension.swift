//
//  Collection+Extension.swift
//  MoneyBox
//
//  Created by David Gray on 07/09/2023.
//

import Foundation

// Taken from: https://stackoverflow.com/a/40331858
extension Collection {
    /// Returns the element at the specified index if it is within bounds, otherwise nil.
    subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
