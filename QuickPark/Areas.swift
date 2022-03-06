//
//  Areas.swift
//  QuickPark
//
//  Created by Deema on 09/07/1443 AH.
//

import Foundation

struct Area {
    var areaKey: String
    var areaname: String
    var locationLat: Double
    var locationLong: Double
    var spotNo: Int
    var logo: String
    var distance: Double
    var imageURL: ImageURL = ImageURL(url: nil, didLoad: false)
}

class ImageURL{
    var url:URL?
    var didLoad:Bool
    
    init(url: URL?, didLoad: Bool){
        self.url = url
        self.didLoad = didLoad
    }
}
