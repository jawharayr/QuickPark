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
        
        view.addSubview(imageView)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        imageView.center = view.center
        DispatchQueue.main.asyncAfter(deadline: .now()+0.5, execute: {
                  self.animate()
                })
    }
   
    private func animate(){
        UIView.animate(withDuration: 1, animations: {
                    let size = self.view.frame.size.width * 3.5
                    let diffX = size - self.view.frame.size.width
                    let diffY = self.view.frame.size.height - size
                    self.imageView.frame = CGRect(
                        x: -(diffX/2),
                        y: (diffY/2),
                        width: size,
                        height: size)
                            
                })
        UIView.animate(withDuration: 1 , animations: {
                  
                   self.imageView.alpha = 0
               }, completion: { done in
                   if done {
                       DispatchQueue.main.asyncAfter(deadline: .now()+0.3, execute: {
                           //why are you putting the main pages code in view contorller!!
                       let viewController = ViewController()
                       viewController.modalTransitionStyle = .crossDissolve
                           viewController.modalPresentationStyle = .fullScreen
                       self.present(viewController, animated: true)
                   })
                       
                   }
               })
        
    }
}





