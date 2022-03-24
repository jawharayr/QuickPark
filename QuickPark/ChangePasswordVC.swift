//
//  ChangePasswordVC.swift
//  QuickPark
//
//  Created by Deema on 15/08/1443 AH.
//

import UIKit
import FirebaseAuth

class ChangePasswordVC: UIViewController {

    
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var errorLabel: UILabel!
    
    @IBOutlet weak var ConfirmPasswordLabel: UILabel!
    
    private func authUser(completion: @escaping (_ error:String?)->()){
        let alert = UIAlertController(title: "Password", message: "Please enter your password to confirm new changes.", preferredStyle: .alert)
        alert.addTextField { textField in
            textField.placeholder = "Enter your password"
            textField.isSecureTextEntry = true
        }
        alert.addAction(.init(title: "Save", style: .default, handler: { _ in
            guard let email = Auth.auth().currentUser?.email,let password = alert.textFields?.first?.text else{return}
            Auth.auth().signIn(withEmail: email, password: password) { authRes, error in
                if let error = error{
                    completion(error.localizedDescription)
                }else if authRes != nil{
                    completion(nil)
                }else{
                    completion("Unexpected error")
                }
            }
        }))
        alert.addAction(.init(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true)
    }
    
    @IBAction func SavePassword(_ sender: Any) {
        if !passwordValidation(){return}
        authUser { error in
            if let error = error{
                let alert = UIAlertController(title: "Error", message: error, preferredStyle: .alert)
                alert.addAction(.init(title: "Close", style: .cancel, handler: nil))
                self.present(alert,animated: true)
            }else{
                Auth.auth().currentUser?.updatePassword(to: self.passwordTextField.text!, completion: { error in
                    if let error = error{
                        let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
                        alert.addAction(.init(title: "Close", style: .cancel, handler: nil))
                        self.present(alert,animated: true)
                    }else{
                        let alert = UIAlertController(title: "Password Changed", message: "Your password has been changed successfully.", preferredStyle: .alert)
                        alert.addAction(.init(title: "Close", style: .cancel, handler: { _ in
                            self.navigationController?.popViewController(animated: true)
                        }))
                        self.present(alert,animated: true)
                    }
                })
            }
        }
    }
    
    @IBAction func Cancel(_ sender: Any) {
        let password = passwordTextField.text ?? ""
        let confirmPassword = confirmPasswordTextField.text ?? ""
        if password.isEmpty && confirmPassword.isEmpty{
            navigationController?.popViewController(animated: true)
        }else{
            let alert = UIAlertController(title: "Cancel", message: "All changes will be disacred, are you sure you'd like to cancel?", preferredStyle: .alert)
            alert.addAction(.init(title: "Cancel", style: .destructive, handler: { _ in
                self.navigationController?.popViewController(animated: true)
            }))
            
            alert.addAction(.init(title: "Close", style: .cancel, handler: nil))
            self.present(alert, animated: true)
        }
    }
    
    @IBAction func editingChangedAction(_ sender: Any) {
        _ = passwordValidation()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        passwordTextField.isSecureTextEntry = true
        confirmPasswordTextField.isSecureTextEntry = true
        // Do any additional setup after loading the view.
    }
    
    func passwordValidation() -> Bool {
        let password = passwordTextField.text ?? ""
        let confirmPassword = confirmPasswordTextField.text ?? ""
        
        if password.isEmpty {
            errorLabel.isHidden = false
            errorLabel.attributedText = NSAttributedString(string: "Please enter a new password", attributes: [NSAttributedString.Key.foregroundColor: UIColor.red])
            return false
        }
        if !password.isValidPassword {
            errorLabel.isHidden = false
            errorLabel.attributedText = NSAttributedString(string: "Please enter valid password", attributes: [NSAttributedString.Key.foregroundColor: UIColor.red])
            return false
        }
        errorLabel.isHidden = true
        if confirmPassword.isEmpty {
            ConfirmPasswordLabel.isHidden = false
            ConfirmPasswordLabel.attributedText = NSAttributedString(string: "Please enter confirm password", attributes: [NSAttributedString.Key.foregroundColor: UIColor.red])
            return false
        }
        if !confirmPassword.isValidPassword {
            ConfirmPasswordLabel.isHidden = false
            ConfirmPasswordLabel.attributedText = NSAttributedString(string: "Please enter valid confirm password", attributes: [NSAttributedString.Key.foregroundColor: UIColor.red])
            return false
        }
        if password != confirmPassword {
            ConfirmPasswordLabel.isHidden = false
            ConfirmPasswordLabel.attributedText = NSAttributedString(string: "Password does not match", attributes: [NSAttributedString.Key.foregroundColor: UIColor.red])
            return false
        }

        errorLabel.isHidden = true
        ConfirmPasswordLabel.isHidden = true
        return true
    }

}
