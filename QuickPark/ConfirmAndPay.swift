//
//  ConfirmAndPay.swift
//  QuickPark
//
//  Created by MAC on 06/07/1443 AH.
//

import UIKit

class ConfirmAndPay: UIViewController {

    @IBOutlet weak var PriceView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        //price View round
        PriceView.layer.cornerRadius = 20

        // Do any additional setup after loading the view.
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
