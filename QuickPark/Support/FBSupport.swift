//
//  FBSupport.swift
//  QuickPark
//
//  Created by Ghaliah Binakeel on 15/02/2022.
//

import Firebase
import UIKit
import SVProgressHUD

struct FBSupport  {
    struct Collections {
        static let profile = "Profile"
    }
}

struct FBAuth {
    static var currentUser : User? {
        return Auth.auth().currentUser
    }
    
    static var uid:String {
        get {
            if let cu = FBAuth.currentUser {
                return cu.uid
            } else {
                SceneDelegate.sceneDelegate.setUpHome()
                return ""
            }
        }
    }
    
    static func register(email:String, password:String, complition:@escaping(User?, Error?) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            guard let authResult = authResult else {
                complition(nil, error)
                return
            }
            complition(authResult.user, nil)
        }
    }
    
    static func login (email:String, password:String, complition:@escaping(User?, Error?) -> Void) {
        SVProgressHUD.show(withStatus: "Loggin in..")
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            if let  e = error {
                SVProgressHUD.showError(withStatus: e.localizedDescription)
            }else{
                SVProgressHUD.showSuccess(withStatus: "Logged in..")
                complition(authResult?.user, error)
            }
        }
    }
    
    static func logout (complition : @escaping(Bool, Error?) -> Void) {
        do {
            try Auth.auth().signOut()
            complition(true, nil)
        } catch {
            complition(false, error)
        }
    }
}

//MARK:
struct FBSUser {
    //func save
}