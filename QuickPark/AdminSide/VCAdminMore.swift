//
//  AdminMore.swift
//  QuickPark
//
//  Created by Ghaliah Binakeel on 25/02/2022.
//

import Foundation
import UIKit
import SVProgressHUD

class VCAdminMore : UITableViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        switch indexPath.row {
        case 0: //Call Feature
            
            break;
        case 1: //logout
            logout()
            break;
        default:
            break
        }
    }
    
    func logout () {
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






