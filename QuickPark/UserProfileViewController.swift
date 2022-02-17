//
//  UserProfileViewController.swift
//  QuickPark
//
//  Created by manar . on 17/02/2022.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseFirestore

class UserProfileViewController: UIViewController {

    
    @IBOutlet weak var txtUserName : UITextField!
    @IBOutlet weak var txtEmail : UITextField!
    @IBOutlet weak var txtPassword : UITextField!
    @IBOutlet weak var txtConfirmPassword : UITextField!
    
    @IBOutlet weak var labelEmailAlert: UILabel!
    @IBOutlet weak var labelFieldsAlert: UILabel!
    var ref = Database.database().reference().child("users")
    
    var id = ""
    var email = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        labelEmailAlert.isHidden = true
        labelFieldsAlert.isHidden = true
        if Auth.auth().currentUser != nil {
            id =  Auth.auth().currentUser!.uid
            //email = Auth.auth().currentUser!.email
        } else {
            print("user is not logged in")
            //User Not logged in
         }
        
        
        self.txtEmail.text = email
        

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
        
        
        //For shadow and cornerRadius for Name textfield
        txtUserName.layer.masksToBounds = false
        txtUserName.layer.shadowRadius = 4.0
        txtUserName.layer.shadowColor = UIColor.lightGray.cgColor
        txtUserName.layer.shadowOffset = CGSize(width: 1.0, height: 1.0)
        txtUserName.layer.shadowOpacity = 1.0
        
        //For shadow and cornerRadius for Email textfield
        txtEmail.layer.masksToBounds = false
        txtEmail.layer.shadowRadius = 4.0
        txtEmail.layer.shadowColor = UIColor.lightGray.cgColor
        txtEmail.layer.shadowOffset = CGSize(width: 1.0, height: 1.0)
        txtEmail.layer.shadowOpacity = 1.0
                
        //For shadow and cornerRadius for Password textfield
        txtPassword.layer.masksToBounds = false
        txtPassword.layer.shadowRadius = 4.0
        txtPassword.layer.shadowColor = UIColor.lightGray.cgColor
        txtPassword.layer.shadowOffset = CGSize(width: 1.0, height: 1.0)
        txtPassword.layer.shadowOpacity = 1.0
        
        //For shadow and cornerRadius for Confirm password textfield
        txtConfirmPassword.layer.masksToBounds = false
        txtConfirmPassword.layer.shadowRadius = 4.0
        txtConfirmPassword.layer.shadowColor = UIColor.lightGray.cgColor
        txtConfirmPassword.layer.shadowOffset = CGSize(width: 1.0, height: 1.0)
        txtConfirmPassword.layer.shadowOpacity = 1.0
        
        
        //Right padding view for Password textfield
        let paddingView: UIView = UIView.init(frame: CGRect(x: 0.0, y: 0.0, width: 12.0, height: 20.0))
        self.txtPassword.leftView = paddingView;
        self.txtPassword.leftViewMode = .always;
        
        //Left padding view for Password textfield
        let paddingView2: UIView = UIView.init(frame: CGRect(x: 0.0, y: 0.0, width: 60.0, height: 20.0))
        self.txtPassword.rightView = paddingView2;
        self.txtPassword.rightViewMode = .always;
        
        //Right padding view for Confirm Password textfield
        let paddingView3: UIView = UIView.init(frame: CGRect(x: 0.0, y: 0.0, width: 12.0, height: 20.0))
        self.txtConfirmPassword.leftView = paddingView3;
        self.txtConfirmPassword.leftViewMode = .always;
        
        //Left padding view for Confirm Password textfield
        let paddingView4: UIView = UIView.init(frame: CGRect(x: 0.0, y: 0.0, width: 60.0, height: 20.0))
        self.txtConfirmPassword.rightView = paddingView4;
        self.txtConfirmPassword.rightViewMode = .always;
        
        //---------------------------------------
        
        getName { (name) in
                    if let name = name {
                        self.txtUserName.text = name
                        print("great success")
                    }
                }
        
    }
    
    func getName(completion: @escaping (_ name: String?) -> Void) {
            guard let uid = Auth.auth().currentUser?.uid else { // safely unwrap the uid; avoid force unwrapping with !
                completion(nil) // user is not logged in; return nil
                return
            }
            Firestore.firestore().collection("users").document(uid).getDocument { (docSnapshot, error) in
                if let doc = docSnapshot {
                    if let name = doc.get("name") as? String {
                        completion(name) // success; return name
                    } else {
                        print("error getting field")
                        completion(nil) // error getting field; return nil
                    }
                } else {
                    if let error = error {
                        print(error)
                    }
                    completion(nil) // error getting document; return nil
                }
            }
        }
    
    //Will get called on password textfield eye button clicked
    @IBAction func btnPasswordClicekd(_ sender : UIButton){
        
        if sender.isSelected {
            //self.txtPassword.background = UIImage(systemName: "eye.slash.fill")
            self.txtPassword.isSecureTextEntry = true
        }else{
            //self.txtPassword.background = UIImage(systemName: "eye.fill")
            self.txtPassword.isSecureTextEntry = false
        }
        sender.isSelected = !sender.isSelected
    }
    
    
    //Will get called on confirm password textfield eye button clicked
    @IBAction func btnConfirmPasswordClicekd(_ sender : UIButton){
        
        if sender.isSelected {
           // self.txtConfirmPassword.background = UIImage(systemName: "eye.slash.fill")
            self.txtConfirmPassword.isSecureTextEntry = true
        }else{
           // self.txtConfirmPassword.background = UIImage(systemName: "eye.fill")
            self.txtConfirmPassword.isSecureTextEntry = false
        }
        sender.isSelected = !sender.isSelected
    }
    
    
    
    
    
    @IBAction func btnSaveClicked(_ sender : UIButton) {
        //When  registration is completed  save data to firebase
        
        let str = self.validateFields()
        
        if str == "true"
        {
            
            if (self.isValidEmail(self.txtEmail.text ?? "") ) {
                
                
            }else{
                labelEmailAlert.text = "Please check your email"
                labelEmailAlert.isHidden = false
               /* let alert = UIAlertController(title: "Ooopps", message: "Email validation failed", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                    
                }))
                self.present(alert, animated: true, completion: nil) */
            }
            
        }else{
            labelFieldsAlert.text = "Please fill out all the information"
            labelFieldsAlert.isHidden = false
           /*let alert = UIAlertController(title: "Ooopps", message: "Fill out all the Fields and try again", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                
            }))
            self.present(alert, animated: true, completion: nil) */
            
        }
    }
    
    
    func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"

        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    
    func validateFields()->String
    {
        let nameString = txtUserName.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let emailString = txtEmail.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let passwordString = txtPassword.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let confirmPasswordString = txtConfirmPassword.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if nameString == "" || emailString == "" || passwordString == "" || confirmPasswordString == "" {
            return "false"
        }
        
        return "true"
    }
    
    func getUserDetails() {
        guard let key = Auth.auth().currentUser?.uid else { return }
        self.ref.child(key).observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            let value = snapshot.value as? [String: Any]
            self.txtEmail.text = value?["email"] as? String
            // ...
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
}

