//
//  LogViewController.swift
//  QuickPark
//
//  Created by Ghaliah Binakeel on 01/02/2022.
//

import UIKit
import FirebaseDatabase

class LogViewController: UIViewController {
     private let database = Database.database().reference()
    @IBOutlet weak var emailField: UITextField!
    
    @IBOutlet weak var passField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func ForgetPassPressed(_ sender: Any) {
    }
    
    @IBAction func loginPressed(_ sender: Any) {
        Add()
    }
    
    @IBAction func goToRegPressed(_ sender: Any) {
        self.performSegue(withIdentifier: "GoToReg", sender: nil)
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
