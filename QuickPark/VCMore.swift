//
//  VCMore.swift
//  QuickPark
//
//  Created by Ghaliah Binakeel on 17/02/2022.
//

import UIKit
import SVProgressHUD

class TVCMore : UITableViewController {
  
    
    //
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        switch indexPath.row {
        case 0: //Call Feature
            break;
        case 1: //Show Obboarding
            if let vc = SBSupport.viewController(sbi: "sbi_OnboardingViewController", inStoryBoard: "Misclenious") as? OnboardingViewController {
                vc.fromViewController = "more"
                self.navigationController?.pushViewController(vc, animated: true)
            }
           
            break;
        case 2: //SHow Terms of service
            let vc = SBSupport.viewController(sbi: "sbi_TermsViewController", inStoryBoard: "Misclenious")
            self.navigationController?.pushViewController(vc, animated: true)
            break;
        case 3: //logout
            logout()
            break;
        default:
            break
        }
    }
    
    func logout () {
        let alert = UIAlertController(title: "Are you sure you want to log out?", message: nil, preferredStyle: .alert)
        alert.addAction(.init(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(.init(title: "Yes", style: .default, handler: { _ in
            FBAuth.logout { success, error in
                if success == false, let e = error {
                    SVProgressHUD.showError(withStatus: e.localizedDescription)
                } else {
                    //SVProgressHUD.showSuccess(withStatus: "Logged Out.")
                    SceneDelegate.sceneDelegate.setUpHome()
                }
            }                    }))
        present(alert, animated: true, completion: nil)
    }
}






