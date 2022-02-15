//
//  AdminHomeListVC.swift
//  QuickPark
//
//  Created by manar . on 12/02/2022.
//

import UIKit
import FirebaseDatabase
import FirebaseStorage
import Firebase
class AdminHomeListVC: UIViewController {

    var parkings = [Area]()
       
    @IBOutlet weak var ParkingView: UIView!
    
    @IBOutlet weak var ParkingsViews: UITableView!
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        ParkingsViews?.delegate = self
        ParkingsViews?.dataSource = self
        //making table view look good
        ParkingsViews?.separatorStyle = .none
        ParkingsViews?.showsVerticalScrollIndicator = false
        
        getParkings()

    }
    private func getParkings() {
        let ref = Database.database().reference()
        ref.child("Areas").observe(DataEventType.value, with: { [self] snapshots in
            print(snapshots.childrenCount)
        
            for snapshot in snapshots.children.allObjects as! [DataSnapshot] {
                let dictionary = snapshot.value as? NSDictionary
                let area = Area(areaname: dictionary?["areaname"] as? String ?? "", loactionLat: "", locationLong: "", spotNo: "", logo: "")
                parkings.append(area)
            }
            
            ParkingsViews.reloadData()
        })
    }

}
    extension AdminHomeListVC: UITableViewDelegate, UITableViewDataSource{
        func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
            return 60
        }
        
        func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
            return 120
        }
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return parkings.count
        }

        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = ParkingsViews.dequeueReusableCell(withIdentifier: "CustomCell") as! CustomCell
            let parking = parkings[indexPath.row]
            cell.Logos.image = UIImage(named: "King Saud University")
            cell.Label.text = parking.areaname
            //cell.ParkingView.layer.cornerRadius = 20 //cell.ParkingView.frame.height / 2
            //cell.Logos.layer.cornerRadius = 20 //cell.Logos.frame.height / 2
           // let borderColor: UIColor =  (parkings[indexPath.row] == " ") ? .red : UIColor(red: 0/225, green: 144/255, blue: 205/255, alpha: 1) //
        /*
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
             let cell = ParkingsViews.dequeueReusableCell(withIdentifier: "CustomCell") as! CustomCell
             let parking = parkings[indexPath.row]
                if !parking.imageURL.didLoad{
                             let child = storageRef.child("AreasImages/\(parking.areaname).png")
                             child.downloadURL { url, error in
                                 print("Did fetch \("AreasImages/\(parking.areaname).png") url: ",url, ", with error: ",error?.localizedDescription)
                                 self.parkings[indexPath.row].imageURL = ImageURL(url: url, didLoad: true)
                                 tableView.reloadRows(at: [indexPath], with: .automatic)
                             }
                         }else{
                             cell.Logos.kf.setImage(with: parking.imageURL.url, placeholder: nil)
                             //
                         }
             */

            return cell
        }
        
        
        func addShadow(backgroundColor: UIColor = .white, cornerRadius: CGFloat = 12, shadowRadius: CGFloat = 5, shadowOpacity: Float = 0.1, shadowPathInset: (dx: CGFloat, dy: CGFloat), shadowPathOffset: (dx: CGFloat, dy: CGFloat)) {
          
            }
      
            }
