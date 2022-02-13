//
//  AccountViewController.swift
//  QuickPark
//
//  Created by manar . on 01/02/2022.
//

import UIKit
import FirebaseDatabase
import Firebase
class AccountViewController: UIViewController {
    
    var userInfo = [User]()
    var userName: String = ""
    var userEmail: String = ""
    

    

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getUserInfo()

        // Do any additional setup after loading the view.
    }
    

    private func getUserInfo() {
        let ref = Database.database().reference()
        ref.child("Users/user").observeSingleEvent(of: .value) {
            (snapshot) in
            if let nameDB = snapshot.value as? Int {
                self.userName = "\(nameDB)"
            }
        }
        
        ref.child("Users").observe(DataEventType.value, with: { [self] snapshots in
            print(snapshots.childrenCount)
        
            for snapshot in snapshots.children.allObjects as! [DataSnapshot] {
                let dictionary = snapshot.value as? NSDictionary
                let user = User(userEmail: dictionary?["UserEmail"] as? String ?? "", userName: "", userPassword: "", userRePassword: "")
                userInfo.append(user)
            }
            
            
        })
    }
    @IBAction func NameTextField(_ sender: Any) {
    }
    
    @IBAction func EmailTextField(_ sender: Any) {
    }
    @IBAction func PasswordTextField(_ sender: Any) {
    }
    @IBAction func RePasswordTextField(_ sender: Any) {
    }
    @IBAction func SaveButton(_ sender: Any) {
        
    }

}
