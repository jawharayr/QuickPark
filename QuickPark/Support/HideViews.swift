//
//  HideViews.swift
//  QuickPark
//
//  Created by Deema on 17/08/1443 AH.
//

import Foundation
import UIKit
import FirebaseDatabase
import Firebase
import FirebaseStorage
import SwiftUI
import FirebaseAuth


class BannerViewLauncher: NSObject  {

    var viewController: UIViewController?

    lazy var bannerView : UIView = {
        let view = UIView(frame: .zero)
        view.backgroundColor = .lightGray
        return view
    }()

    //create more UIelements if you want to design the banner further. don't forget to add them as subviews to the bannerView and give them constraints.

    func showNoNetworkBanner() {

        if let window = UIApplication.shared.keyWindow {

            window.addSubview(bannerView)

            //define your desired size here (y position is out of view so it is off view by default, the y position will be changed when you call the showNoNetworkBanner() method.
            bannerView.frame = CGRect(x: 0, y: -100, width: window.frame.width, height: 100)
            //change withDuration if you want it to display slower or faster, just change all of them to the same for it so look good
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseInOut, animations: {

                self.bannerView.frame = CGRect(x: 0, y: -100, width: window.frame.width, height: 100)

            }, completion: nil)

        }
    }

    func hideNoNetworkBanner() {
        if let window = UIApplication.shared.keyWindow {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseIn, animations: {

                self.bannerView.frame = CGRect(x: 0, y: -100, width: window.frame.width, height: 100)

        }, completion: nil)
        }
    }

}
