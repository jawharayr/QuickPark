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
import MobileCoreServices


class AddAreaViewController: UIViewController {
    private var locationManager = CLLocationManager()
    private let database = Database.database().reference()
    
    @IBOutlet weak var AreaNameTextField: UITextField!
    @IBOutlet weak var SpotNoTextField: UITextField!
    @IBOutlet weak var mapView: MKMapView!
    var areaCoordinate:  CLLocationCoordinate2D? = nil
    
    var areaName: String = ""
    var spotNo: Int = 0
    var areaLat: Optional<Double> = 0.0
    var areaLong: Optional<Double> = 0.0
   
   
    
  

    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
         
        let longTapGesture = UILongPressGestureRecognizer(target: self, action: #selector(longTap))
        mapView.addGestureRecognizer(longTapGesture)
        
    }
    
   
    
    @IBAction func SaveAreaButton(_ sender: UIButton) {
        print("SaveAreaButton is pressed")
        fillFields()
        if areaName == "" || spotNo == 0
            
        { print("empty fields")
            
            
        }
        
        let object: [String : Any] = ["areaname": areaName as Any ,"spotNo": spotNo, "loactionLat": areaLat, "locationLong": areaLong]
        database.child("Areas").child("Area_\(Int.random(in: 0..<100))" ).setValue(object)
     
        
        
    }
    
    func fillFields () { //Filling the atrribute from the user input
        areaName = AreaNameTextField.text!
        spotNo = Int(SpotNoTextField.text!) ?? 0
        areaLat = areaCoordinate?.latitude
        areaLong = areaCoordinate?.longitude
    }
    
    func validateFields () { //Filling the atrribute from the user input
        
    }
    
    @IBAction func chooseImageButton() {
        print("Add image button was pressed")
        
        // Must import `MobileCoreServices`
            let imageMediaType = kUTTypeImage as String
            // Define and present the `UIImagePickerController`
            let pickerController = UIImagePickerController()
            pickerController.sourceType = .photoLibrary
            pickerController.mediaTypes = [imageMediaType]
            pickerController.delegate = self
            present(pickerController, animated: true, completion: nil)

    }
    
    
    
    
    @objc func longTap(sender: UIGestureRecognizer){ //save the user long tap on the map
        print("long tap")
        if sender.state == .began {
            let locationInView = sender.location(in: mapView)
            let locationOnMap = mapView.convert(locationInView, toCoordinateFrom: mapView)
            addAnnotation(location: locationOnMap)
        }
    }

    func addAnnotation(location: CLLocationCoordinate2D){ //Adding the user long tap to the map as annotation
        mapView.removeAnnotations(mapView.annotations)
            let annotation = MKPointAnnotation()
            annotation.coordinate = location
            self.mapView.addAnnotation(annotation)
           areaCoordinate = annotation.coordinate
        
    }
    
    
    
    
    func uploadFile(fileUrl: URL) { //uploading images to firebase storage
      do {
        // Create file name
        let metaData = StorageMetadata()
        let fileExtension = fileUrl.pathExtension
          fillFields()
        let fileName = ("AreasImages/"+areaName+".\(fileExtension)")

        let storageReference = Storage.storage().reference().child(fileName)
          
        let currentUploadTask = storageReference.putFile(from: fileUrl, metadata: metaData) { (storageMetaData,error) in
          if let error = error {
            print("Upload error: \(error.localizedDescription)")
            return
          }
                                                                                    
          // Show UIAlertController here
          print("Image file: \(fileName) is uploaded! View it at Firebase console!")
                                                                                    
          storageReference.downloadURL { (url, error) in
            if let error = error  {
              print("Error on getting download url: \(error.localizedDescription)")
              return
            }
            print("Download url of \(fileName) is \(url!.absoluteString)")
          }
        }
      } catch {
        print("Error on extracting data from url: \(error.localizedDescription)")
      }
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

//imp the ImagePickerController
extension AddAreaViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
    // Check for the media type
    let mediaType = info[UIImagePickerController.InfoKey.mediaType] as! CFString
    if mediaType == kUTTypeImage {
      let imageURL = info[UIImagePickerController.InfoKey.imageURL] as! URL
      // Handle your logic here, e.g. uploading file to Cloud Storage for Firebase
        uploadFile(fileUrl: imageURL)
    }

    picker.dismiss(animated: true, completion: nil)
  }
}
//end imagePicker extension
