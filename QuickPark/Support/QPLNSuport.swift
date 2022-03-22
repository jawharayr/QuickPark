//
//  QPUserNotificationSupport.swift
//  QuickPark
//
//  Created by Ghaliah Binakeel on 08/03/2022.
//

import Foundation
import UserNotifications
import UIKit
import SwiftUI


class QPLNSupport {
    
    static func requestAuthorizarion (vc:UIViewController, complition:@escaping (Bool, String)->Void) {
        let center = UNUserNotificationCenter.current()
        
        center.getNotificationSettings { settings in
            switch settings.authorizationStatus {
            case .notDetermined:
                complition(false, "Notification permission not granted")
                center.requestAuthorization(options: [.alert, .sound]) { success, error in
                    guard success == true, error == nil else {
                        print("Permission, not granted", error?.localizedDescription ?? "Unknown!")
                        return
                    }
                }
                break
            case .denied:
                complition(false, "Notification permission not granted")
                QPAlert(vc).showAlert(title: "Notification Permission", message: "To update you with parking events, we need to send you the notification. Please go to setting and turn on the permission.", buttons: ["Cancle", "Settings"]) { controller, index in
                    if index == 1 {
                        guard let u = URL(string: UIApplication.openSettingsURLString) else {print ("No Settng URL"); return}
                        if UIApplication.shared.canOpenURL(u) {
                            UIApplication.shared.open(u, options: [:]) { success in
                                print ("User open state", success)
                            }
                        }
                    }
                }
                break
            case .authorized:
                complition(true, "")
                break
            case .provisional:
                break
            case .ephemeral:
                break
            @unknown default:
                break
            }
        }
    }
    
    static func add(_ identifier:String,
                    after:TimeInterval,
                    title:String,
                    detail:String,
                    userInfo:[String:Any]) {
        let c = UNMutableNotificationContent()
        c.title = title
        c.body = detail
        c.categoryIdentifier = "k_ParkingNotification"
        c.userInfo = userInfo
        c.sound = UNNotificationSound.defaultCritical
        
        let t = UNTimeIntervalNotificationTrigger(timeInterval: after, repeats: false)
        let ln = UNNotificationRequest(identifier: identifier, content: c, trigger: t)
        
        UNUserNotificationCenter.current().add(ln) { error in
            print("Error adding notification: ", error?.localizedDescription ?? "No Error")
        }
    }
    
    static func remove(_ identifier:String) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
    }
    
    static func removeAllDelivered() {
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
    }
}
