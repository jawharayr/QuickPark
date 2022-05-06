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
            if let vc = SBSupport.viewController(sbi: "sbi_chatRoster", inStoryBoard: "Chat") as? VCChatRoster {
                self.navigationController?.pushViewController(vc, animated: true)
            }
            break;
            
        case 1: //Call Feature
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "ViewPromoCodeVC") as? ViewPromoCodeVC

                navigationController?.pushViewController(vc!, animated: true)
            break;
            
        case 2: //logout
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






