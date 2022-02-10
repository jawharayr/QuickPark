//
//  ViewController.swift
//  QuickPark
//
//  Created by MAC on 25/06/1443 AH.
//

import UIKit
import FirebaseDatabase
class ViewController: UIViewController{
    let parkings = ["King Saud University" , "Imam University" , "Dallah Hospital"]
   

    
    @IBOutlet weak var ParkingsViews: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        ParkingsViews.delegate = self
        ParkingsViews.dataSource = self
        
    }
}
    extension ViewController: UITableViewDelegate, UITableViewDataSource{
        func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
            return 120
        }
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return parkings.count
        }
        
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = ParkingsViews.dequeueReusableCell(withIdentifier: "CustomCell") as! CustomCell
        
            let parking = parkings[indexPath.row]
            cell.Logos.image = UIImage(named: parking)
            cell.Label.text = parking
            return cell
        }
    }





