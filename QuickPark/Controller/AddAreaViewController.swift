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
    
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    var activityIndicatorBG: UIView = UIView()
    var activityIndicatorlabel : UILabel = UILabel()
    
    private var locationManager = CLLocationManager()
    private let database = Database.database().reference()
    
    @IBOutlet weak var lblAreaNameError : UILabel!
    @IBOutlet weak var lblParkingSpotError : UILabel!
    @IBOutlet weak var lblEmptyCheckError : UILabel!
    
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
        
        //For shadow and cornerRadius for AreaName textfield
        AreaNameTextField.layer.masksToBounds = false
        AreaNameTextField.layer.shadowRadius = 4.0
        AreaNameTextField.layer.shadowColor = UIColor.lightGray.cgColor
        AreaNameTextField.layer.shadowOffset = CGSize(width: 1.0, height: 1.0)
        AreaNameTextField.layer.shadowOpacity = 1.0
       
        
        //For shadow and cornerRadius for SpotNo textfield
        SpotNoTextField.layer.masksToBounds = false
        SpotNoTextField.layer.shadowRadius = 4.0
        SpotNoTextField.layer.shadowColor = UIColor.lightGray.cgColor
        SpotNoTextField.layer.shadowOffset = CGSize(width: 1.0, height: 1.0)
        SpotNoTextField.layer.shadowOpacity = 1.0
       
        
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
    
    func resetLabels() {
        self.lblAreaNameError.isHidden = true
        self.lblAreaNameError.text = ""
        self.lblParkingSpotError.isHidden = true
        self.lblParkingSpotError.text = ""
        self.lblEmptyCheckError.isHidden = true
        self.lblEmptyCheckError.text = ""
        
    }
    
    
    func emptyCheck () -> Bool {
        if AreaNameTextField.text?.replacingOccurrences(of: " ", with: "") == "" {
            self.lblEmptyCheckError.isHidden = false
            self.lblEmptyCheckError.text =  "Area name should not be empty"
            return false
        }else if SpotNoTextField.text?.replacingOccurrences(of: " ", with: "") == "" {
            self.lblEmptyCheckError.isHidden = false
            self.lblEmptyCheckError.text =  "Parking spot nuumber should not be empty"
            return false
        }
        self.lblEmptyCheckError.isHidden = true
        return true
    }
    
    
    func validateFields () -> Bool { //Filling the atrribute from the user input
        
        if let areaName = self.AreaNameTextField.text, let spotNumber = self.SpotNoTextField.text {
            
            if !areaName.isString {
                self.lblAreaNameError.isHidden = false
                self.lblAreaNameError.text =  "Area name should only containg string and numbers"
                return false
            }
            if !spotNumber.isNumeric {
                self.lblParkingSpotError.isHidden = false
                self.lblParkingSpotError.text =  "Parking spot number should only contaings digits"
                return false
            }
            
        }
        
        if areaCoordinate == nil {
            self.lblEmptyCheckError.isHidden = false
            self.lblEmptyCheckError.text = "press and hold for a sec on the map to select parking location"
            return false
        }
        
        
        return true
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

extension String {
    
    var isNumeric: Bool {
        guard self.count > 0 else { return false }
        let nums: Set<Character> = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]
        return Set(self).isSubset(of: nums)
    }
    
    var isString: Bool {
        guard self.count > 0 else { return false }
        let str: Set<Character> = [" ", "0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z", "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"]
        
        return Set(self).isSubset(of: str)
    }
}
