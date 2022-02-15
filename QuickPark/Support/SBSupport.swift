//
//  SBSupport.swift
//  QuickPark
//
//  Created by Ghaliah Binakeel on 15/02/2022.
//

import Foundation
import UIKit

class SBSupport {
    static func viewController (sbi : String, inStoryBoard sbName:String) -> UIViewController {
        let sb = UIStoryboard(name: sbName, bundle: .main)
        let vc = sb.instantiateViewController(withIdentifier: sbi)
        return vc
    }
}
