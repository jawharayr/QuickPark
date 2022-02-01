//
//  HomeViewController.swift
//  QuickPark
//
//  Created by manar . on 01/02/2022.
//

import UIKit

class HomeViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        areaListTable.dataSource = self
        areaListTable.register(UINib(nibName: "ParkingAreas", bundle: nil), forCellReuseIdentifier: "ParkingAreas")

        
    }
    

    
    @IBOutlet weak var areaListTable: UITableView!
    
}

extension HomeViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ParkingAreas", for: indexPath) as! ParkingAreas
        cell.areaName.text = "test Name"
        cell.spotNo.text = "test spot"
        cell.locationDesc.text = "test location desc"
        return cell
    }
    
    
    
}
