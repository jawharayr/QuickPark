//
//  AdminEditAreaVC.swift
//  QuickPark
//
//  Created by manar . on 07/03/2022.
//

import UIKit
import CoreLocation
import MapKit
import Firebase
import FirebaseStorage
import MobileCoreServices

class AdminEditAreaVC: UIViewController {
    var thisArea : Area?
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
    @IBOutlet weak var logoImageView: UIImageView!

    @IBOutlet weak var CancelBtn: UIButton!
    
    var curSelectedArea : Area?
    var areaName: String = ""
    var spotNo: Int = 0
    var areaLat: Optional<Double> = 0.0
    var areaLong: Optional<Double> = 0.0
    var imageToUpload : UIImage? = nil
    var areaCoordinate:  CLLocationCoordinate2D? = nil
    

    var parkings = [Area]() //for checking if area name already exist:
    
   
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
        mapView.delegate = self

        
        let TapGesture = UITapGestureRecognizer(target: self, action: #selector(simpleTap))
        mapView.addGestureRecognizer(TapGesture)
        
        
        getAreaInfo()
        
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if self.curSelectedArea == nil {
            self.AreaNameTextField.text = ""
            self.SpotNoTextField.text = ""
        }else{
            
            /* self.AreaNameTextField.text = self.curSelectedArea?.areaname
             self.SpotNoTextField.text = "\(self.curSelectedArea?.spotNo ?? 0)"
             logoImageView.loadFrom(URLAddress: "\(self.curSelectedArea?.imageURL)")
             
             let locationCoord = CLLocationCoordinate2D(latitude: self.curSelectedArea?.locationLat ?? 0.0 , longitude: self.curSelectedArea?.locationLong ?? 0.0)
             addAnnotation(location: locationCoord) */
         }
        
        
        if DataManager.shared.parkingName != "" || DataManager.shared.parkingSpot != ""  {
            self.AreaNameTextField.text = DataManager.shared.parkingName
            self.SpotNoTextField.text = DataManager.shared.parkingSpot
        }else{
            getAreaInfo()
        }
        
        
        if let selectedPlaceMark = DataManager.shared.selectedPlaceMark  {
            
            self.areaCoordinate = selectedPlaceMark.coordinate
            addAnnotation(location: selectedPlaceMark.coordinate)
            
        }
        
        
        
    }
    
    
    
    func getAreaInfo() { // not displaying info in the text field
        print("entered get info fun ")
        //print(curSelectedArea)
        
        // Get Info and save it.
        let initAreaName = self.curSelectedArea?.areaname ?? ""
        let initSpotNo = "\(self.curSelectedArea?.spotNo ?? 0)" ?? "0"
        let initLogo = self.curSelectedArea?.logo ?? ""
        let initURL = URL(string: initLogo)
        let locationLar = self.curSelectedArea?.locationLat
        let locationLong = self.curSelectedArea?.locationLong
        
        
        
       // let imageData = try! Data(contents0f: initURL)
        //let image UIImage(data: imageData)!

        
        if let data = try? Data(contentsOf: initURL!)
            {
            imageToUpload = UIImage(data: data)
            }
        
      
        let locationCoord = CLLocationCoordinate2D(latitude: self.curSelectedArea?.locationLat ?? 0.0 , longitude: self.curSelectedArea?.locationLong ?? 0.0)
        
        let placeMark = MKPlacemark(coordinate: locationCoord)
        self.addAnnotation(location: locationCoord)
        //display in text fields
        self.AreaNameTextField.text = initAreaName
        self.SpotNoTextField.text = initSpotNo
        DataManager.shared.parkingName = initAreaName
        DataManager.shared.parkingSpot = initSpotNo
        DataManager.shared.selectedPlaceMark = placeMark
        
        logoImageView.loadFrom(URLAddress: initLogo)
        
        if let selectedPlaceMark = DataManager.shared.selectedPlaceMark {
            
            self.areaCoordinate = selectedPlaceMark.coordinate
            addAnnotation(location: selectedPlaceMark.coordinate)
        }
        
        
    
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
            self.lblAreaNameError.text =  "Only 3 minimum characters, numbers \"-\" and \",\" are allowed "
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
    
    @IBAction func CancelAreaButton(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
       // let vc = SBSupport.viewController(sbi: "sbi_TermsViewController", inStoryBoard: "AdminHomePage")
       // self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
    
    @IBAction func SaveAreaButton(_ sender: UIButton) {
        
        
            QPAlert(self).showAlert(title: "Are you sure you want to edit this area?", message: "The current data will be changed permenently and you won't be able to restore it", buttons: ["Cancel", "Yes"]) { _, index in
            if index == 1 {
                self.btnYesClicked()
               
            }
        }

            /*let alertController = UIAlertController(title: "Confirmation", message: "Do you really want to edit this place", preferredStyle: .alert)
            
            let yesAction = UIAlertAction(title: "Yes", style: .default) { action in
                self.btnYesClicked()
            }
            
            let noAction = UIAlertAction(title: "No", style: .destructive, handler: nil)
            
            alertController.addAction(yesAction)
            alertController.addAction(noAction)
             self.present(alertController, animated: true, completion: nil)
             */
            

        
    }
    
    
    func btnYesClicked() {

        print("SaveAreaButton is pressed")
        //print (imageToUpload)
         let sensorValue = self.curSelectedArea?.Value ?? 0
        let isAvailable = self.curSelectedArea?.isAvailable

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
                            if error == nil{
                                let object: [String : Any] = ["areaname": self.areaName as Any ,"spotNo": self.spotNo, "locationLat": self.areaLat ?? 0.0, "locationLong": self.areaLong ?? 0.0, "areaImage" : url, "Value": sensorValue, "isAvailable": isAvailable]
                                var areaKey = self.curSelectedArea?.areaKey ?? "Area_0000"
                                if self.thisArea != nil {
                                    areaKey = self.thisArea?.areaKey ?? "Area_0000"
                                }
                                self.database.child("Areas").child(areaKey).setValue(object) { error, ref in
                                    self.navigationController?.popViewController(animated: true)
                                }                   }else{
                               self.showAlert(title: "Photo upload failed", message: "photo uploading failed, please try again")
                            }
                        }
                    }else {
                        let object: [String : Any] = ["areaname": areaName as Any ,"spotNo": spotNo, "locationLat": areaLat ?? 0.0, "locationLong": areaLong ?? 0.0, "areaImage" : "", "Value": sensorValue, "isAvailable": isAvailable]
                        
                        var areaKey = self.curSelectedArea?.areaKey ?? "Area_0000"
                        if self.thisArea != nil {
                            areaKey = self.thisArea?.areaKey ?? "Area_0000"
                        }
                        database.child("Areas").child(areaKey).setValue(object) { error, ref in
                            DataManager.shared.parkingName = ""
                            DataManager.shared.parkingSpot = ""
                            self.navigationController?.popViewController(animated: true)
                        }
                    }

                }
               
            
        }
            
        
        }
        
        
    }
    
    func checkAreaNameExist(thisName : String) -> Bool {
        
        for area in self.parkings {
            //area.areaname == thisName
           
            if  area.areaname.caseInsensitiveCompare(thisName) == .orderedSame {
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
                self.lblAreaNameError.text =  "Only 3 minimum characters, numbers \"-\" and \",\" are allowed"
                if !spotNumber.isNumeric {
                    self.lblParkingSpotError.isHidden = false
                    self.lblParkingSpotError.text =  "Only digits are allowed"
                    return false
                }

                return false
            }
            
            if !spotNumber.isNumeric {
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
    
    
    @objc func simpleTap(sender: UIGestureRecognizer){ //save the user  tap on the map
        print("Simple tap")
        DataManager.shared.parkingName = self.AreaNameTextField.text ?? ""
        DataManager.shared.parkingSpot = self.SpotNoTextField.text ?? ""

        
        self.performSegue(withIdentifier: "editToBiggerMap", sender: self)
        
    }
    
    

    func addAnnotation(location: CLLocationCoordinate2D){ //Adding the user long tap to the map as annotation
        mapView.removeAnnotations(mapView.annotations)
            let annotation = MKPointAnnotation()
            annotation.coordinate = location
            self.mapView.addAnnotation(annotation)
           areaCoordinate = annotation.coordinate
        let span = MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2)
        let region = MKCoordinateRegion(center: annotation.coordinate, span: span)

        mapView.setRegion(region, animated: true)
        
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



extension AdminEditAreaVC: MKMapViewDelegate{

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


    
} //end MKMapDelegate extension


extension AdminEditAreaVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // Check for the media type
        let mediaType = info[UIImagePickerController.InfoKey.mediaType] as! CFString
        if mediaType == kUTTypeImage {
            imageToUpload = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
            // Handle your logic here, e.g. uploading file to Cloud Storage for Firebase
            // uploadFile(fileUrl: imageURL) //upload before cliking save btn
        }
        
        picker.dismiss(animated: true, completion: nil)
        // load new image
        logoImageView.image = imageToUpload
        
    }
}
//end imagePicker extension

extension UIImageView {
    func loadFrom(URLAddress: String) {
        //ImageURL(url: nil, didLoad: false)
        guard let url = URL(string: URLAddress) else {
            print("fail")
            return
        }
        
        DispatchQueue.main.async { [weak self] in
            if let imageData = try? Data(contentsOf: url) {
                if let loadedImage = UIImage(data: imageData) {
                        self?.image = loadedImage
                    print("sucs")
                }
            }
        }
    }
}

extension AdminEditAreaVC : CLLocationManagerDelegate {

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
    
