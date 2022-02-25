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
    
    @IBOutlet weak var confirmLabel: UILabel?
    
    @IBAction func goToLogPressed(_ sender: Any) {
        self.performSegue(withIdentifier: "GoToLog", sender: nil)
    }
    
    
    override func viewDidLoad() {
        
        nameField.layer.masksToBounds = false
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
        
        
        
        super.viewDidLoad()
        //passOfRegField.enablePasswordToggle()
        // Do any additional setup after loading the view.
        // textFieldEmail.setBottomBorderOnlyWith(color: UIColor.gray.cgColor)
        confirmLabel?.isHidden = true
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
            self.validateNameField()
        }
        if textField == emailField {
            self.emailValidation()
        }
        if textField == passOfRegField {
            self.passwordValidation()
        }
        if textField == confirmPas {
            self.passwordValidation()
        }
    }
    func validate() -> Bool {
        passwordLabel.isHidden = true
        confirmLabel?.isHidden = true
        nameLabel.isHidden = true
        emailLabel.isHidden = true
        
        var isValid = true
        let name = nameField?.text?.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() ?? ""
        let email = emailField?.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let password = passOfRegField?.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let password2 = confirmPas?.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        
        // Name Validations
        if name.isEmpty {
            nameLabel.isHidden = false
            nameLabel.attributedText = NSAttributedString(string: "please enter your Name", attributes: [NSAttributedString.Key.foregroundColor: UIColor.red])
            nameField.shake()
            isValid = false
        }
        if !name.isAlphanumeric || name.count < 3 && !name.isEmpty {
            nameLabel.isHidden = false
            nameLabel.attributedText = NSAttributedString(string: "Name should have alphabets and min 3 characters", attributes: [NSAttributedString.Key.foregroundColor: UIColor.red])
            nameField.shake()
            isValid = false
        }
        
        // Email Validations
        if email.isEmpty {
            emailLabel.isHidden = false
            emailLabel.attributedText = NSAttributedString(string: "Please enter your email", attributes: [NSAttributedString.Key.foregroundColor: UIColor.red])
            emailField.shake()
            isValid = false
        }
        if !email.isValidEmail && !email.isEmpty {
            emailLabel.isHidden = false
            emailLabel.attributedText = NSAttributedString(string: "Please enter your valid email", attributes: [NSAttributedString.Key.foregroundColor: UIColor.red])
            emailField.shake()
            isValid = false
        }
        
        // Password Validations
        if password.isEmpty {
            passwordLabel.isHidden = false
            passwordLabel.attributedText = NSAttributedString(string: "Please enter Your Password", attributes: [NSAttributedString.Key.foregroundColor: UIColor.red])
            passOfRegField.shake()
            isValid = false
        }
        if password2.isEmpty {
            confirmLabel?.isHidden = false
            confirmLabel?.attributedText = NSAttributedString(string: "Please confirm Your Password", attributes: [NSAttributedString.Key.foregroundColor: UIColor.red])
            confirmPas.shake()
            isValid = false
        }
        
        if !password.isEmpty && !password2.isEmpty {
            if password != password2 {
                confirmLabel?.isHidden = false
                confirmLabel?.attributedText = NSAttributedString(string: "Passwords do not match", attributes: [NSAttributedString.Key.foregroundColor: UIColor.red])
                confirmPas.shake()
                isValid = false
            }
        }
        
        if !password.isValidPassword {
            passwordLabel.isHidden = false
            passwordLabel.attributedText = NSAttributedString(string: "Please enter valid password", attributes: [NSAttributedString.Key.foregroundColor: UIColor.red])
            passOfRegField.shake()
            isValid = false
        }
        
        return isValid
    }
    
    @IBAction func regPressed(_ sender: Any) {
        if validate() == false {return}
        
        let name = nameField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let email = emailField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let pass = passOfRegField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        
        SVProgressHUD.show()
        FBAuth.register(email: email, password: pass) { user, error in
            if let e = error, user == nil {
                SVProgressHUD.showError(withStatus: e.localizedDescription)
            } else {
                SVProgressHUD.showSuccess(withStatus: "Registered Successfully.")
                SceneDelegate.sceneDelegate.setUpHome()
            }
        }
        
        let database = Firestore.firestore()
        let userdata = ["email": email, "name": name]
        print (userdata)
        database.collection("users").document(email).setData(userdata){(error) in
            //that line was => addDocument(data : ["name" : name , "email" : email]) { (error) in
            if error != nil {
                //
            }
        }
    }
    
    @IBAction func loginPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
}

extension String {
    var isAlphanumeric: Bool {
        let regex = try! NSRegularExpression(pattern: "[^a-zA-Z] [^a-zA-Z]", options: [])
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

        //let passRegEx = "^(?=.*[A-Z])(?=.*[@$!%*?&#])(?=.*[0-9])(?=.*[a-z]).{8,}$"
        
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
    
    func validateNameField() {
        let name = nameField.text?.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() ?? ""
        // Name Validations
        var isValid = true
        if name.isEmpty {
            nameLabel.isHidden = false
            nameLabel.attributedText = NSAttributedString(string: "Please enter your name", attributes: [NSAttributedString.Key.foregroundColor: UIColor.red])
            isValid = false
        }
        if !name.isAlphanumeric || name.count < 3 && !name.isEmpty {
            nameLabel.isHidden = false
            nameLabel.attributedText = NSAttributedString(string: "Name should have alphabets and min 3 characters", attributes: [NSAttributedString.Key.foregroundColor: UIColor.red])
            isValid = false
        }
        if !name.isEmpty && name.count >= 3 && name.isAlphanumeric {
            nameLabel.isHidden = true
        }
        
        if name.isEmpty {
            nameLabel.isHidden = true
        }
    }
    
    func emailValidation() {
        // Email Validations
        let email = emailField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        if email.isEmpty {
            emailLabel.isHidden = false
            emailLabel.attributedText = NSAttributedString(string: "Please enter your email", attributes: [NSAttributedString.Key.foregroundColor: UIColor.red])
        }
        if !email.isValidEmail && !email.isEmpty {
            emailLabel.isHidden = false
            emailLabel.attributedText = NSAttributedString(string: "Please enter your valid email", attributes: [NSAttributedString.Key.foregroundColor: UIColor.red])
        }
        if email.isValidEmail && !email.isEmpty {
            emailLabel.isHidden = true
        }
        if email.isEmpty {
            emailLabel.isHidden = true
        }
    }
    
    func passwordValidation() {
        let password = passOfRegField?.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let password2 = confirmPas.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        
        // Password Validations
        if !password.isEmpty && !password2.isEmpty {
            if password != password2 {
                confirmLabel?.isHidden = false
                confirmLabel?.attributedText = NSAttributedString(string: "Password does not match", attributes: [NSAttributedString.Key.foregroundColor: UIColor.red])
            }
        }
        
        if !password.isValidPassword {
            passwordLabel.isHidden = false
            passwordLabel.attributedText = NSAttributedString(string: "Please enter valid password", attributes: [NSAttributedString.Key.foregroundColor: UIColor.red])
        }
        
        if !password.isEmpty && !password2.isEmpty && (password == password2) && password.isValidPassword {
            passwordLabel.isHidden = true
            confirmLabel?.isHidden = true
        }
        if password.isValidPassword {
            passwordLabel.isHidden = true
        }
        if password.isEmpty {
            passwordLabel.isHidden = true
        }
        if password2.isEmpty {
            confirmLabel?.isHidden = true
        }
    }
    
}


