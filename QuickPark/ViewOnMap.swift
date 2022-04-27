//
//  ViewOnMap.swift
//  QuickPark
//
//  Created by MAC on 22/09/1443 AH.
//

import Foundation
import UIKit
import MapKit
import Firebase
import FirebaseFirestore
import FirebaseAuth
import FirebaseFirestore


class ViewOnMap: UIViewController{
    
    @IBOutlet weak var MapKit: MKMapView!
    
    
    var areas = [Area]()
    var uid = ""
    var reservation:Reservation!

    override func viewDidLoad() {
        super.viewDidLoad()
        MapKit.delegate = self
    getlocation()
        if Auth.auth().currentUser?.uid == nil{
            if  UserDefaults.standard.string(forKey: "uid") == nil{
                uid = UtilitiesManager.sharedIntance.getRandomString()
                UserDefaults.standard.set(uid, forKey: "uid")
            }else{
                uid = UserDefaults.standard.string(forKey: "uid")!
            }
        }else{
            uid = Auth.auth().currentUser!.uid
        }
    }
    @IBAction func WhenCrossClicked(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
        let FirstViewController = ViewController()
        present(FirstViewController, animated: true, completion: nil)
    }
    public func getlocation() {
        self.areas.removeAll()
    let ref = Database.database().reference()
  ref.child("Areas").observe(DataEventType.value, with: { [self] snapshots in
        for snapshot in snapshots.children.allObjects as! [DataSnapshot] {
            let dictionary = snapshot.value as? NSDictionary
            let area = Area(areaKey : snapshot.key, areaname: dictionary?["areaname"] as? String ?? "", locationLat: dictionary?["locationLat"] as? Double ?? 0.0, locationLong: dictionary?["locationLong"] as? Double ?? 0.0, Value: dictionary?["Value"] as? Int ?? 0, isAvailable: dictionary?["isAvailable"] as? Bool ?? false, spotNo: dictionary?["spotNo"] as? Int ?? 0, logo: dictionary?["areaImage"] as? String ?? "", distance: 0.0)
            self.areas.append(area)
      let locationLat:CLLocationDegrees = area.locationLat
      let locationLong:CLLocationDegrees = area.locationLong
       
            let annotation = MKPointAnnotation()
            annotation.coordinate = CLLocationCoordinate2D(latitude: locationLat, longitude: locationLong)
            annotation.title = area.areaname
            MapKit.addAnnotation(annotation)
            let region = MKCoordinateRegion(center: annotation.coordinate, latitudinalMeters: 500, longitudinalMeters: 500)
            MapKit.setRegion(region, animated: true)
         
            
        } }
                             
                            ) }
    
                             
                             }

            
extension ViewOnMap: MKMapViewDelegate{
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView?{
    guard !(annotation is MKUserLocation) else {
        return nil
    }
        var annotationView = MapKit.dequeueReusableAnnotationView(withIdentifier:"custom")
        if annotationView == nil {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "custom")
            annotationView?.canShowCallout = true
        }else {
            annotationView?.annotation = annotation
        }
        annotationView?.image = UIImage(named: "pin (2)")
        return annotationView
    }
    func CheckIfHasReservation(completionHandler:@escaping (_ result : Bool)-> Void){
        let db = Firestore.firestore()
        db.collection("users").document(uid).getDocument { snapshot, err in
            let snapdata = snapshot?.data() as? [String:Any]
            let hasReservation = snapdata?["hasReservation"] as? Bool ?? false
            completionHandler (hasReservation)
            
        }
    }
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        CheckIfHasReservation { result in
            if result == true {
                QPAlert(self).showError(message: "You already have a reservation.")
            }else {
                
        let ref = Database.database().reference()
        let areaRef = ref.child("Areas")
        areaRef.observe(.childAdded, with: { [self] snapshot in
            let areaname = snapshot.childSnapshot(forPath: "areaname").value as? String ?? ""
            print("areaname", areaname)
            if view.annotation?.title == areaname {
                let isAvailable = snapshot.childSnapshot(forPath: "isAvailable").value as? Bool ?? false
                print("isAvailable", isAvailable)
                if isAvailable {
                    let Value = snapshot.childSnapshot(forPath: "Value").value as? Double ?? 0.0
                    print("Value", Value)
                    if Value == 1 {
                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                        let viewController = storyboard.instantiateViewController(withIdentifier: "ConfirmAndPay") as! ConfirmAndPay
                        viewController.areaName = areaname
                        viewController.parking = areas[getAreaByname(name: areaname)!]

                        if #available(iOS 15.0, *) {
                            if let presentationController = viewController.presentationController as? UISheetPresentationController {
                                presentationController.detents = [.medium()]
                                /// change to [.medium(), .large()] for a half and full screen sheet
                            }
                        }
                        viewController.AreaLabel.text = areaname
                        self.present(viewController, animated: true)
                        
                        
                    } else {
                        QPAlert(self).showError(message: "No Available parkings.")

                    }
                } else {
                    QPAlert(self).showError(message: "No Available parkings.")
                }
            }
            
        })
            }
        }

    }
    
    func getAreaByname(name: String) -> Int? {
      return areas.firstIndex { $0.areaname == name }
    }
    
}
