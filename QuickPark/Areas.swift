//
//  Areas.swift
//  QuickPark
//
//  Created by Deema on 09/07/1443 AH.
//

import Foundation

struct Area {
    var areaname: String
    var loactionLat: String
    var locationLong: String
    var spotNo: String
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
