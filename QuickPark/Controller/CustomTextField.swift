//
//  CustomTextField.swift
//  QuickPark
//
//  Created by manar . on 10/02/2022.
//

import Foundation
import UIKit
class CustomTextField:UITextField{
    override init(frame: CGRect) {
           super.init(frame: frame)
    }
      required public init?(coder aDecoder: NSCoder) {
           super.init(coder: aDecoder)
      }
        
    func commonInit(){
        //TODO:- will define it later
        self.placeholderColor = UIColor.white

        
    }
    
    var placeholderColor:UIColor = UIColor.lightGray{
        didSet{
            self.setPlaceholderColor()
            
        }
        
    }
    private func setPlaceholderColor(){
        self.attributedPlaceholder = NSAttributedString(string: self.placeholder ?? "",attributes:
            [NSAttributedString.Key.foregroundColor : placeholderColor])
                                                                                                
    }
} //end class
