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
    
    //Test alerts and didPress
    
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!)
    {
    let ref = Constants.refs.databaseChats.childByAutoId()

    let message = [“sender_id”: senderId, “name”: senderDisplayName, “text”: text]

    ref.setValue(message)

    finishSendingMessage()
    }
    
    let query = Constants.refs.databaseChats.queryLimited(toLast: 10)

    _ = query.observe(.childAdded, with: { [weak self] snapshot in

    if let data = snapshot.value as? [String: String],
    let id = data[“sender_id”],
    let name = data[“name”],
    let text = data[“text”],
    !text.isEmpty
    {
    if let message = JSQMessage(senderId: id, displayName: name, text: text)
    {
    self?.messages.append(message)

    self?.finishReceivingMessage()
    }
    }
    })
    
    func ChatAlert() {
        alert.addTextField { textField in

        if let name = defaults.string(forKey: “jsq_name”)
        {
        textField.text = name
        }
        else
        {
        let names = [“Ford”, “Arthur”, “Zaphod”, “Trillian”, “Slartibartfast”, “Humma Kavula”, “Deep Thought”]
        textField.text = names[Int(arc4random_uniform(UInt32(names.count)))]
        }
        }

        alert.addAction(UIAlertAction(title: “OK”, style: .default, handler: { [weak self, weak alert] _ in

        if let textField = alert?.textFields?[0], !textField.text!.isEmpty {

        self?.senderDisplayName = textField.text

        self?.title = “Chat: \(self!.senderDisplayName!)”

        defaults.set(textField.text, forKey: “jsq_name”)
        defaults.synchronize()
        }
        }))

        present(alert, animated: true, completion: nil)
        }
    
}






