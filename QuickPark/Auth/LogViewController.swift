//
//  LogViewController.swift
//  QuickPark
//
//  Created by Ghaliah Binakeel on 01/02/2022.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth
import SVProgressHUD
import ProgressHUD

class LogViewController: UIViewController {
     private let database = Database.database().reference()
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passField: UITextField!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var passLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        passLabel.isHidden = true
        emailLabel.isHidden = true
       // self.setupViews()

    }
    
    
    
    func setupViews() {
        
        
        self.emailField?.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        self.passField?.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
    
    }
    @objc func textFieldDidChange(textField: UITextField){
      
        if textField == emailField {
            self.emailField
        }
        if textField == passField {
            self.passField
        }
    }
    @IBAction func ForgetPassPressed(_ sender: Any) {
    }
    
    func validate() -> Bool {
        if (emailField.text ?? "").isEmpty || (passField.text ?? "").isEmpty {
            SVProgressHUD.showError(withStatus: "Email and password field can not be empty.")
            return false
        }
        return true
    }
    
    @IBAction func loginPressed(_ sender: Any) {
        guard let email = emailField.text, let password = passField.text else {return}
        emailAuth(email: email, password: password)
        if validate() == false {return}
        
        FBAuth.login(email: email, password: password) { user, error in
            SceneDelegate.sceneDelegate.setUpHome()
        }
        
    }
    @discardableResult
    func showError(message: String?) -> UIAlertController {
        showAlert(title: " ",  message: message ?? "Unexpected error!")
    }
    @discardableResult
    func showAlert(title: String? = nil, message: String, onOK: (() -> Void)? = nil) -> UIAlertController {
        showAlert(title: title, message: message, buttons: ["OK"]) { _, _ in
            onOK?()
        }
    }
    @discardableResult
    func showAlert(title: String? = nil, message: String, buttons: [String], handler: ((UIAlertController, Int) -> Void)?) -> UIAlertController {
        
        let alert = UIAlertController(title: title ?? "", message: message, preferredStyle: .alert)
        
        if buttons.isEmpty {
            alert.addAction(UIAlertAction(title: "OK", style: .cancel) { [unowned alert] _ in
                handler?(alert, 0)
            })
        } else {
            for (idx, button) in buttons.enumerated() {
                alert.addAction(UIAlertAction(title: button, style: .default) { [unowned alert] _ in
                    handler?(alert, idx)
                })
            }
        }
        
        present(alert, animated: true, completion: nil)
        
        return alert
    }
    
    
    func emailAuth(email:String,password:String) {
        ProgressHUD.show()
        Auth.auth().signIn(withEmail: email, password: password) { (authResult, error) in
            if let error = error as NSError? {
                ProgressHUD.dismiss()

                switch AuthErrorCode(rawValue: error.code) {
                case .userDisabled:
                    self.showError(message: "User disabled")
                case .wrongPassword:
                    self.showError(message: "Wrong password or Email")
                case .invalidEmail:
                    self.showError(message: "Wrong password or Email")
                case .userNotFound:
                    self.showError(message: "User not found")
                default:
                    self.showError(message: error.localizedDescription)
                }
                // ckeck if the driver license is falid or not
            }
        }
    }
    
    @IBAction func GoRegPressed(_ sender: Any) {
        // self.performSegue(withIdentifier: "GoReg", sender: nil)
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
    /*
     @IBAction func LoginButton(_ sender: UIButton) {
         if EmailTextField.text?.isEmpty == true || PasswordTextField.text?.isEmpty == true  {
 //            let alert = Service.shared.createAlertController(title: "", message: "Please fill all fields!")
 //            self.present(alert, animated: true, completion: nil)
 //            return
         }
     

     
         guard let email = EmailTextField.text, let password = PasswordTextField.text else { return }
         emailAuth(email: email, password: password)
         func emailValidate() -> Bool {
             return true
         }

         if !emailValidate() {
             return
         }

     }
    
     override func viewDidLoad() {
         super.viewDidLoad()
         passwordLabel.isHidden = true
         emailLabel.isHidden = true
        // self.setupViews()
         PasswordTextField.enablePasswordToggle()
     }
     
 //    func setupViews() {
 //        self.EmailTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
 //        self.PasswordTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
 //
 //    }
 //
 //    //Gets called everytime the text changes in the textfield.
 //    @objc func textFieldDidChange(textField: UITextField){
 //
 //        if textField == EmailTextField {
 //            self.emailValidation()
 //        }
 //        if textField == PasswordTextField {
 //            self.passwordValidation()
 //        }
 //
 //    }
    
     func emailAuth(email:String,password:String) {
         ProgressHUD.show()
         Auth.auth().signIn(withEmail: email, password: password) { (authResult, error) in
             if let error = error as NSError? {
                 ProgressHUD.dismiss()

                 switch AuthErrorCode(rawValue: error.code) {
                 case .userDisabled:
                     self.showError(message: "User disabled")
                 case .wrongPassword:
                     self.showError(message: "Wrong password or Email")
                 case .invalidEmail:
                     self.showError(message: "Wrong password or Email")
                 case .userNotFound:
                     self.showError(message: "User not found")
                 default:
                     self.showError(message: error.localizedDescription)
                 }
                 // ckeck if the driver license is falid or not
             } else if let user = authResult?.user {
                 print("User signs in successfully")
                 userRef.child(user.uid).observeSingleEvent(of: .value, with: { [unowned self] snapshot in
                     ProgressHUD.dismiss()

                     if let user = User(snapshot) {
                         print("Got data \(user)")
                         if user.role == "valet", user.role == "driver", !user.active {
                                                     try? Auth.auth().signOut()
                                                     self.showAlert(title: "Your account is deactivated!", message: "Please check your email for mor information")
                                                 }
                         if user.role == "valet", !user.isVerified {
                             try? Auth.auth().signOut()
                             self.showAlert(title: "Verification needed", message: "Driver license is waiting for verification, please wait!")
                         } else {
                             UserDefaults.standard.set(snapshot.value, forKey: "currentUser")
                             if User.currentUser?.isPhoneVerified == true {
                                 SceneDelegate.shared.reset()
                             } else {
                                 show(UIStoryboard.Phone.instantiateInitialViewController()!, sender: nil)
                             }
                         }
                     } else {
                         print("No data available")
                         try? Auth.auth().signOut()
                     }
                 })
             }
         }
     }
     
     */
    
    
    
    
    
    
    
    
    
   /* reset pass
    @IBAction func ForgotPass(_ sender: Any) {
      
        let forgotPasswordAlert = UIAlertController(title: "Forgot password?", message: "Enter email address", preferredStyle: .alert)
           forgotPasswordAlert.addTextField { (textField) in
               textField.placeholder = "Enter email address"
           }
           forgotPasswordAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
           forgotPasswordAlert.addAction(UIAlertAction(title: "Reset Password", style: .default, handler: { (action) in
               let resetEmail = forgotPasswordAlert.textFields?.first?.text
               Auth.auth().sendPasswordReset(withEmail: resetEmail!, completion: { (error) in
                   if error != nil{
                       self.showAlert(title: "Error", message: "Please enter a valid email!")
                   }else {
                       self.showAlert(title: "Password reset successful", message: "You have successfully requested to reset your password! please check your email ")
                   }
               })
           }))
           //PRESENT ALERT
           self.present(forgotPasswordAlert, animated: true, completion: nil)
       
    }
    
    */
    
}
