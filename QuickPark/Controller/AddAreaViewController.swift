//
//  AddAreaViewController.swift
//  QuickPark
//
//  Created by manar . on 31/01/2022.


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
    
    @IBOutlet weak var AreaNameTextField: UITextField!
    
    @IBOutlet weak var SpotNoTextField: UITextField!
    
    @IBAction func SaveAreaButton(_ sender: UIButton) {
        print("SaveAreaButton is pressed")
        
    }
    
    @IBOutlet var Map: MKMapView!
    
    
    
    
}

extension AddAreaViewController: CLLocationManagerDelegate{
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let areaLocation = locations.last
        print (areaLocation)
        
        let centerLocation = CLLocationCoordinate2D (latitude: (areaLocation?.coordinate.latitude)! , longitude: (areaLocation?.coordinate.longitude)!)
        let region = MKCoordinateRegion(center: centerLocation, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        
        Map.setRegion(region, animated: true)
        Map.showsUserLocation = true
        
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
}
