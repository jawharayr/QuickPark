//
//  OnboardingVC.swift
//  QuickPark
//
//  Created by manar . on 23/02/2022.
//

import UIKit
import paper_onboarding

class OnboardingVC: UIViewController {
     
    //@IBOutlet var skipButton: UIButton!
    @IBOutlet weak var skipButton : UIButton!
    var Name: UILabel!
    
    var itemsArr : Array = [
     OnboardingItemInfo(informationImage: UIImage(named: "icons8-search.svg")! ,
                                    title: "Search",
                              description: "Find the suitable parking area for you.",
                                 pageIcon: UIImage(named: "icons8-search.svg")!,
                                    color: UIColor.blue,
                        titleColor: UIColor.white,
                         descriptionColor: UIColor.white,
                        titleFont: UIFont(name: "Nunito-Bold", size: 36.0) ?? UIFont.boldSystemFont(ofSize: 36.0),
                          descriptionFont: UIFont(name: "OpenSans-Regular", size: 14.0) ?? UIFont.systemFont(ofSize: 14.0)),

     OnboardingItemInfo(informationImage: UIImage(named: "icons8-search.svg")!,
                                     title: "Reserve",
                               description: "Choose your parking time and confirm.",
                                  pageIcon: UIImage(named: "icons8-search.svg")!,
                                     color: UIColor.blue,
                                titleColor: UIColor.white,
                          descriptionColor: UIColor.white,
                                 titleFont: UIFont(name: "Nunito-Bold", size: 36.0) ?? UIFont.boldSystemFont(ofSize: 36.0),
                           descriptionFont:  UIFont(name: "OpenSans-Regular", size: 14.0) ?? UIFont.systemFont(ofSize: 14.0)),

     OnboardingItemInfo(informationImage: UIImage(named: "icons8-search.svg")!,
                                  title: "Arrive",
                            description: "Use your entery QR Code to enter the parking area." + "Your reservation will be cancelled if you don't arrive within 15 min of your starting time.",
                               pageIcon: UIImage(named: "icons8-search.svg")!,
                                  color: UIColor.blue,
                             titleColor: UIColor.white,
                       descriptionColor: UIColor.white,
                              titleFont: UIFont(name: "Nunito-Bold", size: 36.0) ?? UIFont.boldSystemFont(ofSize: 36.0),
                        descriptionFont: UIFont(name: "OpenSans-Regular", size: 14.0) ?? UIFont.systemFont(ofSize: 14.0)),
     
     OnboardingItemInfo(informationImage: UIImage(named: "icons8-search.svg")!,
                                  title: "Park",
                            description: "A notification will be send before your end time." + "Parking longer than your end time will be counted as extra charges.",
                               pageIcon: UIImage(named: "icons8-search.svg")!,
                                  color: UIColor.blue,
                             titleColor: UIColor.white,
                       descriptionColor: UIColor.white,
                              titleFont: UIFont(name: "Nunito-Bold", size: 36.0) ?? UIFont.boldSystemFont(ofSize: 36.0),
                        descriptionFont: UIFont(name: "OpenSans-Regular", size: 14.0) ?? UIFont.systemFont(ofSize: 14.0)),
     
     OnboardingItemInfo(informationImage: UIImage(named: "icons8-search.svg")!,
                                  title: "Leave",
                            description: "End your parking and pay to receive your exit QR Code.",
                               pageIcon: UIImage(named: "icons8-search.svg")!,
                                  color: UIColor.blue,
                             titleColor: UIColor.white,
                       descriptionColor: UIColor.white,
                              titleFont: UIFont(name: "Nunito-Bold", size: 36.0) ?? UIFont.boldSystemFont(ofSize: 36.0),
                        descriptionFont: UIFont(name: "OpenSans-Regular", size: 14.0) ?? UIFont.systemFont(ofSize: 14.0)) ]

    override func viewDidLoad() {
        super.viewDidLoad()
        skipButton.isHidden = true

        setupPaperOnboardingView()

        view.bringSubviewToFront(skipButton)
    }

    private func setupPaperOnboardingView() {
        let onboarding = PaperOnboarding()
        onboarding.delegate = self
        onboarding.dataSource = self
        onboarding.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(onboarding)

        // Add constraints
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
}

// MARK: Actions

extension ViewController {

    @IBAction func skipButtonTapped(_: UIButton) {
        print(#function)
    }
}

// MARK: PaperOnboardingDelegate

extension ViewController: PaperOnboardingDelegate {

    func onboardingWillTransitonToIndex(_ index: Int) {
        skipButton.isHidden = index == 2 ? false : true
    }

    func onboardingConfigurationItem(_ item: OnboardingContentViewItem, index: Int) {
        
        //item.titleCenterConstraint?.constant = 100
        //item.descriptionCenterConstraint?.constant = 100
        
        // configure item
        
        //item.titleLabel?.backgroundColor = .redColor()
        //item.descriptionLabel?.backgroundColor = .redColor()
        //item.imageView = ...
    }
}

// MARK: PaperOnboardingDataSource

extension ViewController: PaperOnboardingDataSource {

    func onboardingItem(at index: Int) -> OnboardingItemInfo {
        return itemsArr[index]
        
    }

    func onboardingItemsCount() -> Int {
        return 5
    }
    
    //    func onboardinPageItemRadius() -> CGFloat {
    //        return 2
    //    }
    //
    //    func onboardingPageItemSelectedRadius() -> CGFloat {
    //        return 10
    //    }
    //    func onboardingPageItemColor(at index: Int) -> UIColor {
    //        return [UIColor.white, UIColor.red, UIColor.green][index]
    //    }
}


//MARK: Constants
private extension ViewController {
    
    static let titleFont = UIFont(name: "Nunito-Bold", size: 36.0) ?? UIFont.boldSystemFont(ofSize: 36.0)
    static let descriptionFont = UIFont(name: "OpenSans-Regular", size: 14.0) ?? UIFont.systemFont(ofSize: 14.0)
}

