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
                        SVProgressHUD.showError(withStatus: e.localizedDescription)
                    } else {
                        //SVProgressHUD.showSuccess(withStatus: "Logged Out.")
                        SceneDelegate.sceneDelegate.setUpHome()
                    }
                }
            }
        }
    }
}
    
    
   /*  @IBAction func logoutPress(_ button: Any?) {
        let alert = UIAlertController(title: "Are you sure you want to log out?", message: nil, preferredStyle: .alert)
        alert.addAction(.init(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(.init(title: "Yes", style: .default, handler: { _ in
            FBAuth.logout { success, error in
                if success == false, let e = error {
                    SVProgressHUD.showError(withStatus: e.localizedDescription)
                } else {
                    SVProgressHUD.showSuccess(withStatus: "Logged Out.")
                    SceneDelegate.sceneDelegate.setUpHome()
                }
            }
        }))
        present(alert, animated: true, completion: nil)
    } */

