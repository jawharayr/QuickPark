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
    var imageToUpload : UIImage? = nil

   
   
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
        AreaNameTextField.borderStyle = UITextField.BorderStyle.roundedRect

       
        
        //For shadow and cornerRadius for SpotNo textfield
        SpotNoTextField.layer.masksToBounds = false
        SpotNoTextField.layer.shadowRadius = 4.0
        SpotNoTextField.layer.shadowColor = UIColor.lightGray.cgColor
        SpotNoTextField.layer.shadowOffset = CGSize(width: 1.0, height: 1.0)
        SpotNoTextField.layer.shadowOpacity = 1.0
        SpotNoTextField.borderStyle = UITextField.BorderStyle.roundedRect

        
        
        activityIndicatorBG = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        activityIndicatorBG.backgroundColor = UIColor.systemGray4
        activityIndicatorBG.layer.cornerRadius = 8.0
        activityIndicatorBG.layer.masksToBounds = true
        activityIndicatorBG.center = self.view.center
        self.activityIndicatorBG.isHidden = true
        
        
        activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 25, y: 16, width: 50.0, height: 50.0))
        activityIndicator.hidesWhenStopped = true
        activityIndicator.style = .large
        activityIndicatorBG.addSubview(activityIndicator)
        
        activityIndicatorlabel = UILabel(frame: CGRect(x: 2, y: 71, width: 96, height: 21))
        activityIndicatorlabel.textColor = .label
        activityIndicatorlabel.text = "Loading..."
        activityIndicatorlabel.font = UIFont(name: "Helvetica", size: 12)
        activityIndicatorlabel.textAlignment = .center
        activityIndicatorBG.addSubview(activityIndicatorlabel)
        
        self.view.addSubview(activityIndicatorBG)
       
        
    }
    
   
    
    @IBAction func SaveAreaButton(_ sender: UIButton) {
        print("SaveAreaButton is pressed")
        
        self.resetLabels()
        
        let emptyCheck = self.emptyCheck()
        
        if emptyCheck == true {
            
            let fieldsOk = self.validateFields()
            
            if fieldsOk == true {
            areaName = AreaNameTextField.text!
            spotNo = Int(SpotNoTextField.text!) ?? 0
                areaLat = areaCoordinate?.latitude ?? 0.0
                areaLong = areaCoordinate?.longitude ?? 0.0
              
               
            //image uploading should be imp inside the saveBtn fun so that the image don't get uploaded before the
            //user click on the save btn
            
            if let imageToUpload = self.imageToUpload {
                //Uplaoding image and save imageUrl into database:
                self.startActivityIndicator(withText: "Uploading Data")
                FirebaseManager.shared.uploadImageToFirebaseStorage(imageName:"\(String(describing: areaLat))_\(String(describing: areaLong))_picture", imageToUpload: imageToUpload ) { (url, error) in
                    self.stopActivityIndicator()
                    if error == nil{
                        let object: [String : Any] = ["areaname": self.areaName as Any ,"spotNo": self.spotNo, "loactionLat": "\(self.areaLat ?? 0.0)", "locationLong": "\(self.areaLong ?? 0.0)", "areaImage" : url]
                        self.database.child("Areas").child("Area_\(Int.random(in: 0..<100))" ).setValue(object) { error, ref in
                            self.navigationController?.popViewController(animated: true)
                        }                    }else{
                       self.showAlert(title: "Photo upload failed", message: "photo uploading failed, please try again")
                    }
                }
            }else { //upload area info to the database
                let object: [String : Any] = ["areaname": areaName as Any ,"spotNo": spotNo, "loactionLat": areaLat ?? 0.0, "locationLong": areaLong ?? 0.0, "areaImage" : ""]
                database.child("Areas").child("Area_\(Int.random(in: 0..<100))" ).setValue(object) { error, ref in
                    self.navigationController?.popViewController(animated: true)
                    
                }
            }
            
        }
            
        
        }
        
        
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
            self.lblEmptyCheckError.text =  "Please fill all the fields"
            return false
        }else if SpotNoTextField.text?.replacingOccurrences(of: " ", with: "") == "" {
            self.lblEmptyCheckError.isHidden = false
            self.lblEmptyCheckError.text =  "Please fill all the fields"
            return false
        }
        self.lblEmptyCheckError.isHidden = true
        return true
    }
    
    
    func validateFields () -> Bool { //Filling the atrribute from the user input
        
        if let areaName = self.AreaNameTextField.text, let spotNumber = self.SpotNoTextField.text {
            
            if !areaName.isString {
                self.lblAreaNameError.isHidden = false
                self.lblAreaNameError.text =  "Area name should only contain string and numbers"
                return false
            }
            if !spotNumber.isNumeric {
                self.lblParkingSpotError.isHidden = false
                self.lblParkingSpotError.text =  "Parking spot number should only contain digits"
                return false
            }
            
        }
        
        if areaCoordinate == nil {
            self.lblEmptyCheckError.isHidden = false
            self.lblEmptyCheckError.text = "Long tap on the map to select the location"
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
    
    
    func startActivityIndicator(withText message : String? = "") {
        DispatchQueue.main.async {
            self.activityIndicatorBG.isHidden = false
            self.activityIndicatorlabel.text = message
            self.activityIndicator.startAnimating()
        }
        
    }
    
    func stopActivityIndicator() {
        DispatchQueue.main.async {
            self.activityIndicatorBG.isHidden = true
            self.activityIndicator.stopAnimating()
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
            imageToUpload = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
            // Handle your logic here, e.g. uploading file to Cloud Storage for Firebase
            // uploadFile(fileUrl: imageURL) //upload before cliking save btn
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
        let str: Set<Character> = [" ", "0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "-", ",", "a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z", "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"]
        
        return Set(self).isSubset(of: str)
    }
}

extension UIViewController {
    
    
    func showAlert(title: String, message: String) // Error alert for uploading images
    {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(defaultAction)
        present(alertController, animated: true, completion: nil)
    }
    
    
    
    func showErrorAlert()
    {
        let alertController = UIAlertController(title: "Sorry", message: "Something went wrong, please try again", preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(defaultAction)
        present(alertController, animated: true, completion: nil)
    }
    
    func showConfirmationAlert()
    {
        let alertController = UIAlertController(title: "Confirm submition", message: "The area has been added", preferredStyle: .alert)
        alertController.addAction(.init(title: "Ok", style: .cancel, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
    
}
