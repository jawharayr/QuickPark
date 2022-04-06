//
//  Reservations.swift
//  QuickPark
//
//  Created by Deema on 07/07/1443 AH.
//

import Foundation
import UIKit

struct Reservation {
    
    var id:String
    var Name: String
    var Date: String
    var StartTime: Double
    var EndTime: Double
    var Price: String
    var ExtraCharge: String
    var isActive: Bool
    var area:String
    var userName:String
    var isCompleted:Bool
    var qrcode:String
    var isScanned:Bool = false
    var logo: String
    var imageURL: ImageURL = ImageURL(url: nil, didLoad: false)

    class ImageURL{
        var url:URL?
        var didLoad:Bool
        
        init(url: URL?, didLoad: Bool){
            self.url = url
            self.didLoad = didLoad
        }
}
    
    init(dict:[String:Any]) {
        self.id = dict["id"] as? String ?? ""
        self.Name = dict["Name"] as? String ?? ""
        self.Date = dict["Date"] as? String ?? ""
        self.StartTime = dict["StartTime"] as? Double ?? 0.0
        self.EndTime = dict["EndTime"] as? Double ?? 0.0
        self.Price = dict["Price"] as? String ?? ""
        self.ExtraCharge = dict["ExtraCharge"] as? String ?? ""
        self.isActive = dict["isActive"] as? Bool ?? false
        self.area = dict["area"] as? String ?? ""
        self.isCompleted = dict["isCompleted"] as? Bool ?? false
        self.userName = dict["userName"] as? String ?? ""
        self.qrcode = dict["qrcode"] as? String ?? ""
        self.isScanned = dict["isScanned"] as? Bool ?? false
        self.logo = dict["areaImage"] as? String ?? ""
    
    }
    

}
