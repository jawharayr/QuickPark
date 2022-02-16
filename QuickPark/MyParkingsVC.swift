//
//  MyParkingsVC.swift
//  QuickPark
//
//  Created by Deema on 03/07/1443 AH.

//

import UIKit
import FirebaseDatabase
import Foundation

class MyParkingsVC: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    @IBOutlet weak var SegmentedControl: UISegmentedControl!
    
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
    
    var reservations = [Reservation]()
    var pastReservations = [Reservation]()
    
    @IBOutlet weak var EmptyLabel: UILabel!
    @IBOutlet weak var Active: UICollectionView!
    
    
    @IBOutlet weak var Past: UITableView!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Do any additional setup after loading the view.
        getReservations()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        Active.dataSource = self
        Active.delegate = self
    
        Past.delegate = self
        Past.dataSource = self
        
    }
  
    /* func removeConstraint() {
    
        removeConstraint()
    }*/
    
    
    @IBAction func EndParking(_ sender: Any) {
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
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return reservations.count
    }
    
 
    @IBOutlet weak var EndParking: UIButton!
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "reservationCell", for: indexPath) as! ReservationCell
        let reservation = reservations[indexPath.row]
        
        cell.Name.text = reservation.Name
        cell.Date.text = reservation.Date
        cell.StartTime.text =   reservation.StartTime + " to " + reservation.EndTime
     //   cell.EndTime.text = "End time: "
        cell.Price.text = "Price: " + reservation.Price
        cell.ExtraCharge.text = "ExtraCharge: " + reservation.ExtraCharge
        cell.logo.image = UIImage(named: "King Saud University")

        
        
        return cell
    }
    
    private func getReservations() {
        let ref = Database.database().reference()
        ref.child("Reservations").child("UserID").observe(DataEventType.value, with: { [self] snapshots in
            print(snapshots.childrenCount)
        
            reservations.removeAll()
            pastReservations.removeAll()
            for snapshot in snapshots.children.allObjects as! [DataSnapshot] {
                let dictionary = snapshot.value as? NSDictionary
                let reservation = Reservation(Name: dictionary?["Name"] as? String ?? "", Date: dictionary?["Date"] as? String ?? "" , StartTime: dictionary?["StartTime"] as? String ?? "", EndTime: dictionary?["EndTime"] as? String ?? "", Price: dictionary?["Price"] as? String ?? "", ExtraCharge: dictionary?["ExtraCharge"] as? String ?? "", isActive: dictionary?["isActive"] as? Bool ?? false)
                if (reservation.isActive) {
                    reservations.append(reservation)
                }else{
                    pastReservations.append(reservation)
                }
                
            }
            
            if (reservations.isEmpty) {
                EmptyLabel.isHidden = false
                EndParking.isHidden = true
                Active.isHidden = true
                ActiveView.collectionView?.isHidden = true
            }
            
            Active.reloadData()
            Past.reloadData()
        })
    }
    @IBOutlet weak var ActiveView: UICollectionViewFlowLayout!
}
// Past reservations
extension MyParkingsVC: UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
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
        cell.EndTime.text = object.EndTime
        cell.StartTime.text = object.StartTime
        
        return cell
    }

      

}
