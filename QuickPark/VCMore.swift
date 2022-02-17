//
//  VCMore.swift
//  QuickPark
//
//  Created by Ghaliah Binakeel on 17/02/2022.
//

import UIKit
import SVProgressHUD

class TVCMore : UITableViewController {
    @IBOutlet weak var logoutButton: UIButton!
    
    @IBAction func logoutButtonTouched(_ sender: Any) {
        SVProgressHUD.show(withStatus: "Logging Out...")
        FBAuth.logout { success, error in
            if success == false, let e = error {
                SVProgressHUD.showError(withStatus: e.localizedDescription)
            } else {
                SVProgressHUD.showSuccess(withStatus: "Logged Out.")
                SceneDelegate.sceneDelegate.setUpHome()
            }
        }
    }
}
