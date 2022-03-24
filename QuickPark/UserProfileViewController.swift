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
    @IBOutlet weak var LabelNameAlert: UILabel!
    
    var ref = Database.database().reference().child("users")
    
    var id = ""
    var email = ""
    private var name = ""
    let yourAttributes: [NSAttributedString.Key: Any] = [
          .underlineStyle: NSUnderlineStyle.single.rawValue
      ] // .double.rawValue, .thick.rawValue
             
 
    
    @IBAction func cancelAction(_ sender: Any) {
        if !(txtUserName.text != name || txtEmail.text != email){return}
        let alert = UIAlertController(title: "Cancel", message: "Are you sure you want to cancel changes?", preferredStyle: .alert)
        alert.addAction(.init(title: "Discard Changes", style: .destructive, handler: { _ in
            self.txtUserName.text = self.name
            self.txtEmail.text = self.email
        }))
        alert.addAction(.init(title: "Close", style: .cancel, handler: nil))
        self.present(alert, animated: true)
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        txtUserName.delegate = self
        labelEmailAlert.isHidden = true
        labelFieldsAlert.isHidden = true
        LabelNameAlert.isHidden = true
        userLoggedIn()
        
        self.navigationController?.navigationBar.isHidden = true
        self.setupViews()
         let deleteAttributeString = NSMutableAttributedString(
            string: "Delete Account",
            attributes: yourAttributes
         )
        
        let changePassAttributeString = NSMutableAttributedString(
           string: "Change Password",
           attributes: yourAttributes
        )
        changePassbtn.setAttributedTitle(changePassAttributeString, for: .normal)
      //  deletebtn.setAttributedTitle(deleteAttributeString, for: .normal)

    }
    
    @IBAction func changePasswordAction(_ sender: Any) {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ChangePasswordVC") as! ChangePasswordVC
        navigationController?.pushViewController(vc, animated: true)
    }
    func setupViews() {
        self.txtUserName?.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        self.txtEmail?.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
         }

    @objc func textFieldDidChange(textField: UITextField){
        if textField == txtUserName {
            _ = self.isValidName(txtUserName.text ?? " ")
        }
        if textField == txtEmail {
            _ = self.EmailValidation(txtEmail.text ?? " ")
        }

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        getName { (name) in
                    if let name = name {
                        self.name = name
                        self.txtUserName.text = name
                        print("success in getting name")
                    }
                }
        self.txtEmail.text = email
        
        
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
    
    
    func EmailValidation(_ email: String) -> Bool {
        labelEmailAlert.isHidden = true
        let Uemail = txtEmail.text ?? ""
        if Uemail.isEmpty {
            labelEmailAlert.isHidden = false
            labelEmailAlert.attributedText = NSAttributedString(string: "Please Enter your email", attributes: [NSAttributedString.Key.foregroundColor: UIColor.red])
            return false
        }
        if !Uemail.isValidEmail && !Uemail.isEmpty {
            labelEmailAlert.isHidden = false
            labelEmailAlert.attributedText = NSAttributedString(string: "Please Enter valid email", attributes: [NSAttributedString.Key.foregroundColor: UIColor.red])
            return false
        }
        if Uemail.isValidEmail && !Uemail.isEmpty {
            labelEmailAlert.isHidden = true
        }
      //  return true }
     let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"

        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    func isValidName(_ text: String) -> Bool {
//        let name = nameField.text ?? ""//?.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() ?? ""
        let name = text.trimmingCharacters(in: .whitespacesAndNewlines)
        if name.isEmpty {
            LabelNameAlert.isHidden = false
            LabelNameAlert.attributedText = NSAttributedString(string: "Please enter your name", attributes: [NSAttributedString.Key.foregroundColor: UIColor.red])
            return false
            
        }
        if !name.isAlphanumeric || name.count < 3 {
            LabelNameAlert.isHidden = false
            LabelNameAlert.attributedText = NSAttributedString(string: "Name should have alphabets and min 3 letters characters", attributes: [NSAttributedString.Key.foregroundColor: UIColor.red])
            return false
            
        }
        if !name.isAlphanumeric || name.count > 32 {
            LabelNameAlert.isHidden = false
            LabelNameAlert.attributedText = NSAttributedString(string: "Name should have alphabets and max 32 letters characters", attributes: [NSAttributedString.Key.foregroundColor: UIColor.red])
            return false
            
        }
        LabelNameAlert.isHidden = true
       // labelFieldsAlert.isHidden = true
        return true
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
    
    private func alertUser(title:String?, body: String?){
        let alert = UIAlertController(title: title, message: body, preferredStyle: .alert)
        alert.addAction(.init(title: "Close", style: .cancel, handler: nil))
        self.present(alert,animated: true)
    }
    
    @IBAction func saveProfileBtn(_ sender: UIButton) {
        if !(txtUserName.text != name || txtEmail.text != email){return}
        let str = self.validateFields()
        if str == "true"
        {
            let newEmail = txtEmail.text ?? ""
            let newName = txtUserName.text ?? ""
            if (self.isValidName(newName) ){
                if (self.EmailValidation(newEmail) ){
                    
                    authUser { error in
                        if let error = error{
                            self.alertUser(title: "Error", body: error)
                        }else{
                            let database = Firestore.firestore()
                            let userdata = ["email": newEmail, "name": self.txtUserName.text ?? ""]
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
                                    self.alertUser(title: "Error", body: error.localizedDescription)
                                }else{
                                    self.alertUser(title: "Information updated", body: "Your account information has been updated successfully.")
                                }
                            })
                        }
                    }
                    
                }else{
                //   EmailValidation(txtEmail.text ?? " ")
                    labelEmailAlert.isHidden = false
                    labelEmailAlert.text = "Please check your email"
                  
                   /* let alert = UIAlertController(title: "Ooopps", message: "Email validation failed", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                        
                    }))
                    self.present(alert, animated: true, completion: nil) */
                }
            }
        }
        if name.isEmpty && email.isEmpty {
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

extension UserProfileViewController: UITextFieldDelegate{
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == txtUserName {
            let cs = CharacterSet.init(charactersIn: K_acceptableNameCharactors).inverted
            let filtered = string.components(separatedBy: cs).joined(separator: "")
            return (string == filtered)
        }
        return true
    }
    
}
