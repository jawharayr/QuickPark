//
//  My/Users/deema/Downloads/QuickPark 2/QuickPark/Base.lproj/Main.storyboardParkingsVC.swift
//  QuickPark
//
//  Created by Deema on 03/07/1443 AH.

//

import UIKit
import FirebaseDatabase
import Foundation
import FirebaseAuth
import SwiftUI

class MyParkingsVC: UIViewController {
    
    @IBOutlet weak var SegmentedControl: UISegmentedControl!
    
    //    @IBOutlet weak var viewLoader: UIView!
    //    @IBOutlet weak var lblCountDown: UILabel!
    
    
    
    
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
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Do any additional setup after loading the view.
        //        getReservations()
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
        
        getIfAnyReservation()
        
        Active.layer.cornerRadius = 20
        Active.layer.shadowOpacity = 0.1
        Active.layer.shadowOffset = .zero
        Active.layer.shadowRadius = 10
        
    }
    
    
    
    func getIfAnyReservation(){
        
        lblCountDown.textColor =  UIColor(red: 0, green: 144/255, blue: 205/255, alpha: 1)
        self.viewLoader.viewWithTag(101)?.removeFromSuperview()
        self.viewLoader.viewWithTag(102)?.removeFromSuperview()
        Active.isHidden = true
        ViewAC.isHidden = true
        EmptyLabel.isHidden = false
        reservation = nil
        pastReservations.removeAll()
        self.clearData()
        Past.reloadData()
        RESERVATIONS.child(uid).observeSingleEvent(of: .value) { dataSnap in
            if dataSnap.exists(){
                let reserDict = dataSnap.value as! [String:Any]
                for (k,_) in reserDict{
                    let res = Reservation.init(dict: reserDict[k] as! [String : Any])
                    if !res.isCompleted{
                        self.reservation = res
                        break
                    }else{
                        self.pastReservations.append(res)
                    }
                }
                self.Past.reloadData()
                if self.reservation != nil{
                    self.ViewAC.isHidden = false
                    self.EmptyLabel.isHidden = true
                    self.loadData()
                    //                    self.getStartTime()
                }else{
                    self.clearData()
                }
            }
        }
    }
    
    func loadData(){
        
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
        print("MyParkngVC", self.totalTime)
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
        let start = TimeInterval.init(reservation.StartTime)
        let end = TimeInterval.init(reservation.EndTime)
        
        
        UserDefaults.standard.set(true, forKey: "isOverTime")
        
        self.totalTime = Int(UtilitiesManager.sharedIntance.getTimerValue(start: Date.init(timeIntervalSince1970: end), endtime: Date()))
        stopTimer()
        self.viewLoader.isHidden = false
        totalTime += 1
        startTimer()
        
        
    }
    
    //    func getIfAnyReservation(){
    //        viewLoader.isHidden = true
    //        self.reservation = nil
    //        RESERVATIONS.child(uid).observe(.value) { dataSnap in
    //            if dataSnap.exists(){
    //                let reserDict = dataSnap.value as! [String:Any]
    //                for (k,_) in reserDict{
    //                    let res = Reservation.init(dict: reserDict[k] as! [String : Any])
    //                    if res.isCompleted{
    //                    }else{
    //                        self.reservation = res
    //                    }
    //                }
    //
    //                if self.reservation != nil{
    //
    //                    self.checkIfTimeIsValid()
    //                }
    //            }
    //        }
    //    }
    
    
    
    @IBAction func EndParking(_ sender: Any) {
        QPAlert(self).showAlert(title:"End Parking.", message: "Are you sure?" , buttons:  ["Yes","cancel"]) { _, index in
            if index == 0 {
                self.calculateTime()
        }
        }
    }
    
    @IBAction func Pay(_ sender: Any) {
        if let image = generateQRCode(using: "test"){
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "QRCodeVC") as! QRCodeVC
            vc.image = image
            navigationController?.pushViewController(vc, animated: true)
            
        }
        
    }
    func generateQRCode(using string:String) -> UIImage? {
            
            let data = string.data(using: String.Encoding.ascii)
            
            if let filter = CIFilter(name: "CIQRCodeGenerator"){
                filter.setValue( data, forKey: "inputMessage")
                let transform = CGAffineTransform(scaleX: 3, y: 3)
                if let output = filter.outputImage?.transformed(by: transform){
                    return UIImage(ciImage: output)
                }
            }
            return nil
            
        }
//        UtilitiesManager.sharedIntance.showAlertWithAction(self, message: "Are you sure?", title: "End Parking?", buttons: ["YES","cancel"]) { index in
//            if index == 0{
//                self.calculateTime()
//            }
//        }

    
    func calculateTime(){
        
        var extra:Double = 0.0
        var price:Double = 0.0
        var total:Double = 0.0
        var minOfPrice:Double = 0.0
        var minOfExtra:Double = 0.0
        
        var HoursofPrice=0.0
        var HoursofExtra = 0.0
        
        var isInteger = true
        
        let startTime = reservation.StartTime
        let endTime = reservation.EndTime
        
        let now = Date.init().addingMinutes(minutes: 1)
        
        
        if now.timeIntervalSince1970 > TimeInterval.init(endTime){
            
            minOfPrice = UtilitiesManager.sharedIntance.minutesInTimeIntervals(startTime: Int(TimeInterval.init(startTime)), endTime: Int(TimeInterval.init(endTime)))
            
            HoursofPrice = minOfPrice/60
            isInteger = floor(HoursofPrice) == HoursofPrice // true
            
            if (isInteger){
                price = HoursofPrice * 15
            }
            else{
                price =  ( floor(HoursofPrice) * 15 ) + 15
            }
            
            minOfExtra = UtilitiesManager.sharedIntance.minutesInTimeIntervals(startTime: Int(TimeInterval.init(endTime)), endTime: Int(now.timeIntervalSince1970))
            
            HoursofExtra = minOfExtra/60
            isInteger = floor(HoursofExtra) == HoursofExtra // true if its integer
            
            if (isInteger){
                extra = HoursofExtra * 15
            }
            else{
                extra =  ( floor(HoursofExtra) * 15 ) + 15
            }
            
            total = price + extra
        }else{
            
            minOfPrice = UtilitiesManager.sharedIntance.minutesInTimeIntervals(startTime: Int(TimeInterval.init(startTime)), endTime: Int(TimeInterval.init(endTime)))
            
            HoursofPrice = minOfPrice/60
            isInteger = floor(HoursofPrice) == HoursofPrice // true
            
            if (isInteger){
                price = HoursofPrice * 15
            }
            else{
                price =  ( floor(HoursofPrice) * 15 ) + 15
            }
            
            total = price
        }
        
        
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PayAbleViewController") as! PayAbleViewController
        vc.total = "\(total.rounded())"
        vc.extra = "\(extra.rounded())"
        vc.price = "\(price.rounded())"
        vc.modalPresentationStyle = .overFullScreen
        vc.reservation = self.reservation
        self.present(vc, animated: true, completion: nil)
    }
    
    
    
    @IBAction func ActiveAndPast(_ sender: Any) {
        if SegmentedControl.selectedSegmentIndex == 0{
            // Active
            Active.isHidden = false
            Past.isHidden = true
        }else{
            // Past
            Active.isHidden = true
            Past.isHidden = false
            EmptyLabel.isHidden = true
        }
    }
    
    
    
    func timeFormatted(_ totalSeconds: Int) -> String {
        let hour = totalSeconds / 3600
        let minute = totalSeconds / 60 % 60
        let second = totalSeconds % 60
        
        // return formated string
        return String(format: "%02i:%02i:%02i", hour, minute, second)
    }
    
    /* func removeConstraint() {
     
     removeConstraint()
     }*/
    
    
    //    @IBAction func EndParking(_ sender: Any) {
    //        if let image = generateQRCode(using: "test"){
    //            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "QRCodeVC") as! QRCodeVC
    //            vc.image = image
    //            vc.reservation = self.reservation
    //            navigationController?.pushViewController(vc, animated: true)
    //
    //
    //        }
    //    }
    
  /*  func generateQRCode(using string:String) -> UIImage? {
        
        let data = string.data(using: String.Encoding.ascii)
        
        if let filter = CIFilter(name: "CIQRCodeGenerator"){
            filter.setValue( data, forKey: "inputMessage")
            let transform = CGAffineTransform(scaleX: 3, y: 3)
            if let output = filter.outputImage?.transformed(by: transform){
                return UIImage(ciImage: output)
            }
        }
        return nil
        
    } */
    
    
    
    //    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    //        return reservations.count
    //    }
    
    //    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    //
    //
    //        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "reservationCell", for: indexPath) as! ReservationCell
    //
    //     cell.Name.text = reservation.Name
    //       cell.Date.text = reservation.Date
    //        let ds = reservations[indexPath.row]
    //        cell.StartTime.text = TimeInterval.init(ds.StartTime).dateFromTimeinterval()
    //        cell.EndTime.text = TimeInterval.init(ds.EndTime).dateFromTimeinterval()
    //        cell.area.text = ds.area
    //        cell.reservation = reservations[indexPath.row]
    //        if !ds.isCompleted{
    //            cell.checkIfTimeIsValid()
    //        }
    //        cell.mainVC = self
    //        cell.viewWidth.constant = self.view.frame.width - 40
    //        cell.viewHeight.constant = 400
    //        cell.uid = self.uid
    //     //   cell.EndTime.text = "End time: "
    ////        cell.Price.text = "Price: " + reservation.Price
    ////        cell.ExtraCharge.text = "ExtraCharge: " + reservation.ExtraCharge
    ////        cell.logo.image = UIImage(named: "King Saud University")
    //
    //
    //
    //        return cell
    //    }
    
    
    //    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
    //        let cel = cell as! ReservationCell
    //
    ////        cell.Name.text = reservation.Name
    ////        cell.Date.text = reservation.Date
    //        let ds = reservations[indexPath.row]
    //        cel.StartTime.text = TimeInterval.init(ds.StartTime).dateFromTimeinterval()
    //        cel.EndTime.text = TimeInterval.init(ds.EndTime).dateFromTimeinterval()
    //        cel.area.text = ds.area
    //        cel.reservation = reservations[indexPath.row]
    //        if !ds.isCompleted{
    //            cel.checkIfTimeIsValid()
    //        }
    //        cel.mainVC = self
    //        cel.viewWidth.constant = self.view.frame.width - 40
    //        cel.viewHeight.constant = 400
    //        cel.uid = self.uid
    //    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize.init(width: self.view.frame.width - 40, height: 387)
    }
    
    
    
    /*   private func getReservations() {
    //        ref.child("Reservations").child("UserID").observe(DataEventType.value, with: { [self] snapshots in
    //            print(snapshots.childrenCount)
    //
    //            reservations.removeAll()
    //            pastReservations.removeAll()
    //            for snapshot in snapshots.children.allObjects as! [DataSnapshot] {
    //                let dictionary = snapshot.value as? NSDictionary
    //                let reservation = Reservation(id:dictionary?["id"] as? String ?? "missing Id",Name: dictionary?["Name"] as? String ?? "", Date: dictionary?["Date"] as? String ?? "" , StartTime: dictionary?["StartTime"] as? String ?? "", EndTime: dictionary?["EndTime"] as? String ?? "", Price: dictionary?["Price"] as? String ?? "", ExtraCharge: dictionary?["ExtraCharge"] as? String ?? "", isActive: dictionary?["isActive"] as? Bool ?? false)
    //                if (reservation.isActive) {
    //                    reservations.append(reservation)
    //                }else{
    //                    pastReservations.append(reservation)
    //                }
    //
    //            }
    //
    //            if (reservations.isEmpty) {
    //                EmptyLabel.isHidden = false
    //                EndParking.isHidden = true
    //                Active.isHidden = true
    //                ActiveView.collectionView?.isHidden = true
    //            }
    //
    //            Active.reloadData()
    //            Past.reloadData()
    //        })
    //    } */
    
    @objc func methodOfReceivedNotification(notification: Notification) {
        
        getIfAnyReservation()
    }
    
    @IBOutlet weak var ActiveView: UICollectionViewFlowLayout!
}

// Past reservations
extension MyParkingsVC: UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 220
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pastReservations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "PastTableViewCell") as! PastTableViewCell
        let object = pastReservations[indexPath.row]
        cell.logo.image = UIImage(named: "King Saud University")


        cell.Name.text = object.Name
        cell.Date.text = object.Date
        cell.ExtraCharges.text = object.ExtraCharge
        cell.Price.text = object.Price
        cell.StartTime.text = TimeInterval.init(object.StartTime).dateFromTimeinterval()
        cell.EndTime.text = TimeInterval.init(object.EndTime).dateFromTimeinterval()
        
        return cell
    }
    
    
}

