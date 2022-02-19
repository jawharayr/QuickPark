//
//  ViewController.swift
//  QuickPark
//
//  Created by MAC on 25/06/1443 AH.
//

import UIKit
import FirebaseDatabase
class ViewController: UIViewController{
   
    private let imageView: UIImageView = {
            let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 250, height: 250))
            imageView.image = UIImage(named: "logo")
            return imageView
            
        }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
      
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

    }
   
}





