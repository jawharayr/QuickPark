//
//  AppDelegate.swift
//  QuickPark
//
//  Created by MAC on 25/06/1443 AH.
//

import UIKit
import Braintree
import Firebase
import IQKeyboardManagerSwift

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window:UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        BTAppContextSwitcher.setReturnURLScheme("G3.QuickPark.payments")
        
        FirebaseApp.configure()
        IQKeyboardManager.shared.enable = true

          if Auth.auth().currentUser?.uid == nil{
            if  UserDefaults.standard.string(forKey: "uid") == nil{
                UserDefaults.standard.set(UtilitiesManager.sharedIntance.getRandomString(), forKey: "uid")
            }else{
                _ = UserDefaults.standard.string(forKey: "uid")!
            }
        }else{
            _ = Auth.auth().currentUser!.uid
        }
        
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

   func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
       if url.scheme?.localizedCaseInsensitiveCompare("G3.QuickPark.payments") == .orderedSame {
               return BTAppContextSwitcher.handleOpenURL(url)
           }
           return false
    }

}


