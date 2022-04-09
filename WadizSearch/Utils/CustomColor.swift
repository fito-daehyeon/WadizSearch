//
//  CustomColor.swift
//  WadizSearch
//
//  Created by DaeHyeon Kim on 2022/04/09.
//
import SwiftUI
import UIKit

enum ThemeColor {
    case MainColor

    
    func getUIColor() -> UIColor {
        switch self {
        case .MainColor:
            return UIColor(red: 139 / 255, green: 188 / 255, blue: 189 / 255, alpha: 1.00)
      
            
        }
    }
    
    func getSwiftUIColor() -> Color {
        return Color(self.getUIColor())
    }
}

