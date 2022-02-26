//
//  TermsViewController.swift
//  QuickPark
//
//  Created by Ghaliah Binakeel on 11/02/2022.
//

import UIKit

class TermsViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.tableView.backgroundView = UIImageView(image: UIImage(named: "5a36a11aee712c8452ae989ab425827d"))
    }
    
    
    @IBAction func backButtonPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}
