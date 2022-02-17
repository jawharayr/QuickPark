//
//  PastTableViewCell.swift
//  QuickPark
//
//  Created by Deema on 11/07/1443 AH.
//

import UIKit

class PastTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    @IBOutlet weak var Name: UILabel!
    @IBOutlet weak var Date: UILabel!
    @IBOutlet weak var StartTime: UILabel!
    @IBOutlet weak var EndTime: UILabel!
    @IBOutlet weak var logo: UIImageView!
    @IBOutlet weak var Price: UILabel!
    @IBOutlet weak var ExtraCharges: UILabel!
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
