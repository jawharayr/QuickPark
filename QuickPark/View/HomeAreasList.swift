//
//  ParkingAreas.swift
//  QuickPark
//
//  Created by manar . on 01/02/2022.
//

import UIKit

class HomeAreasList: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBOutlet weak var areaName: UILabel!
    @IBOutlet weak var spotNo: UILabel!
    @IBOutlet weak var locationDesc: UILabel!
}
