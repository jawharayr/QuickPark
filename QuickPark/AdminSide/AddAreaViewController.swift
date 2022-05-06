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

protocol HandlePlaceMark {
    func thisIsThePlacemark(placemark:MKPlacemark)
}

class AddAreaViewController: UIViewController {
    var thisArea : Area?
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    var activityIndicatorBG: UIView = UIView()
    var activityIndicatorlabel : UILabel = UILabel()
    
    private var locationManager = CLLocationManager()
    private let database = Database.database().reference()
    
    @IBOutlet weak var lblAreaNameError : UILabel!
    @IBOutlet weak var lblParkingSpotError : UILabel!
    @IBOutlet weak var lblEmptyCheckError : UILabel!
    @IBOutlet weak var lblLogoIsPicked: UILabel!
    
    @IBOutlet weak var AreaNameTextField: UITextField!
    @IBOutlet weak var SpotNoTextField: UITextField!
    @IBOutlet weak var mapView: MKMapView!
    var areaCoordinate:  CLLocationCoordinate2D? = nil
    @IBOutlet weak var CancelBtn: UIButton!
    
    
    var areaName: String = ""
    var spotNo: Int = 0
    var areaLat: Optional<Double> = 0.0
    var areaLong: Optional<Double> = 0.0
    var imageToUpload : UIImage? = nil
    var sensorValue: Int = 0
    var isAvailable: Bool = false

    var parkings = [Area]() //for checking if area name already exist:
        

    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
        
        mapView.delegate = self

        //let longTapGesture = UILongPressGestureRecognizer(target: self, action: #selector(longTap))
        //mapView.addGestureRecognizer(longTapGesture)
        
        let TapGesture = UITapGestureRecognizer(target: self, action: #selector(simpleTap))
        mapView.addGestureRecognizer(TapGesture)
        
       
        
        
        
        //For shadow and cornerRadius for AreaName textfield
        AreaNameTextField.layer.masksToBounds = false
        AreaNameTextField.layer.shadowRadius = 4.0
        AreaNameTextField.layer.shadowColor = UIColor.lightGray.cgColor
        AreaNameTextField.layer.shadowOffset = CGSize(width: 1.0, height: 1.0)
        AreaNameTextField.layer.shadowOpacity = 1.0
        AreaNameTextField.borderStyle = UITextField.BorderStyle.roundedRect

        AreaNameTextField.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: .editingChanged)

        
       
        
        //For shadow and cornerRadius for SpotNo textfield
        SpotNoTextField.layer.masksToBounds = false
        SpotNoTextField.layer.shadowRadius = 4.0
        SpotNoTextField.layer.shadowColor = UIColor.lightGray.cgColor
        SpotNoTextField.layer.shadowOffset = CGSize(width: 1.0, height: 1.0)
        SpotNoTextField.layer.shadowOpacity = 1.0
        SpotNoTextField.borderStyle = UITextField.BorderStyle.roundedRect

        SpotNoTextField.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: .editingChanged)

        
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
    
    
    
    @objc func textFieldDidChange(_ sender : UITextField){
        if sender == self.AreaNameTextField {
            print("AreaNameTextField")
            self.checkAreaName(sender.text ?? "")
            
        }else if sender == SpotNoTextField {
            print("SpotNoTextField")
            self.checkSpotNumber(sender.text ?? "")

        }
    }
    
    func checkAreaName(_ value : String){
    
        if (value == ""){
            self.lblAreaNameError.isHidden = true
            self.lblAreaNameError.text =  ""
        }else{
            
        if !value.isString {
            self.lblAreaNameError.isHidden = false
            self.lblAreaNameError.text =  "Only 3 minimum characters, numbers \"-\" and \",\" are allowed"
        }else{
            self.lblAreaNameError.isHidden = true
            self.lblAreaNameError.text =  ""
        }
        
        }
    }
    
    func checkSpotNumber(_ value : String){
        
        if (value == ""){
            self.lblParkingSpotError.isHidden = true
            self.lblParkingSpotError.text =  ""
        }else{
            
        if !value.isNumeric {
            self.lblParkingSpotError.isHidden = false
            self.lblParkingSpotError.text =  "Only digits are allowed"
        }else{
            self.lblParkingSpotError.isHidden = true
            self.lblParkingSpotError.text =  ""
        }
            
        }
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if self.thisArea == nil {
            self.AreaNameTextField.text = ""
            self.SpotNoTextField.text = ""
        }else{
            self.AreaNameTextField.text = self.thisArea?.areaname
            self.SpotNoTextField.text = "\(self.thisArea?.spotNo ?? 0)"
            let locationCoord = CLLocationCoordinate2D(latitude: self.thisArea?.locationLat ?? 0.0 , longitude: self.thisArea?.locationLong ?? 0.0)
            addAnnotation(location: locationCoord)
        }
        
        
        if let selectedPlaceMark = DataManager.shared.selectedPlaceMark {
            
            self.areaCoordinate = selectedPlaceMark.coordinate
            addAnnotation(location: selectedPlaceMark.coordinate)
        }
        
        self.AreaNameTextField.text = DataManager.shared.parkingName
        self.SpotNoTextField.text = DataManager.shared.parkingSpot
        
    }
    
    
    @IBAction func CancelAreaButton(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
       // let vc = SBSupport.viewController(sbi: "sbi_TermsViewController", inStoryBoard: "AdminHomePage")
       // self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func SaveAreaButton(_ sender: UIButton) {
        print("SaveAreaButton is pressed")
        print (imageToUpload)
        
        self.resetLabels()
        
        let emptyCheck = self.emptyCheck()
        
        if emptyCheck == true {
            
            let fieldsOk = self.validateFields()
            
            if fieldsOk == true {
            areaName = AreaNameTextField.text!
            spotNo = Int(SpotNoTextField.text!) ?? 0
            areaLat = areaCoordinate?.latitude ?? 0.0
            areaLong = areaCoordinate?.longitude ?? 0.0
              
                let isAreaNameExist = self.checkAreaNameExist(thisName: areaName)
                if isAreaNameExist == true {
                    self.lblEmptyCheckError.isHidden = false
                    self.lblEmptyCheckError.text =  "This area does exist. Enter a new name plaese"
                }else{
                    //image uploading should be imp inside the saveBtn fun so that the image don't get uploaded before the
                    //user click on the save btn
                    self.lblEmptyCheckError.isHidden = true
                    if let imageToUpload = self.imageToUpload {
                        //Uplaoding image and save imageUrl into database:
                        self.startActivityIndicator(withText: "Uploading Data")
                        

                        FirebaseManager.shared.uploadImageToFirebaseStorage(imageName:"\(String(describing: areaLat))_\(String(describing: areaLong))_picture", imageToUpload: imageToUpload ) { (url, error) in
                            self.stopActivityIndicator()
                            //self.showConfirmationAlert() dont transfer to homepage

                            if error == nil{
                                let object: [String : Any] = ["areaname": self.areaName as Any ,"spotNo": self.spotNo, "locationLat": self.areaLat ?? 0.0, "locationLong": self.areaLong ?? 0.0, "areaImage" : url, "Value": self.sensorValue, "isAvailable": self.isAvailable]
                                
                                var areaKey = "Area_\(Int.random(in: 0..<100))"
                                if self.thisArea != nil {
                                    areaKey = self.thisArea?.areaKey ?? "Area_0000"
                                }
                                self.database.child("Areas").child(areaKey).setValue(object) { error, ref in
                                    self.showConfirmationAlert()
                                }     }else{
                               self.showAlert(title: "Photo upload failed", message: "photo uploading failed, please try again")
                            }
                        }
                     

                    }else {
                        let object: [String : Any] = ["areaname": areaName as Any ,"spotNo": spotNo, "locationLat": areaLat ?? 0.0, "locationLong": areaLong ?? 0.0, "areaImage" : "", "Value": sensorValue, "isAvailable": isAvailable]
                        
                        var areaKey = "Area_\(Int.random(in: 0..<100))"
                        if self.thisArea != nil {
                            areaKey = self.thisArea?.areaKey ?? "Area_0000"
                        }
                        database.child("Areas").child(areaKey).setValue(object) { error, ref in
                            
                            self.showConfirmationAlert()
                        }
                    }

                }
               
            
        }
            
        
        }
        
    }
    
    func checkAreaNameExist(thisName : String) -> Bool {
        
        for area in self.parkings {
            if area.areaname == thisName {
                return true
            }
        }
        
        return false
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
                self.AreaNameTextField.shake()
                self.lblAreaNameError.text =  "Only 3 minimum characters, numbers \"-\" and \",\" are allowed"
                //should have alphabets and min 3 characters
                if !spotNumber.isNumeric {
                    self.lblParkingSpotError.isHidden = false
                    self.SpotNoTextField.shake()
                    self.lblParkingSpotError.text =  "Only digits are allowed"
                    return false
                }

                return false
            }
            
            if !spotNumber.isNumeric {
                self.SpotNoTextField.shake()
                self.lblParkingSpotError.isHidden = false
                self.lblParkingSpotError.text =  "Only digits are allowed"
                return false
            }
                        
        }
        
        if areaCoordinate == nil {
            self.lblEmptyCheckError.isHidden = false
            self.lblEmptyCheckError.text = "Tap on the map to select the location"
            return false
        }
        
        if imageToUpload == nil {
            self.lblEmptyCheckError.isHidden = false
            self.lblEmptyCheckError.text = "Choose an image"
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
    
    
  
    
   /* @objc func longTap(sender: UIGestureRecognizer){ //save the user long tap on the map
        print("long tap")
        if sender.state == .began {
            let locationInView = sender.location(in: mapView)
            let locationOnMap = mapView.convert(locationInView, toCoordinateFrom: mapView)
            addAnnotation(location: locationOnMap)
        }
    } */
    
    @objc func simpleTap(sender: UIGestureRecognizer){ //save the user  tap on the map
        print("Simple tap")
        DataManager.shared.parkingName = self.AreaNameTextField.text ?? ""
        DataManager.shared.parkingSpot = self.SpotNoTextField.text ?? ""

        
        self.performSegue(withIdentifier: "mapToBiggerMap", sender: self)
        
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

    // message on the map pin "!"
/*func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
    if control == view.rightCalloutAccessoryView {
        if let doSomething = view.annotation?.title! {
           print("do something")
        }
    }
} */
    
} //end MKMapDelegate extension



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
        self.lblLogoIsPicked.isHidden = false
        self.lblLogoIsPicked.text = "Image has been chosen"
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
        guard self.count > 2 else { return false }
        let str: Set<Character> = [" ", "0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "-", ",", "a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z", "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"]
        
        return Set(self).isSubset(of: str)
    }
    var isPString: Bool {
        guard self.count > 2 else { return false }
        let str: Set<Character> = [" ", "0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z", "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"]
        
        return Set(self).isSubset(of: str)
    }
}

extension UIViewController {
    
    
    func showAlert(title: String, message: String) // Error alert for uploading images
    {
        QPAlert(self).showAlert(title: title, message:message, onOK: nil)
//        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
//        let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
//        alertController.addAction(defaultAction)
//        present(alertController, animated: true, completion: nil)
    }
    
    
    
    func showErrorAlert()
    {
        QPAlert(self).showAlert(title: "Sorry", message: "Something went wrong, please try again", onOK: nil)
        
        
    }
    
    func showConfirmationAlert()
    {
        QPAlert(self).showAlert(title: "Area Added Successfully", message: "The area has been added to the areas' list") {
            self.navigationController?.popViewController(animated: true)
        }
  
    }
    
}


extension AddAreaViewController : CLLocationManagerDelegate {

        func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
             print("error:: \(error.localizedDescription)")
        }

        func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
            if status == .authorizedWhenInUse {
                locationManager.requestLocation()
            }
        }

        func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {

            if locations.first != nil {
                print("location:: \(locations.first)")
            }

        }

    }



