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
    
    
    @IBOutlet weak var labelEmailAlert: UILabel!
    @IBOutlet weak var labelFieldsAlert: UILabel!
    var ref = Database.database().reference().child("users")
    
    var id = ""
    var email = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        
        labelEmailAlert.isHidden = true
        labelFieldsAlert.isHidden = true
        userLoggedIn()
        
        getName { (name) in
                    if let name = name {
                        self.txtUserName.text = name
                        print("success in getting name")
                    }
                }
        self.txtEmail.text = email

        self.navigationController?.navigationBar.isHidden = true

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
        
        
        //For shadow and cornerRadius for Confirm password textfield
       
        
        
        //Right padding view for Password textfield
        let paddingView: UIView = UIView.init(frame: CGRect(x: 0.0, y: 0.0, width: 12.0, height: 20.0))
        
        
        //Left padding view for Password textfield
        let paddingView2: UIView = UIView.init(frame: CGRect(x: 0.0, y: 0.0, width: 60.0, height: 20.0))
       
        
        //Right padding view for Confirm Password textfield
        let paddingView3: UIView = UIView.init(frame: CGRect(x: 0.0, y: 0.0, width: 12.0, height: 20.0))
       
        
        //Left padding view for Confirm Password textfield
        let paddingView4: UIView = UIView.init(frame: CGRect(x: 0.0, y: 0.0, width: 60.0, height: 20.0))
        
        
        //---------------------------------------
        
       
        
    }
    
    func getName(completion: @escaping (_ name: String?) -> Void) {
            guard let uemail = Auth.auth().currentUser?.email else { // safely unwrap the uid; avoid force unwrapping with !
                
                completion(nil) // user is not logged in; return nil
                return
            }
        print (uemail)
        
            Firestore.firestore().collection("users").document(uemail).getDocument { (docSnapshot, error) in
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
    
    func userLoggedIn() {
        if Auth.auth().currentUser != nil {
            id =  Auth.auth().currentUser!.uid
            //email = Auth.auth().currentUser!.email
        } else {
            print("user is not logged in")
            //User Not logged in
         }
        if Auth.auth().currentUser != nil {
            email = Auth.auth().currentUser!.email!
        } else {
            print("user is not logged in")
            //User Not logged in
         }
    }
    
    //Will get called on password textfield eye button clicked
    
    
    
    //Will get called on confirm password textfield eye button clicked
    
    
    
    
    
    
    
    
    
    func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"

        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    
    func validateFields()->String
    {
        let nameString = txtUserName.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let emailString = txtEmail.text!.trimmingCharacters(in: .whitespacesAndNewlines)
       
        
        if nameString == "" || emailString == ""  {
            return "false"
        }
        
        return "true"
    }
    
 
    
    @IBAction func saveProfileBtn(_ sender: UIButton) {
        
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
    
    
}

