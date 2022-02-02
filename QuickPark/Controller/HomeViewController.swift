//
//  HomeViewController.swift
//  QuickPark
//
//  Created by manar . on 01/02/2022.
//

import UIKit

class HomeViewController: UIViewController {
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        areaListTable.reloadData()
        print (ParkingAreas.shared.landmarks)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        areaListTable.dataSource = self
        areaListTable.register(UINib(nibName: "ParkingAreas", bundle: nil), forCellReuseIdentifier: "ParkingAreas")

        
    }
    

    
    @IBOutlet weak var areaListTable: UITableView!
    
}

extension HomeViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ParkingAreas.shared.landmarks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ParkingAreas", for: indexPath) as! HomeAreasList
        cell.areaName.text = ParkingAreas.shared.landmarks[indexPath.row].areaName
        cell.spotNo.text = ParkingAreas.shared.landmarks[indexPath.row].spotNo
        cell.locationDesc.text = ""
        return cell
    }
    
    
    
}
