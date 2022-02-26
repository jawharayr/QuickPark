//
//  AdminMore.swift
//  QuickPark
//
//  Created by Ghaliah Binakeel on 25/02/2022.
//

import Foundation
import UIKit
import SVProgressHUD

class VCAdminMore : UIViewController {
    @IBAction func logoutPressed(_ sender: Any) {
        QPAlert(self).showAlert(title: "Are you sure you want to log out?", message: nil, buttons: ["Cancel", "Yes"]) { _, index in
            if index == 1 {
                FBAuth.logout { success, error in
                    if success == false, let e = error {
                        QPAlert(self).showError(message: e.localizedDescription)
                    } else {
                        SceneDelegate.sceneDelegate.setUpHome()
                    }
                }
            }
        }
    }
}
    
    
   

