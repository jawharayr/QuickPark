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
        case 0: //Call Feature
            //hcta feature
            
            if let vc = SBSupport.viewController(sbi: "sbi_VCChat", inStoryBoard: "Chat") as? VCChat {
                //vc.fromViewController = "more"
                self.navigationController?.pushViewController(vc, animated: true)
            }
            break;
        case 1: //Show Obboarding
            if let vc = SBSupport.viewController(sbi: "sbi_HowToViewController", inStoryBoard: "Misclenious") as? HowToViewController {
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
    
    func handleChatBtnPress() {
       Client.shared.set(user:  .init(id: .random()), token: .development) { result in
           switch result {
           case .success:
               print ("chat user successe")
           case .failure(let error):
               print(error)
           }
       }
       
       let uid = Client.shared.user.id
       let channel = Client.shared.channel(type: .messaging, id: "support-\(uid)")
       channel.extraData = ChannelExtraData(name: "\(uid) support")
       channel.create { _ in
           channel.add(user: .init(id: "Agent")) { _ in
               
           }
       }
        print("printing bk ----")
       let chatVC = ChatViewController()
       chatVC.presenter = .init(channel: channel)
       chatVC.title = "Support"
       
       let navigation = UINavigationController(rootViewController: chatVC)
       
       self.present(navigation, animated: true, completion: {
           
       })
}
    
    
}


extension String {
    static func random(length: Int = 10) -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<length).map{ _ in letters.randomElement()! })
    }
}



