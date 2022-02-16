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
import SDWebImage


class AdminHomeListVC: UIViewController {

    var parkings = [Area]()
       
    @IBOutlet weak var ParkingView: UIView!
    
    @IBOutlet weak var ParkingsViews: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        ParkingsViews?.delegate = self
        ParkingsViews?.dataSource = self
        ParkingsViews?.separatorStyle = .none
        ParkingsViews?.showsVerticalScrollIndicator = false
        
        getParkings()

    }
    private func getParkings() {
        let ref = Database.database().reference()
        ref.child("Areas").observe(DataEventType.value, with: { [self] snapshots in
            print(snapshots.childrenCount)
            parkings.removeAll()
            for snapshot in snapshots.children.allObjects as! [DataSnapshot] {
                let dictionary = snapshot.value as? NSDictionary
                let area = Area(areaname: dictionary?["areaname"] as? String ?? "", loactionLat: "", locationLong: "", spotNo: "", logo: dictionary?["areaImage"] as? String ?? "" )
                parkings.append(area)
            }
            
            ParkingsViews.reloadData()
        })
    }

}
    extension AdminHomeListVC: UITableViewDelegate, UITableViewDataSource{
        
        func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
            return 100
        }
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return parkings.count
        }

        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = ParkingsViews.dequeueReusableCell(withIdentifier: "CustomCell") as! CustomCell
            let parking = parkings[indexPath.row]
            cell.Logos.sd_setImage(with: URL(string: parking.logo), placeholderImage:UIImage(named: "locPlaceHolder"))
            cell.Label.text = parking.areaname

            return cell
        }
        
        
        func addShadow(backgroundColor: UIColor = .white, cornerRadius: CGFloat = 12, shadowRadius: CGFloat = 5, shadowOpacity: Float = 0.1, shadowPathInset: (dx: CGFloat, dy: CGFloat), shadowPathOffset: (dx: CGFloat, dy: CGFloat)) {
          
            }
      
            }
