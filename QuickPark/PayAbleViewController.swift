//
//  PayAbleViewController.swift
//  QuickPark
//
//  Created by Macbook Pro on 22/02/2022.
//

import UIKit
import Braintree
import FirebaseDatabase

class PayAbleViewController: UIViewController {
    @IBOutlet weak var lblPrice:UILabel!
    @IBOutlet weak var lblExtra:UILabel!
    @IBOutlet weak var lblTotal:UILabel!
    @IBOutlet weak var mainView:UIView!
    
    var price = ""
    var total = ""
    var extra = ""
    var reservation:Reservation!
    
    private let database = Database.database().reference()
    
    //for paypal
    var braintreeClient: BTAPIClient!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        lblPrice.text = price + " SAR"
        lblExtra.text = extra + " SAR"
        lblTotal.text = total + " SAR"
        mainView.layer.cornerRadius = 20
        
        //Paypal
        braintreeClient = BTAPIClient(authorization: "sandbox_5rv25jbw_qf575jr29ngyc4r9")
    }
    
    func openExitQRCodePage(){
        let unique = String("\(Date().timeIntervalSince1970)").replacingOccurrences(of: ".", with: "")
        print("My unique QR code: ",unique)
        if let image = generateQRCode(using: unique){
            
            let object: [String : Any] = ["isScanned":false]
            database.child("QRCode").child(unique).setValue(object) { error, ref in
                print("Error wihle saving QRCode to Firebase. Error= ",error?.localizedDescription)
            }
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "QRCodeVC") as! QRCodeVC
            vc.image = image
            vc.reservation = self.reservation
            vc.exitQRCode = unique
            vc.modalPresentationStyle = .overFullScreen
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    @IBAction func payTapped(){
    /*    if let image = generateQRCode(using: "test"){
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "QRCodeVC") as! QRCodeVC
            vc.image = image
            vc.reservation = self.reservation
            vc.modalPresentationStyle = .overFullScreen
            self.present(vc, animated: true, completion: nil)
        } */
        
        // openExitQRCodePage()
        let payPalDriver = BTPayPalDriver(apiClient: braintreeClient)
        let request = BTPayPalCheckoutRequest(amount: total)
        request.currencyCode = "USD" // Optional; see BTPayPalCheckoutRequest.h for more options

        payPalDriver.tokenizePayPalAccount(with: request) { (tokenizedPayPalAccount, error) in
            if let tokenizedPayPalAccount = tokenizedPayPalAccount {
                print("Got a nonce: \(tokenizedPayPalAccount.nonce)")
                // Access additional information
                let email = tokenizedPayPalAccount.email
                let firstName = tokenizedPayPalAccount.firstName
                let lastName = tokenizedPayPalAccount.lastName
                let phone = tokenizedPayPalAccount.phone

                // See BTPostalAddress.h for details
                let billingAddress = tokenizedPayPalAccount.billingAddress
                let shippingAddress = tokenizedPayPalAccount.shippingAddress
            } else if let error = error {
                // Handle error here...
                print(error)
            } else {
                // Buyer canceled payment approval
            }
        }
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


// PayPal
extension PayAbleViewController: BTViewControllerPresentingDelegate{
    func paymentDriver(_ driver: Any, requestsPresentationOf viewController: UIViewController) {
        
    }
    
    func paymentDriver(_ driver: Any, requestsDismissalOf viewController: UIViewController) {
        
    }
}
