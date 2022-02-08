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
   

   
    @IBOutlet weak var StartTime: UITextField!
    

    
    @IBOutlet weak var StartEndView: UIView!
  
    @IBOutlet weak var PriceView: UIView!
    @IBOutlet weak var ConfirmButton: UIButton!
    
   
    @IBOutlet weak var PayButton: UIButton!
    @IBOutlet weak var BlueView: UIView!
    let timePicker = UIDatePicker()
    @IBOutlet weak var ParkingsViews: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        ParkingsViews?.delegate = self
        ParkingsViews?.dataSource = self
        //making table view look good
        ParkingsViews?.separatorStyle = .none
        ParkingsViews?.showsVerticalScrollIndicator = false
        
        
      
        
    }
    @objc func doneButtonClicked()
    {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        StartTime.text = formatter.string(from: timePicker.date)
        self.view.endEditing(true)
        
    }
}
    extension ViewController: UITableViewDelegate, UITableViewDataSource{
        func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
            return 60
        }
        func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
            return 120
        }
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return parkings.count
        }
        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
                            let viewController = storyboard.instantiateViewController(withIdentifier: "ConfirmAndPay")
                            
                            if let presentationController = viewController.presentationController as? UISheetPresentationController {
                                presentationController.detents = [.medium()] /// change to [.medium(), .large()] for a half and full screen sheet
                            }
                            
                            self.present(viewController, animated: true)
        }
        
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = ParkingsViews.dequeueReusableCell(withIdentifier: "CustomCell") as! CustomCell
            let parking = parkings[indexPath.row]
            cell.Logos.image = UIImage(named: parking)
            cell.Label.text = parking
            cell.ParkingView.layer.cornerRadius = cell.ParkingView.frame.height / 2
            cell.Logos.layer.cornerRadius = cell.Logos.frame.height / 2
            cell.ParkingView.layer.borderWidth = 1
            let borderColor: UIColor =  (parkings[indexPath.row] == " ") ? .red : UIColor(red: 0/225, green: 144/255, blue: 205/255, alpha: 1)
            (parkings[indexPath.row] == " ") ? (cell.Alert.text = "No Available Parkings") : (cell.Alert.text = " ")
            cell.ParkingView.layer.borderColor = borderColor.cgColor
            return cell
        }
      
            }





