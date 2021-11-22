//
//  ViewStyle_Extension.swift
//  GambleToby_Pickup
//
//  Created by Toby Gamble on 11/21/21.
//

import Foundation
import UIKit

extension UIView {
    func addCornerRadius(shadow: Bool) {
        self.layer.cornerRadius = 15
        
        if shadow {
            addShadow()
        }
    }
    
    func addShadow() {
        self.layer.shadowColor = UIColor.systemGray.cgColor
        self.layer.shadowOpacity = 0.5
        self.layer.shadowRadius = 2
        self.layer.shadowOffset = CGSize(width: 4, height: 4)
    }
}
