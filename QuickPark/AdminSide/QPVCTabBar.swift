//
//  TabBarVC.swift
//  QuickPark
//
//  Created by MAC on 01/07/1443 AH.
//
import UIKit

class QPVCTabBar: UITabBarController, UITabBarControllerDelegate {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.delegate = self
        QPLNSupport.requestAuthorizarion(vc: self) { success, message in
            print(success, message)
        }
        
        let bgView = UIView()
        bgView.backgroundColor = .white
        bgView.layer.cornerRadius = 32
        bgView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        bgView.translatesAutoresizingMaskIntoConstraints = false
        tabBar.insertSubview(bgView, at: 0)
        bgView.topAnchor.constraint(equalTo: tabBar.topAnchor).isActive = true
        bgView.leftAnchor.constraint(equalTo: tabBar.leftAnchor).isActive = true
        bgView.bottomAnchor.constraint(equalTo: tabBar.bottomAnchor).isActive = true
        bgView.rightAnchor.constraint(equalTo: tabBar.rightAnchor).isActive = true
        bgView.layer.shadowRadius = 8
        bgView.layer.shadowOffset = CGSize(width: 3, height: 3)
        bgView.layer.shadowOpacity = 0.5
        
        tabBar.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.methodOfReceivedNotification(notification:)), name: Notification.Name("newMessage"), object: nil)
    }
    
    @objc func methodOfReceivedNotification(notification: Notification) {
        if let vcs = self.viewControllers {
            vcs.last?.tabBarItem.badgeValue = " "
        }
    }
    
    func tabBar(tabBar: UITabBar, didSelectItem item: UITabBarItem) {
        print("Selected item")
        if let vcs = self.viewControllers, self.selectedIndex ==  vcs.count {
            item.badgeValue = nil
        }
    }
    
    // UITabBarControllerDelegate
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        NotificationCenter.default.post(name: Notification.Name("updateTimer"), object: 0)
        print("Selected view controller")
        if let vcs = self.viewControllers {
            vcs.last?.tabBarItem.badgeValue = nil 
        }
    }
}


/*
 // MARK: - Navigation
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
 // Get the new view controller using segue.destination.
 // Pass the selected object to the new view controller.
 }
 */
