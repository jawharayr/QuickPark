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
    
    
    @IBOutlet weak var passOfRegField: UITextField!
    
    
    @IBOutlet weak var confirmPas: UITextField!
    
    @IBAction func goTermsPressed(_ sender: Any) {
        
    }
    
    @IBAction func goToLogPressed(_ sender: Any) {
        self.performSegue(withIdentifier: "GoToLog", sender: nil)
    }
    

    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func AgreedPressed(_ sender: Any) {
    }
    
  
    
    @IBAction func regPressed(_ sender: Any) {
       // let error = validateRegFields ()
    }
    
    /* msg fields if error happen
     override func viewDidLoad() {
         super.viewDidLoad()
         textFieldPassword.enablePasswordToggle()
         // Do any additional setup after loading the view.
         
        // textFieldEmail.setBottomBorderOnlyWith(color: UIColor.gray.cgColor)
         confirmLabel.isHidden = true
         passwordLabel.isHidden = true
         emailLabel.isHidden = true
         nameLabel.isHidden = true
         self.setupViews()
     }
     
     func setupViews() {
         self.textFieldName.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
         self.textFieldEmail.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
         self.textFieldPassword.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
         self.textFieldPasswordConfirm.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
     }
     */
    
    
    
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
    
    
    
    /* making the user
     func emailAuth(email: String, password: String){
         ProgressHUD.show()
         Auth.auth().createUser(withEmail: email, password: password) { [self] authResult, error in
             ProgressHUD.dismiss()
             
             if let error = error as NSError? {
                 switch AuthErrorCode(rawValue: error.code) {
                 case .emailAlreadyInUse:
                     // Error: The email address is already in use by another account.
                     emailLabel.attributedText = NSAttributedString(string: "Email already in use", attributes: [NSAttributedString.Key.foregroundColor: UIColor.red])
                     textFieldEmail.shake()
                 case .invalidEmail:
                     // Error: The email address is badly formatted.
                     emailLabel.attributedText = NSAttributedString(string: "Invalid Email", attributes: [NSAttributedString.Key.foregroundColor: UIColor.red])
                     textFieldEmail.shake()
                 case .weakPassword:
                     // Error: The password must be 6 characters long or more.
                     passwordLabel.attributedText = NSAttributedString(string: "Weak Password", attributes: [NSAttributedString.Key.foregroundColor: UIColor.red])
                     textFieldPassword.shake()
                 default:
                     self.showError(message: error.localizedDescription)
                 }
             } else {
                 print("User signs up successfully")
                 let user = Auth.auth().currentUser!
                 let email = user.email
                 
                 let object = ["username": textFieldName.text!,
                               "email": email!,
                               "role": "driver",
                               "gender": genderValue,
                               "userId": user.uid]
                 
                 ProgressHUD.show()
                 userRef.child(user.uid)
                     .setValue(object) { error, ref in
                         ProgressHUD.dismiss()
                         
                         UserDefaults.standard.setValue(object, forKey: "currentUser")
                         
                         if let data = avatar?.jpegData(compressionQuality: 0.1) {
                             let ref = storage.reference().child("avatars/\(user.uid).jpg")
                             let task = ref.putData(data, metadata: nil, completion: { meta, error in
                                 ProgressHUD.dismiss()
                                 guard error == nil else {
                                     showError(message: error?.localizedDescription)
                                     return
                                 }
                                 
                                 ref.downloadURL { (url, error) in
                                     guard let url = url else {
                                         print("Failed to get url")
                                         return
                                     }
                                     User.currentUser?.avatar = url.absoluteString
                                     userRef.child(user.uid).updateChildValues(["avatar": url.absoluteString])
                                     addPhone()
                                 }
                             })
                             task.observe(StorageTaskStatus.progress) { (snapShot) in
                                 let progress = snapShot.progress!.completedUnitCount / snapShot.progress!.totalUnitCount
                                 ProgressHUD.showProgress(CGFloat(progress))
                             }
                         } else {
                             addPhone()
                         }
                     }
             }
         }
     }
     
     func addPhone() {
         show(UIStoryboard.Phone.instantiateInitialViewController()!, sender: nil)
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

 extension SignUpDriverVC {
     
     func validateNameField() {
         let name = textFieldName.text?.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() ?? ""
         // Name Validations
         var isValid = true
         if name.isEmpty {
             nameLabel.isHidden = false
             nameLabel.attributedText = NSAttributedString(string: "Please enter Your Name", attributes: [NSAttributedString.Key.foregroundColor: UIColor.red])
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
         let email = textFieldEmail.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
         if email.isEmpty {
             emailLabel.isHidden = false
             emailLabel.attributedText = NSAttributedString(string: "Please enter Your Email", attributes: [NSAttributedString.Key.foregroundColor: UIColor.red])
         }
         if !email.isValidEmail && !email.isEmpty {
             emailLabel.isHidden = false
             emailLabel.attributedText = NSAttributedString(string: "Please enter Your Valid Email", attributes: [NSAttributedString.Key.foregroundColor: UIColor.red])
         }
         if email.isValidEmail && !email.isEmpty {
             emailLabel.isHidden = true
         }
         if email.isEmpty {
             emailLabel.isHidden = true
         }
     }
     
     func passwordValidation() {
         let password = textFieldPassword.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
         let password2 = textFieldPasswordConfirm.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
         
         // Password Validations
         if !password.isEmpty && !password2.isEmpty {
             if password != password2 {
                 confirmLabel.isHidden = false
                 confirmLabel.attributedText = NSAttributedString(string: "password does not match", attributes: [NSAttributedString.Key.foregroundColor: UIColor.red])
             }
         }
         
         if !password.isValidPassword {
             passwordLabel.isHidden = false
             passwordLabel.attributedText = NSAttributedString(string: "Please enter Valid Password", attributes: [NSAttributedString.Key.foregroundColor: UIColor.red])
         }
         
         if !password.isEmpty && !password2.isEmpty && (password == password2) && password.isValidPassword {
             passwordLabel.isHidden = true
             confirmLabel.isHidden = true
         }
         if password.isValidPassword {
             passwordLabel.isHidden = true
         }
         if password.isEmpty {
             passwordLabel.isHidden = true
         }
         if password2.isEmpty {
             confirmLabel.isHidden = true
         }
         
     }
     
 }
     */
    
}
