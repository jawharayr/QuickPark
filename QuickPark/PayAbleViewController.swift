//
//  PayAbleViewController.swift
//  QuickPark
//
//  Created by Macbook Pro on 22/02/2022.
//

import UIKit
import Firebase
import Braintree
import FirebaseDatabase

class PayAbleViewController: UIViewController {
    @IBOutlet weak var lblPrice:UILabel!
    @IBOutlet weak var lblExtra:UILabel!
    @IBOutlet weak var lblTotal:UILabel!
    @IBOutlet weak var mainView:UIView!
    
    @IBOutlet weak var RegenerateMsg: UILabel!
    @IBAction func XButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBOutlet weak var payButton: UIButton!
    @IBOutlet weak var PromoTxt: UITextField!
    
    @IBOutlet weak var KSULabel: UILabel!
    var ref:DatabaseReference!
    var price = ""
    var total = ""
    var extra = ""
    var promocode = ""
    var reservation:Reservation!
    
    private let database = Database.database().reference()
    var braintreeClient: BTAPIClient!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        RegenerateMsg.isHidden = true
        ref = Database.database().reference()
        PromoTxt.delegate = self
        lblPrice.text = price + " SAR"
        lblExtra.text = extra + " SAR"
        lblTotal.text = total + " SAR"
        if reservation.area == ""{
            KSULabel.text = "King Saud University"
        }else {
            KSULabel.text = reservation.area
        }
        mainView.layer.cornerRadius = 20
        braintreeClient = BTAPIClient(authorization: "sandbox_5rv25jbw_qf575jr29ngyc4r9")
        
        if ParkingManager.shared.paymentMadeWithoutExit {
            payButton.setTitle("Pay & Re-generate QRCode", for: .normal)
            RegenerateMsg.isHidden = false
        }
        
        displayValue()
    }
    
    func displayValue() {
        lblPrice.text = price + " SAR"
        lblExtra.text = extra + " SAR"
        lblTotal.text = total + " SAR"
    }
    
    func track(qrcode code: String){
        Database.database().reference().child("QRCode").child(code).observe(.value) { dataSnap in
            if dataSnap.exists(){
                guard let reserDict = dataSnap.value as? [String:Any] else{return}
                if let isScanned = reserDict["isScanned"] as? Bool, isScanned{
                    self.dismiss(animated: false, completion: nil)
                    QPLNSupport.remove(self.reservation.id)
                }
            }
        }
    }
    
    @IBAction func payTapped(){
        let payPalDriver = BTPayPalDriver(apiClient: braintreeClient)
        let request = BTPayPalCheckoutRequest(amount: total)
        //let request = BTPayPalCheckoutRequest(amount: "90")//test line
        request.currencyCode = "USD" // Optional; see BTPayPalCheckoutRequest.h for more options
        
        payPalDriver.tokenizePayPalAccount(with: request) { (tokenizedPayPalAccount, error) in
            if let tokenizedPayPalAccount = tokenizedPayPalAccount {
                print("Got a nonce: \(tokenizedPayPalAccount.nonce)")
                /*let email = tokenizedPayPalAccount.email
                 let firstName = tokenizedPayPalAccount.firstName
                 let lastName = tokenizedPayPalAccount.lastName
                 let phone = tokenizedPayPalAccount.phone
                 
                 // See BTPostalAddress.h for details
                 let billingAddress = tokenizedPayPalAccount.billingAddress
                 let shippingAddress = tokenizedPayPalAccount.shippingAddress*/
                
                self.openExitQRCodePage()
            } else if let error = error {
                print(error)
            } else {
                print("Buyer canceled payment approval")
            }
        }
    }
    
    func openExitQRCodePage(){
        let uniqueQRCode = String("\(Date().timeIntervalSince1970)").replacingOccurrences(of: ".", with: "")
        if let image = generateQRCode(using: uniqueQRCode){
            let object: [String : Any] = ["isScanned":false]
            database.child("QRCode").child(uniqueQRCode).setValue(object) { error, ref in
                print("Error wihle saving QRCode to Firebase. Error= ",error?.localizedDescription ?? "Unknown Error")
            }
            
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "QRCodeVC") as! QRCodeVC
            vc.image = image
            vc.reservation = self.reservation
            vc.exitQRCode = uniqueQRCode
            vc.modalPresentationStyle = .overFullScreen
            self.present(vc, animated: true, completion: nil)
            
            let paidActiveParking = PaidActiveParking(lastPaidTime: Date().timeIntervalSince1970, lastPaidAmount: total.floatValue, totalPaidAmount: total.floatValue)
            ParkingManager.shared.paidActiveParking = paidActiveParking
        }
    }
    
    @objc func exitParkingQRCodeExpired() {
        payButton.setTitle("Pay Margin", for: .normal)
    }
    
    func updateValues() {
        
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
}

extension CIImage {
    var transparent: CIImage? {
        return inverted?.blackTransparent
    }
    
    var inverted: CIImage? {
        guard let invertedColorFilter = CIFilter(name: "CIColorInvert") else { return nil }
        invertedColorFilter.setValue(self, forKey: "image")
        return invertedColorFilter.outputImage
    }
    
    var blackTransparent: CIImage? {
        guard let blackTransparentCIFilter = CIFilter(name: "CIMaskToAlpha") else { return nil }
        blackTransparentCIFilter.setValue(self, forKey: "image")
        return blackTransparentCIFilter.outputImage
    }
    
    func tinted(using color: UIColor) -> CIImage? {
        guard
            let transparentQRImage = transparent,
            let filter = CIFilter(name: "CIMultiplyCompositing"),
            let colorFilter = CIFilter(name: "CIConstantColorGenerator") else { return nil }
        
        let ciColor = CIColor(color: color)
        colorFilter.setValue(ciColor, forKey: kCIInputColorKey)
        let colorImage = colorFilter.outputImage
        filter.setValue(colorImage, forKey: kCIInputImageKey)
        filter.setValue(transparentQRImage, forKey: kCIInputBackgroundImageKey)
        return filter.outputImage!
    }
    
    func addLogo(with image: CIImage) -> CIImage? {
        guard let combinedFilter = CIFilter(name: "CISourceOverCompositing") else { return nil }
        let centerTransform = CGAffineTransform(translationX: extent.midX - (image.extent.size.width / 2), y: extent.midY - (image.extent.size.height / 2))
        combinedFilter.setValue(image.transformed(by: centerTransform), forKey: "image")
        combinedFilter.setValue(self, forKey: "inputBackgroundImage")
        return combinedFilter.outputImage!
    }
}


// PayPal
extension PayAbleViewController: BTViewControllerPresentingDelegate{
    func paymentDriver(_ driver: Any, requestsPresentationOf viewController: UIViewController) {
        
    }
    
    func paymentDriver(_ driver: Any, requestsDismissalOf viewController: UIViewController) {
        
    }
}
extension PayAbleViewController:UITextFieldDelegate{
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if let text = textField.text,
           let textRange = Range(range, in: text) {
            let updatedText = text.replacingCharacters(in: textRange,with: string)
            if updatedText.count == 5{
                checkPromoCode(promoCode: updatedText)
                return true
            }else if updatedText.count > 5{
                return false
            }
            
        }
        return true
    }
    
    func checkPromoCode(promoCode:String){
        let completePromo = "PromoCode_"+promoCode
        
        ref.child("PromoCode").child(completePromo).observeSingleEvent(of: .value) { dataSnap in
            if dataSnap.exists(){
                let promoData = Promo.init(dict: dataSnap.value as? [String:Any] ?? [:])
                if promoData.SelectedArea == "All Areas" || self.reservation.area == promoData.SelectedArea {
                    self.makeDiscount(promo: promoData)
                }else{
                    UtilitiesManager.sharedIntance.showAlert(title: "Oops", message: "\(promoCode) is not available for this parking area.", VC: self)
                    self.PromoTxt.text = ""
                }
            }else{
                UtilitiesManager.sharedIntance.showAlert(title: "Oops", message: "\(promoCode) is invalid or Expired.", VC: self)
                self.PromoTxt.text = ""
            }
        }
    }
    
    func makeDiscount(promo:Promo){
        
        if promo.Precentage != ""{
            
            self.total = "\(Double(total)!-(calculatePercentage(value: Double(total)!,percentageVal: Double(promo.Precentage) ?? 0)))"
            self.lblTotal.text = self.total
            self.PromoTxt.isUserInteractionEnabled = false
            self.PromoTxt.resignFirstResponder()

//            let percentage = (Double(promo.Precentage) ?? 0) / 100
//            let discountedPrice = Double(total) ?? 0.0 - (Double(total) ?? 0.0 * percentage)
//            self.total = "\(discountedPrice.rounded())"
//            self.lblTotal.text = "\(discountedPrice.rounded())"
        }else if promo.Price != ""{
            let discountedPrice = Double(total)! - Double(promo.Price)!
            self.total = "\(discountedPrice.rounded())"
            self.lblTotal.text = "\(discountedPrice.rounded())"
            self.PromoTxt.isUserInteractionEnabled = false
            self.PromoTxt.resignFirstResponder()
        }
        
    }
    
    
}


class Promo{
   
    var Precentage:String
    var Price:String
    var SelectedArea:String
    var  isvalid:Bool
    var promoCode:String

    //    "All Areas"

   
    init(Precentage: String,Price:String, SelectedArea: String, isvalid: Bool, promoCode: String) {
        self.Precentage = Precentage
        self.Price = Price
        self.SelectedArea = SelectedArea
        self.isvalid = isvalid
        self.promoCode = promoCode
    }
    
    
    init(dict:[String:Any]){
        self.Precentage = dict["Precentage"] as? String ?? ""
        self.SelectedArea = dict["SelectedArea"] as? String ?? ""
        self.Price = dict["Price"] as? String ?? ""
        self.isvalid = dict["isvalid"] as? Bool ?? false
        self.promoCode = dict["promoCode"] as? String ?? ""
    }
    
    
    
}


public func calculatePercentage(value:Double,percentageVal:Double)->Double{
    let val = value * percentageVal
    return val / 100.0
}
