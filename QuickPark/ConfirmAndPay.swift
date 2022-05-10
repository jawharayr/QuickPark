//
//  ConfirmAndPay.swift
//  QuickPark
//
//  Created by MAC on 06/07/1443 AH.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth
import FirebaseFirestore
import MapKit
import CoreLocation
import StoreKit
let K_NotificationReservationTimer : TimeInterval = 900//10 //Time interval


class ConfirmAndPay: UIViewController {
    
  
    @IBOutlet weak var DueationLabel: UILabel!
    @IBOutlet weak var PriceView: UIView!
    @IBOutlet weak var StartTimeTxt: UITextField!
    @IBOutlet weak var EndTimeTxt: UITextField!
    @IBOutlet weak var StartWithView: UIView!
    @IBOutlet weak var TotalPrice: UILabel!
    
    @IBOutlet weak var GoToLocation: UIView!
    @IBOutlet weak var DoneButton: UIButton!
    @IBOutlet weak var EndWithView: UIView!
    @IBOutlet weak var AreaView: UIView!
    
    @IBOutlet weak var AreaLabel: UILabel!
    
    @IBOutlet weak var DurationView: UIView!
    
    @IBOutlet weak var GotoLocation: UIButton!
    
    let StartTimePicker = UIDatePicker()
    let EndTimePicker = UIDatePicker()
    var startTimer = ""
    var endTimer = ""
    var startDateTime = Date()
    var ref:DatabaseReference!
    var areaName = ""
    
    var uid = ""
    var parking:Area!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        StartTimeTxt.delegate = self
        EndTimeTxt.delegate = self
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
        
        
       // AreaView.layer.cornerRadius = 20
        StartWithView.layer.cornerRadius = 20
        EndWithView.layer.cornerRadius = 20
        PriceView.layer.cornerRadius = 40
        GoToLocation.layer.cornerRadius = 20
        //shadow
        //AreaView.layer.shadowColor = UIColor.black.cgColor
        //AreaView.layer.shadowOpacity = 0.1
        //AreaView.layer.shadowOffset = .zero
        //AreaView.layer.shadowRadius = 10
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
        //
        GoToLocation.layer.shadowColor = UIColor.black.cgColor
        GoToLocation.layer.shadowOpacity = 0.1
        GoToLocation.layer.shadowOffset = .zero
        GoToLocation.layer.shadowRadius = 10
      
        DoneButton.layer.cornerRadius = 20
        
        //time picker
        createTimePicker()
        
    }
    
    @IBAction func WhenDoneClicked(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
        let FirstViewController = ViewController()
        present(FirstViewController, animated: true, completion: nil)
        
    }
    @IBAction func GoToLocation(_ sender: Any) {
        Take()
    }
    @objc func Take(){
        ref = Database.database().reference()
        ref.child("Areas").observe(DataEventType.value, with: { [self] snapshots in
            print(snapshots.childrenCount)
            
            for (_,snapshot) in (snapshots.children.allObjects as! [DataSnapshot]).enumerated() {
                let dictionary = snapshot.value as? NSDictionary
                let area = Area(areaKey : snapshot.key, areaname: dictionary?["areaname"] as? String ?? "", locationLat: dictionary?["locationLat"] as? Double ?? 0.0, locationLong: dictionary?["locationLong"] as? Double ?? 0.0, Value: dictionary?["Value"] as? Int ?? 0, isAvailable: dictionary?["isAvailable"] as? Bool ?? false, spotNo: dictionary?["spotNo"] as? Int ?? 0, logo: dictionary?["areaImage"] as? String ?? "", distance: 0.0)
                if(areaName == area.areaname){
                                   let locationLat:CLLocationDegrees = area.locationLat
                                   let locationLong:CLLocationDegrees = area.locationLong
                                   print(locationLat)
                    print(locationLong)
                    present(in: self, sourceView: self.view, locationLat: locationLat, locationLong: locationLong,areaName:areaName)
          
    }
              //  present(self, animated: (GoToLocation != nil))
    } })
            }
  
    
    func present(in viewController: UIViewController, sourceView: UIView,locationLat:CLLocationDegrees,locationLong:CLLocationDegrees,areaName:String) {
      let actionSheet = UIAlertController(title: "Open Location", message: "Choose an app to open direction", preferredStyle: .actionSheet)
      actionSheet.addAction(UIAlertAction(title: "Google Maps", style: .default, handler: { _ in
          // Pass the coordinate inside this URL
          let url = URL(string: "comgooglemaps://?daddr="+String(locationLat)+","+String(locationLong)+")&directionsmode=driving&zoom=14&views=traffic")!
          if UIApplication.shared.canOpenURL(url){
              UIApplication.shared.open(url, options: [:], completionHandler: nil)
          }
          else{
              let vc = SKStoreProductViewController()
              vc.loadProduct(withParameters: [SKStoreProductParameterITunesItemIdentifier: NSNumber(value: 585027354)], completionBlock: nil)
              self.present(vc, animated: true)
          }
      }))//google maps
      actionSheet.addAction(UIAlertAction(title: "Apple Maps", style: .default, handler: { _ in
          // Pass the coordinate that you want here

          let regionDistance:CLLocationDistance = 1000
                                  let coordinates = CLLocationCoordinate2DMake(locationLat, locationLong)
                                  let regionspam = MKCoordinateRegion(center: coordinates, latitudinalMeters: regionDistance, longitudinalMeters: regionDistance)
                                  let options = [MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: regionspam.center), MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: regionspam.span)]
                                  let placemark = MKPlacemark(coordinate: coordinates)
                                  let mapItem = MKMapItem(placemark: placemark)
                                  mapItem.name = areaName
          if mapItem.openInMaps(launchOptions: options){
              //
          }else {
              let vc = SKStoreProductViewController()
              vc.loadProduct(withParameters: [SKStoreProductParameterITunesItemIdentifier: NSNumber(value: 915056765)], completionBlock: nil)
              self.present(vc, animated: true)
          }
      }))//apple maps
      actionSheet.popoverPresentationController?.sourceRect = sourceView.bounds
      actionSheet.popoverPresentationController?.sourceView = sourceView
      actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
      viewController.present(actionSheet, animated: true, completion: nil)
      
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

        
        let calendar = Calendar.current
        //First range
        let startTime = Date()
       let startRangeEnd = calendar.date(byAdding: DateComponents(minute: 30), to: startTime)!
        StartTimePicker.date = startTime
        StartTimePicker.minimumDate = startTime
        StartTimePicker.maximumDate = startRangeEnd
        if #available(iOS 13.4, *)  {
            StartTimePicker.preferredDatePickerStyle = .wheels
            EndTimePicker.preferredDatePickerStyle = .wheels
        }
    }

    @objc func donePressed(){
        self.view.endEditing(true)
        StartWithView.backgroundColor = .white
        EndWithView.backgroundColor = .white
        StartTimeTxt.backgroundColor = .white
        EndTimeTxt.backgroundColor = .white
    }
    
    private let database = Database.database().reference()

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
            
            let unique = String("\(Date().timeIntervalSince1970)").replacingOccurrences(of: ".", with: "")
            
            let reservationId = UtilitiesManager.sharedIntance.getRandomString()
            UserDefaults.standard.set(reservationId, forKey: "reservationId")
//            let paramas = ["id":reservationId,"Date":dateStr,"EndTime":EndTimePicker.date.timeIntervalSince1970,"ExtraCharge":"0","Name":"user_name","Price":TotalPrice.text ?? 0,"StartTime":StartTimePicker.date.timeIntervalSince1970,"area":areaName,"isCompleted":false] as [String : Any]
            let paramas = ["id":reservationId,"Date":dateStr,"EndTime":EndTimePicker.date.timeIntervalSince1970,"ExtraCharge":"0","Name":"user_name","Price":TotalPrice.text ?? 0,"StartTime":StartTimePicker.date.timeIntervalSince1970,"area":areaName,"isCompleted":false,"qrcode": unique,"isScanned":false] as [String : Any]
            
            print("My unique QR code: ",unique)
            if let image = UIImage.generateQRCode(using: unique){
                
                let object: [String : Any] = ["isScanned":false]
                
                database.child("QRCode").child(unique).setValue(object) { error, ref in
                    print("Error wihle saving QRCode to Firebase. Error= ",error?.localizedDescription) }
                
            
                QPLNSupport.add(reservationId,
                                after: K_NotificationReservationTimer,
                                title: "Your reservation was canceled.",
                                detail: "because reservation time of 15 min was expired.",
                                userInfo:paramas)

                let vc = self.storyboard?.instantiateViewController(withIdentifier: "EnterParkingVC") as! EnterParkingVC
            vc.image = image
            vc.qrcode = unique
            vc.endTimer = self.endTimer
            vc.reservation = Reservation.init(dict: ["id":reservationId,"Date":dateStr,"EndTime":EndTimePicker.date.timeIntervalSince1970,"ExtraCharge":"0","Name":"user_name","Price":TotalPrice.text ?? 0,"StartTime":StartTimePicker.date.timeIntervalSince1970,"area":areaName])
           
                vc.qrcodeDidScan = { [weak self] in
                    self?.dismiss(animated: false, completion: nil)
                }
                
                self.present(vc, animated: true, completion: {
                RESERVATIONS.child(self.uid).child(reservationId).setValue(paramas)
                    let database = Firestore.firestore()
                    database.collection("users").document((Auth.auth().currentUser?.email)!).setData( ["hasReservation": true], merge: true)
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
    
    
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
    }}
    
extension Date {
    func add(years: Int = 0) -> Date? {
        let components = DateComponents(year: years, month: 0, day: 0, hour: 0, minute: 0, second: 0)
        return Calendar.current.date(byAdding: components, to: self)
    }
    
    func add(years: Int = 0, months: Int = 0, days: Int = 0, hours: Int = 0, minutes: Int = 0, seconds: Int = 0) -> Date? {
        let components = DateComponents(year: years, month: months, day: days, hour: hours, minute: minutes, second: seconds)
        return Calendar.current.date(byAdding: components, to: self)
    }

    var startOfDay: Date {
        return Calendar.current.startOfDay(for: self)
    }
    
    var endOfDay: Date {
        var components = DateComponents()
        components.day = 1
        components.second = -1
        return Calendar.current.date(byAdding: components, to: startOfDay)!
    }
    
}

extension ConfirmAndPay: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        let currentTime = Date()
        let calendar = Calendar.current
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        let startTime = max(StartTimePicker.date, currentTime)
        let endTime2 = startDateTime.add(minutes: 30) ?? calendar.date(byAdding: DateComponents(minute: 30), to: formatter.date(from: StartTimeTxt.text!)!)!
        switch textField {
        case self.StartTimeTxt:
            startDateTime = startTime
            StartTimeTxt.text = formatter.string(from: startTime)
        case self.EndTimeTxt:
            EndTimePicker.date = endTime2
            EndTimePicker.minimumDate = startDateTime.addingMinutes(minutes: 30)
            let endRangeEnd2 = calendar.startOfDay(for: calendar.date(byAdding: DateComponents(day: 1), to: self.startDateTime)!)
            EndTimePicker.maximumDate = endRangeEnd2
        default: break
        }
    }
        
    
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        let currentTime = Date()
        let calendar = Calendar.current
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        let startTime = max(StartTimePicker.date, currentTime)
        let endTime2 = EndTimePicker.date
        let hourAndMinutes = Calendar.current.dateComponents([.hour, .minute], from: startTime, to: endTime2)
        switch textField {
        case self.StartTimeTxt:
            startDateTime = startTime
            StartTimeTxt.text = formatter.string(from: startTime)
            self.view.endEditing(true)
            formatter.locale = Locale(identifier: "en_US_POSIX")
            formatter.dateFormat = "h:mm a"
            startTimer = formatter.string(from: startTime)
        case self.EndTimeTxt:
            EndTimePicker.date = endTime2
            EndTimePicker.minimumDate = endTime2
            EndTimePicker.maximumDate = self.startDateTime.endOfDay
            print("EndTimePicker.date \(EndTimePicker.date)")
            print("formatter.string(from: EndTimePicker.date) \(formatter.string(from: EndTimePicker.date))")
            EndTimeTxt.text = formatter.string(from: EndTimePicker.date)
            print(endTime2)
            endTimer = formatter.string(from: endTime2)
        default: break
        }
        print(hourAndMinutes)
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
        self.view.endEditing(true)
    }
}

