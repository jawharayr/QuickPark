//
//  FBSupport.swift
//  QuickPark
//
//  Created by Ghaliah Binakeel on 15/02/2022.
//

import Firebase

struct FBAuth {
    static var currentUser : User? {
        return Auth.auth().currentUser
    }
    
    static var uid:String {
        get {
            if let cu = FBAuth.currentUser {
                return cu.uid
            } else {
                AppDelegate.appDelegate?.setUpHome()
                return ""
            }
        }
    }
}
