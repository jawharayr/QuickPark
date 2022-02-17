//
//  resetPassViewController.swift
//  QuickPark
//
//  Created by Ghaliah Binakeel on 11/02/2022.
//

import UIKit
import SVProgressHUD

class TVCResetPassword: UITableViewController {

    @IBOutlet weak var emailTextField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func doneButtonPressed(_ sender: Any) {
        guard let email = emailTextField.text, email.count > 3 else {
            SVProgressHUD.showError(withStatus: "Invalid Email")
            return
        }
        
        FBAuth.resetPasword(email: email) { error in
            if let e = error {
                SVProgressHUD.showError(withStatus: e.localizedDescription)
            }else{
                SVProgressHUD.showSuccess(withStatus: "Reset link sent to your registered email. Please follow the instruction to update the password.")
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
}
