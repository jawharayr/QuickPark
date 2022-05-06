//
//  PromoCodeCell.swift
//  QuickPark
//
//  Created by Deema on 27/09/1443 AH.
//

import UIKit

class PromoCodeCell: UITableViewCell {
    
    @IBOutlet weak var MainView: UIView!
    @IBOutlet weak var BackView: UIView!
    @IBOutlet weak var PCodeView: UIView!
    
    @IBOutlet weak var promocode: UILabel!
    @IBOutlet weak var Area: UILabel!
    @IBOutlet weak var Discount: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.PCodeView.layer.borderWidth = 1
        self.PCodeView.layer.cornerRadius = 20
        self.PCodeView.layer.borderColor = UIColor.white.cgColor
        self.PCodeView.layer.masksToBounds = true
        self.BackView.layer.shadowOpacity = 0.18
        self.BackView.layer.shadowOffset = CGSize(width: 0, height: 2)
      // self.BackView.layer.shadowRadius = 6
        self.BackView.layer.shadowColor = UIColor.black.cgColor
        self.BackView.layer.masksToBounds = false
        self.BackView.layer.cornerRadius = 15
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    override func layoutSubviews() {
        super.layoutSubviews()

        MainView.frame = MainView.frame.inset(by: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10))
    }

}
