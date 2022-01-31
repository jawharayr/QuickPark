//
//  AddAreaViewController.swift
//  QuickPark
//
//  Created by manar . on 31/01/2022.
//

import UIKit
import CoreLocation
import MapKit


class AddAreaViewController: UIViewController {
    private var locationManager = CLLocationManager()
    
  

    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate=self
        locationManager.requestAlwaysAuthorization()
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()

        
    }
    

    
    @IBOutlet var mapPin: UIView!
    
    @IBOutlet var areaNmaeTextField: UIView!
}

extension AddAreaViewController: CLLocationManagerDelegate{
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let areaLocation = locations.last
        print (areaLocation)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
}
