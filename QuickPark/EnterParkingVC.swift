//
//  EnterParkingVC.swift
//  QuickPark
//
//  Created by Macbook Pro on 19/02/2022.
//

import UIKit
import FirebaseDatabase

let K_NotificationEndParkingBefore : TimeInterval = 1830//600 sec not, should be 600

class EnterParkingVC: UIViewController {
    
    
    @IBOutlet weak var imgQR : UIImageView!
    @IBOutlet weak var lblCountDown : UILabel!
    @IBOutlet weak var viewLoader: UIView!
    
    @IBOutlet weak var EntryQR: UIImageView!
    var qrcodeDidScan:(()->())?
    
    var timer: Timer?
    var totalTime = 900
    var endTimer = ""
    var waitingTime:Int? = 0
    var reservation:Reservation!
    var image: UIImage?
    var qrcode:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imgQR.image = image
        if let qrcode = qrcode, !qrcode.isEmpty{
            track(qrcode: qrcode)
        }


        // Do any additional setup after loading the view.
        colour = UIColor(red: 0, green: 144/255, blue: 205/255, alpha: 1)
        startActivityAnimating(padding: 2, isFromOnView: false, view: self.viewLoader,width: 100,height: 100)
        checkIfTimeIsValid()
    }
    
    func track(qrcode code: String){
        Database.database().reference().child("QRCode").child(code).observe(.value) { dataSnap in
            if dataSnap.exists(){
                guard let reserDict = dataSnap.value as? [String:Any] else{return}
              //  print("Iterating on QRCode dictionary: ",reserDict)
                if let isScanned = reserDict["isScanned"] as? Bool, isScanned{
                    UserDefaults.standard.set(true, forKey: "start")
                    NotificationCenter.default.post(name: Notification.Name("updateTimer"), object: 0)
                    self.dismiss(animated: false, completion: nil)
                    self.qrcodeDidScan?()
                    
                    //Addded end parking notification. This function will also remove the end parking notification
                    self.addEndOFParkingNotification()
                }
            }
        }
//        Database.database().reference().child("QRCode").child(code).observeSingleEvent(of: .value, with: )
    }
    
    
    func checkIfTimeIsValid(){
        if UtilitiesManager.sharedIntance.checkIfTimeIsValidToStart(start: Date.init(timeIntervalSince1970: TimeInterval.init(reservation.StartTime)), end: Date.init(timeIntervalSince1970: TimeInterval.init(reservation.EndTime))){
            if UserDefaults.standard.bool(forKey: "start"){
//                self.getStartTime()
            }else{
                self.getStartTime15()
            }
           
        }else{
            setCustomExecution(date: Date.init(timeIntervalSince1970: TimeInterval.init(reservation.StartTime)))
            viewLoader.isHidden = false
            lblCountDown.text = "Wait to start"
        }
    }
    
    func setCustomExecution(date:Date){
        let timer = Timer(fireAt: date, interval: 0, target: self, selector: #selector(runCode), userInfo: nil, repeats: false)
        RunLoop.main.add(timer, forMode: .common)

    }
    
    @objc func runCode(){
        checkIfTimeIsValid()
        NotificationCenter.default.post(name: Notification.Name("updateTimer"), object: 0)
    }
    
 
    func getStartTime15(){
        let start = TimeInterval.init(reservation.StartTime)
        
        let enddate = Date.init(timeIntervalSince1970: start).addingMinutes(minutes: 15)
        let end = enddate.timeIntervalSince1970
        
        
        let isValidTime = UtilitiesManager.sharedIntance.checkIfTimeIsValid(endTime: Date.init(timeIntervalSince1970: end))
        if isValidTime{
            self.totalTime = Int(UtilitiesManager.sharedIntance.getTimerValue(start: Date(), endtime: Date.init(timeIntervalSince1970: end)))
            self.viewLoader.isHidden = false
            startTimer()
        }else{
            UserDefaults.standard.set(false, forKey: "start")
            
            NotificationCenter.default.post(name: Notification.Name("updateTimer"), object: 0)
            self.view.window!.rootViewController?.dismiss(animated: false, completion: nil)
        }
    }
    
    // MARK: - QRScan
    //Dummy_code to completing the flow it will replace with QR scan
    func QRScan(){
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            // your code here
            if let timer = self.timer {
                timer.invalidate()
                self.timer = nil
            }
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "CountdownParkingVC") as! CountdownParkingVC
            vc.endTimer = self.endTimer
            self.present(vc, animated: true, completion: nil)
        }
    }
 
    
    
    @IBAction func btnSkip(_ sender:Any){
        
//        UserDefaults.standard.set(true, forKey: "start")
//
//        NotificationCenter.default.post(name: Notification.Name("updateTimer"), object: 0)
        self.view.window!.rootViewController?.dismiss(animated: false, completion: nil)
    }
    
    func cancelParkingReservatinNotification() {
        QPLNSupport.remove(reservation.id)
    }
    
    
    func addEndOFParkingNotification() {
        //cancelin starting 15 min notification
        cancelParkingReservatinNotification()
        
        //Adding notification to trigger before 10 min of parking end.
        let notificationTime = reservation.EndTime - K_NotificationEndParkingBefore
        let t = Date(timeIntervalSince1970: notificationTime).timeIntervalSinceNow
        print("reservation.EndTime", reservation.EndTime,    "notificationTime",notificationTime, "t", t)
        
        QPLNSupport.add(reservation.id,
                        after: t,
                        title: "Alert",
                        detail: "Your parking will end in \(K_NotificationEndParkingBefore/60) minutes.",
                        userInfo:[:])
    }
    
    
    @IBAction func btnExist(_ sender:Any){
        
        UserDefaults.standard.set(false, forKey: "start")
        
        NotificationCenter.default.post(name: Notification.Name("updateTimer"), object: 0)
        self.view.window!.rootViewController?.dismiss(animated: false, completion: nil)
    }
    
    // MARK: - Timer
    
    private func startTimer() {
        self.timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
    }
    
    @objc func updateTimer() {
        print(self.totalTime)
        self.lblCountDown.text = self.timeFormatted(self.totalTime) // will show timer
        if totalTime != 0 {
            totalTime -= 1  // decrease counter timer
        } else {
            if let timer = self.timer {
                timer.invalidate()
                self.timer = nil
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    func timeFormatted(_ totalSeconds: Int) -> String {
        let seconds: Int = totalSeconds % 60
        let minutes: Int = (totalSeconds / 60) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    
    func getWaitingTime(){
        
//        UtilitiesManager.sharedIntance.secondsInTimeIntervals(startTime: <#T##Int#>, endTime: <#T##Int#>)
        
    }
    
    
//    @objc func updateWaitingTime(){
//        waitingTime! += 1
//        lblWaitingTime.isHidden = false
//        lblWaitingTime.text = timeString(time: TimeInterval(waitingTime!))
//    }
//
//    func timeString(time:TimeInterval) -> String {
//        let hours = Int(time) / 3600
//        let minutes = Int(time) / 60 % 60
//        let seconds = Int(time) % 60
//        if hours == 0 && minutes < 10 {
//
//            self.lblWaitingTime.textColor = UIColor.THEME_RED_COLOR
//            self.btnCancelRideOnReach.layer.borderColor = UIColor.THEME_RED_COLOR.cgColor
//            self.btnCancelRideOnReach.setTitleColor(UIColor.THEME_RED_COLOR, for: .normal)
//
//        }else{
//
//            self.lblWaitingTime.textColor = UIColor.systemGreen
//            self.btnCancelRideOnReach.layer.borderColor = UIColor.YELLOW_THEME_COLOR.cgColor
//            self.btnCancelRideOnReach.setTitleColor(UIColor.YELLOW_THEME_COLOR, for: .normal)
//        }
//        return String(format:"%02i:%02i:%02i", hours, minutes, seconds)
//    }
    
    
    
}


////
////  EnterParkingVC.swift
////  QuickPark
////
////  Created by Macbook Pro on 19/02/2022.
////
//
//import UIKit
//import FirebaseDatabase
//

//
//class EnterParkingVC: UIViewController {
//    @IBOutlet weak var imgQR : UIImageView!
//    @IBOutlet weak var lblCountDown : UILabel!
//    @IBOutlet weak var viewLoader: UIView!
//    var reservation : Reservation!
//
//    @IBOutlet weak var EntryQR: UIImageView!
//    var qrcodeDidScan:(()->())?
//
//    var timer: Timer?
//    var totalTime = 900
//    var endTimer = ""
//    var waitingTime:Int? = 0
//
//    var image: UIImage?
//    var qrcode:String?
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        imgQR.image = image
//        if let qrcode = qrcode{
//            track(qrcode: qrcode)
//        }
//
//
//        // Do any additional setup after loading the view.
//        colour = UIColor(red: 0, green: 144/255, blue: 205/255, alpha: 1)
//        startActivityAnimating(padding: 2, isFromOnView: false, view: self.viewLoader,width: 100,height: 100)
//        checkIfTimeIsValid()
//    }
//
//    func track(qrcode code: String){
//        Database.database().reference().child("QRCode").child(code).observe(.value) { dataSnap in
//            if dataSnap.exists(){
//                guard let reserDict = dataSnap.value as? [String:Any] else{return}
//              //  print("Iterating on QRCode dictionary: ",reserDict)
//                if let isScanned = reserDict["isScanned"] as? Bool, isScanned{
//                    UserDefaults.standard.set(true, forKey: "start")
//                    NotificationCenter.default.post(name: Notification.Name("updateTimer"), object: 0)
//                    self.dismiss(animated: false, completion: nil)
//                    self.qrcodeDidScan?()
//                }
//            }
//        }
////        Database.database().reference().child("QRCode").child(code).observeSingleEvent(of: .value, with: )
//    }
//
//
//    func checkIfTimeIsValid(){
//        if UtilitiesManager.sharedIntance.checkIfTimeIsValidToStart(start: Date.init(timeIntervalSince1970: TimeInterval.init(reservation.StartTime)), end: Date.init(timeIntervalSince1970: TimeInterval.init(reservation.EndTime))){
//            if UserDefaults.standard.bool(forKey: "start"){
////                self.getStartTime()
//            }else{
//                self.getStartTime15()
//            }
//
//        }else{
//            setCustomExecution(date: Date.init(timeIntervalSince1970: TimeInterval.init(reservation.StartTime)))
//            viewLoader.isHidden = false
//            lblCountDown.text = "Wait to start"
//        }
//    }
//
//    func setCustomExecution(date:Date){
//        let timer = Timer(fireAt: date, interval: 0, target: self, selector: #selector(runCode), userInfo: nil, repeats: false)
//        RunLoop.main.add(timer, forMode: .common)
//
//    }
//
//    @objc func runCode(){
//        checkIfTimeIsValid()
//        NotificationCenter.default.post(name: Notification.Name("updateTimer"), object: 0)
//    }
//
//
//    func getStartTime15(){
//        let start = TimeInterval.init(reservation.StartTime)
//        let enddate = Date.init(timeIntervalSince1970: start).addingMinutes(minutes: 15)
//        let end = enddate.timeIntervalSince1970
//        let isValidTime = UtilitiesManager.sharedIntance.checkIfTimeIsValid(endTime: Date.init(timeIntervalSince1970: end))
//        if isValidTime{
//            self.totalTime = Int(UtilitiesManager.sharedIntance.getTimerValue(start: Date(), endtime: Date.init(timeIntervalSince1970: end)))
//            self.viewLoader.isHidden = false
//            startTimer()
//        }else{
//            UserDefaults.standard.set(false, forKey: "start")
//            NotificationCenter.default.post(name: Notification.Name("updateTimer"), object: 0)
//            self.view.window!.rootViewController?.dismiss(animated: false, completion: nil)
//        }
//    }
//
//    // MARK: - QRScan
//    //Dummy_code to completing the flow it will replace with QR scan
//    func QRScan(){
//        DispatchQueue.main.asyncAfter(deadline: .now()) {
//            // your code here
//            if let timer = self.timer {
//                timer.invalidate()
//                self.timer = nil
//            }
//            let vc = self.storyboard?.instantiateViewController(withIdentifier: "CountdownParkingVC") as! CountdownParkingVC
//            vc.endTimer = self.endTimer
//            vc.reservation = self.reservation
//            self.present(vc, animated: true, completion: nil)
//        }
//    }
//
//
//    @IBAction func btnSkip(_ sender:Any) {
//        UserDefaults.standard.set(true, forKey: "start")
//        NotificationCenter.default.post(name: Notification.Name("updateTimer"), object: 0)
//
//        self.view.window!.rootViewController?.dismiss(animated: false, completion: nil)
//
//        //cancelin starting 15 min notification
//        cancelParkingReservatinNotification()
//
//        //Adding notification to trigger before 10 min of parking end.
//        let notificationTime = reservation.EndTime - K_NotificationEndParkingBefore
//        let t = Date(timeIntervalSince1970: notificationTime).timeIntervalSinceNow
//        print("reservation.EndTime", reservation.EndTime,    "notificationTime",notificationTime, "t", t)
//
//
//        QPLNSupport.add(reservation.id,
//                        after: t,
//                        title: "Alert",
//                        detail: "Your parking will end in \(K_NotificationEndParkingBefore/60) minutes.",
////                        detail: "Your parking will end in 10 minutes.",
//                        userInfo:[:])
//    }
//
//    @IBAction func btnExist(_ sender:Any){
//        UserDefaults.standard.set(false, forKey: "start")
//        NotificationCenter.default.post(name: Notification.Name("updateTimer"), object: 0)
//        self.view.window!.rootViewController?.dismiss(animated: false, completion: nil)
//    }
//
//    func cancelParkingReservatinNotification() {
//        QPLNSupport.remove(reservation.id)
//    }
//
//    // MARK: - Timer
//    private func startTimer() {
//        self.timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
//    }
//
//    @objc func updateTimer() {
//        print("EPVC totalTime", self.totalTime)
//        self.lblCountDown.text = self.timeFormatted(self.totalTime) // will show timer
//        if totalTime != 0 {
//            totalTime -= 1  // decrease counter timer
//        } else {
//            if let timer = self.timer {
//                timer.invalidate()
//                self.timer = nil
//                self.dismiss(animated: true, completion: nil)
//            }
//        }
//    }
//    func timeFormatted(_ totalSeconds: Int) -> String {
//        let seconds: Int = totalSeconds % 60
//        let minutes: Int = (totalSeconds / 60) % 60
//        return String(format: "%02d:%02d", minutes, seconds)
//    }
//
//
//    func getWaitingTime(){
//
////        UtilitiesManager.sharedIntance.secondsInTimeIntervals(startTime: <#T##Int#>, endTime: <#T##Int#>)
//
//    }
//
//
////    @objc func updateWaitingTime(){
////        waitingTime! += 1
////        lblWaitingTime.isHidden = false
////        lblWaitingTime.text = timeString(time: TimeInterval(waitingTime!))
////    }
////
////    func timeString(time:TimeInterval) -> String {
////        let hours = Int(time) / 3600
////        let minutes = Int(time) / 60 % 60
////        let seconds = Int(time) % 60
////        if hours == 0 && minutes < 10 {
////
////            self.lblWaitingTime.textColor = UIColor.THEME_RED_COLOR
////            self.btnCancelRideOnReach.layer.borderColor = UIColor.THEME_RED_COLOR.cgColor
////            self.btnCancelRideOnReach.setTitleColor(UIColor.THEME_RED_COLOR, for: .normal)
////
////        }else{
////
////            self.lblWaitingTime.textColor = UIColor.systemGreen
////            self.btnCancelRideOnReach.layer.borderColor = UIColor.YELLOW_THEME_COLOR.cgColor
////            self.btnCancelRideOnReach.setTitleColor(UIColor.YELLOW_THEME_COLOR, for: .normal)
////        }
////        return String(format:"%02i:%02i:%02i", hours, minutes, seconds)
////    }
//
//
//
//}
