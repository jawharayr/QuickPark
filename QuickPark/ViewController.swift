//
//  ViewController.swift
//  QuickPark
//
//  Created by MAC on 25/06/1443 AH.
//

import UIKit
import FirebaseDatabase
import Firebase
import FirebaseStorage
import CoreLocation
import Kingfisher
import SwiftUI
import FirebaseAuth
import grpc
import SDWebImage

class ViewController: UIViewController {
    //  let parkings = ["King Saud University" , "Imam University" , "Dallah Hospital"]
    @IBOutlet weak var searchText: UITextField!
    //
    var favouriteArray : [String]! {
        set{
            UserDefaults.standard.set(newValue, forKey: "favouriteArray")
        }get {
            return UserDefaults.standard.object(forKey: "favouriteArray") as? [String] ?? []

        }
    }
    var parkings = [Area]()
    var favParkings = [Area]()
    
    var searchedArea = [Area]()
    var searchedLogos = [Area]()
    var searchedDistance = [Area]()
    var filtered = false
    var waitingTime:Int? = 0
    
    var selectedIndex = 0
    
    var locationManager:CLLocationManager?
    var currentLocation:CLLocation?
    let storageRef = Storage.storage().reference()
    var ref:DatabaseReference!
    
    @IBOutlet var segments : UISegmentedControl!
    
    
    @IBOutlet weak var HelloLabel: UILabel!
    
    @IBOutlet weak var NoResults: UILabel!
    @IBOutlet weak var SearchTxt: UIView!
    @IBOutlet weak var ParkingView: UIView!
    @IBOutlet weak var lblCountDown: UILabel!
    @IBOutlet weak var viewLoader: UIView!
    @IBOutlet weak var ParkingsViews: UITableView!
    var searching = false
    var initialRead = true
    var totalTime = 0
    var timer: Timer?
    var uid = ""
    var reservation: Reservation!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        getName { (name) in
                    if let name = name {
        self.HelloLabel.text = "Hello, \(name)!"
                    
                    }
                }
        NoResults.isHidden = true
        searchText.addTarget(self, action: #selector(searchRecord), for: .editingChanged)
        ref = Database.database().reference()
        
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
        
        setUI()
        getIfAnyReservation()
        
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.getParkings()
        
    }
    @objc func searchRecord(sender : UITextField){
        self.searchedArea.removeAll()
        self.searchedLogos.removeAll()
        self.searchedDistance.removeAll()
        let searchedData:Int=searchText.text!.count
        if searchedData != 0 {
            searching = true
            
            for parking in parkings {
                if let parkingToSearch = searchText.text {
                    let range = parking.areaname.lowercased().range(of: parkingToSearch, options: .caseInsensitive, range: nil, locale: nil)
                    if range != nil {
                        self.searchedArea.append(parking)
                        self.searchedLogos.append(parking)
                        self.searchedDistance.append(parking)
                    }
                }
            }
        }else {
            searchedLogos = parkings
            searchedArea = parkings
            searchedDistance = parkings
            searching = false
        }
        ParkingsViews.reloadData()
       
        }
    
    
    func getName(completion: @escaping (_ name: String?) -> Void) {
            guard let uemail = Auth.auth().currentUser?.email else { // safely unwrap the uid; avoid force unwrapping with !
                
                completion(nil) // user is not logged in; return nil
                return
            }

        
            Firestore.firestore().collection("users").document(uemail).getDocument { (docSnapshot, error) in
                if let doc = docSnapshot {
                    if let name = doc.get("name") as? String {
                        completion(name) // success; return name
                    } else {
                        print("error getting field")
                        completion(nil) // error getting field; return nil
                    }
                } else {
                    if let error = error {
                        print(error)
                    }
                    completion(nil) // error getting document; return nil
                }
            }
        }
    
    
    func setUI(){
        ParkingsViews?.delegate = self
        ParkingsViews?.dataSource = self
      
        //making table view look good
        ParkingsViews?.separatorStyle = .none
        ParkingsViews?.showsVerticalScrollIndicator = false
        requestLocationPermission()
        SearchTxt.layer.cornerRadius = 20
        SearchTxt.layer.shadowOpacity = 0.1
        SearchTxt.layer.shadowOffset = .zero
        SearchTxt.layer.shadowRadius = 10
        NotificationCenter.default.addObserver(self, selector: #selector(self.methodOfReceivedNotification(notification:)), name: Notification.Name("updateTimer"), object: nil)
        //        guard UtilitiesManager.sharedIntance.retriveTimer() > 0 else{return}
        //        self.totalTime = UtilitiesManager.sharedIntance.retriveTimer()
        //        self.viewLoader.isHidden = false
        //        startTimer()
    
        
        
    }
    
    
    func getIfAnyReservation(){
        viewLoader.isHidden = true
        self.reservation = nil
        RESERVATIONS.child(uid).observeSingleEvent(of: .value, with: { dataSnap in
            if dataSnap.exists(){
                let reserDict = dataSnap.value as! [String:Any]
                for (k,_) in reserDict{
                    let res = Reservation.init(dict: reserDict[k] as! [String : Any])
                    if !res.isCompleted{
                        self.reservation = res
                        
//                        if !res.isScanned, !res.qrcode.isEmpty{
//                            print("Will track QRCode: ",res.qrcode)
//                            print("Reservation reference: ",dataSnap.ref,"\n url=",dataSnap.ref.url)
//                            self.track(qrcode: res.qrcode,ref: dataSnap.ref,resId: k)
//                        }
                        break
                    }else{
                        self.reservation = nil
                        self.stopTimer()
                    }
                }
                
                if self.reservation != nil{
                    
                    self.checkIfTimeIsValid()
                }
            }
        })
    }
    
    
    @IBAction func allAndFavourites(_ sender: UISegmentedControl) {
        let selection = sender.selectedSegmentIndex
        switch selection {
        case 0:
           
            self.SearchTxt.isHidden = false
            selectedIndex = 0
            ParkingsViews.reloadData()

            
            break
        case 1:
            
            self.SearchTxt.isHidden = true
            selectedIndex = 1
            ParkingsViews.reloadData()

            break
            
        default: break
        }
    }
    
    
    func track(qrcode code: String,ref: DatabaseReference,resId:String){
        Database.database().reference().child("QRCode").child(code).observe(.value) { dataSnap in
            if dataSnap.exists(){
                let reserDict = dataSnap.value as! [String:Any]
                if let isScanned = reserDict["isScanned"] as? Bool, isScanned{
                    ref.child(resId).updateChildValues(["isScanned":true])
                    ref.child(resId).observeSingleEvent(of: .value) { resSnap in
                        let dict = resSnap.value as? [String:Any] ?? [:]
                        print("Reservation after update: ",dict)
                        let res = Reservation.init(dict: dict)
                        self.reservation = res
                        UserDefaults.standard.set(true, forKey: "start")
                        NotificationCenter.default.post(name: Notification.Name("updateTimer"), object: 0)
                    }
                }
            }
        }
    }
    
    func checkIfTimeIsValid(){
        viewLoader.isHidden = true
        if UtilitiesManager.sharedIntance.checkIfTimeIsValidToStart(start: Date.init(timeIntervalSince1970: TimeInterval.init(reservation.StartTime)), end: Date.init(timeIntervalSince1970: TimeInterval.init(reservation.EndTime))){
            if UserDefaults.standard.bool(forKey: "start"){
                self.getStartTime()
            }else{
                self.getStartTime15()
            }
        }else if checkIfTimeOver(end: reservation.EndTime) {
            playOverTimer()
        }else {
//            setCustomExecution(date: Date.init(timeIntervalSince1970: TimeInterval.init(reservation.StartTime)))
            viewLoader.isHidden = false
            lblCountDown.text = "Wait to start"
        }
    }
    
    
    
    
    func checkIfTimeOver(end:Double)->Bool{
        let isValidTime = UtilitiesManager.sharedIntance.checkIfTimeIsValid(endTime: Date.init(timeIntervalSince1970: end))
        if isValidTime{
           return false
        }else{
            // remove data from firebase
           return true
        }
    }
    
    
    @objc func methodOfReceivedNotification(notification: Notification) {
        
       
        viewLoader.isHidden = true
        getIfAnyReservation()
        
        
    }
    
    
    func getStartTime(){
        let start = TimeInterval.init(reservation.StartTime)
        let end = TimeInterval.init(reservation.EndTime)
        
        
        let isValidTime = UtilitiesManager.sharedIntance.checkIfTimeIsValid(endTime: Date.init(timeIntervalSince1970: end))
        if isValidTime{
            self.totalTime = Int(UtilitiesManager.sharedIntance.getTimerValue(start: Date(), endtime: Date.init(timeIntervalSince1970: end)))
            self.viewLoader.isHidden = false
            stopTimer()
            startTimer()
        }else{
            
            
            
            // remove data from firebase
            UserDefaults.standard.set(false, forKey: "start")
            //UtilitiesManager.sharedIntance.showAlert(view: self, title:"Oops", message: "You are late reservation was cancelled by server.")
            
            QPAlert(self).showError(message: "You are late, reservation was cancelled by server.")
            
            RESERVATIONS.child(uid).removeValue()
            guard let areaName = UserDefaults.standard.string(forKey: "parkingArea")else{return}
            self.ref.child("Areas").child(areaName).child("isAvailable").setValue(true)
            UserDefaults.standard.removeObject(forKey: "parkingArea")
//
        }
        
        
    }
    
    
    
    func playOverTimer(){
        let start = TimeInterval.init(reservation.StartTime)
        let end = TimeInterval.init(reservation.EndTime)
        
            stopTimer()
        UserDefaults.standard.set(true, forKey: "isOverTime")
        
        self.totalTime = Int(UtilitiesManager.sharedIntance.getTimerValue(start: Date.init(timeIntervalSince1970: end), endtime: Date()))
        
            self.viewLoader.isHidden = false
            startTimer()
        
        
    }
    
    
    
    
//    func setCustomExecution(date:Date){
//        let timer = Timer(fireAt: date, interval: 0, target: self, selector: #selector(runCode), userInfo: nil, repeats: false)
//        RunLoop.main.add(timer, forMode: .common)
//
//    }
    
//    @objc func runCode(){
//        NotificationCenter.default.post(name: Notification.Name("updateTimer"), object: 0)
//    }
    
    
    func getStartTime15(){
        
        
        let start = TimeInterval.init(reservation.StartTime)
        
        let enddate = Date.init(timeIntervalSince1970: start).addingMinutes(minutes: 15)
        
        
        let end = enddate.timeIntervalSince1970
        
        
        let isValidTime = UtilitiesManager.sharedIntance.checkIfTimeIsValid(endTime: Date.init(timeIntervalSince1970: end))
        if isValidTime{
            self.totalTime = Int(UtilitiesManager.sharedIntance.getTimerValue(start: Date(), endtime: Date.init(timeIntervalSince1970: end)))
            self.viewLoader.isHidden = false
            stopTimer()
            startTimer()
        }else{
            // remove data from firebase
            UserDefaults.standard.set(false, forKey: "start")
            //UtilitiesManager.sharedIntance.showAlert(view: self, title:"Oops", message: "You are late reservation was cancelled by server.")
            QPAlert(self).showError(message: "You are late, reservation was cancelled by server.")
            RESERVATIONS.child(uid).removeValue()
        }
        
        
    }
    
    // MARK: - Timer
    
    private func startTimer() {
        self.timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
    }
    
    @objc func updateTimer() {
        print(self.totalTime)
        self.lblCountDown.text = self.timeFormatted(self.totalTime) // will show timer
        if totalTime > 0 {
            if UserDefaults.standard.bool(forKey: "isOverTime"){
                 totalTime += 1
            }else{
                totalTime -= 1
            }
              // decrease counter timer
        } else {
            
            if !UserDefaults.standard.bool(forKey: "start"){
                if let timer = self.timer {
                    timer.invalidate()
                    self.timer = nil
                    NotificationCenter.default.post(name: Notification.Name("updateTimer"), object: 0)
                }
            }else{
                UserDefaults.standard.bool(forKey: "isOverTime")
                totalTime += 1
            }
        }
    }
    func timeFormatted(_ totalSeconds: Int) -> String {
        let hour = totalSeconds / 3600
        let minute = totalSeconds / 60 % 60
        let second = totalSeconds % 60

               // return formated string
               return String(format: "%02i:%02i:%02i", hour, minute, second)
    }
    
    func stopTimer(){
        if let timer = self.timer {
            timer.invalidate()
            self.timer = nil
        }
    }
    // MARK: - TextField
    
    private func requestLocationPermission(){
        locationManager = CLLocationManager()
        locationManager?.requestAlwaysAuthorization()
        locationManager?.startUpdatingLocation()
        locationManager?.delegate = self
    }
    
    private func getParkings() {
        let ref = Database.database().reference()
        ref.child("Areas").observe(DataEventType.value, with: { [self] snapshots in
            print(snapshots.childrenCount)
            
            parkings.removeAll()
            favParkings.removeAll()
            for (i,snapshot) in (snapshots.children.allObjects as! [DataSnapshot]).enumerated() {
                let dictionary = snapshot.value as? NSDictionary
                var area = Area(areaKey : snapshot.key, areaname: dictionary?["areaname"] as? String ?? "", locationLat: dictionary?["locationLat"] as? Double ?? 0.0, locationLong: dictionary?["locationLong"] as? Double ?? 0.0, Value: dictionary?["Value"] as? Int ?? 0, isAvailable: dictionary?["isAvailable"] as? Bool ?? false, spotNo: dictionary?["spotNo"] as? Int ?? 0, logo: dictionary?["areaImage"] as? String ?? "", distance: 0.0)
                
                
                
                let location = CLLocation(latitude: Double(area.locationLat) ?? 0,
                                          longitude: Double(area.locationLong) ?? 0)
                if let currentLocation = currentLocation{
                    let distance = currentLocation.distance(from: location)//1000
                    let distanceString = Double(String(format: "%.4f", distance)) ?? 0
                    let newDistance = Double(distanceString) ?? 0
                    area.distance = newDistance
                }
                
                
                parkings.append(area)
                let thisTimeArray = self.favouriteArray ?? []
                if thisTimeArray.contains(area.areaname){
                    self.favParkings.append(area)
                }
            }
            parkings = parkings.sorted(by:{$0.distance < $1.distance })
            ParkingsViews.reloadData()
        })
    }
    
    
    @objc func btnFavClicked(_ sender : UIButton){
        print("fav button clicked")
        
        
        var favouriteArray : [String] = self.favouriteArray
        let newValue = sender.accessibilityValue ?? ""
        
        if let index = favouriteArray.firstIndex(of: newValue) {
            favouriteArray.remove(at: index)
        }else{
            favouriteArray.append(sender.accessibilityValue ?? "")
        }
        
        self.favouriteArray = favouriteArray
        self.populateFavArray()
        ParkingsViews.reloadData()
    }
    
    
    
    func populateFavArray() {
        self.favParkings = []
        for thiss in self.parkings {
            if (self.favouriteArray.firstIndex(of: thiss.areaname) != nil){
                self.favParkings.append(thiss)
            }
        }
    }
    
    @IBAction func btnGoToTimer(_ sender:Any){
        stopTimer()
        if UserDefaults.standard.bool(forKey: "start"){
            self.tabBarController?.selectedIndex = 1
        }else{
            guard let qrcodeImage = UIImage.generateQRCode(using: reservation.qrcode) else{
                print("Couldn't generate image using: ",reservation.qrcode)
                return}
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "EnterParkingVC") as! EnterParkingVC
            vc.image = qrcodeImage
            vc.qrcode = reservation.qrcode
            vc.reservation = self.reservation
            self.present(vc, animated: true, completion: nil)
        }
    }
    
}

extension ViewController: CLLocationManagerDelegate{
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last{
            currentLocation = location
            
        }
    }
    
}

extension ViewController: UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate{
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if selectedIndex == 1 {
            return self.favParkings.count
        }
        
        if searching{
            if searchedArea.count == 0 {
                NoResults.isHidden = false }
                return searchedArea.count
            } else{
                NoResults.isHidden = true
            return parkings.count
                
            }
    }
    // هذي الميثود حقت الشاشه الصغيره اللي تطلع بعد مانضغط
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if viewLoader.isHidden == false{
            //UtilitiesManager.sharedIntance.showAlert(view: self, title: "Oops", message: "You already have an reservertion.")
            QPAlert(self).showError(message: "You already have an reservertion.")
            return
        }
        
        guard let myCell = tableView.cellForRow(at: indexPath) as? CustomCell else {return}
        
        let areaRef = ref.child("Areas")
        areaRef.observe(.childAdded, with: { snapshot in
            let areaname = snapshot.childSnapshot(forPath: "areaname").value as? String ?? ""
            print("areaname", areaname)
            if myCell.Label.text == areaname {
                let isAvailable = snapshot.childSnapshot(forPath: "isAvailable").value as? Bool ?? false
                print("isAvailable", isAvailable)
                if isAvailable {
                    let Value = snapshot.childSnapshot(forPath: "Value").value as? Double ?? 0.0
                    print("Value", Value)
                    if Value == 1 {
                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                        let viewController = storyboard.instantiateViewController(withIdentifier: "ConfirmAndPay") as! ConfirmAndPay
                        viewController.parking = self.parkings[indexPath.row]
                        viewController.areaName = areaname
                        if #available(iOS 15.0, *) {
                            if let presentationController = viewController.presentationController as? UISheetPresentationController {
                                presentationController.detents = [.medium()]
                                /// change to [.medium(), .large()] for a half and full screen sheet
                            }
                        }
                        viewController.AreaLabel.text = areaname
                        self.present(viewController, animated: true)
                    } else {
                        myCell.layer.borderColor = UIColor.red.cgColor
                        myCell.Alert.text = "No Available Parkings"
                    }
                } else {
                    myCell.layer.borderColor = UIColor.red.cgColor
                    myCell.Alert.text = "No Available Parkings"
                }
            }
            
        })
        
        areaRef.observeSingleEvent(of: .value, with: { snapshot in
            print("Done")
            self.initialRead = false
        })
        
    }
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = ParkingsViews.dequeueReusableCell(withIdentifier: "CustomCell") as! CustomCell
        let parking = parkings[indexPath.row]
//        let dist = parking.distance/1000
        let dist = parking.distance
        if dist < 1000{
            let x = Double(String(Int(dist))) ?? 0
            cell.Km.text = "\(x) m"
        }else{
            let x = Double(String(format: "%.2f", dist/1000 )) ?? 0
            cell.Km.text = "\(x) km"
        }
        
        
        if self.selectedIndex == 1 {
            let searchedAreaS = favParkings[indexPath.row]
            cell.Label.text = searchedAreaS.areaname
            let dist = searchedAreaS.distance/1000
            let x = Double(String(format: "%.2f", dist )) ?? 0
            cell.Km.text = "\(x) km"
            cell.Logos.sd_setImage(with: URL(string: searchedAreaS.logo), placeholderImage:UIImage(named: "locPlaceHolder"))
            cell.btnFav.accessibilityValue = searchedAreaS.areaname
        }
        else if searching {
            let searchedAreaS = searchedArea[indexPath.row]
            cell.Label.text = searchedAreaS.areaname
            let dist = searchedAreaS.distance/1000
            let x = Double(String(format: "%.2f", dist )) ?? 0
            cell.Km.text = "\(x) km"
            cell.Logos.sd_setImage(with: URL(string: searchedAreaS.logo), placeholderImage:UIImage(named: "locPlaceHolder"))
            cell.btnFav.accessibilityValue = searchedAreaS.areaname
        
        } else {
            cell.Label.text = parking.areaname
            cell.Logos.sd_setImage(with: URL(string: parking.logo), placeholderImage:UIImage(named: "locPlaceHolder"))
            let dist = parking.distance/1000
            let x = Double(String(format: "%.2f", dist )) ?? 0
            cell.Km.text = "\(x) km"
            cell.btnFav.accessibilityValue = parking.areaname
            
        }
       
        
        cell.btnFav.tag = indexPath.row
        if self.selectedIndex == 1 {
        cell.btnFav.setImage(UIImage(systemName: "suit.heart.fill"), for: .normal)
        }else {
            if (self.favouriteArray.firstIndex(of: cell.btnFav.accessibilityValue ?? "") != nil) {
                cell.btnFav.setImage(UIImage(systemName: "suit.heart.fill"), for: .normal)
            }else {
                cell.btnFav.setImage(UIImage(systemName: "suit.heart"), for: .normal)
            }
        }
        cell.btnFav.addTarget(self, action: #selector(self.btnFavClicked), for: .touchUpInside)
        
        
    
        (parking.areaname == " ") ? (cell.Alert.text = "No Available Parkings") : (cell.Alert.text = " ")
        
       
        return cell
        
    }
    //this is to push somthing
    func addShadow(backgroundColor: UIColor = .white, cornerRadius: CGFloat = 12, shadowRadius: CGFloat = 5, shadowOpacity: Float = 0.1, shadowPathInset: (dx: CGFloat, dy: CGFloat), shadowPathOffset: (dx: CGFloat, dy: CGFloat)) {
        
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        searchText.resignFirstResponder()
        return true
    }
    
}
