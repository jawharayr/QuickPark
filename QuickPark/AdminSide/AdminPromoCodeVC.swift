//
//  AdminPromoCodeVC.swift
//  QuickPark
//
//  Created by Deema on 22/09/1443 AH.
//

import UIKit
import FirebaseDatabase
import FirebaseStorage
import Firebase

let acceptableNameCharactors = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"

class CellClass: UITableViewCell{
    
}



class AdminPromoCodeVC: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    var thisCode: PromoCode?

    init(SelectedArea: String, promoCode: String, Precentage: String, Price: String, isvalid: Bool) {
        
        self.SelectedArea = SelectedArea
        self.promoCode = promoCode
        self.Precentage = Precentage
        self.Price = Price
        self.isvalid = isvalid

        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
         }

    

    @IBOutlet weak var PromoCodeTxt: UITextField!
    @IBOutlet weak var PromoCodeLabel: UILabel!
    @IBOutlet weak var PrecentageBtn: UIButton!
    @IBOutlet weak var PriceBtn: UIButton!
    @IBOutlet weak var Info: UIView!
    @IBOutlet weak var PriceTxt: UITextField!
    @IBOutlet weak var PrecentageTxt: UITextField!
    let pickerPrecentage = UIPickerView()
    @IBOutlet weak var PriceView: UIView!
    @IBOutlet weak var PrecentageView: UIView!
    @IBOutlet weak var SelectArea: UIButton!
    @IBOutlet weak var selectAreaLabel: UILabel!
    
    @IBOutlet weak var DiscountLabel: UILabel!
    private let database = Database.database().reference()

    var parkings = [Area]()
    var numbers = ["1", "2", "3", "4", "5","6", "7", "8", "9", "10", "11", "12", "13", "14", "15", "16", "17","18", "19", "20", "21", "22", "23", "24", "25", "26", "27", "28", "29", "30", "31", "32", "33", "34", "35", "36", "37", "38", "39", "40", "41", "42", "43", "44", "45", "46", "47", "48", "49", "50", "51","52", "53", "54", "55", "56", "57", "58", "59", "60", "61", "62", "63", "64", "65", "66", "67", "68", "69", "70", "71", "72", "73", "74", "75", "76", "77", "78", "79", "80", "81", "82", "83", "84", "85", "86", "87", "88", "89", "90", "91", "92", "93", "94", "95", "96", "97", "98", "99", "100"]
    
    var currentIndex = 0


    var selectedButton = UIButton()
    var dataSource = [String]()
    let transparentView = UIView()
    let tableView = UITableView()
    var namesList = [String]()

    var SelectedArea: String = " "
    var promoCode: String = " "
    var Precentage: String = " "
    var Price: String = " "
    var isvalid: Bool = true

    var codes = [PromoCode]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupViews()
        
       // view UI
        self.Info.layer.borderWidth = 1
        self.Info.layer.cornerRadius = 6
        self.Info.layer.borderColor = UIColor.white.cgColor
        self.Info.layer.masksToBounds = true
        self.Info.layer.shadowOpacity = 0.18
        self.Info.layer.shadowOffset = CGSize(width: 0, height: 2)
        self.Info.layer.shadowColor = UIColor.black.cgColor
        self.Info.layer.masksToBounds = false
        
        SelectArea.contentHorizontalAlignment = .left;
        SelectArea.setTitle("Areas", for: .normal)
        SelectArea.setTitleColor(UIColor.gray, for: UIControl.State.normal)
        
        pickerPrecentage.delegate = self
        pickerPrecentage.dataSource = self
      
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(CellClass.self, forCellReuseIdentifier: "Cell")
        

        //tool bar
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        //bar button(
        let btnDone = UIBarButtonItem(title: "Done" , style: .plain, target: self , action: #selector(closePicker))
        toolbar.setItems([btnDone], animated: true)
        PrecentageTxt.inputView = pickerPrecentage
        PrecentageTxt.inputAccessoryView = toolbar
      
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
       // parkings.removeAll()
        getParkings()
        getPromoCode()
//        if self.thisCode == nil {
//            self.PromoCodeTxt.text = ""
//            self.PriceTxt.text = ""
//            self.PrecentageTxt.text = ""
//      // self.SelectArea.currentTitle = "Areas"
//        }else{
            self.PromoCodeTxt.text = self.thisCode?.promoCode
            self.PriceTxt.text = self.thisCode?.Price
            self.PrecentageTxt.text = self.thisCode?.Precentage
            //self.SelectArea.currentTitle = self.thisCode?.selectedArea
        //}
    }
    

    func addTransparentView(frames: CGRect) {
        let window = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
        transparentView.frame = window?.frame ?? self.view.frame
        self.view.addSubview(transparentView)
        
        tableView.frame = CGRect(x: frames.origin.x + 20 , y: 210 + frames.origin.y + frames.height, width: frames.width, height: 0)
        self.view.addSubview(tableView)
        tableView.layer.cornerRadius = 5
        
        transparentView.backgroundColor = UIColor.black.withAlphaComponent(0.9)
        tableView.reloadData()
        let tapgesture = UITapGestureRecognizer(target: self, action: #selector(removeTransparentView))
        transparentView.addGestureRecognizer(tapgesture)
        transparentView.alpha = 0
        UIView.animate(withDuration: 0.4, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: .curveEaseInOut, animations: {
            self.transparentView.alpha = 0.5
            self.tableView.frame = CGRect(x: frames.origin.x + 20 , y: 210 + frames.origin.y + frames.height + 5, width: frames.width, height: CGFloat(self.dataSource.count * 50))
        }, completion: nil)
    }
    
    
    @objc func removeTransparentView() {
        let frames = selectedButton.frame
        UIView.animate(withDuration: 0.4, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: .curveEaseInOut, animations: {
            self.transparentView.alpha = 0
            self.tableView.frame = CGRect(x: frames.origin.x + 20 , y: 210 + frames.origin.y + frames.height, width: frames.width, height: 0)
        }, completion: nil)
    }
    
    private func getParkings() {
        let ref = Database.database().reference()
        ref.child("Areas").observe(DataEventType.value, with: { [self] snapshots in
            print(snapshots.childrenCount)
            parkings.removeAll()
            namesList = ["All Areas"]
            for snapshot in snapshots.children.allObjects as! [DataSnapshot] {
                let dictionary = snapshot.value as? NSDictionary
                let area = Area(areaKey : snapshot.key, areaname: dictionary?["areaname"] as? String ?? "", locationLat: dictionary?["locationLat"] as? Double ?? 0.0, locationLong: dictionary?["locationLong"] as? Double ?? 0.0, Value: dictionary?["Value"] as? Int ?? 0, isAvailable: dictionary?["isAvailable"] as? Bool ?? false, spotNo: dictionary?["spotNo"] as? Int ?? 0, logo: dictionary?["areaImage"] as? String ?? "", distance: 0.0)
                let names = area.areaname
                parkings.append(area)
                namesList.append(names)
                
            }
        })
    }
    
    private func getPromoCode() {
        let ref = Database.database().reference()
        ref.child("PromoCode").observe(DataEventType.value, with: { [self] snapshots in
            print("snapshots.childrenCount")
            print(snapshots.childrenCount)
            codes.removeAll()
            for snapshot in snapshots.children.allObjects as! [DataSnapshot] {
                let dictionary = snapshot.value as? NSDictionary
                let code = PromoCode(codeKey: snapshot.key, SelectedArea: dictionary?["SelectedArea"] as? String ?? "", promoCode: dictionary?["promoCode"] as? String ?? "",Precentage: dictionary?["Precentage"] as? String ?? "",Price: dictionary?["Price"] as? String ?? "", isvalid: dictionary?["isvalid"] as? Bool ?? false)
                codes.append(code)
            }
        })
    }

    @IBAction func BtnSelectArea(_ sender: Any) {
        dataSource = namesList
        selectedButton = SelectArea
        SelectArea.setTitleColor(UIColor("#297ab3"), for: UIControl.State.normal)
        addTransparentView(frames: SelectArea.frame)
    }
    
    
    
    @IBAction func BtnPrecentage(_ sender: Any) {
        DiscountLabel.isHidden = true
        self.PriceTxt?.text = nil
        PriceView.isHidden = true
        PrecentageView.isHidden = false
    }
    
  
    @IBAction func BtnPrice(_ sender: Any) {
        DiscountLabel.isHidden = true
        self.PrecentageTxt?.text = nil
        PriceView.isHidden = false
        PrecentageView.isHidden = true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return numbers.count
    }
    
    func pickerView(_ pickerView:UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return numbers[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        currentIndex = row
        PrecentageTxt.text = numbers[row] }
    
    
    @objc func closePicker(){
        PrecentageTxt.text = numbers[currentIndex]
        view.endEditing(true)
    }
    
    
    @IBAction func AddPromoCode(_ sender: Any) {
        
        if validate() == false {return}
        
        if validate() == true {
            promoCode = PromoCodeTxt.text!.replacingOccurrences(of: " ", with: "")

            SelectedArea = SelectArea.currentTitle!
            Precentage = PrecentageTxt.text!.replacingOccurrences(of: " ", with: "")
            Price = PriceTxt.text!.replacingOccurrences(of: " ", with: "")

        
            
        let object: [String : Any] = ["promoCode": promoCode as Any ,"SelectedArea": SelectedArea, "Precentage": Precentage, "Price": Price, "isvalid": isvalid]
        
        var codeKey = "PromoCode_\(promoCode)"
        if self.thisCode != nil {
            codeKey = self.thisCode?.codeKey ?? "PromoCode_0000"
        }
        database.child("PromoCode").child(codeKey).setValue(object) { error, ref in
            self.ConfirmationAlert()
        }
        }
        }

    func ConfirmationAlert()
    {
        QPAlert(self).showAlert(title: "Promo code Added Successfully", message: "The promo code has been added.") {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    func setupViews() {
        
        self.PromoCodeTxt?.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        self.PrecentageTxt?.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        self.PriceTxt?.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        self.SelectArea?.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)

    }

    @objc func textFieldDidChange(textField: UITextField){
        
        if textField == PromoCodeTxt {
            _ = self.isValidPromoCode()
        }
        if textField == SelectArea {
            _ = self.isValidSelectedArea()
        }
        if textField == PrecentageTxt {
            _ =  self.isValidPercentage()
        }
        if textField == PriceTxt {
            _ = self.isValidPrice()
        }
    }
    
    func validate() -> Bool {
        
        PromoCodeLabel.isHidden = true
        selectAreaLabel.isHidden = true
        DiscountLabel.isHidden = true
        
        var isValid = true
        if self.isValidPromoCode() == false  {
            isValid = false
        }
        if self.isValidSelectedArea() == false  {
            isValid = false
        }
        if self.isValidPercentage() == false && self.isValidPrice() == false{
            isValid = false
      }
//        if self.isValidPrice() == false {
//            isValid = false
//        }
        return isValid
    }
    
    func checkPromoCodeExist(thisPromoCode : String) -> Bool {

        for code in self.codes {
            if code.promoCode.caseInsensitiveCompare(thisPromoCode) == .orderedSame {
                return true
            }
        }
    return false
    
    }
               
    // check promocode
    func isValidPromoCode() -> Bool{
        
        let PromoCodeTx = PromoCodeTxt.text ?? "".replacingOccurrences(of: " ", with: "")

        if PromoCodeTx.isEmpty {
            PromoCodeLabel.isHidden = false
            PromoCodeLabel.attributedText = NSAttributedString(string: "Please Enter the Promo Code", attributes: [NSAttributedString.Key.foregroundColor: UIColor.red])
            return false
        }
        
        let isExist = checkPromoCodeExist(thisPromoCode: PromoCodeTx)
        if isExist == true {
            self.PromoCodeLabel.isHidden = false
            self.PromoCodeLabel.attributedText = NSAttributedString(string: "Promo Code is already exist", attributes: [NSAttributedString.Key.foregroundColor: UIColor.red])
            return false
        }

     
        if PromoCodeTx.count > 16 || PromoCodeTx.count < 3 {
            PromoCodeLabel.isHidden = false
            PromoCodeLabel.attributedText = NSAttributedString(string: "Promo Code should have min 3 characters and max 16 characters", attributes: [NSAttributedString.Key.foregroundColor: UIColor.red])
            return false
        }
        
        if !PromoCodeTx.isPString {
            PromoCodeLabel.isHidden = false
            PromoCodeLabel.attributedText = NSAttributedString(string: "Promo Code should contain only numbers and letters", attributes: [NSAttributedString.Key.foregroundColor: UIColor.red])
            return false
        }

    PromoCodeLabel.isHidden = true
        return true
    }
    
    // check selected area
    func isValidSelectedArea() -> Bool{
    
        if SelectArea.currentTitle == "Areas" || SelectArea.currentTitle == nil{
           
            selectAreaLabel.isHidden = false
            selectAreaLabel.attributedText = NSAttributedString(string: "Please Select Area", attributes: [NSAttributedString.Key.foregroundColor: UIColor.red])
            return false
        }
        
        return true
    }
                        
    func isValidPercentage()-> Bool{

        let DiscountTxt = PrecentageTxt.text ?? ""//?.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() ??""
        DiscountLabel.isHidden = true
        if DiscountTxt.isEmpty {
            DiscountLabel.isHidden = false
            DiscountLabel.attributedText = NSAttributedString(string: "Please select the the discount Percentage", attributes: [NSAttributedString.Key.foregroundColor: UIColor.red])
            return false
        }
        
        
        if !DiscountTxt.isNumeric {
            DiscountLabel.isHidden = false
            DiscountLabel.attributedText = NSAttributedString(string: "Percentage should contain only numbers", attributes: [NSAttributedString.Key.foregroundColor: UIColor.red])
            return false
        }
        
        if DiscountTxt.count > 5 {
            PromoCodeLabel.isHidden = false
            PromoCodeLabel.attributedText = NSAttributedString(string: "Percentage should have max 5 characters", attributes: [NSAttributedString.Key.foregroundColor: UIColor.red])
            return false
        }
        return true
    }
    

    func isValidPrice()-> Bool{

        let DiscountTxt = PriceTxt.text ?? ""//?.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() ??""
    
        if DiscountTxt.isEmpty {
            DiscountLabel.isHidden = false
            DiscountLabel.attributedText = NSAttributedString(string: "Please select the the discount price", attributes: [NSAttributedString.Key.foregroundColor: UIColor.red])
            return false
        }
        if !DiscountTxt.isNumeric {
            DiscountLabel.isHidden = false
            DiscountLabel.attributedText = NSAttributedString(string: "Price should contain only numbers", attributes: [NSAttributedString.Key.foregroundColor: UIColor.red])
            return false
        }
        
        if DiscountTxt.count > 5 {
            PromoCodeLabel.isHidden = false
            PromoCodeLabel.attributedText = NSAttributedString(string: "Price should have max 5 characters", attributes: [NSAttributedString.Key.foregroundColor: UIColor.red])
            return false
        }
        return true
    }
}

extension AdminPromoCodeVC: UITableViewDelegate, UITableViewDataSource {
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return dataSource.count
        }
        
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
            cell.textLabel?.text = dataSource[indexPath.row]
            return cell
        }
        
        func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
            return 50
        }
        
        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            selectedButton.setTitle(dataSource[indexPath.row], for: .normal)
            removeTransparentView()
        }
    }

extension String {
    var isAlphanumerics: Bool {
        let regex = try! NSRegularExpression(pattern: "[^a-zA-Z][^0-9][^a-zA-Z]", options: [])///^[a-z ,.'-]+$/i
        if regex.firstMatch(in: self, options: [], range: NSMakeRange(0, self.count)) != nil {
            return false
        }else{
            return true
        }
    }
}

extension AdminPromoCodeVC : UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == PromoCodeTxt {
            let cs = CharacterSet.init(charactersIn: acceptableNameCharactors).inverted
            let filtered = string.components(separatedBy: cs).joined(separator: "")
            return (string == filtered)
        }
        return true
    }
}
