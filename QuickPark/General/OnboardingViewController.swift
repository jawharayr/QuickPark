//
//  OnboardingViewController.swift
//  QuickPark
//
//  Created by manar . on 23/02/2022.
//

import UIKit


class OnboardingViewController: UIViewController {
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
            OnboardingSlide(title: "QuickPark", description: "No more driving around looking for an available parking spot, reserve your spot ahead of time", image: UIImage(named: "OnBoarding1.svg")!),
            
            OnboardingSlide(title: "Always near you", description: "We offer parking areas in multiple locations. park wherever you like!", image: UIImage(named: "OnBoarding2.svg")!),
            
            OnboardingSlide(title: "Available at any time", description: "Reserve your parking at any time, we are availble 24/7 for you!", image: UIImage(named: "OnBoarding3.svg")!)
            
            
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

extension OnboardingViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
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

