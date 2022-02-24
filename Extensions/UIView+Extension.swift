//
//  UIView+Extension.swift
//  QuickPark
//
//  Created by Ghaliah Binakeel on 24/02/2022.
//

import Foundation
//
//  UIView+Extension.swift
//  QuickPark
//
//  Created by manar . on 23/02/2022.
//

import UIKit

extension UIView {
    @IBInspectable var cornerRadius: CGFloat {
        get { return cornerRadius }
        set {
            self.layer.cornerRadius = newValue
        }
    }
}


