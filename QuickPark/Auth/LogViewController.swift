//
//  LogViewController.swift
//  QuickPark
//
//  Created by Ghaliah Binakeel on 01/02/2022.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

class LogViewController: UIViewController {
     private let database = Database.database().reference()
    @IBOutlet weak var emailField: UITextField!
    
    
    @IBOutlet weak var passField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func ForgetPassPressed(_ sender: Any) {
    }
    
    @IBAction func loginPressed(_ sender: Any) {
        Add()
    }
    
    @IBAction func GoRegPressed(_ sender: Any) {
        self.performSegue(withIdentifier: "GoReg", sender: nil)
    }
    
    
    
   
    @objc private func Add() {
   let object: [String : Any] = [
    "email" : "\(String(describing: emailField.text))" as NSObject,
    "Pass" : "\(String(describing: passField.text))"
    ]
        database.child("user_\(Int.random(in: 0..<3000))").setValue(object)
    }
    
    func validateLogFields () -> String? {
        emailField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
        passField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == ""
        ; do {
            return "please fill in all the fields"
        }
    }
    /* func validateRegFields () -> String? {
         //all fields are filled
         emailField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
         passOfRegField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
         confirmPas.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
         nameField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == ""
         ; do {
             return "please fill in all the fields"
         }
         let securePass = passOfRegField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
         
         if isPasswordValid(securePass) == false {
          return "error msg"
         }
     }
     
     func isPasswordValid(_ password : String) -> Bool{
         let passwordTest = NSPredicate(format: "SELF MATCHES %@", "^(?=.*[a-z])(?=.*[$@$#!%*?&])[A-Za-z\\d$@$#!%*?&]{8,}")
         return passwordTest.evaluate(with: password)
     } */
     
     
     
     
     /* @IBAction func actionSignUp(_ sender: UIButton) {
         if textFieldName.text?.isEmpty == true || textFieldEmail.text?.isEmpty == true || textFieldPassword.text?.isEmpty == true {
         }
         if validate() {
             guard let email = textFieldEmail.text, let password = textFieldPassword.text else { return
             }
             emailAuth(email: email, password: password)
        }
     
         
    }
     
     func validate() -> Bool {
         var isValid = true
         let name = textFieldName.text?.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() ?? ""
         let email = textFieldEmail.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
         let password = textFieldPassword.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
         let password2 = textFieldPasswordConfirm.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
         
         // Name Validations
         if name.isEmpty {
             nameLabel.isHidden = false
             nameLabel.attributedText = NSAttributedString(string: "Please enter Your Name", attributes: [NSAttributedString.Key.foregroundColor: UIColor.red])
             textFieldName.shake()
             isValid = false
         }
         if !name.isAlphanumeric || name.count < 3 && !name.isEmpty {
             nameLabel.isHidden = false
             nameLabel.attributedText = NSAttributedString(string: "Name should have alphabets and min 3 characters", attributes: [NSAttributedString.Key.foregroundColor: UIColor.red])
             textFieldName.shake()
             isValid = false
         }
         if !name.isEmpty && name.count >= 3 && name.isAlphanumeric {
             nameLabel.isHidden = true
         }
         
         // Email Validations
         if email.isEmpty {
             emailLabel.isHidden = false
             emailLabel.attributedText = NSAttributedString(string: "Please enter Your Email", attributes: [NSAttributedString.Key.foregroundColor: UIColor.red])
             textFieldEmail.shake()
             isValid = false
         }
         if !email.isValidEmail && !email.isEmpty {
             emailLabel.isHidden = false
             emailLabel.attributedText = NSAttributedString(string: "Please enter Your Valid Email", attributes: [NSAttributedString.Key.foregroundColor: UIColor.red])
             textFieldEmail.shake()
             isValid = false
         }
         if email.isValidEmail && !email.isEmpty {
             emailLabel.isHidden = true
         }
         
         // Password Validations
         if password.isEmpty {
             passwordLabel.isHidden = false
             passwordLabel.attributedText = NSAttributedString(string: "Please enter Your Password", attributes: [NSAttributedString.Key.foregroundColor: UIColor.red])
             textFieldPassword.shake()
             isValid = false
         }
         if password2.isEmpty {
             confirmLabel.isHidden = false
             confirmLabel.attributedText = NSAttributedString(string: "Please confirm Your Password", attributes: [NSAttributedString.Key.foregroundColor: UIColor.red])
             textFieldPasswordConfirm.shake()
             isValid = false
         }
         if !password.isEmpty && !password2.isEmpty {
             if password != password2 {
                 confirmLabel.isHidden = false
                 confirmLabel.attributedText = NSAttributedString(string: "Passwords do not match", attributes: [NSAttributedString.Key.foregroundColor: UIColor.red])
                 textFieldPasswordConfirm.shake()
                 isValid = false
             }
         }
         
         if !password.isValidPassword {
             passwordLabel.isHidden = false
             passwordLabel.attributedText = NSAttributedString(string: "Please enter Valid Password", attributes: [NSAttributedString.Key.foregroundColor: UIColor.red])
             textFieldPassword.shake()
             isValid = false
         }
         
         if !password.isEmpty && !password2.isEmpty && (password == password2) && password.isValidPassword {
             passwordLabel.isHidden = true
             confirmLabel.isHidden = true
         }
         
         
         return isValid
     }
     */
    
}
