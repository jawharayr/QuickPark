//
//  ConfirmAndPay.swift
//  QuickPark
//
//  Created by MAC on 06/07/1443 AH.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth
import Firebase

let K_ReservationTimer : TimeInterval = 10 //Time interval (first not) should be 900

class ConfirmAndPay: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var DueationLabel: UILabel!
    @IBOutlet weak var PriceView: UIView!
    @IBOutlet weak var StartTimeTxt: UITextField!
    @IBOutlet weak var EndTimeTxt: UITextField!
    @IBOutlet weak var StartWithView: UIView!
    @IBOutlet weak var TotalPrice: UILabel!
    @IBOutlet weak var DoneButton: UIButton!
    @IBOutlet weak var EndWithView: UIView!
    @IBOutlet weak var AreaView: UIView!
    @IBOutlet weak var AreaLabel: UILabel!
    @IBOutlet weak var DurationView: UIView!
    
    
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
        PriceView.layer.cornerRadius = 40
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
        
        /*  if let image = generateQRCode(using: "test"){
         let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "EnterParkingVC") as! EnterParkingVC
         vc.image = image
         navigationController?.pushViewController(vc, animated: true)
         
         }*/
        
    }
    
    /*
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
     
     }*/
    
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
        print("C&P: hourAndMinutes", hourAndMinutes)
        
        
        // Calculate price, the formula is just an example
        var minutesPrice = 0
        if ( hourAndMinutes.minute! == 0 ){
            minutesPrice = 0
        }
        else {
            minutesPrice = 15
        }
        
        let price = hourAndMinutes.hour! * 15 + minutesPrice
        TotalPrice.text = String(price) + "SAR"
        DurationView.isHidden = false
        DueationLabel.text = ": \(hourAndMinutes.hour!)" + " hour " + "\(hourAndMinutes.minute!)" + " min"
    }
    
    private let database = Database.database().reference()
    @IBAction func btnConfirmParkingAndPayClicked(_ sender: Any) {
        if startTimer.isEmpty || endTimer.isEmpty {
            QPAlert(self).showError(message: "Select start and End Time to continue.")
        }else{
            let df = DateFormatter()
            df.dateFormat = "d MMM yyyy"
            let dateStr = df.string(from: Date())
            
            let unique = String("\(Date().timeIntervalSince1970)").replacingOccurrences(of: ".", with: "")
            let hourAndMinutes = Calendar.current.dateComponents([.hour, .minute], from: StartTimePicker.date, to: EndTimePicker.date)
            
            print("C&P: hourAndMinutes", hourAndMinutes)
            let reservationId = UtilitiesManager.sharedIntance.getRandomString()
            let paramas = ["id":reservationId,
                           "Date":dateStr,
                           "EndTime":EndTimePicker.date.timeIntervalSince1970,
                           "ExtraCharge":"0",
                           "Name":"user_name",
                           "Price":TotalPrice.text ?? 0,
                           "StartTime":StartTimePicker.date.timeIntervalSince1970,
                           "area":areaName,
                           "isCompleted":false] as [String : Any]
            
            QPLNSupport.add(reservationId,
                            after: K_ReservationTimer,
                            title: "Your reservation was canceled.",
                            detail: "because reservation time of 15 min was expired.",
                            userInfo: paramas)
            
            print("My unique QR code: ",unique)
            if let image = UIImage.generateQRCode(using: unique){
                
                let object: [String : Any] = ["isScanned":false]
                
                database.child("QRCode").child(unique).setValue(object) { error, ref in
                    print("Error wihle saving QRCode to Firebase. Error= ",error?.localizedDescription)
                }
                
                //                let vc = self.storyboard?.instantiateViewController(withIdentifier: "EnterParkingVC") as! EnterParkingVC
                //                vc.image = image
                //                vc.qrcode = unique
                //                vc.endTimer = self.endTimer
                //                vc.reservation = Reservation.init(dict: ["id":reservationId,"Date":dateStr,"EndTime":EndTimePicker.date.timeIntervalSince1970,"ExtraCharge":"0","Name":"user_name","Price":TotalPrice.text ?? 0,"StartTime":StartTimePicker.date.timeIntervalSince1970,"area":areaName,"qrcode": unique])
                //                vc.qrcodeDidScan = { [weak self] in
                //                    self?.dismiss(animated: false, completion: nil)
                //=======
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "EnterParkingVC") as! EnterParkingVC
                vc.image = image
                vc.qrcode = unique
                vc.endTimer = self.endTimer
                
                vc.reservation = Reservation.init(dict: ["id":reservationId,
                                                         "Date":dateStr,
                                                         "EndTime":EndTimePicker.date.timeIntervalSince1970,
                                                         "ExtraCharge":"0",
                                                         "Name":"user_name",
                                                         "Price":TotalPrice.text ?? 0,
                                                         "StartTime":StartTimePicker.date.timeIntervalSince1970,
                                                         "area":areaName])
                vc.qrcodeDidScan = { [weak self] in
                    self?.dismiss(animated: false, completion: nil)
                    self.present(vc, animated: true, completion: {
                        RESERVATIONS.child(self.uid).child(reservationId).setValue(paramas)
                        if self.parking.areaname == "King Saud University"{
                            self.ref.child("Areas").child("Area_23").child("isAvailable").setValue(false)
                            UserDefaults.standard.set("Area_23", forKey: "parkingArea")
                        }else{
                            self.ref.child("Areas").child("Area_88").child("isAvailable").setValue(false)
                            UserDefaults.standard.set("Area_88", forKey: "parkingArea")
                            //>>>>>>> main
                        }
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
                    }
                    
                    
                    /*
                     // MARK: - Navigation
                     
                     // In a storyboard-based application, you will often want to do a little preparation before navigation
                     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
                     // Get the new view controller using segue.destination.
                     // Pass the selected object to the new view controller.
                     }
                     */
                    
                    }
