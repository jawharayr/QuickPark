//
//  CustomCell.swift
//  QuickPark
//
//  Created by MAC on 29/06/1443 AH.
//

import UIKit

class CustomCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    @IBOutlet weak var ParkingView: UIView!
    
    @IBOutlet weak var Label: UILabel!
    
    @IBOutlet weak var Alert: UILabel!
    @IBOutlet weak var Logos: UIImageView!
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    override func layoutSubviews() {
        super.layoutSubviews()

        ParkingView.frame = ParkingView.frame.inset(by: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10))
    }

}
