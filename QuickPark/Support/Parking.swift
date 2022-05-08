//
//  Parking.swift
//  QuickPark
//
//  Created by Ghaliah on 08/05/22.
//

import Foundation

struct UDKeys {
    static let K_Parking_End_Time = "K_Parking_End_Time"
}

class ParkingAfterPaymentManager {
    static let shared = ParkingAfterPaymentManager()
    
    var lastPaymentTime : TimeInterval? {
        set (v) {
            UserDefaults.standard.set(v, forKey: UDKeys.K_Parking_End_Time)
        }
        get {
            return UserDefaults.standard.value(forKey: UDKeys.K_Parking_End_Time)
        }
    }
    
}
