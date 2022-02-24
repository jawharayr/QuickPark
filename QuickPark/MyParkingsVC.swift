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

class MyParkingsVC: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate,UICollectionViewDelegateFlowLayout {
   
    
    @IBOutlet weak var SegmentedControl: UISegmentedControl!
    
//    @IBOutlet weak var viewLoader: UIView!
    //    @IBOutlet weak var lblCountDown: UILabel!

    
    
    
    var totalTime = 0
    var uid = ""
    var reservations = [Reservation]()
    var pastReservations = [Reservation]()
    var ref:DatabaseReference!
    var reservation:Reservation!
    var timer :Timer!
    
    
    @IBOutlet weak var EmptyLabel: UILabel!
    @IBOutlet weak var Active: UICollectionView!
    @IBOutlet weak var Past: UITableView!
    
    

    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Do any additional setup after loading the view.
//        getReservations()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
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
        
        Active.dataSource = self
        Active.delegate = self
    
        Past.delegate = self
        Past.dataSource = self
        
        getIfAnyReservation()
        
    }
  
    
    
    func getIfAnyReservation(){
        pastReservations.removeAll()
        Active.reloadData()
        RESERVATIONS.child(uid).observe(.value) { dataSnap in
            if dataSnap.exists(){
                let reserDict = dataSnap.value as! [String:Any]
                for (k,_) in reserDict{
                    let res = Reservation.init(dict: reserDict[k] as! [String : Any])
                    if !res.isCompleted{
                        self.reservations.append(res)
                        self.reservation = res
                    }else{
                        self.pastReservations.append(res)
                        self.Past.reloadData()
                    }
                }
                
                if self.reservation != nil{
                    self.Active.reloadData()
//                    self.getStartTime()
                }
            }
        }
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
        }
    }
    
    
    
    
   
    
    
    
    @objc func updateTimer() {
        print(self.totalTime)
//        self.lblCountDown.text = timeFormatted(self.totalTime) // will show timer
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
    
    /* func removeConstraint() {
    
        removeConstraint()
    }*/
    
    
    @IBAction func EndParking(_ sender: Any) {
        if let image = generateQRCode(using: "test"){
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "QRCodeVC") as! QRCodeVC
            vc.image = image
            vc.reservation = self.reservation
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
    
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return reservations.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "reservationCell", for: indexPath) as! ReservationCell
        
//        cell.Name.text = reservation.Name
//        cell.Date.text = reservation.Date
        let ds = reservations[indexPath.row]
        cell.StartTime.text = TimeInterval.init(ds.StartTime).dateFromTimeinterval()
        cell.EndTime.text = TimeInterval.init(ds.EndTime).dateFromTimeinterval()
        cell.area.text = ds.area
        cell.reservation = reservations[indexPath.row]
        cell.checkIfTimeIsValid()
        cell.mainVC = self
        cell.viewWidth.constant = self.view.frame.width - 40
        cell.viewHeight.constant = 400
     //   cell.EndTime.text = "End time: "
//        cell.Price.text = "Price: " + reservation.Price
//        cell.ExtraCharge.text = "ExtraCharge: " + reservation.ExtraCharge
//        cell.logo.image = UIImage(named: "King Saud University")

        
        
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize.init(width: self.view.frame.width - 40, height: 387)
    }
    
    
//    private func getReservations() {
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
//    }
    
    @objc func methodOfReceivedNotification(notification: Notification) {
        
//        let time = notification.object as! Int
//        if time == 0{
//
//        }
//        guard time>0 else{self.viewLoader.isHidden = true;return}
//        self.totalTime = time
//        self.viewLoader.isHidden = false
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
