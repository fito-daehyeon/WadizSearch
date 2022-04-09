//
//  IntExtension.swift
//  WadizSearch
//

import Foundation

extension Int {
    var decimalFormatString: String? {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        return numberFormatter.string(for: self)
    }
}
