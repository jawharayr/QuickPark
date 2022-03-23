//
//  TabBarVC.swift
//  QuickPark
//
//  Created by MAC on 01/07/1443 AH.
//
import UIKit

class AdminTabBarVC: UITabBarController, UITabBarControllerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.delegate = self
        
//        let appearance = UITabBarAppearance()
//        appearance.shadowColor = .white
////        appearance.stackedLayoutAppearance.normal.titlePositionAdjustment = UIOffset(horizontal: 0, vertical: 16)
////        appearance.stackedLayoutAppearance.selected.titlePositionAdjustment = UIOffset(horizontal: 0, vertical: 16)
//        tabBar.standardAppearance = appearance
        
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
        
        //Keeping code heree if we want to use custom images later
//        for (idx, vc) in viewControllers!.enumerated() {
//            vc.tabBarItem.image = UIImage(named: "tabbar_\(idx)")?.withRenderingMode(.alwaysOriginal)
//            vc.tabBarItem.selectedImage = UIImage(named: "tabbar_\(idx)_selected")?.withRenderingMode(.alwaysOriginal)
//            vc.tabBarItem.imageInsets = UIEdgeInsets(top: 6, left: 0, bottom: -6, right: 0)
//        }
        
        
        tabBar.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
    }
    
    func tabBar(tabBar: UITabBar, didSelectItem item: UITabBarItem) {
        
        print("Selected item")
    }
    
    // UITabBarControllerDelegate
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        NotificationCenter.default.post(name: Notification.Name("updateTimer"), object: 0)
        print("Selected view controller")
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
