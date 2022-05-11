//
//  ViewPromoCodeVC.swift
//  QuickPark
//
//  Created by Deema on 27/09/1443 AH.
//

import UIKit
import FirebaseDatabase
import Foundation
import FirebaseAuth

class ViewPromoCodeVC: UIViewController {

    var promocodeList = [PromoCode]()
    var ref:DatabaseReference!
    var promocode:PromoCode!
    

    @IBOutlet weak var ViewLabel: UILabel!
    @IBOutlet weak var CodeTable: UITableView!


    override func viewDidLoad() {
        super.viewDidLoad()
        
        CodeTable.delegate = self
        CodeTable.dataSource = self
        ViewLabel.isHidden = true
        
 
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        promocodeList.removeAll()
        getPromoCode()
        
   
    }
    
    @IBAction func AddPromoCodes(_ sender: Any) {
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "AdminPromoCodeVC") as? AdminPromoCodeVC

            navigationController?.pushViewController(vc!, animated: true)
        
    }
    
    
    
    
    
    private func getPromoCode() {
        let ref = Database.database().reference()
        ref.child("PromoCode").observe(DataEventType.value, with: { [self] snapshots in
            print("snapshots.childrenCount")
            print(snapshots.childrenCount)
            promocodeList.removeAll()
            for snapshot in snapshots.children.allObjects as! [DataSnapshot] {
                let dictionary = snapshot.value as? NSDictionary
                let code = PromoCode(codeKey: snapshot.key, SelectedArea: dictionary?["SelectedArea"] as? String ?? "", promoCode: dictionary?["promoCode"] as? String ?? "",Precentage: dictionary?["Precentage"] as? String ?? "",Price: dictionary?["Price"] as? String ?? "", isvalid: dictionary?["isvalid"] as? Bool ?? false)
                promocodeList.append(code)
            }
            CodeTable.reloadData()
        })
        if promocodeList.isEmpty || promocodeList.count == 0 {
            ViewLabel.isHidden = false
        }
 }


}

extension ViewPromoCodeVC: UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        CodeTable.backgroundColor = UIColor("#F5F5F5")
        return 60
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 125
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("promocodeList number of rows")
        print(promocodeList.count)
        return promocodeList.count
        }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
    let cell = tableView.dequeueReusableCell(withIdentifier: "PromoCodeCell") as! PromoCodeCell
        let object = promocodeList[indexPath.row]
        
        cell.promocode.text = object.promoCode
        cell.Area.text = object.SelectedArea
        if object.Precentage == "" || object.Precentage == " " {
            cell.Discount.text = "-" + object.Price + " SAR"
        }
        
        if object.Price == "" || object.Price == " " {
            cell.Discount.text = object.Precentage + "%"
        }
       // vc?.Discount = obj.
        return cell
    }
    
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//
//       let vc = self.storyboard?.instantiateViewController(withIdentifier: "EditPromoCodeVC") as? EditPromoCodeVC
////         let vc = (UIStoryboard(name: "AdminMain", bundle: nil).instantiateViewController(withIdentifier: "EditPromoCodeVC") as! EditPromoCodeVC)
//
////        let sb = UIStoryboard(name:"AdminMain",bundle: Bundle.main)
////        let vc = sb.instantiateViewController(withIdentifier: "EditPromoCodeVC") as! EditPromoCodeVC
//
//        let obj = self.promocodeList[indexPath.row]
//        vc?.PromoCodeTxt.text = obj.promoCode
//        vc?.SelectArea.setTitle(obj.SelectedArea, for: .normal)
//
//        if obj.Precentage == ""  {
//            vc?.PriceTxt.text = obj.Price
//            vc?.DiscountLabel.isHidden = true
//            vc?.PrecentageTxt?.text = " "
//            vc?.PriceView.isHidden = false
//            vc?.PrecentageView.isHidden = true
//        }
//
//        if obj.Price == ""  {
//            vc?.PrecentageTxt.text = obj.Precentage
//            vc?.DiscountLabel.isHidden = true
//            vc?.PriceTxt?.text = " "
//            vc?.PriceView.isHidden = true
//            vc?.PrecentageView.isHidden = false
//        }
//
//        navigationController?.pushViewController(vc!, animated: true)
//                }
    
    func showConfirmationDeleteAlert()
    {
        QPAlert(self).showAlert(title: "Promo Code Deleted Successfully", message: "The promo code has been deleted") {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
        func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
            let deleteAction = UIContextualAction(style: .destructive, title: "Delete") {  (contextualAction, view, boolValue) in
                QPAlert(self).showAlert(title: "Are you sure you want to delete this promo code?", message: "The promo code will be deleted permenently and you won't be able to restore it", buttons: ["Cancel", "Yes"]) { _, index in
                    if index == 1 {
                        let ref = Database.database().reference()
                        ref.child("PromoCode").child(self.promocodeList[indexPath.row].codeKey).removeValue { error, ref in
                            tableView.reloadData()
                        }
                        self.showConfirmationDeleteAlert()
                    }
                }
               
            }
            
            let swipeActions = UISwipeActionsConfiguration(actions: [deleteAction])
            return swipeActions
        }
        
        
    func addShadow(backgroundColor: UIColor = .white, cornerRadius: CGFloat = 12, shadowRadius: CGFloat = 5, shadowOpacity: Float = 0.1, shadowPathInset: (dx: CGFloat, dy: CGFloat), shadowPathOffset: (dx: CGFloat, dy: CGFloat)) {
        
    } }

