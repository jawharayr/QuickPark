//
//  PastTableViewCell.swift
//  QuickPark
//
//  Created by Deema on 11/07/1443 AH.
//

import UIKit

class PastTableViewCell: UITableViewCell {

    @IBOutlet weak var MainView: UIView!
    @IBOutlet weak var BackView: UIView!
    
    @IBOutlet weak var PastView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.PastView.layer.borderWidth = 1
        self.PastView.layer.cornerRadius = 20
        self.PastView.layer.borderColor = UIColor.white.cgColor
        self.PastView.layer.masksToBounds = true

        self.BackView.layer.shadowOpacity = 0.18
        self.BackView.layer.shadowOffset = CGSize(width: 0, height: 2)
      //  self.BackView.layer.shadowRadius = 6
        self.BackView.layer.shadowColor = UIColor.black.cgColor
        self.BackView.layer.masksToBounds = false
     //   self.BackView.addBorder(toSide: .Right, withColor: UIColor.red.cgColor, andThickness: 1.0)
    //    self.PastView.addBorder(toSide: .Right, withColor: UIColor.red.cgColor, andThickness: 1.0)
    //    self.MainView.addBorder(toSide: .Right, withColor: UIColor.red.cgColor, andThickness: 1.0)
  
        self.BackView.layer.cornerRadius = 15


    }

    @IBOutlet weak var Name: UILabel!
    @IBOutlet weak var Date: UILabel!
    @IBOutlet weak var StartTime: UILabel!
    @IBOutlet weak var EndTime: UILabel!
    @IBOutlet weak var Price: UILabel!
    @IBOutlet weak var ExtraCharges: UILabel!
    
    
    @IBOutlet weak var Logo: UIImageView!
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)


        // Configure the view for the selected state
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()

        MainView.frame = MainView.frame.inset(by: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10))
    }

}
