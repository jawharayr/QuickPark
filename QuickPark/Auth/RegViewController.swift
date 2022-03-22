//
//  RegViewController.swift
//  QuickPark
//
//  Created by Ghaliah Binakeel on 01/02/2022.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseFirestore
import SVProgressHUD

let K_acceptableNameCharactors = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz "

class RegViewController: UIViewController {
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var passOfRegField: UITextField!
    @IBOutlet weak var confirmPas: UITextField!
    
    @IBAction func goTermsPressed(_ sender: Any) {
        
    }
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var passwordLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var confirmLabel: UILabel!
    
    @IBAction func goToLogPressed(_ sender: Any) {
        self.performSegue(withIdentifier: "GoToLog", sender: nil)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nameField.layer.masksToBounds = false
        nameField.delegate = self
        nameField.layer.shadowRadius = 4.0
        nameField.layer.shadowColor = UIColor.lightGray.cgColor
        nameField.layer.shadowOffset = CGSize (width: 1.0, height: 1.0)
        nameField.layer.shadowOpacity = 1.0
        nameField.borderStyle = UITextField.BorderStyle.roundedRect
        
        
        emailField.layer.masksToBounds = false
        emailField.layer.shadowRadius = 4.0
        emailField.layer.shadowColor = UIColor.lightGray.cgColor
        emailField.layer.shadowOffset = CGSize (width: 1.0, height: 1.0)
        emailField.layer.shadowOpacity = 1.0
        emailField.borderStyle = UITextField.BorderStyle.roundedRect
        
        passOfRegField.layer.masksToBounds = false
        passOfRegField.layer.shadowRadius = 4.0
        passOfRegField.layer.shadowColor = UIColor.lightGray.cgColor
        passOfRegField.layer.shadowOffset = CGSize (width: 1.0, height: 1.0)
        passOfRegField.layer.shadowOpacity = 1.0
        passOfRegField.borderStyle = UITextField.BorderStyle.roundedRect
        
        
        confirmPas.layer.masksToBounds = false
        confirmPas.layer.shadowRadius = 4.0
        confirmPas.layer.shadowColor = UIColor.lightGray.cgColor
        confirmPas.layer.shadowOffset = CGSize (width: 1.0, height: 1.0)
        confirmPas.layer.shadowOpacity = 1.0
        confirmPas.borderStyle = UITextField.BorderStyle.roundedRect
        
        
        
        //passOfRegField.enablePasswordToggle()
        // Do any additional setup after loading the view.
        // textFieldEmail.setBottomBorderOnlyWith(color: UIColor.gray.cgColor)
        confirmLabel.isHidden = true
        passwordLabel.isHidden = true
        emailLabel.isHidden = true
        nameLabel.isHidden = true
        self.setupViews()
        
        // Do any additional setup after loading the view.
    }
    
    func setupViews() {
        self.nameField?.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        self.emailField?.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        self.passOfRegField?.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        self.confirmPas?.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
    }
    
    @objc func textFieldDidChange(textField: UITextField){
        if textField == nameField {
            _ = self.validateNameField()
        }
        if textField == emailField {
            _ = self.emailValidation()
        }
        if textField == passOfRegField {
            _ =  self.passwordValidation()
        }
        if textField == confirmPas {
            _ = self.confirmPasswordValidation()
        }
    }
    
    func validate() -> Bool {
        passwordLabel.isHidden = true
        confirmLabel.isHidden = true
        nameLabel.isHidden = true
        emailLabel.isHidden = true
        
        var isValid = true
        if self.validateNameField() == false  {
            nameField.shake()
            isValid = false
        }
        if self.emailValidation() == false  {
            emailField.shake()
            isValid = false
        }
        if self.passwordValidation() == false {
            passOfRegField.shake()
            isValid = false
        }
        if self.confirmPasswordValidation() == false {
            confirmPas.shake()
            isValid = false
        }
        return isValid
    }
    
    @IBAction func regPressed(_ sender: Any) {
        if validate() == false {return}
        
        let emailLower = emailField.text!.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        print (emailLower)
        let name = nameField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let email = emailField.text!.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        let pass = passOfRegField.text!
        
        SVProgressHUD.show()
        FBAuth.register(email: email, password: pass) { user, error in
            SVProgressHUD.dismiss()
            if let e = error, user == nil {
                QPAlert(self).showError(message: e.localizedDescription)
            } else {
                QPAlert(self).showError(message: "Registered Successfully.") //duration?
                SceneDelegate.sceneDelegate.setUpHome()
            }
        }
        
        let database = Firestore.firestore()
        let userdata = ["email": email, "name": name]
        print (userdata)
        database.collection("users").document(email).setData(userdata){(error) in
            if error != nil {
            }
        }
    }
    
    @IBAction func loginPressed(_ sender: Any) {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    
    @IBAction func termsOfServicePressed(_ sender: Any) {
        let vc = SBSupport.viewController(sbi: "sbi_TermsViewController", inStoryBoard: "Misclenious")
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
}

extension String {
    var isAlphanumeric: Bool {
        let regex = try! NSRegularExpression(pattern: "[^a-zA-Z][ ][^a-zA-Z]", options: [])///^[a-z ,.'-]+$/i
        if regex.firstMatch(in: self, options: [], range: NSMakeRange(0, self.count)) != nil {
            return false
        }else{
            return true
        }
    }
    var isValidEmail: Bool {
        let regex = try? NSRegularExpression(pattern: "^(?!(?:(?:\\x22?\\x5C[\\x00-\\x7E]\\x22?)|(?:\\x22?[^\\x5C\\x22]\\x22?)){255,})(?!(?:(?:\\x22?\\x5C[\\x00-\\x7E]\\x22?)|(?:\\x22?[^\\x5C\\x22]\\x22?)){65,}@)(?:(?:[\\x21\\x23-\\x27\\x2A\\x2B\\x2D\\x2F-\\x39\\x3D\\x3F\\x5E-\\x7E]+)|(?:\\x22(?:[\\x01-\\x08\\x0B\\x0C\\x0E-\\x1F\\x21\\x23-\\x5B\\x5D-\\x7F]|(?:\\x5C[\\x00-\\x7F]))*\\x22))(?:\\.(?:(?:[\\x21\\x23-\\x27\\x2A\\x2B\\x2D\\x2F-\\x39\\x3D\\x3F\\x5E-\\x7E]+)|(?:\\x22(?:[\\x01-\\x08\\x0B\\x0C\\x0E-\\x1F\\x21\\x23-\\x5B\\x5D-\\x7F]|(?:\\x5C[\\x00-\\x7F]))*\\x22)))*@(?:(?:(?!.*[^.]{64,})(?:(?:(?:xn--)?[a-z0-9]+(?:-+[a-z0-9]+)*\\.){1,126}){1,}(?:(?:[a-z][a-z0-9]*)|(?:(?:xn--)[a-z0-9]+))(?:-+[a-z0-9]+)*)|(?:\\[(?:(?:IPv6:(?:(?:[a-f0-9]{1,4}(?::[a-f0-9]{1,4}){7})|(?:(?!(?:.*[a-f0-9][:\\]]){7,})(?:[a-f0-9]{1,4}(?::[a-f0-9]{1,4}){0,5})?::(?:[a-f0-9]{1,4}(?::[a-f0-9]{1,4}){0,5})?)))|(?:(?:IPv6:(?:(?:[a-f0-9]{1,4}(?::[a-f0-9]{1,4}){5}:)|(?:(?!(?:.*[a-f0-9]:){5,})(?:[a-f0-9]{1,4}(?::[a-f0-9]{1,4}){0,3})?::(?:[a-f0-9]{1,4}(?::[a-f0-9]{1,4}){0,3}:)?)))?(?:(?:25[0-5])|(?:2[0-4][0-9])|(?:1[0-9]{2})|(?:[1-9]?[0-9]))(?:\\.(?:(?:25[0-5])|(?:2[0-4][0-9])|(?:1[0-9]{2})|(?:[1-9]?[0-9]))){3}))\\]))$", options: .caseInsensitive)
        return regex?.firstMatch(in: self, options: [], range: NSMakeRange(0, self.count)) != nil
    }
    var isValidPassword: Bool {
        if (self.isEmpty){return false}
        let passRegEx = "^(?=.*[0-9])(?=.*[a-z]).{6,}$"
        let passwordTest=NSPredicate(format: "SELF MATCHES %@", passRegEx);
        return passwordTest.evaluate(with: self)
    }
    
    
}
extension UITextField {
    func shake(baseColor: UIColor = .gray, numberOfShakes shakes: Float = 3, revert: Bool = true) {
        let animation: CABasicAnimation = CABasicAnimation(keyPath: "shadowColor")
        animation.fromValue = baseColor.cgColor
        animation.toValue = UIColor.red.cgColor
        animation.duration = 0.4
        if revert { animation.autoreverses = true } else { animation.autoreverses = false }
        self.layer.add(animation, forKey: "")
        
        let shake: CABasicAnimation = CABasicAnimation(keyPath: "position")
        shake.duration = 0.07
        shake.repeatCount = shakes
        if revert { shake.autoreverses = true  } else { shake.autoreverses = false }
        shake.fromValue = NSValue(cgPoint: CGPoint(x: self.center.x - 10, y: self.center.y))
        shake.toValue = NSValue(cgPoint: CGPoint(x: self.center.x + 10, y: self.center.y))
        self.layer.add(shake, forKey: "position")
    }
}

extension RegViewController {
    func validateNameField() -> Bool {
        let name = nameField.text ?? ""//?.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() ?? ""
        if name.isEmpty {
            nameLabel.isHidden = false
            nameLabel.attributedText = NSAttributedString(string: "Please enter your name", attributes: [NSAttributedString.Key.foregroundColor: UIColor.red])
            return false
            
        }
        if !name.isAlphanumeric || name.count < 3 {
            nameLabel.isHidden = false
            nameLabel.attributedText = NSAttributedString(string: "Name should have alphabets and min 3 letters characters", attributes: [NSAttributedString.Key.foregroundColor: UIColor.red])
            return false
            
        }
        if !name.isAlphanumeric || name.count > 32 {
            nameLabel.isHidden = false
            nameLabel.attributedText = NSAttributedString(string: "Name should have alphabets and max 32 letters characters", attributes: [NSAttributedString.Key.foregroundColor: UIColor.red])
            return false
            
        }
        nameLabel.isHidden = true
        return true
    }
    
    func emailValidation() -> Bool {
        // Email Validations
        let email = emailField.text ?? ""
        if email.isEmpty {
            emailLabel.isHidden = false
            emailLabel.attributedText = NSAttributedString(string: "Please enter your email", attributes: [NSAttributedString.Key.foregroundColor: UIColor.red])
            return false
        }
        if !email.isValidEmail && !email.isEmpty {
            emailLabel.isHidden = false
            emailLabel.attributedText = NSAttributedString(string: "Please enter your valid email", attributes: [NSAttributedString.Key.foregroundColor: UIColor.red])
            return false
        }
        if email.isValidEmail && !email.isEmpty {
            emailLabel.isHidden = true
        }
        return true
    }
    
    func passwordValidation() -> Bool {
        let password = passOfRegField.text ?? ""
        if !password.isValidPassword {
            passwordLabel.isHidden = false
            passwordLabel.attributedText = NSAttributedString(string: "Please enter valid password", attributes: [NSAttributedString.Key.foregroundColor: UIColor.red])
            return false
        }
        
        passwordLabel.isHidden = true
        return true
    }
    
    func confirmPasswordValidation() -> Bool {
        let password = passOfRegField.text ?? ""
        let password2 = confirmPas.text ?? ""
        
        // Password Validations
        if password2.isEmpty {
            confirmLabel.isHidden = false
            confirmLabel.attributedText = NSAttributedString(string: "Please enter confirm password", attributes: [NSAttributedString.Key.foregroundColor: UIColor.red])
            return false
        }
        if password != password2 {
            confirmLabel.isHidden = false
            confirmLabel.attributedText = NSAttributedString(string: "Password does not match", attributes: [NSAttributedString.Key.foregroundColor: UIColor.red])
            return false
        }
        
        if !password.isEmpty && (password == password2) {
            confirmLabel.isHidden = true
            return false
        }
        return true
    }
    
}


extension RegViewController : UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == nameField {
            let cs = CharacterSet.init(charactersIn: K_acceptableNameCharactors).inverted
            let filtered = string.components(separatedBy: cs).joined(separator: "")
            return (string == filtered)
        }
        return true
    }
}
