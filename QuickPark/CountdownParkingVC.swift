//
//  ParkingVC.swift
//  QuickPark
//
//  Created by Macbook Pro on 19/02/2022.
//

import UIKit
import NVActivityIndicatorView

class CountdownParkingVC: UIViewController, UITabBarControllerDelegate {
    var reservation : Reservation!
    @IBOutlet weak var viewLoader:UIView!
    @IBOutlet weak var viewExtraLoader:UIView!
    
    @IBOutlet weak var lblCountDown:UILabel!
    @IBOutlet weak var lblWarning:UILabel!
    
    var activityIndicator : NVActivityIndicatorView!
    var timer: Timer?
    var totalTime = 1860
    var endTimer = ""
    var extraTime = 0
    var status = false //For setting timer to calculate extra time
    override func viewDidLoad() {
        super.viewDidLoad()
        startActivityAnimating(padding: 2, isFromOnView: false, view: self.viewLoader,width: 300,height: 300)
        guard !endTimer.isEmpty else{startTimer();return}
        getDifferenceBetweenTime()
        UtilitiesManager.sharedIntance.saveTimer(time: endTimer)
        
    }
    
    // MARK: - Timer
    private func startTimer() {
        self.timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
    }
    
    @objc func updateTimer() {
        if totalTime != 0 {
            if status {
                extraTime += 1  // increase counter timer
                self.lblCountDown.text = UtilitiesManager.sharedIntance.timeFormatted(self.extraTime) // will show timer
            }
            
            else{
                self.lblCountDown.text = UtilitiesManager.sharedIntance.timeFormatted(self.totalTime) // will show timer
                totalTime -= 1  // decrease counter timer
            }
            
        } else {
            totalTime -= 1
            lblWarning.isHidden = false
            self.viewLoader.isHidden = true
            self.lblCountDown.textColor = .red
            status = true
            colour = .red
            startActivityAnimating(padding: 2, isFromOnView: false, view: self.viewExtraLoader,width: 300,height: 300)
        }
    }
    
    
    func getDifferenceBetweenTime(){
        let time = endTimer
        //h:mm a
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm a"
        let timeDate = dateFormatter.date(from: time)!
        let calendar = Calendar.current
        let timeComponents = calendar.dateComponents([.hour, .minute], from: timeDate)
        let nowComponents = calendar.dateComponents([.hour, .minute], from: Date())
        
        let difference = calendar.dateComponents([.minute], from: nowComponents, to: timeComponents).minute!
        self.totalTime = difference * 60
        startTimer()
        //print("difference",difference)
    }
    func stopTimer(){
        if let timer = self.timer {
            timer.invalidate()
            self.timer = nil
        }
    }
    
    func calculateAmount(){
        let price = extraTime / 60 * 6
        print("totalPrice",price)
        //TotalPrice.text = String(price) + "SAR"
        
    }
    
    @IBAction func btnEndParking(_ sender:Any){
        stopTimer()
        calculateAmount()
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "QRCodeVC") as! QRCodeVC
        self.present(vc, animated: true, completion: nil)
    }
    
    @IBAction func btnExist(_ sender:Any){
        stopTimer()
        NotificationCenter.default.post(name: Notification.Name("updateTimer"), object: 0)
        self.view.window!.rootViewController?.dismiss(animated: false, completion: nil)
    }
    
}
