//
//  DataManager.swift
//  QuickPark
//
//  Created by manar . on 13/03/2022.
//

import Foundation
import CoreLocation
import MapKit


class DataManager {
    
    var selectedPlaceMark : MKPlacemark?
    var parkingName = ""
    var parkingSpot = ""
    
    
    static let shared = DataManager()
    fileprivate init(){}
    
    
}
