//
//  ConfirmOrderVC.swift
//  QuickPark
//
//  Created by MAC on 06/07/1443 AH.
//

import UIKit

class ConfirmOrderVC: UIViewController {
    @IBOutlet var ConfirmView: UIView!
    @IBOutlet weak var AreaView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        AreaView?.layer.cornerRadius=20
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
