//
//  FBSupport.swift
//  QuickPark
//
//  Created by Ghaliah Binakeel on 15/02/2022.
//

import Firebase
import UIKit
import SVProgressHUD

struct QPUser : Codable {
    let name : String
    let email : String
    let uid : String
}


struct KServerValues {
    static let admin = QPUser(name: "Support Team", email: "qpadminpro@gmail.com", uid: "LK9udFovdVMiANGTTy45JqF7DDT2")
}

struct FBSupport  {
    struct Collections {
        static let profile = "Profile"
    }
}

struct FBAuth {
    static var currentUser : User? {
        return Auth.auth().currentUser
    }
    
    static var isAdmin : Bool {
        if let user = FBAuth.currentUser {
            if user.email == KServerValues.admin.email {
                return true
            }
        }
        return false
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
    
    static func resetPasword(email:String, complition: @escaping( Error?) -> Void) {
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            complition(error)
        }
    }
    
}

//MARK:
struct FBSUser {
    static var admin : ChatUser {
        get {
            return ChatUser(senderId: "LK9udFovdVMiANGTTy45JqF7DDT2", displayName: "Support Team")
        }
    }
    
    static var currrentUser : User {
        return Auth.auth().currentUser!
    }
}
