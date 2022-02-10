//
//  AddAreaViewController.swift
//  QuickPark
//
//  Created by manar . on 31/01/2022.


import UIKit
import CoreLocation
import MapKit
import Firebase
import FirebaseStorage


class AddAreaViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    private var locationManager = CLLocationManager()
    private let database = Database.database().reference()
    private let storage = Storage.storage().reference()
    @IBOutlet weak var AreaNameTextField: UITextField!
    @IBOutlet weak var SpotNoTextField: UITextField!
    @IBOutlet weak var mapView: MKMapView!
    var areaCoordinate:  CLLocationCoordinate2D? = nil
    var areaName:String = ""
    var imagePickerController = UIImagePickerController()
   
    
  

    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        imagePickerController.delegate = self
        let longTapGesture = UILongPressGestureRecognizer(target: self, action: #selector(longTap))
        mapView.addGestureRecognizer(longTapGesture)
        
    }
    
   
    
    @IBAction func SaveAreaButton(_ sender: UIButton) {
        print("SaveAreaButton is pressed")
        let areaName = AreaNameTextField.text
        let spotNo = SpotNoTextField.text
        let areaLat = areaCoordinate?.latitude
        let areaLong = areaCoordinate?.longitude
       
        if areaName == "" || spotNo == ""
        { print("empty fields")
            
            
        }
        
        let object: [String : Any] = ["areaname": areaName! as Any ,"spotNo": spotNo, "loactionLat": areaLat, "locationLong": areaLong]
        database.child("Areas").child("Area_\(Int.random(in: 0..<100))" ).setValue(object)
     
        
        
    }
    
    @IBAction func chooseImageButton() {
        print("Add image button was pressed")
        
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.allowsEditing = true
        present(imagePickerController, animated: true)
     
    }
    
    
    
    
    @objc func longTap(sender: UIGestureRecognizer){
        print("long tap")
        if sender.state == .began {
            let locationInView = sender.location(in: mapView)
            let locationOnMap = mapView.convert(locationInView, toCoordinateFrom: mapView)
            addAnnotation(location: locationOnMap)
        }
    }

    func addAnnotation(location: CLLocationCoordinate2D){
        mapView.removeAnnotations(mapView.annotations)
            let annotation = MKPointAnnotation()
            annotation.coordinate = location
            self.mapView.addAnnotation(annotation)
           areaCoordinate = annotation.coordinate
        
        
    }
    
    
    
}




extension AddAreaViewController: MKMapViewDelegate{

func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
    guard annotation is MKPointAnnotation else { print("no mkpointannotaions"); return nil }
    
    let reuseId = "pin"
    var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
    
    if pinView == nil {
        pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
        pinView!.canShowCallout = true
        pinView!.rightCalloutAccessoryView = UIButton(type: .infoDark)
        pinView!.pinTintColor = UIColor.blue
    }
    else {
        pinView!.annotation = annotation
    }
    return pinView
}

func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
    if control == view.rightCalloutAccessoryView {
        if let doSomething = view.annotation?.title! {
           print("do something")
        }
    }
}
} //end MKMapDelegate extension

