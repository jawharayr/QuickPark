//
//  OnboardingVC.swift
//  QuickPark
//
//  Created by manar . on 23/02/2022.
//

import UIKit
import paper_onboarding

class OnboardingVC: UIViewController, PaperOnboardingDataSource {
     
 

    override func viewDidLoad() {
        super.viewDidLoad()

          let onboarding = PaperOnboarding()
          onboarding.dataSource = self
          onboarding.translatesAutoresizingMaskIntoConstraints = false
          view.addSubview(onboarding)

          // add constraints
        for attribute: NSLayoutConstraint.Attribute in [.left, .right, .top, .bottom] {
            let constraint = NSLayoutConstraint(item: onboarding,
                                                attribute: attribute,
                                                relatedBy: .equal,
                                                toItem: view,
                                                attribute: attribute,
                                                multiplier: 1,
                                                constant: 0)
            view.addConstraint(constraint)
          }
    }

    func onboardingItem(at index: Int) -> OnboardingItemInfo {

       return [
        OnboardingItemInfo(informationImage: UIImage(named: "searchOB.svg")! ,
                                       title: "Search",
                                 description: "Find the suitable parking area for you.",
                                    pageIcon: UIImage(named: "icons8-search.svg")!,
                           color: UIColor.white,
                           titleColor: UIColor(red: 0, green: 144, blue: 205, alpha: 1.00),
                            descriptionColor: UIColor(red: 0, green: 144, blue: 205, alpha: 1.00),
                           titleFont: UIFont(name: "Nunito-Bold", size: 36.0) ?? UIFont.boldSystemFont(ofSize: 36.0),
                             descriptionFont: UIFont(name: "OpenSans-Regular", size: 14.0) ?? UIFont.systemFont(ofSize: 14.0)),

        OnboardingItemInfo(informationImage: UIImage(named: "bookingOB.svg")!,
                                        title: "Reserve",
                                  description: "Choose your parking time and confirm.",
                                     pageIcon: UIImage(named: "icons8-search.svg")!,
                                    color: UIColor.white,
                           titleColor: UIColor(red: 0.0, green: 0.144, blue: 0.205, alpha: 1.00),
                           descriptionColor: UIColor(red: 0.0, green: 144, blue: 205, alpha: 1.00),
                                    titleFont: UIFont(name: "Nunito-Bold", size: 40.0) ?? UIFont.boldSystemFont(ofSize: 36.0),
                              descriptionFont:  UIFont(name: "OpenSans-Regular", size: 20.0) ?? UIFont.systemFont(ofSize: 14.0)),

        OnboardingItemInfo(informationImage: UIImage(named: "arriveOB.svg")!,
                                     title: "Arrive",
                               description: "Use your entery QR Code to enter the parking area." + "Your reservation will be cancelled if you don't arrive within 15 min of your starting time.",
                                  pageIcon: UIImage(named: "icons8-search.svg")!,
                                color: UIColor.white,
                                titleColor: UIColor(red: 0, green: 144, blue: 205, alpha: 1.00),
                          descriptionColor: UIColor(red: 0, green: 144, blue: 205, alpha: 1.00),
                                 titleFont: UIFont(name: "Nunito-Bold", size: 36.0) ?? UIFont.boldSystemFont(ofSize: 36.0),
                           descriptionFont: UIFont(name: "OpenSans-Regular", size: 14.0) ?? UIFont.systemFont(ofSize: 14.0)),
        
        OnboardingItemInfo(informationImage: UIImage(named: "parkOB.svg")!,
                                     title: "Park",
                               description: "A notification will be send before your end time." + "Parking longer than your end time will be counted as extra charges.",
                                  pageIcon: UIImage(named: "icons8-search.svg")!,
                                color: UIColor.white,
                                titleColor: UIColor(red: 0, green: 144, blue: 205, alpha: 1.00),
                          descriptionColor: UIColor(red: 0, green: 144, blue: 205, alpha: 1.00),
                                 titleFont: UIFont(name: "Nunito-Bold", size: 36.0) ?? UIFont.boldSystemFont(ofSize: 36.0),
                           descriptionFont: UIFont(name: "OpenSans-Regular", size: 14.0) ?? UIFont.systemFont(ofSize: 14.0)),
        
        OnboardingItemInfo(informationImage: UIImage(named: "leaveOB.svg")!,
                                     title: "Leave",
                               description: "End your parking and pay to receive your exit QR Code.",
                                  pageIcon: UIImage(named: "icons8-search.svg")!,
                                color: UIColor.white,
                                titleColor: UIColor(red: 0, green: 144, blue: 205, alpha: 1.00),
                          descriptionColor: UIColor(red: 0, green: 144, blue: 205, alpha: 1.00),
                                 titleFont: UIFont(name: "Nunito-Bold", size: 36.0) ?? UIFont.boldSystemFont(ofSize: 36.0),
                           descriptionFont: UIFont(name: "OpenSans-Regular", size: 14.0) ?? UIFont.systemFont(ofSize: 14.0)) ] [index]
     }

     func onboardingItemsCount() -> Int {
        return 5
      }
    
    func onboardingConfigurationItem(item: OnboardingContentViewItem, index: Int) {

    //    item.titleLabel?.backgroundColor = .redColor()
    //    item.descriptionLabel?.backgroundColor = .redColor()
    //    item.imageView = ...
      }
}



