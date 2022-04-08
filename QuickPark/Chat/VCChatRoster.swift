//
//  AdminChatRoster.swift
//  QuickPark
//
//  Created by manar . on 31/03/2022.
//

import UIKit
import Firebase

class UserCell : UITableViewCell {
    var chat : Chat!
    var user : QPUser! {
        didSet {
            self.textLabel?.text = user.name
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}


class VCChatRoster : UIViewController {
    @IBOutlet var tableView: UITableView!
    @IBOutlet var noMessageLabel: UILabel!
    let db = Firestore.firestore()
    var chats : [Chat] = [] {
        didSet {
            self.tableView.reloadData()
            self.tableView.refreshControl?.endRefreshing()
        }
    }
    
    //let refreshControl : UIRefreshControl!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadChatRoster()
        let rc = UIRefreshControl()
        rc.addTarget(self, action: #selector(refreshChatData(_:)), for: .valueChanged)
        self.tableView.refreshControl = rc
    }
    
    @objc private func refreshChatData(_ sender:Any) {
        loadChatRoster()
    }
    
    func loadChatRoster() {
        noMessageLabel.text = ""
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        db.collection("Chats").whereField("users", arrayContains: uid).getDocuments { querySnapshot, error in
            if let e = error {
                print("Error: ", e.localizedDescription)
            } else {
                guard let sds  = querySnapshot?.documents, sds.count > 0 else {
                    self.noMessageLabel.text = "No chats"
                    return
                    
                }
                
                self.chats.removeAll()
                var cs : [Chat] = []
                var dataLoadCounter = 0
                for d in sds {
                    let c = Chat(dictionary: d.data())
                    c.documentID = d.documentID
                    if let uid = Auth.auth().currentUser?.uid, let otherUserID = (c.users.filter { $0 != uid}).last {
                        d.reference.collection("thread")
                            .whereField("senderID", isEqualTo: otherUserID)
                            .whereField("isRead", isEqualTo: false).getDocuments(completion: { threadQuery, error in
                                if let error = error {
                                    print("Error: \(error)")
                                } else {
                                    c.unreadCount = threadQuery?.documents.count ?? 0
                                }
                                cs.append(c)
                                dataLoadCounter += 1
                                
                                if dataLoadCounter == sds.count {
                                    DispatchQueue.main.async {
                                        self.chats = cs
                                    }
                                }
                            })
                    }
                }
            }
        }
    }
}


extension VCChatRoster:UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.chats.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell : UserCell!
        if let c = tableView.dequeueReusableCell(withIdentifier: "ci_chatUser") as? UserCell {
            cell = c
        }else {
            cell = UserCell(style: UITableViewCell.CellStyle.value1, reuseIdentifier: "ci_chatUser")
            cell.detailTextLabel?.textColor = #colorLiteral(red: 0.2745098174, green: 0.4862745106, blue: 0.1411764771, alpha: 1)
            cell.detailTextLabel?.font = .boldSystemFont(ofSize: 18)
            cell.accessoryType = .disclosureIndicator
//            cell.detailTextLabel?.backgroundColor = .red
//            var f = cell.detailTextLabel?.frame
//            f?.size = CGSize(width: 32, height: 32)
//            cell.detailTextLabel?.frame = f ?? .zero
//            cell.detailTextLabel?.layer.cornerRadius = 16
//            cell.detailTextLabel?.layer.masksToBounds = true
        }
        let c = chats[indexPath.row]
        cell.chat = c
        cell.detailTextLabel?.text = ((c.unreadCount ?? 0) != 0) ?  "\(c.unreadCount!)" : ""
        c.loadOtherUser { user in
            cell?.user = user
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var c = chats[indexPath.row]
        c.unreadCount = 0
        chats[indexPath.row] = c
        //let cell  = tableView.cellForRow(at: indexPath) as! UserCell
        self.performSegue(withIdentifier: "si_rosterToChat", sender: indexPath)
    }
}

//navigate
extension VCChatRoster {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? ChatViewController, let indexPath = sender as? IndexPath, let otherUser = chats[indexPath.row].otherUser {
            vc.otherUser = ChatUser(senderId: otherUser.uid, displayName: otherUser.name)
            self.tableView.reloadData()
        }
    }
}