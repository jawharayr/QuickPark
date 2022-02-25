//
//  ReservationCell.swift
//  QuickPark
//
//  Created by Deema on 08/07/1443 AH.
//

import UIKit
import Foundation

class ReservationCell: UICollectionViewCell {

//    @IBOutlet weak var Name: UILabel!
    @IBOutlet weak var StartTime: UILabel!
    @IBOutlet weak var EndTime: UILabel!
//    @IBOutlet weak var Price: UILabel!
//    @IBOutlet weak var ExtraCharge: UILabel!
//    @IBOutlet weak var Date: UILabel!
    @IBOutlet weak var btnEnd: UIButton!

    @IBOutlet weak var area: UILabel!
    @IBOutlet weak var lblCountDown: UILabel!
    @IBOutlet weak var viewLoader: UIView!
    
    @IBOutlet weak var viewWidth:NSLayoutConstraint!
    @IBOutlet weak var viewHeight:NSLayoutConstraint!
    
    
    var mainVC:UIViewController!
    var timer:Timer!
    var totalTime = 0
    var reservation:Reservation!
    var uid = ""
    
    
    override func awakeFromNib() {
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
        self.lblCountDown.text = UtilitiesManager.sharedIntance.timeFormatted(self.totalTime) // will show timer
        if totalTime != 0 {
            totalTime -= 1
            if totalTime < 600{
                lblCountDown.textColor = UIColor.red
            }
        } else {
            if let timer = self.timer {
                timer.invalidate()
                self.timer = nil
            }
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
        }else{
            
            self.btnEnd.isUserInteractionEnabled = false
            lblCountDown.text = "Wait to start"
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
    
    
    func getIfAnyReservation(){
        viewLoader.isHidden = true
        self.reservation = nil
        RESERVATIONS.child(uid).observe(.value) { dataSnap in
            if dataSnap.exists(){
                let reserDict = dataSnap.value as! [String:Any]
                for (k,_) in reserDict{
                    let res = Reservation.init(dict: reserDict[k] as! [String : Any])
                    if res.isCompleted{
                    }else{
                        self.reservation = res
                    }
                }
                
                if self.reservation != nil{
                    
                    self.checkIfTimeIsValid()
                }
            }
        }
    }
    
    
    
    @IBAction func EndParking(_ sender: Any) {
        
        
        UtilitiesManager.sharedIntance.showAlertWithAction(mainVC, message: "Are you sure?", title: "End Parking?", buttons: ["YES","cancel"]) { index in
            if index == 0{
                self.calculateTime()
            }
        }
    }
    
    
    
    
    
    func calculateTime(){
        
        
        var extra:Double = 0.0
        var price:Double = 0.0
        var total:Double = 0.0
        
        let startTime = reservation.StartTime
        let endTime = reservation.EndTime
        
        let now = Date.init().addingMinutes(minutes: 1)
        
        if now.timeIntervalSince1970 > TimeInterval.init(endTime){
            price = UtilitiesManager.sharedIntance.minutesInTimeIntervals(startTime: Int(TimeInterval.init(startTime)), endTime: Int(TimeInterval.init(endTime))) * 0.25
            extra = UtilitiesManager.sharedIntance.minutesInTimeIntervals(startTime: Int(TimeInterval.init(endTime)), endTime: Int(now.timeIntervalSince1970)) * 0.25
            total = price + extra
        }else{
            price = UtilitiesManager.sharedIntance.minutesInTimeIntervals(startTime: Int(TimeInterval.init(startTime)), endTime: Int(TimeInterval.init(endTime))) * 0.25
            total = price
        }
        
        
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PayAbleViewController") as! PayAbleViewController
        vc.total = "\(total.rounded())"
        vc.extra = "\(extra.rounded())"
        vc.price = "\(price.rounded())"
        vc.modalPresentationStyle = .overFullScreen
        vc.reservation = self.reservation
        mainVC.present(vc, animated: true, completion: nil)
    }
    
    
    }

