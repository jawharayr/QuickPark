//
//  Area.swift
//  QuickPark
//
//  Created by manar . on 12/02/2022.
//

import Foundation


struct Area {
    var areaname: String
    var loactionLat: String
    var locationLong: String
    var spotNo: String
    var logo: String
}

class ImageURL{
    var url:URL?
    var didLoad:Bool
    
    init(url: URL?, didLoad: Bool){
        self.url = url
        self.didLoad = didLoad
    }
}
