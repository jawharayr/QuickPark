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
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var messageCountlabel: UILabel!
    var chat : Chat! {
        didSet {
            self.detailLabel.text = chat.dateString
            self.messageCountlabel.isHidden = true
            if let uc = chat.unreadCount, uc > 0 {
                self.messageCountlabel.isHidden = false
                self.messageCountlabel.text = "\(uc)"
            }
        }
    }
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
                                    if let md = threadQuery?.documents.first, let m = Message(dictionary: md.data()) {
                                        c.lastMessage = m
                                    }
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
        if let c = tableView.dequeueReusableCell(withIdentifier: "ci_UserCell") as? UserCell {
            cell = c
        }
        let c = chats[indexPath.row]
        cell.chat = c
        c.loadOtherUser { user in
            cell?.user = user
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let c = chats[indexPath.row]
        c.unreadCount = 0
        chats[indexPath.row] = c
        //let cell  = tableView.cellForRow(at: indexPath) as! UserCell
        self.performSegue(withIdentifier: "si_rosterToChat", sender: indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 104
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
