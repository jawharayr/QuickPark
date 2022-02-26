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

class ViewController: UIViewController, UITextFieldDelegate {
    //  let parkings = ["King Saud University" , "Imam University" , "Dallah Hospital"]
    
    
    
    
    //
    var parkings = [Area]()
    var searchedArea = [Area]()
    var filtered = false
    var waitingTime:Int? = 0
    
    
    var locationManager:CLLocationManager?
    var currentLocation:CLLocation?
    let storageRef = Storage.storage().reference()
    var ref:DatabaseReference!
    
    @IBOutlet weak var SearchTxt: UITextField!
    @IBOutlet weak var ParkingView: UIView!
    @IBOutlet weak var lblCountDown: UILabel!
    @IBOutlet weak var viewLoader: UIView!
    @IBOutlet weak var ParkingsViews: UITableView!
    var initialRead = true
    var totalTime = 0
    var timer: Timer?
    var uid = ""
    var reservation: Reservation!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
    
    
    
    func setUI(){
        ParkingsViews?.delegate = self
        ParkingsViews?.dataSource = self
        SearchTxt.delegate = self
        
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
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let text = SearchTxt.text{
            filterText(query: text+string)
            
        }
        return true
    }
    func filterText( query:String){
        searchedArea.removeAll()
        for str in parkings {
            if str.areaname.lowercased().starts(with: query.lowercased()){
                searchedArea.append(str)
            }
        }
        ParkingsViews.reloadData()
        filtered = true
        
    }
    
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
            for (i,snapshot) in (snapshots.children.allObjects as! [DataSnapshot]).enumerated() {
                let dictionary = snapshot.value as? NSDictionary
                var area = Area(areaname: dictionary?["areaname"] as? String ?? "",
                                loactionLat: "\(dictionary?["loactionLat"] as? Double ?? 0)",
                                locationLong: "\(dictionary?["locationLong"] as? Double ?? 0)",
                                spotNo: "", logo: dictionary?["areaImage"] as? String ?? "" ,distance: 0)
                
                
                
                let location = CLLocation(latitude: Double(area.loactionLat) ?? 0,
                                          longitude: Double(area.locationLong) ?? 0)
                if let currentLocation = currentLocation{
                    let distance = currentLocation.distance(from: location)/1000
                    let distanceString = Double(String(format: "%.2f", distance)) ?? 0
                    let newDistance = Double(distanceString) ?? 0
                    area.distance = newDistance
                }
                
                parkings.append(area)
            }
            parkings = parkings.sorted(by:{$0.distance < $1.distance })
            ParkingsViews.reloadData()
        })
    }
    
    @IBAction func btnGoToTimer(_ sender:Any){
        stopTimer()
        if UserDefaults.standard.bool(forKey: "start"){
            self.tabBarController?.selectedIndex = 1
        }else{
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "EnterParkingVC") as! EnterParkingVC
            vc.reservation = self.reservation
            self.present(vc, animated: true, completion: nil)
        }
        
        //NotificationCenter.default.post(name: Notification.Name("timr"), object: self.totalTime)
       
        
    }
    
}

extension ViewController: CLLocationManagerDelegate{
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last{
            currentLocation = location
            self.getParkings()
        }
    }
    
}

extension ViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if !searchedArea.isEmpty{
            return searchedArea.count
            
        }
        
        return filtered ? 0 : parkings.count
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
        let dist = parking.distance/1000
        let x = Double(String(format: "%.2f", dist )) ?? 0
        cell.Km.text = "\(x) km"
        
        cell.Logos.sd_setImage(with: URL(string: parking.logo), placeholderImage:UIImage(named: "locPlaceHolder"))

        if searchedArea.count > 0 && indexPath.row < searchedArea.count {
            let searchedAreaS = searchedArea[indexPath.row]
            cell.Label.text = searchedAreaS.areaname
        } else {
            cell.Label.text = parking.areaname
        }
    /*
        if !parking.imageURL.didLoad{
            let child = storageRef.child("AreasImages/\(parking.areaname).png")
            child.downloadURL { url, error in
                print("Did fetch \("AreasImages/\(parking.areaname).png") url: ",url, ", with error: ",error?.localizedDescription)
                self.parkings[indexPath.row].imageURL = ImageURL(url: url, didLoad: true)
                tableView.reloadRows(at: [indexPath], with: .automatic)
            }
        }else{
            cell.Logos.kf.setImage(with: parking.imageURL.url, placeholder: nil)
            //
        }*/
        
        
        //            cell.Logos.kf.setImage(with: parking.imageURL, placeholder: UIImage(named: "King Saud University"))
        
        //cell.ParkingView.layer.cornerRadius = 20 //cell.ParkingView.frame.height / 2
        //cell.Logos.layer.cornerRadius = 20 //cell.Logos.frame.height / 2
        // let borderColor: UIColor =  (parkings[indexPath.row] == " ") ? .red : UIColor(red: 0/225, green: 144/255, blue: 205/255, alpha: 1) //
        (parking.areaname == " ") ? (cell.Alert.text = "No Available Parkings") : (cell.Alert.text = " ")
        
       
        return cell
        
    }
    func addShadow(backgroundColor: UIColor = .white, cornerRadius: CGFloat = 12, shadowRadius: CGFloat = 5, shadowOpacity: Float = 0.1, shadowPathInset: (dx: CGFloat, dy: CGFloat), shadowPathOffset: (dx: CGFloat, dy: CGFloat)) {
        
    }
    
    
}
