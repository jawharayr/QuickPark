//
//  VCMore.swift
//  QuickPark
//
//  Created by Ghaliah Binakeel on 17/02/2022.
//

import UIKit
import SVProgressHUD

class TVCMore : UITableViewController {
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    //
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            if let vc = SBSupport.viewController(sbi: "sbi_ChatViewController", inStoryBoard: "Chat") as? ChatViewController {
                self.navigationController?.pushViewController(vc, animated: true)
                vc.otherUser = FBSUser.admin
            }
            break;
        case 1:
            if let vc = SBSupport.viewController(sbi: "sbi_HowToViewController", inStoryBoard: "Misclenious") as? HowToViewController {
                vc.fromViewController = "more"
                self.navigationController?.pushViewController(vc, animated: true)
            }
            break;
        case 2:
            let vc = SBSupport.viewController(sbi: "sbi_TermsViewController", inStoryBoard: "Misclenious")
            self.navigationController?.pushViewController(vc, animated: true)
            break;
        case 3:
            logout()
            break;
        default:
            break
        }
    }
    
    func logout () {
        let userID = FBSUser.currrentUser.email ?? ""
        QPAlert(self).showAlert(title: "Are you sure you want to log out?", message: nil, buttons: ["Cancel", "Yes"]) { _, index in
        if index == 1 {
            FBAuth.logout { success, error in
            if success == false, let e = error {
                QPAlert(self).showError(message: e.localizedDescription)
            } else {
            PushNotificationManager.shared.removeFirestorePushTokenOnLogOut(userID: userID)
            SceneDelegate.sceneDelegate.setUpHome()
                        }
                    }
            }
        }
    }
}
    
    
    







