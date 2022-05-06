//
//  EditPromoCodeVC.swift
//  QuickPark
//
//  Created by Deema on 27/09/1443 AH.
//

import UIKit
import FirebaseDatabase
import FirebaseStorage
import Firebase

class EditPromoCodeVC: UIViewController {

    @IBOutlet weak var Info: UIView!

//    @IBOutlet weak var PrecentageBtn: UIButton!
//    @IBOutlet weak var PriceBtn: UIButton!
    var SelectedArea: String = " "
    var promoCode: String = " "
    var Precentage: String = " "
    var Price: String = " "
    var isvalid: Bool = true
    
    @IBOutlet weak var PromoCodeTxt: UITextField!
    @IBOutlet weak var PromoCodeLabel: UILabel!
    @IBOutlet weak var SelectArea: UIButton!
    @IBOutlet weak var selectAreaLabel: UILabel!
    @IBOutlet weak var PrecentageTxt: UITextField!
    @IBOutlet weak var PriceTxt: UITextField!
    @IBOutlet weak var PriceView: UIView!
    @IBOutlet weak var PrecentageView: UIView!
    @IBOutlet weak var DiscountLabel: UILabel!
    
    



    private let database = Database.database().reference()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    
        PromoCodeTxt.text = promoCode
        SelectArea.setTitle(SelectedArea, for: .normal)
        PrecentageTxt.text = Precentage
        PriceTxt.text = Price
        
        
        self.Info.layer.borderWidth = 1
        self.Info.layer.cornerRadius = 20
        self.Info.layer.borderColor = UIColor.white.cgColor
        self.Info.layer.masksToBounds = true

        self.Info.layer.shadowOpacity = 0.18
        self.Info.layer.shadowOffset = CGSize(width: 0, height: 2)
        self.Info.layer.shadowColor = UIColor.black.cgColor
        self.Info.layer.masksToBounds = false
        self.Info.layer.cornerRadius = 15
    }
    

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Do any additional setup after loading the view.

        }

}
