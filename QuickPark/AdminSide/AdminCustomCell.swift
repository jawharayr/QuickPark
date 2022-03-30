//
//  AdminCustomCell.swift
//  QuickPark
//
//  Created by manar . on 15/03/2022.
//

import UIKit

class AdminCustomCell: UITableViewCell {

    @IBOutlet weak var MainView: UIView!
    @IBOutlet weak var BackView: UIView!
    
    @IBOutlet weak var Km: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()

        self.BackView.layer.borderWidth = 1
        self.BackView.layer.cornerRadius = 20
        self.BackView.layer.borderColor = UIColor.white.cgColor
        self.BackView.layer.masksToBounds = true
        //self.BackView.addBorder(toSide: .Right, withColor: UIColor.red.cgColor, andThickness: 1.5)

        self.MainView.layer.shadowOpacity = 0.18
        self.MainView.layer.shadowOffset = CGSize(width: 0, height: 2)
        self.MainView.layer.shadowRadius = 6
        self.MainView.layer.shadowColor = UIColor.black.cgColor
        self.MainView.layer.masksToBounds = false
        self.MainView.addBorder(toSide: .Right, withColor: UIColor.red.cgColor, andThickness: 2.0)
        
    }
    
    //@IBOutlet weak var ParkingView: UIView!
    @IBOutlet weak var Label: UILabel!
    @IBOutlet weak var Alert: UILabel!
    @IBOutlet weak var Logos: UIImageView!
    @IBOutlet weak var ParkingView: UIView!
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()

        ParkingView.frame = ParkingView.frame.inset(by: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10))
    }

}
