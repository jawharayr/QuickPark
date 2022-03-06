//
//  QRCodeVC.swift
//  QuickPark
//
//  Created by Deema on 11/07/1443 AH.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth


class QRCodeVC: UIViewController {
    
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var lblCountDown: UILabel!
    @IBOutlet weak var viewLoader: UIView!
    
    @IBOutlet weak var ExitQR: UIImageView!
    
    var timer: Timer?
    var totalTime = 600
    var image:UIImage?
    var reservation:Reservation!
    
    
    var ref:DatabaseReference!
    var uid = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
       ExitQR.image = image
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
        
        
       // imageView.image = image
        // Do any additional setup after loading the view.
        startTimer()
        colour = UIColor(red: 0, green: 144/255, blue: 205/255, alpha: 1)
        startActivityAnimating(padding: 2, isFromOnView: false, view: self.viewLoader,width: 100,height: 100)
        UtilitiesManager.sharedIntance.removeTimer()
    }
    
    

    
    // MARK: - CountDown_Timer
    private func startTimer() {
        //self.totalTime = 60
        self.timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
    }
    
    func stopTimer(){
        if let timer = self.timer {
            timer.invalidate()
            self.timer = nil
        }
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
            }
        }
    }
    
    
    func timeFormatted(_ totalSeconds: Int) -> String {
        let seconds: Int = totalSeconds % 60
        let minutes: Int = (totalSeconds / 60) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    @IBAction func btnExist(_ sender:Any){
        stopTimer()
        NotificationCenter.default.post(name: Notification.Name("updateTimer"), object: 0)
        self.view.window!.rootViewController?.dismiss(animated: false, completion: nil)
    }
    
    @IBAction func skipTapped(_ sender:Any){
        finishParking()
    }
    
    
    func finishParking(){
        
        
        RESERVATIONS.child(self.uid).child(reservation.id).child("ExtraCharge").setValue(reservation.ExtraCharge) { err, data in
            if err == nil{
                RESERVATIONS.child(self.uid).child(self.reservation.id).child("isCompleted").setValue(true) { err, data in
                    if err == nil{
                        
                        guard let areaName = UserDefaults.standard.string(forKey: "parkingArea")else{return}
                        self.ref.child("Areas").child(areaName).child("isAvailable").setValue(true) { err, data in
                            if err == nil{
                                UserDefaults.standard.set(false, forKey: "isOverTime")
                                UserDefaults.standard.set(false, forKey: "start")
                                UserDefaults.standard.removeObject(forKey: "parkingArea")
                                NotificationCenter.default.post(name: Notification.Name("updateTimer"), object: 0)
                                self.view.window!.rootViewController?.dismiss(animated: false, completion: nil)
                            }
                        }
                        
                    }
                }
            }
            
        }
        
    }
    
}
