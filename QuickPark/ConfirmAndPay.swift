//
//  ConfirmAndPay.swift
//  QuickPark
//
//  Created by MAC on 06/07/1443 AH.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth


class ConfirmAndPay: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var StartTimeTxt: UITextField!
    @IBOutlet weak var EndTimeTxt: UITextField!
    @IBOutlet weak var StartWithView: UIView!
    @IBOutlet weak var TotalPrice: UILabel!
    
    @IBOutlet weak var DoneButton: UIButton!
    @IBOutlet weak var PriceView: UIView!
    @IBOutlet weak var EndWithView: UIView!
    @IBOutlet weak var AreaView: UIView!
    
    @IBOutlet weak var AreaLabel: UILabel!
    
    
    
    let StartTimePicker = UIDatePicker()
    let EndTimePicker = UIDatePicker()
    var startTimer = ""
    var endTimer = ""
    
    var ref:DatabaseReference!
    var areaName = ""
    
    var uid = ""
    var parking:Area!
    
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
        
        AreaView.layer.cornerRadius = 20
        StartWithView.layer.cornerRadius = 20
        EndWithView.layer.cornerRadius = 20
        PriceView.layer.cornerRadius = 20
        //shadow
        AreaView.layer.shadowColor = UIColor.black.cgColor
        AreaView.layer.shadowOpacity = 0.1
        AreaView.layer.shadowOffset = .zero
        AreaView.layer.shadowRadius = 10
        //
        StartWithView.layer.shadowColor = UIColor.black.cgColor
        StartWithView.layer.shadowOpacity = 0.1
        StartWithView.layer.shadowOffset = .zero
        StartWithView.layer.shadowRadius = 10
        //
        EndWithView.layer.shadowColor = UIColor.black.cgColor
        EndWithView.layer.shadowOpacity = 0.1
        EndWithView.layer.shadowOffset = .zero
        EndWithView.layer.shadowRadius = 10
        //
        PriceView.layer.shadowColor = UIColor.black.cgColor
        PriceView.layer.shadowOpacity = 0.1
        PriceView.layer.shadowOffset = .zero
        PriceView.layer.shadowRadius = 10
        DoneButton.layer.cornerRadius = 20
        
        //time picker
        createTimePicker()
        
    }
    
    @IBAction func WhenDoneClicked(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
        let FirstViewController = ViewController()
        present(FirstViewController, animated: true, completion: nil)
        
    }
    
    
    func createTimePicker() {
        
        StartTimeTxt.textAlignment = .center
        EndTimeTxt.textAlignment = .center
        
        //tool bar
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        //bar button(
        let doneBtn = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(donePressed))
        toolbar.setItems([doneBtn], animated: true)
        
        //assign tool bar
        StartTimeTxt.inputAccessoryView = toolbar
        EndTimeTxt.inputAccessoryView = toolbar
        
        // assign time picker to the txt field
        StartTimeTxt.inputView = StartTimePicker
        EndTimeTxt.inputView = EndTimePicker
        
        //time picker mode
        /* StartTimePicker.datePickerMode = .time
         EndTimePicker.datePickerMode = .time*/
        
        
        let calendar = Calendar.current
        //First range
        let startTime = Date()
        let startRangeEnd = calendar.date(byAdding: DateComponents(minute: 30), to: startTime)!
        let startRange = startTime...startRangeEnd
        //Second range
        let endTime = calendar.date(byAdding: DateComponents(minute: 1), to: startRangeEnd)!
        let endRangeEnd = calendar.startOfDay(for: calendar.date(byAdding: DateComponents(day: 1), to: startTime)!)
        let endRange = endTime...endRangeEnd
        StartTimePicker.date = startTime
        StartTimePicker.minimumDate = startTime
        StartTimePicker.maximumDate = startRangeEnd
        EndTimePicker.date = endTime
        EndTimePicker.minimumDate = endTime
        EndTimePicker.maximumDate = endRangeEnd
        if #available(iOS 13.4, *)  {
            StartTimePicker.preferredDatePickerStyle = .wheels
            EndTimePicker.preferredDatePickerStyle = .wheels
        }
    }
    
    @objc func donePressed(){
        // formatter
        let calendar = Calendar.current
        let startTime = Date()
        let startRangeEnd = calendar.date(byAdding: DateComponents(minute: 30), to: startTime)!
        let startRange = startTime...startRangeEnd
        //Second range
        let endTime = calendar.date(byAdding: DateComponents(minute: 1), to: startRangeEnd)!
        let endRangeEnd = calendar.startOfDay(for: calendar.date(byAdding: DateComponents(day: 1), to: startTime)!)
        let endRange = endTime...endRangeEnd
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        
        StartTimeTxt.text = formatter.string(from: StartTimePicker.date)
        self.view.endEditing(true)
        
        EndTimeTxt.text = formatter.string(from: EndTimePicker.date)
        self.view.endEditing(true)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "h:mm a"
        startTimer = formatter.string(from: StartTimePicker.date)
        endTimer = formatter.string(from: EndTimePicker.date)
        // print(start, end)
        
        // Format and print in 12h format
        let hourAndMinutes = Calendar.current.dateComponents([.hour, .minute], from: StartTimePicker.date, to: EndTimePicker.date)
        print(hourAndMinutes)
        
        // Calculate price, the formula is just an example
        let price = hourAndMinutes.hour! * 15 + hourAndMinutes.minute! * 15 / 60
        TotalPrice.text = String(price) + "SAR"
        
        
        
        
        /*let starttimecal = StartTimeTxt.text!
         let endtimecal = EndTimeTxt.text!
         
         let StartTo24 = starttimecal
         let EndTo24 = endtimecal
         let dateFormatter = DateFormatter()
         dateFormatter.dateFormat = "h:mm a"
         
         let Stime = dateFormatter.date(from: StartTo24)
         dateFormatter.dateFormat = "HH:mm"
         //let STime24 = dateFormatter.string(from: Stime!)
         print("24 hour formatted Date:",Stime)
         let ETime = dateFormatter.date(from: EndTo24)
         dateFormatter.dateFormat = "HH:mm"
         //let ETime24 = dateFormatter.string(from: ETime!)
         print("24 hour formatted Date:",ETime)*/
        
        
        
        
    }
    
    @IBAction func btnContirmClicked(_ sender: Any) {
        if startTimer.isEmpty || endTimer.isEmpty {
            QPAlert(self).showError(message: "Select start and End Time to continue.")
            //UtilitiesManager.sharedIntance.showAlert(view: self, title: "Oops", message: "Select start and End Time to continue.")
        }else{
            let df = DateFormatter()
            df.dateFormat = "d MMM yyyy"
            let dateStr = df.string(from: Date())
            
            
            let hourAndMinutes = Calendar.current.dateComponents([.hour, .minute], from: StartTimePicker.date, to: EndTimePicker.date)
            print(hourAndMinutes)
            let reservationId = UtilitiesManager.sharedIntance.getRandomString()
            let paramas = ["id":reservationId,"Date":dateStr,"EndTime":EndTimePicker.date.timeIntervalSince1970,"ExtraCharge":"0","Name":"user_name","Price":TotalPrice.text ?? 0,"StartTime":StartTimePicker.date.timeIntervalSince1970,"area":areaName,"isCompleted":false] as [String : Any]
            
            
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "EnterParkingVC") as! EnterParkingVC
            vc.endTimer = self.endTimer
            vc.reservation = Reservation.init(dict: ["id":reservationId,"Date":dateStr,"EndTime":EndTimePicker.date.timeIntervalSince1970,"ExtraCharge":"0","Name":"user_name","Price":TotalPrice.text ?? 0,"StartTime":StartTimePicker.date.timeIntervalSince1970,"area":areaName])
            self.present(vc, animated: true, completion: {
                RESERVATIONS.child(self.uid).child(reservationId).setValue(paramas)
                if self.parking.areaname == "King Saud University"{
                    self.ref.child("Areas").child("Area_23").child("isAvailable").setValue(false)
                    UserDefaults.standard.set("Area_23", forKey: "parkingArea")
                }else{
                    self.ref.child("Areas").child("Area_88").child("isAvailable").setValue(false)
                    UserDefaults.standard.set("Area_88", forKey: "parkingArea")
                }
            })
        }
        
        
    }
    
    
    /*private func calculateIntialPrice() -> Double {
     let pricePerHour = 15.0
     let startTime = 0
     let endTime = 0
     
     let intialPrice : Double = Double(( endTime -  startTime )) * pricePerHour
     
     return intialPrice
     
     }*/
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
