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
    
    @discardableResult
    func showError(message: String?) -> UIAlertController {
        showAlert(title: nil,  message: message ?? "Unexpected error!")
    }
    
    @discardableResult
    func showAlert(title: String? = nil, message: String, onOK: (() -> Void)? = nil) -> UIAlertController {
        showAlert(title: title, message: message, buttons: ["OK"]) { _, _ in
            onOK?()
        }
    }
    
    @discardableResult
    func showAlert(title: String? = nil, message: String, buttons: [String], handler: ((UIAlertController, Int) -> Void)?) -> UIAlertController {
        
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        
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
            }
            else {
                SceneDelegate.sceneDelegate.setUpHome()
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
