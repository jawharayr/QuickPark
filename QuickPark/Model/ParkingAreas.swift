//
//  ParkingAreas.swift
//  QuickPark
//
//  Created by manar . on 01/02/2022.
//

import Foundation

class ParkingAreas {
    static let shared = ParkingAreas()
    var landmarks: [Landmark] = [] 
    
    private init() {}
}
