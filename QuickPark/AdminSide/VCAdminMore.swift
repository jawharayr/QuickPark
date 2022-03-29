//
//  AdminMore.swift
//  QuickPark
//
//  Created by Ghaliah Binakeel on 25/02/2022.
//

import Foundation
import UIKit
import SVProgressHUD
import StreamChat
import StreamChatClient

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
    
    
    @IBAction func handleAgentChatPress(_ sender: Any) {
        
        Client.shared.set(user: .init(id: "Agent"), token: .development) { result in
                   switch result {
                   case .success:
                       let channelsVC = ChannelsViewController()
                       channelsVC.title = "Support Queue"
                       channelsVC.presenter = .init(filter: .equal("type", to: "messaging"))
                       self.navigationController?.pushViewController(channelsVC, animated: true)
                   case .failure(let error):
                       print(error)
                   }
               }
           }
    
}






