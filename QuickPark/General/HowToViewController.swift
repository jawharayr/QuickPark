//
//  OnboardingViewController.swift
//  QuickPark
//
//  Created by manar . on 23/02/2022.
//

import UIKit


class HowToViewController: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var nextBtn: UIButton!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var skipButton: UIButton!
    var slides: [OnboardingSlide] = []
    
    var fromViewController : String!
    
    var currentPage = 0 {
        didSet {
            pageControl.currentPage = currentPage
            if currentPage == slides.count - 1 {
                nextBtn.setTitle((fromViewController == "login") ? "Get Started" : "Back", for: .normal)
            } else {
                nextBtn.setTitle("Next", for: .normal)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        slides = [
            OnboardingSlide(title: "Search", description: "Find the suitable parking area for you.", image: UIImage(named: "searchOB.svg")!),
            
            OnboardingSlide(title: "Reserve", description: "Choose your parking time and confirm.", image: UIImage(named: "bookingOB.svg")!),
            
            OnboardingSlide(title: "Arrive", description: "Use your entery QR Code to enter the parking area." + "Your reservation will be cancelled if you don't arrive within 15 min of your starting time.", image: UIImage(named: "arriveOB.svg")!),
            
            OnboardingSlide(title: "Park", description: "A notification will be send before your end time." + "Parking longer than your end time will be counted as extra charges.", image: UIImage(named: "parkOB.svg")!),
            
            OnboardingSlide(title: "Leave", description: "End your parking and pay to receive your exit QR Code.", image: UIImage(named: "leaveOB.svg")!)
        ]
        
        pageControl.numberOfPages = slides.count
    }
    
    @IBAction func nextBtnClicked(_ sender: UIButton) {
        if currentPage == slides.count - 1 {
            manageNavigation()
        } else {
            currentPage += 1
            let indexPath = IndexPath(item: currentPage, section: 0)
            collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        }
    }
    
    @IBAction func skipButtonTouched(_ sender: Any) {
        manageNavigation()
    }
    
    func manageNavigation () {
        switch fromViewController {
        case "login":
            goToRegister()
            break
        case "more":
            self.navigationController?.popViewController(animated: true)
            break
        default:
            break
        }
    }
    
    func goToRegister () {
        let vc = SBSupport.viewController(sbi: "sbi_regisrationView", inStoryBoard: "Auth")
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension HowToViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return slides.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: OnboardingCollectionViewCell.identifier, for: indexPath) as! OnboardingCollectionViewCell
        cell.setup(slides[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let width = scrollView.frame.width
        currentPage = Int(scrollView.contentOffset.x / width)
    }
}

