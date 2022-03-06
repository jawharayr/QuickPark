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
    var selectedArea : Area?
    
    @IBOutlet weak var ParkingView: UIView!
    
    @IBOutlet weak var SearchTxt: UITextField!
    @IBOutlet weak var ParkingsViews: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ParkingsViews?.delegate = self
        ParkingsViews?.dataSource = self
        ParkingsViews?.separatorStyle = .none
        ParkingsViews?.showsVerticalScrollIndicator = false
        SearchTxt.layer.cornerRadius = 20
        SearchTxt.layer.shadowOpacity = 0.1
        SearchTxt.layer.shadowOffset = .zero
        SearchTxt.layer.shadowRadius = 10
        
        
    }
   
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.selectedArea = nil
        getParkings()
    }
    
    private func getParkings() {
        let ref = Database.database().reference()
        ref.child("Areas").observe(DataEventType.value, with: { [self] snapshots in
            print(snapshots.childrenCount)
            parkings.removeAll()
            for snapshot in snapshots.children.allObjects as! [DataSnapshot] {
                let dictionary = snapshot.value as? NSDictionary
                let area = Area(areaKey : snapshot.key, areaname: dictionary?["areaname"] as? String ?? "", locationLat: dictionary?["locationLat"] as? Double ?? 0.0, locationLong: dictionary?["locationLong"] as? Double ?? 0.0, spotNo: dictionary?["spotNo"] as? Int ?? 0, logo: dictionary?["areaImage"] as? String ?? "", distance: 0.0  )
                parkings.append(area)
                
            }
            
            
            parkings = parkings.sorted { $0.areaname < $1.areaname}
            ParkingsViews.reloadData()
        })
    }
    
    @IBAction func btnAdddAreaClicked() {
        self.performSegue(withIdentifier: "listToAddArea", sender: self)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "listToAddArea"{
            let dest = segue.destination as! AddAreaViewController
            dest.parkings = self.parkings
        }
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
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") {  (contextualAction, view, boolValue) in
            
            let ref = Database.database().reference()
            ref.child("Areas").child(self.parkings[indexPath.row].areaKey).removeValue { error, ref in
                tableView.reloadData()
            }
        }
        
        let editAction = UIContextualAction(style: .normal, title: "Modify") {  (contextualAction, view, boolValue) in
            self.selectedArea = self.parkings[indexPath.row]
            self.performSegue(withIdentifier: "AddAreaViewController", sender: self)
        }
        
        let swipeActions = UISwipeActionsConfiguration(actions: [deleteAction, editAction])
        
        return swipeActions
    }
    
}
