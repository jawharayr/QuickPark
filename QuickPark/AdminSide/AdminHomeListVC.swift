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
    var searchedArea = [Area]()
    var searchedLogos = [Area]()
    var searchedDistance = [Area]()
    var selectedArea : Area?
    
    @IBOutlet weak var searchText: UITextField!
    @IBOutlet weak var ParkingView: UIView!
    
    
    @IBOutlet weak var SearchTxt: UIView!
    @IBOutlet weak var ParkingsViews: UITableView!
    var searching = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchText.addTarget(self, action: #selector(searchRecord), for: .editingChanged)
        ParkingsViews?.delegate = self
        ParkingsViews?.dataSource = self
        ParkingsViews?.separatorStyle = .none
        ParkingsViews?.showsVerticalScrollIndicator = false
        SearchTxt.layer.cornerRadius = 20
        SearchTxt.layer.shadowOpacity = 0.1
        SearchTxt.layer.shadowOffset = .zero
        SearchTxt.layer.shadowRadius = 10
        
        
    }
    @objc func searchRecord(sender : UITextField){
        self.searchedArea.removeAll()
        self.searchedLogos.removeAll()
        let searchedData:Int=searchText.text!.count
        if searchedData != 0 {
            searching = true
            
            for parking in parkings {
                if let parkingToSearch = searchText.text {
                    let range = parking.areaname.lowercased().range(of: parkingToSearch, options: .caseInsensitive, range: nil, locale: nil)
                    if range != nil {
                        self.searchedArea.append(parking)
                        self.searchedLogos.append(parking)

                    }
                }
            }
        }else {
            searchedLogos = parkings
            searchedArea = parkings
            searching = false
        }
        ParkingsViews.reloadData()
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
                let area = Area(areaKey : snapshot.key, areaname: dictionary?["areaname"] as? String ?? "", locationLat: dictionary?["locationLat"] as? Double ?? 0.0, locationLong: dictionary?["locationLong"] as? Double ?? 0.0, Value: dictionary?["Value"] as? Int ?? 0, isAvailable: dictionary?["isAvailable"] as? Bool ?? false, spotNo: dictionary?["spotNo"] as? Int ?? 0, logo: dictionary?["areaImage"] as? String ?? "", distance: 0.0)
                parkings.append(area)
                
            }
            
            
            parkings = parkings.sorted { $0.areaname < $1.areaname}
            ParkingsViews.reloadData()
        })
    }
    
    @IBAction func btnAdddAreaClicked() {
        DataManager.shared.selectedPlaceMark = nil
        DataManager.shared.parkingName = ""
        DataManager.shared.parkingSpot = ""
        self.performSegue(withIdentifier: "GoToAdminAddAreaVC", sender: self)
    }
    
    
  
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "GoToAdminEditAreaVC" {
            let secondView = segue.destination as! AdminEditAreaVC
                  let object = selectedArea
            secondView.curSelectedArea = selectedArea
            secondView.parkings = self.parkings
            
            //secondView.spotNo = selectedArea?.spotNo
          
            //dvc.selectedArea = curSelectedArea
        } else if segue.identifier == "GoToAdminAddAreaVC" {
            let secondView = segue.destination as! AddAreaViewController
            secondView.parkings = self.parkings
            
            //secondView.spotNo = selectedArea?.spotNo
          
            //dvc.selectedArea = curSelectedArea
        }
        
        
    }
    
}
extension AdminHomeListVC: UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searching{
            return searchedArea.count
            
        } else{
        
            return parkings.count }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = ParkingsViews.dequeueReusableCell(withIdentifier: "AdminCustomCell") as! AdminCustomCell
        let parking = parkings[indexPath.row]
        cell.Logos.sd_setImage(with: URL(string: parking.logo), placeholderImage:UIImage(named: "locPlaceHolder"))
        cell.Label.text = parking.areaname
        
        if searching {
            let searchedAreaS = searchedArea[indexPath.row]
            cell.Label.text = searchedAreaS.areaname
        
            cell.Logos.sd_setImage(with: URL(string: searchedAreaS.logo), placeholderImage:UIImage(named: "locPlaceHolder"))
        
        } else {
            cell.Label.text = parking.areaname
            cell.Logos.sd_setImage(with: URL(string: parking.logo), placeholderImage:UIImage(named: "locPlaceHolder"))
         
           
            
        }
       
  
        
        return cell
    }
    
    
    func addShadow(backgroundColor: UIColor = .white, cornerRadius: CGFloat = 12, shadowRadius: CGFloat = 5, shadowOpacity: Float = 0.1, shadowPathInset: (dx: CGFloat, dy: CGFloat), shadowPathOffset: (dx: CGFloat, dy: CGFloat)) {
        
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func showConfirmationDeleteAlert()
    {
        QPAlert(self).showAlert(title: "Area Deleted Successfully", message: "The area has been deleted") {
            self.navigationController?.popViewController(animated: true)
        }
  
    }
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") {  (contextualAction, view, boolValue) in
            QPAlert(self).showAlert(title: "Are you sure you want to delete this area?", message: "The area will be deleted permenently and you won't be able to restore it", buttons: ["Cancel", "Yes"]) { _, index in
                if index == 1 {
                    let ref = Database.database().reference()
                    ref.child("Areas").child(self.parkings[indexPath.row].areaKey).removeValue { error, ref in
                        tableView.reloadData()
                    }
                    self.showConfirmationDeleteAlert()
                }
            }
           
        } // */
           
        
        
       /* let editAction = UIContextualAction(style: .normal, title: "Edit") {  (contextualAction, view, boolValue) in
            self.selectedArea = self.parkings[indexPath.row]
            let sender: Area? = self.parkings[indexPath.row]

            self.performSegue(withIdentifier: "GoToAdminEditAreaVC", sender: sender)
        } */
        
        let swipeActions = UISwipeActionsConfiguration(actions: [deleteAction])
        
        return swipeActions
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedArea = self.parkings[indexPath.row]
        let sender: Area? = self.parkings[indexPath.row]

        self.performSegue(withIdentifier: "GoToAdminEditAreaVC", sender: sender)
        
    }
    
}

/*override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {

    if (segue.identifier == "AdminEditAreaVC") {

        // initialize new view controller and cast it as your view controller
        var viewController = segue.destinationViewController as AdminEditAreaVC
        // your new view controller should have property that will store passed value
        viewController.selectedArea = curSelectedArea
    }

} */
