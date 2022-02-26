//
//  Utilities.swift
//  QuickPark
//
//  Created by Macbook Pro on 20/02/2022.
//

import Foundation
import UIKit

class UtilitiesManager{
    static let sharedIntance = UtilitiesManager()

    //save_Timer in user default
    
    func saveTimer(time:String){
        UserDefaults.standard.set(time, forKey: "time") //setObject
    }
    
    func retriveTimer() -> Int{
        guard let time = UserDefaults.standard.string(forKey: "time") else{return 0}
        
            //let time = time
            //h:mm a
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "h:mm a"
            let timeDate = dateFormatter.date(from: time)!
            let calendar = Calendar.current
            let timeComponents = calendar.dateComponents([.hour, .minute], from: timeDate)
            let nowComponents = calendar.dateComponents([.hour, .minute], from: Date())
            
            let difference = calendar.dateComponents([.minute], from: nowComponents, to: timeComponents).minute!
        
//            self.totalTime = difference * 60
//            startTimer()
            //print("difference",difference)
        
        return difference * 60
    }
    
    func showAlert(title:String,message:String,VC:UIViewController){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let ok = UIAlertAction(title: "OK", style: .default, handler: { action in
        })
        alert.addAction(ok)
        DispatchQueue.main.async(execute: {
            VC.present(alert, animated: true)
        })
    }
    
    
    func showAlertWithAction(_ vc:UIViewController, message:String,title:String, buttons:[String], completion:((_ index:Int) -> Void)!) -> Void {
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        for index in 0..<buttons.count{
            
            alertController.setValue(NSAttributedString(string: title, attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 16),NSAttributedString.Key.foregroundColor : #colorLiteral(red: 0.5725490451, green: 0, blue: 0.2313725501, alpha: 1)]), forKey: "attributedTitle")
            
            alertController.setValue(NSAttributedString(string: message, attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 14),NSAttributedString.Key.foregroundColor : #colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1)]), forKey: "attributedMessage")
            
            
            let action = UIAlertAction(title: buttons[index], style: .default, handler: {
                (alert: UIAlertAction!) in
                if(completion != nil){
                    completion(index)
                }
            })
            
            action.setValue(UIColor.black, forKey: "titleTextColor")
            alertController.addAction(action)
        }
        
        vc.present(alertController, animated: true, completion: nil)
    }
    
    func getRandomString(_ length: Int? = 20) -> String {
      let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
      return String((0..<length!).map{ _ in letters.randomElement()! })
    }
    
    
    func secondsInTimeIntervals(startTime:Int,endTime:Int)->Double{
        let std = Date(timeIntervalSince1970: TimeInterval(startTime))
        let end = Date(timeIntervalSince1970: TimeInterval(endTime))
        
        let formatter = DateComponentsFormatter()
            formatter.allowedUnits = [.second]
        formatter.unitsStyle = .positional
            let difference = formatter.string(from: std, to: end) ?? "0"
            print("Time To cover",difference,"\n")
        
        return Double(difference) ?? 0.0
        
    }
    
    func minutesInTimeIntervals(startTime:Int,endTime:Int)->Double{
        let std = Date(timeIntervalSince1970: TimeInterval(startTime))
        let end = Date(timeIntervalSince1970: TimeInterval(endTime))
        
        let formatter = DateComponentsFormatter()
            formatter.allowedUnits = [.minute]
        formatter.unitsStyle = .positional
            let difference = formatter.string(from: std, to: end) ?? "0"
            print("Time To cover",difference,"\n")
        
        return Double(difference) ?? 0.0
        
    }
    
    
    func timeFormatted(_ totalSeconds: Int) -> String {
        let seconds: Int = totalSeconds % 60
        let minutes: Int = (totalSeconds / 60) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    
    func getTimerValue(start:Date,endtime:Date) -> TimeInterval {
            return endtime.timeIntervalSinceReferenceDate - start.timeIntervalSinceReferenceDate
    }
   
    
    func checkIfTimeIsEarly(start:Date)->Bool{
        let now = Date.init()
        if now.timeIntervalSince1970 - start.timeIntervalSince1970 > 0{
            return true
        }else{
            return false
        }

    }
    
    func checkIfTimeIsValid(endTime:Date)->Bool{
        let today = Date.init()
        if today.timeIntervalSinceReferenceDate - endTime.timeIntervalSinceReferenceDate > 0{
            return false
        }else{
            return true
        }

    }
    
    func checkIfTimeIsValidToStart(start:Date,end:Date)->Bool{
        let now = Date.init()
        if now.timeIntervalSince1970 < end.timeIntervalSince1970{
            if now.timeIntervalSince1970 - start.timeIntervalSince1970 > 0{
                return true
            }else{
                return false
            }
        }else{
            return false
        }

    }
    
    func removeTimer(){
        UserDefaults.standard.removeObject(forKey: "time")
    }
    
    
   
    
//    func showAlert(view: UIViewController, title: String, message: String) {
//            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
//            let defaultAction = UIAlertAction(title: "OK", style: .default, handler: { action in
//            })
//            alert.addAction(defaultAction)
//            DispatchQueue.main.async(execute: {
//                view.present(alert, animated: true)
//            })
//        }

    
}


extension TimeInterval{

        func hoursMinutesFromTimeInterval() -> String {

            let time = NSInteger(self)
            let minutes = (time / 60) % 60
            let hours = (time / 3600)

            return String(format: "%0.2d:%0.2d:%0.2d.%0.3d",hours,minutes)

        }
    
    func dateFromTimeinterval() -> String {

        let df = DateFormatter()
        df.dateFormat = "hh:mm a d MMM"
        let date = Date.init(timeIntervalSince1970: self)
        return df.string(from: date)

    }
}


extension Date {
    func addingMinutes(minutes: Int) -> Date {
        return Calendar.current.date(byAdding: .minute, value: minutes, to: self)!
    }
}
