//
//
//  Created by Deema on 03/07/1443 AH.

//

import UIKit
import FirebaseDatabase
import Foundation
import FirebaseFirestore
import FirebaseAuth
import SwiftUI
import SDWebImage

class MyParkingsVC: UIViewController {
    @IBOutlet weak var SegmentedControl: UISegmentedControl!
    @IBOutlet weak var EQRCode: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    var totalTime = 0
    var uid = ""
    var pastReservations = [Reservation]()
    var ref:DatabaseReference!
    var reservation:Reservation!
    var timer:Timer!
    @IBOutlet weak var StartTime: UILabel!
    @IBOutlet weak var EndTime: UILabel!
    @IBOutlet weak var area: UILabel!
    @IBOutlet weak var btnEnd: UIButton!
    @IBOutlet weak var lblCountDown: UILabel!
    @IBOutlet weak var viewLoader: UIView!
    @IBOutlet weak var ViewAC: UIView!
    @IBOutlet weak var EmptyLabel: UILabel!
    @IBOutlet weak var Active: UIView!
    @IBOutlet weak var Past: UITableView!
    @IBOutlet weak var PastLabel: UILabel!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getIfAnyReservation()
        
        Past.backgroundColor = UIColor("#F5F5F5")
        self.PastLabel.isHidden = true
        if pastReservations.isEmpty && SegmentedControl.selectedSegmentIndex == 1 {
            PastLabel.isHidden = false
        }
        
        if UserDefaults.standard.bool(forKey: "start") {//The reservation is active
            SegmentedControl.selectedSegmentIndex = 0
            ActiveAndPast(SegmentedControl)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        clearData()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.methodOfReceivedNotification(notification:)), name: Notification.Name("updateTimer"), object: nil)
        
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
        
        Past.delegate = self
        Past.dataSource = self
        Active.layer.cornerRadius = 20
        Active.layer.shadowOpacity = 0.1
        Active.layer.shadowOffset = .zero
        Active.layer.shadowRadius = 10
        if pastReservations.isEmpty && SegmentedControl.selectedSegmentIndex == 1 {
            PastLabel.isHidden = false }
    }
    
    // cancel resrvation by the user SPRINT #3
    @IBAction func cancelResrevation(_ sender: Any) {
        let reservationID = UserDefaults.standard.object(forKey: "reservationId") as! String
        QPAlert(self).showAlert(title: "Are you sure you want to cancel your resrevation?", message: nil, buttons: ["Cancel", "Yes"]) { [self] _, index in
            if index == 1 {
                self.finishCancelling()
            }
        }
        
    }
    
    func track(qrcode code: String){
        Database.database().reference().child("QRCode").child(code).observe(.value) { dataSnap in
            if dataSnap.exists(){
                guard let reserDict = dataSnap.value as? [String:Any] else{return}
                //  print("Iterating on QRCode dictionary: ",reserDict)
                if let isScanned = reserDict["isScanned"] as? Bool{
                    self.EQRCode.isHidden = isScanned
                    self.cancelButton.isHidden = isScanned
                }
            }
        }
    }
    
    func getIfAnyReservation() {
        lblCountDown.textColor =  UIColor(red: 0, green: 144/255, blue: 205/255, alpha: 1)
        self.viewLoader.viewWithTag(101)?.removeFromSuperview()
        self.viewLoader.viewWithTag(102)?.removeFromSuperview()
        Active.isHidden = true
        ViewAC.isHidden = true
        EmptyLabel.isHidden = false
        reservation = nil
        self.clearData()
        Past.reloadData()
        
        RESERVATIONS.child(uid).observeSingleEvent(of: .value) { [self] dataSnap in
            
            if dataSnap.exists(){
                self.pastReservations.removeAll()
                
                let reserDict = dataSnap.value as! [String:Any]
                print("All Keys = ", reserDict.keys)
                for k in reserDict.keys{
                    print ("Key = ", k)
                    let res = Reservation.init(dict: reserDict[k] as! [String : Any])
                    if !res.isCompleted {
                        self.reservation = res
                        if !res.qrcode.isEmpty{
                            self.track(qrcode: res.qrcode)
                        }
                    }else{
                        self.pastReservations.append(res)
                    }
                }
                self.pastReservations = self.pastReservations.sorted(by:{$1.StartTime < $0.StartTime })
                self.PastLabel.isHidden = (self.pastReservations.count > 0)
                self.Past.reloadData()
                
                //Active reservation Stuff
                if self.reservation != nil {
                    self.ViewAC.isHidden = false
                    self.EmptyLabel.isHidden = true
                    self.loadData()
                }else{
                    self.clearData()
                }
            }
        }
    }
    
    func finishCancelling(){
            
            RESERVATIONS.child(self.uid).child(reservation.id).child("ExtraCharge").setValue(reservation.ExtraCharge) { err, data in
                if err == nil{
                    RESERVATIONS.child(self.uid).child(self.reservation.id).child("isCancelled").setValue(true) { err, data in
                        if err == nil{
                            RESERVATIONS.child(self.uid).child(self.reservation.id).child("isCompleted").setValue(true)
                            guard let areaName = UserDefaults.standard.string(forKey: "parkingArea")else{return}
                            self.ref.child("Areas").child(areaName).child("isAvailable").setValue(true) { err, data in
                                if err == nil{
                                    let database = Firestore.firestore()
                                    database.collection("users").document(self.uid).setData( ["hasReservation": false], merge: true)
                                    UserDefaults.standard.set(false, forKey: "start")
                                    UserDefaults.standard.removeObject(forKey: "parkingArea")
                                    NotificationCenter.default.post(name: Notification.Name("updateTimer"), object: 0)
                                }
                            }
                            
                        }
                    }
                }
                
            }
            
        }
    
    func loadData() {
        if timer != nil{
            timer.invalidate()
        }
        EmptyLabel.isHidden = true
        StartTime.isHidden = false
        EndTime.isHidden = false
        area.isHidden = false
        viewLoader.isHidden = false
        btnEnd.isHidden = false
        EmptyLabel.isHidden = false
        StartTime.text = TimeInterval.init(reservation.StartTime).dateFromTimeinterval()
        EndTime.text = TimeInterval.init(reservation.EndTime).dateFromTimeinterval()
        area.text = reservation.area
        print("Will set area name= ",reservation.area)
        if !reservation.isCompleted{
            checkIfTimeIsValid()
        }
    }
    
    func clearData(){
        StartTime.isHidden = true
        EndTime.isHidden = true
        area.isHidden = true
        viewLoader.isHidden = true
        viewLoader.viewWithTag(101)?.removeFromSuperview()
        btnEnd.isHidden = true
        EmptyLabel.isHidden = false
        if timer != nil{
            timer.invalidate()
            timer = nil
        }
    }
    
    private func startTimer() {
        startActivityAnimating(padding: 0, isFromOnView: false, view: self.viewLoader,width: self.viewLoader.frame.width,height: self.viewLoader.frame.height)
        self.timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
    }
    
    @objc func updateTimer() {
        print(self.totalTime)
        self.lblCountDown.text = timeFormatted(self.totalTime) // will show timer
        if totalTime > 0 {
            
            if UserDefaults.standard.bool(forKey: "isOverTime"){
                totalTime += 1
                lblCountDown.textColor = UIColor.red
                self.viewLoader.viewWithTag(101)?.removeFromSuperview()
                self.viewLoader.viewWithTag(102)?.removeFromSuperview()
                startActivityAnimatingRed(padding: 0, isFromOnView: false, view: self.viewLoader,width: self.viewLoader.frame.width,height: self.viewLoader.frame.height)
            }else{
                
                totalTime -= 1
                if totalTime < 600{
                    lblCountDown.textColor = UIColor.red
                    self.viewLoader.viewWithTag(101)?.removeFromSuperview()
                    self.viewLoader.viewWithTag(102)?.removeFromSuperview()
                    startActivityAnimatingRed(padding: 0, isFromOnView: false, view: self.viewLoader,width: self.viewLoader.frame.width,height: self.viewLoader.frame.height)
                }
            }
            
        }else{
            
            playOverTimer()
        }
    }
    
    
    func checkIfTimeIsValid(){
        if UtilitiesManager.sharedIntance.checkIfTimeIsValidToStart(start: Date.init(timeIntervalSince1970: TimeInterval.init(reservation.StartTime)), end: Date.init(timeIntervalSince1970: TimeInterval.init(reservation.EndTime))){
            if UserDefaults.standard.bool(forKey: "start"){
                self.getStartTime()
                self.btnEnd.isUserInteractionEnabled = true
            }else{
                lblCountDown.text = "Wait to start"
                self.btnEnd.isUserInteractionEnabled = false
            }
        }else if checkIfTimeOver(end: reservation.EndTime){
            playOverTimer()
        }else{
            self.btnEnd.isUserInteractionEnabled = false
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
    
    func stopTimer(){
        if let timer = self.timer {
            timer.invalidate()
            self.timer = nil
        }
    }
    
    func getStartTime(){
        let start = TimeInterval.init(reservation.StartTime)
        let end = TimeInterval.init(reservation.EndTime)
        let isValidTime = UtilitiesManager.sharedIntance.checkIfTimeIsValid(endTime: Date.init(timeIntervalSince1970: end))
        if isValidTime{
            self.totalTime = Int(UtilitiesManager.sharedIntance.getTimerValue(start: Date(), endtime: Date.init(timeIntervalSince1970: end)))
            startTimer()
        }else{
            totalTime = 0
        }
    }
    
    
    func playOverTimer(){
        let end = TimeInterval.init(reservation.EndTime)
        UserDefaults.standard.set(true, forKey: "isOverTime")
        
        self.totalTime = Int(UtilitiesManager.sharedIntance.getTimerValue(start: Date.init(timeIntervalSince1970: end), endtime: Date()))
        stopTimer()
        self.viewLoader.isHidden = false
        totalTime += 1
        startTimer()
    }
    
    @IBAction func EndParking(_ sender: Any) {
        QPAlert(self).showAlert(title:"End Parking", message: "Are you sure?" , buttons:  ["Yes","cancel"]) { _, index in
            if index == 0 {
                self.showPaymentDetails()
            }
        }
        
    }
    
    
    @IBAction func EntryQRCode(_ sender: Any) {
        guard let qrcodeImage = UIImage.generateQRCode(using: reservation.qrcode) else{
            print("Couldn't generate image using: ",reservation.qrcode)
            return}
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "EnterParkingVC") as! EnterParkingVC
        vc.image = qrcodeImage
        vc.qrcode = reservation.qrcode
        vc.reservation = self.reservation
        self.present(vc, animated: true, completion: nil)
    }
    
    @IBAction func Pay(_ sender: Any) {
        let x = String(Int.random(in: 1000...6000))
        if let image = UIImage.generateQRCode(using: x){
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "QRCodeVC") as! QRCodeVC
            vc.image = image
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func showPaymentDetails() {
//        let result = ParkingManager.shared.calculateTime(reservation: reservation)
//        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PayAbleViewController") as! PayAbleViewController
//        vc.total = "\(result.0.rounded())"
//        vc.extra = "\(result.1.rounded())"
//        vc.price = "\(result.2.rounded())"
//        vc.modalPresentationStyle = .overFullScreen
//        vc.reservation = self.reservation
//        self.present(vc, animated: true, completion: nil)
        ParkingManager.shared.presentPayableView(on: self, reservation: reservation)
    }
    
    @IBAction func ActiveAndPast(_ sender: UISegmentedControl) {
        let selection = sender.selectedSegmentIndex
        switch selection {
        case 0:
            PastLabel.isHidden = true
            Active.isHidden = false
            Past.isHidden = true
        case 1:
            Past.isHidden = false
            if pastReservations.isEmpty {
                PastLabel.isHidden = false
            }
        default: break
        }
    }
    
    func timeFormatted(_ totalSeconds: Int) -> String {
        let hour = totalSeconds / 3600
        let minute = totalSeconds / 60 % 60
        let second = totalSeconds % 60
        return String(format: "%02i:%02i:%02i", hour, minute, second)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize.init(width: self.view.frame.width - 40, height: 387)
    }
    
    @objc func methodOfReceivedNotification(notification: Notification) {
        getIfAnyReservation()
    }
    
    @IBOutlet weak var ActiveView: UICollectionViewFlowLayout!
}

// Past reservations
extension MyParkingsVC: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        Past.backgroundColor = UIColor("#F5F5F5")
        return 60
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 147
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pastReservations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PastTableViewCell") as! PastTableViewCell
        let object = pastReservations[indexPath.row]
        cell.Logo.sd_setImage(with: URL(string: object.logo), placeholderImage:UIImage(named: "locPlaceHolder"))
        cell.Name.text = object.area
        cell.Price.text = object.Price
        cell.StartTime.text = TimeInterval.init(object.StartTime).dateFromTimeinterval()
        cell.layer.cornerRadius = 20;
        cell.layer.masksToBounds = true;
        
        if object.isCancelled{
                   cell.PastView.backgroundColor = UIColor.white
                   cell.PastView.layer.borderColor = UIColor.white.cgColor
                   cell.BackView.backgroundColor = UIColor.white
                   cell.Price.text = "0.0"
                   cell.Price.textColor = .black
               }else{
                   cell.PastView.backgroundColor = UIColor.white
                   cell.PastView.layer.borderColor = UIColor.white.cgColor
                   cell.BackView.backgroundColor = UIColor.white
                   cell.Price.text = object.Price
                   cell.Price.textColor = .black
                   
               }
        
        let ref = Database.database().reference()
        ref.child("Areas").observe(DataEventType.value, with: { [self] snapshots in
            print(snapshots.childrenCount)
            
            for (i, snapshot) in (snapshots.children.allObjects as! [DataSnapshot]).enumerated() {
                let dictionary = snapshot.value as? NSDictionary
                let area = Area(
                    areaKey : snapshot.key, areaname: dictionary?["areaname"] as? String ?? "",
                    locationLat: dictionary?["locationLat"] as? Double ?? 0.0,
                    locationLong: dictionary?["locationLong"] as? Double ?? 0.0,
                    Value: dictionary?["Value"] as? Int ?? 0,
                    isAvailable: dictionary?["isAvailable"] as? Bool ?? false,
                    spotNo: dictionary?["spotNo"] as? Int ?? 0,
                    logo: dictionary?["areaImage"] as? String ?? "", distance: 0.0)
                
                if cell.Name.text == area.areaname {
                    cell.Logo.sd_setImage(with: URL(string: area.logo), placeholderImage:UIImage(named: "locPlaceHolder"))
                }
            }
        })
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "ReservationDetailsVC") as? ReservationDetailsVC
        let obj = self.pastReservations[indexPath.row]
        if obj.isCancelled{
                   vc?.areaname = obj.area
                   vc?.date = obj.Date
                  vc?.Stime = obj.StartTime
                  vc?.Etime = obj.EndTime
                  vc?.price = "0.0"
                  vc?.extra = "0.0"
               }else{
                   vc?.areaname = obj.area
                   vc?.date = obj.Date
                  vc?.Stime = obj.StartTime
                  vc?.Etime = obj.EndTime
                  vc?.price = obj.Price
                  vc?.extra = obj.ExtraCharge
               }
        let ref = Database.database().reference()
        ref.child("Areas").observe(DataEventType.value, with: { [self] snapshots in
            print(snapshots.childrenCount)
            
            for (i,snapshot) in (snapshots.children.allObjects as! [DataSnapshot]).enumerated() {
                let dictionary = snapshot.value as? NSDictionary
                let area = Area(
                    areaKey : snapshot.key,
                    areaname: dictionary?["areaname"] as? String ?? "",
                    locationLat: dictionary?["locationLat"] as? Double ?? 0.0,
                    locationLong: dictionary?["locationLong"] as? Double ?? 0.0, Value: dictionary?["Value"] as? Int ?? 0,
                    isAvailable: dictionary?["isAvailable"] as? Bool ?? false,
                    spotNo: dictionary?["spotNo"] as? Int ?? 0,
                    logo: dictionary?["areaImage"] as? String ?? "",
                    distance: 0.0)
                
                if vc?.areaname == area.areaname {
                    vc?.Logo.sd_setImage(with: URL(string: area.logo), placeholderImage:UIImage(named: "locPlaceHolder"))
                }
            }
        })
        
        navigationController?.pushViewController(vc!, animated: true)
    }
    
    func addShadow(backgroundColor: UIColor = .white, cornerRadius: CGFloat = 12, shadowRadius: CGFloat = 5, shadowOpacity: Float = 0.1, shadowPathInset: (dx: CGFloat, dy: CGFloat), shadowPathOffset: (dx: CGFloat, dy: CGFloat)) {
        
    } }

extension UIColor {
    convenience init(_ hex: String, alpha: CGFloat = 1.0) {
        var cString = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        if cString.hasPrefix("#") {
            cString.removeFirst()
        }
        
        if cString.count != 6 {
            self.init("F5F5F5")
            return
        }
        
        var rgbValue: UInt64 = 0
        Scanner(string: cString).scanHexInt64(&rgbValue)
        
        self.init(red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
                  green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
                  blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
                  alpha: alpha)
    }
    
}
