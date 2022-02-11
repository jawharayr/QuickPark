//
//  ConfirmAndPay.swift
//  QuickPark
//
//  Created by MAC on 06/07/1443 AH.
//

import UIKit

class ConfirmAndPay: UIViewController {

    @IBOutlet weak var StartTimeTxt: UITextField!
    @IBOutlet weak var EndTimeTxt: UITextField!
    
    let StartTimePicker = UIDatePicker()
    let EndTimePicker = UIDatePicker()
    
    @IBOutlet weak var StartWithView: UIView!
    
    @IBAction func WhenDoneClicked(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
        let FirstViewController = ViewController()
               present(FirstViewController, animated: true, completion: nil)
        
    }
    @IBOutlet weak var DoneButton: UIButton!
    @IBOutlet weak var PriceView: UIView!
    @IBOutlet weak var EndWithView: UIView!
    @IBOutlet weak var AreaView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        AreaView.layer.cornerRadius = 20
        StartWithView.layer.cornerRadius = 20
        EndWithView.layer.cornerRadius = 20
        PriceView.layer.cornerRadius = 20
        //shadow
        AreaView.layer.shadowColor = UIColor.black.cgColor
        AreaView.layer.shadowOpacity = 0.1
        AreaView.layer.shadowOffset = .zero
       AreaView.layer.shadowRadius = 10
        //
        StartWithView.layer.shadowColor = UIColor.black.cgColor
        StartWithView.layer.shadowOpacity = 0.1
        StartWithView.layer.shadowOffset = .zero
       StartWithView.layer.shadowRadius = 10
        //
        EndWithView.layer.shadowColor = UIColor.black.cgColor
        EndWithView.layer.shadowOpacity = 0.1
        EndWithView.layer.shadowOffset = .zero
       EndWithView.layer.shadowRadius = 10
        //
        PriceView.layer.shadowColor = UIColor.black.cgColor
        PriceView.layer.shadowOpacity = 0.1
        PriceView.layer.shadowOffset = .zero
       PriceView.layer.shadowRadius = 10
        DoneButton.layer.cornerRadius = 20
        
        //time picker
                createTimePicker()
      
    }
    
    
    func createTimePicker() {
            
            StartTimeTxt.textAlignment = .center
            EndTimeTxt.textAlignment = .center
            
            //tool bar
            let toolbar = UIToolbar()
            toolbar.sizeToFit()
            
            //bar button(
           let doneBtn = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(donePressed))
           toolbar.setItems([doneBtn], animated: true)
        
            //assign tool bar
            StartTimeTxt.inputAccessoryView = toolbar
            EndTimeTxt.inputAccessoryView = toolbar
            
            // assign time picker to the txt field
            StartTimeTxt.inputView = StartTimePicker
            EndTimeTxt.inputView = EndTimePicker
            
            //time picker mode
            StartTimePicker.datePickerMode = .time
            EndTimePicker.datePickerMode = .time
            
             if #available(iOS 13.4, *)  {
                   StartTimePicker.preferredDatePickerStyle = .wheels
                   EndTimePicker.preferredDatePickerStyle = .wheels
               }
        
        }

    @objc func donePressed(){
           // formatter
           let formatter = DateFormatter()
           formatter.dateStyle = .none
           formatter.timeStyle = .short
           
           StartTimeTxt.text = formatter.string(from: StartTimePicker.date)
           self.view.endEditing(true)
           
           EndTimeTxt.text = formatter.string(from: EndTimePicker.date)
           self.view.endEditing(true)
       }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
