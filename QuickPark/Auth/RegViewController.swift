//
//  RegViewController.swift
//  QuickPark
//
//  Created by Ghaliah Binakeel on 01/02/2022.
//

import UIKit

class RegViewController: UIViewController {
    @IBOutlet weak var nameField: UITextField!
 
    @IBOutlet weak var emailField: UITextField!
    
    @IBOutlet weak var genderField: UITextField!
    
    @IBOutlet weak var passOfRegField: UITextField!
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func AgreedPressed(_ sender: Any) {
    }
    
    @IBAction func goToTermsAndPolicy(_ sender: Any) {
    }
    
    @IBAction func regPressed(_ sender: Any) {
    }
    
    @IBAction func goToLoginPressed(_ sender: Any) {
        self.performSegue(withIdentifier: "GotoLog", sender: nil)
    }
    func validateREgFields () -> String? {
        emailField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
        passOfRegField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
        nameField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
        genderField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == ""
        ; do {
            return "please fill in all the fields"
        }
    }
    
    func isPasswordValid(_ password : String) -> Bool{
        let passwordTest = NSPredicate(format: "SELF MATCHES %@", "^(?=.*[a-z])(?=.*[$@$#!%*?&])[A-Za-z\\d$@$#!%*?&]{8,}")
        return passwordTest.evaluate(with: password)
    }
    
    
    
}
