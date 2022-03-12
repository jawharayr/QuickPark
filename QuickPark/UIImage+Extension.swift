//
//  UIImage+Extension.swift
//  QuickPark
//
//  Created by Deema on 09/08/1443 AH.
//

import Foundation
import UIKit

extension UIImage{
    
    static func generateQRCode(using string:String) -> UIImage? {
        
        let data = string.data(using: String.Encoding.ascii)
        
        if let filter = CIFilter(name: "CIQRCodeGenerator"){
            filter.setValue( data, forKey: "inputMessage")
            let transform = CGAffineTransform(scaleX: 3, y: 3)
            if let output = filter.outputImage?.transformed(by: transform){
                return UIImage(ciImage: output)
            }
        }
        return nil
        
    }
    
}
