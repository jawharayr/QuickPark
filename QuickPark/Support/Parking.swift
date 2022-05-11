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

struct NotificationNames {
    static let K_QRCodeExpired = Notification.Name(rawValue: "K_QRCodeExpired")
}

class ParkingManager {
    static let shared = ParkingManager()
    
    var lastPaymentTime : TimeInterval? {
        set (v) {
            UserDefaults.standard.set(v, forKey: UDKeys.K_Parking_End_Time)
        }
        get {
            return UserDefaults.standard.value(forKey: UDKeys.K_Parking_End_Time) as! TimeInterval
        }
    }
    
    var paymentMadeWithoutExit : Bool {
        return (self.lastPaymentTime != nil)
    }

    func calculateTime(reservation: Reservation) -> (Double, Double, Double) {
        var extra:Double = 0.0
        var price:Double = 0.0
        var total:Double = 0.0
        var minOfPrice:Double = 0.0
        var minOfExtra:Double = 0.0
        var HoursofPrice=0.0
        var HoursofExtra = 0.0
        var isInteger = true
        let startTime = reservation.StartTime
        let endTime = reservation.EndTime
        
        let now = Date.init().addingMinutes(minutes: 1)
        if now.timeIntervalSince1970 > TimeInterval.init(endTime) {
            minOfPrice = UtilitiesManager.sharedIntance.minutesInTimeIntervals(startTime: Int(TimeInterval.init(startTime)), endTime: Int(TimeInterval.init(endTime)))
            
            HoursofPrice = minOfPrice/60
            isInteger = floor(HoursofPrice) == HoursofPrice // true
            
            if (isInteger){
                price = HoursofPrice * 15
            }
            else{
                price =  ( floor(HoursofPrice) * 15 ) + 15
            }
            
            minOfExtra = UtilitiesManager.sharedIntance.minutesInTimeIntervals(startTime: Int(TimeInterval.init(endTime)), endTime: Int(now.timeIntervalSince1970))
            
            HoursofExtra = minOfExtra/60
            isInteger = floor(HoursofExtra) == HoursofExtra // true if its integer
            
            if (isInteger){
                extra = HoursofExtra * 15
            }
            else{
                extra =  ( floor(HoursofExtra) * 15 ) + 15
            }
            
            total = price + extra
        }else{
            
            minOfPrice = UtilitiesManager.sharedIntance.minutesInTimeIntervals(startTime: Int(TimeInterval.init(startTime)), endTime: Int(TimeInterval.init(endTime)))
            
            HoursofPrice = minOfPrice/60
            isInteger = floor(HoursofPrice) == HoursofPrice // true
            
            if (isInteger){
                price = HoursofPrice * 15
            }
            else{
                price =  ( floor(HoursofPrice) * 15 ) + 15
            }
            
            total = price
        }
        
        return (total, extra, price)
    }
}

