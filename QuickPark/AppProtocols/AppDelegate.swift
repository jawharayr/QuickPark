//
//  AppDelegate.swift
//  QuickPark
//
//  Created by MAC on 25/06/1443 AH.
//

import UIKit
import Firebase
@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    public static var appDelegate = UIApplication.shared.delegate as? AppDelegate
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        FirebaseApp.configure()
        
        //set up home
        setUpHome()
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


}

extension AppDelegate {
     
    func setUpHome () {
        if FBAuth.currentUser != nil {
            let htb = SBSupport.viewController(sbi: "sbi_HomeTabbar", inStoryBoard: "Main")
            self.setRootViewController(htb)
        } else {
            let lvc = SBSupport.viewController(sbi: "sbi_AuthNavigationViewController", inStoryBoard: "Auth")
            self.setRootViewController(lvc)
        }
    }
    
    //to set the root view controllr on the window. This will change the base controller depending upon the user auth condition
    func setRootViewController(_ vc:UIViewController) {
        self.window?.rootViewController = vc
        self.window?.makeKeyAndVisible()
    }
}
