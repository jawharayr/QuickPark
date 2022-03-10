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
    
    @IBOutlet weak var changePassbtn: UIButton!
    @IBOutlet weak var deletebtn: UIButton!
    
    @IBOutlet weak var labelEmailAlert: UILabel!
    @IBOutlet weak var labelFieldsAlert: UILabel!
    var ref = Database.database().reference().child("users")
    
    var id = ""
    var email = ""
    let yourAttributes: [NSAttributedString.Key: Any] = [
          .underlineStyle: NSUnderlineStyle.single.rawValue
      ] // .double.rawValue, .thick.rawValue
             
      
     
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
        
         let deleteAttributeString = NSMutableAttributedString(
            string: "Delete Account",
            attributes: yourAttributes
         )
        
        let changePassAttributeString = NSMutableAttributedString(
           string: "Change Password",
           attributes: yourAttributes
        )
        changePassbtn.setAttributedTitle(changePassAttributeString, for: .normal)
        deletebtn.setAttributedTitle(deleteAttributeString, for: .normal)

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
            let newEmail = txtEmail.text ?? ""
            if (self.isValidEmail(newEmail) ) {
                
                let database = Firestore.firestore()
                let userdata = ["email": newEmail, "name": txtUserName.text ?? ""]
                print (userdata)
                
                if let currentEmail = Auth.auth().currentUser?.email{
                    database.collection("users").document(currentEmail).delete()
                }
                database.collection("users").document(newEmail).setData(userdata){(error) in
                    if let error = error{
                        print("Error occured while writing new user data. Error= ",error.localizedDescription)
                    }else{
                        print("Did update user data successfully.")
                    }
                }
                Auth.auth().currentUser?.updateEmail(to: newEmail, completion: { error in
                    if let error = error{
                        print("Error occured while updated Auth.auth().currentUser email. Error= ",error.localizedDescription)
                    }else{
                        print("User email updated successfully to: ",newEmail)
                    }
                })
                
            }else{
                labelEmailAlert.isHidden = false
                labelEmailAlert.text = "Please check your email"
              
               /* let alert = UIAlertController(title: "Ooopps", message: "Email validation failed", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                    
                }))
                self.present(alert, animated: true, completion: nil) */
            }
            
        }else{
            labelFieldsAlert.isHidden = false
            labelFieldsAlert.text = "Please fill out all the information"
            
           /*let alert = UIAlertController(title: "Ooopps", message: "Fill out all the Fields and try again", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                
            }))
            self.present(alert, animated: true, completion: nil) */
            
        }
    }
    
    
    // /*
    @IBAction func deleteAccountPressed(_ sender: Any) {
        QPAlert(self).showAlert(title: "Are you sure you want to delete your account?", message: "Your account will be deleted permenently and you won't be able to restore it", buttons: ["Cancel", "Yes"]) { _, index in
            if index == 1 {
                
                var deleteEmail =  Auth.auth().currentUser!.uid
                Auth.auth().currentUser?.delete()

                
                
                if Auth.auth().currentUser != nil {
                    deleteEmail = Auth.auth().currentUser!.email!
                } else {
                    print("user is not logged in")
                    //User Not logged in
                 }

                
                
                // delete the document
                Firestore.firestore().collection("users").document(deleteEmail).delete();
                
                FBAuth.logout { success, error in
                    if success == false, let e = error {
                        QPAlert(self).showError(message: e.localizedDescription)
                    } else {
                        SceneDelegate.sceneDelegate.setUpHome()
                    }
                } // end logout
            }
        }
    } // */
    
    
}

