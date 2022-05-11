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
        //buttons shadow & style
        emailField.layer.masksToBounds = false
        emailField.layer.shadowRadius = 4.0
        emailField.layer.shadowColor = UIColor.lightGray.cgColor
        emailField.layer.shadowOffset = CGSize (width: 1.0, height: 1.0)
        emailField.layer.shadowOpacity = 1.0
        emailField.borderStyle = UITextField.BorderStyle.roundedRect
        
        
        passField.layer.masksToBounds = false
        passField.layer.shadowRadius = 4.0
        passField.layer.shadowColor = UIColor.lightGray.cgColor
        passField.layer.shadowOffset = CGSize (width: 1.0, height: 1.0)
        passField.layer.shadowOpacity = 1.0
        passField.borderStyle = UITextField.BorderStyle.roundedRect
        
        
        super.viewDidLoad()
        passLabel.isHidden = true
        emailLabel.isHidden = true
        self.setupViews()
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
    
    @IBAction func reggisterButtonTouched(_ sender: Any) {
        if let vc = SBSupport.viewController(sbi: "sbi_OnboardingViewController", inStoryBoard: "Misclenious") as? OnboardingViewController {
            vc.fromViewController = "login"
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func validate() -> Bool {
        var isValid = true
        emailLabel.isHidden = true
        emailLabel.isHidden = true
        if let t = emailField.text, t.isEmpty  {
            emailLabel.isHidden = false
            emailLabel.attributedText = NSAttributedString(string: "email cannot be empty", attributes: [NSAttributedString.Key.foregroundColor: UIColor.red])
            emailField.shake()
            isValid = false
        }
        if let t = passField.text, t.isEmpty  {
            passLabel.isHidden = false
            passLabel.attributedText = NSAttributedString(string: "passowrd cannot be empty", attributes: [NSAttributedString.Key.foregroundColor: UIColor.red])
            passField.shake()
            isValid = false
        }
        return isValid
    }
    
    
    @IBAction func loginPressed(_ sender: Any) {
        guard let email = emailField.text, let password = passField.text else {return}
        if validate() == false {return}
        emailAuth(email: email, password: password)
    }
    
    func emailAuth(email:String,password:String) {
        SVProgressHUD.show()
        Auth.auth().signIn(withEmail: email, password: password) { (authResult, error) in
            if let error = error as NSError? {
                SVProgressHUD.show()
                let qpAlert = QPAlert(self)
                switch AuthErrorCode(rawValue: error.code) {
                case .userDisabled:
                    qpAlert.showError(message: "User disabled")
                case .wrongPassword:
                    qpAlert.showError(message: "Wrong password or Email")
                case .invalidEmail:
                    qpAlert.showError(message: "Wrong password or Email")
                case .userNotFound:
                    qpAlert.showError(message: "User not found")
                default:
                    qpAlert.showError(message: error.localizedDescription)
                }
            }
            else {
                PushNotificationManager.shared.updateFirestorePushTokenIfNeeded()

                SceneDelegate.sceneDelegate.setUpHome()
                FBAuth.enableNotification(condition: true, email: email)
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
}
