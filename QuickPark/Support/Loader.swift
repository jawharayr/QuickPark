//
//  Loader.swift
//  QuickPark
//
//  Created by Usman on 19/02/2022.
//

import Foundation
import UIKit
import NVActivityIndicatorView


 var activityRestorationIdentifier: String {
    return "NVActivityIndicatorViewContainer"
}



// MARK: - Circle_Animation
var colour = UIColor(red: 0, green: 144/255, blue: 205/255, alpha: 1)

func startActivityAnimating(padding: CGFloat? = nil, isFromOnView:Bool,view:UIView , width : CGFloat , height:CGFloat,color:UIColor = colour) {
    view.tag = 100
    var activityIndicator : NVActivityIndicatorView!
    let type = NVActivityIndicatorType.ballScaleRippleMultiple
    let xAxis = (view.frame.size.width / 2 - width/2)//self.view.center.x // or use  // or use (faqWebView.frame.size.width / 2)
    let yAxis = (view.frame.size.height / 2 - height/2)//self.view.center.y // or use  // or use (faqWebView.frame.size.height / 2)
    
    let frame = CGRect(x: (xAxis), y: (yAxis), width: width, height: height)
    activityIndicator = NVActivityIndicatorView(frame: frame)
    activityIndicator.type = type // add your type
    activityIndicator.color = color // add your color
    activityIndicator.tag = 101
    view.addSubview(activityIndicator) // or use  webView.addSubview(activityIndicator)
    activityIndicator.startAnimating()
}


func startActivityAnimatingRed(padding: CGFloat? = nil, isFromOnView:Bool,view:UIView , width : CGFloat , height:CGFloat,color:UIColor = UIColor.systemRed) {
    view.tag = 100
    var activityIndicator : NVActivityIndicatorView!
    let type = NVActivityIndicatorType.ballScaleRippleMultiple
    let xAxis = (view.frame.size.width / 2 - width/2)//self.view.center.x // or use  // or use (faqWebView.frame.size.width / 2)
    let yAxis = (view.frame.size.height / 2 - height/2)//self.view.center.y // or use  // or use (faqWebView.frame.size.height / 2)
    
    
    
    let frame = CGRect(x: (xAxis), y: (yAxis), width: width, height: height)
    activityIndicator = NVActivityIndicatorView(frame: frame)
    activityIndicator.type = type // add your type
    activityIndicator.color = color // add your color
    activityIndicator.tag = 102
    view.addSubview(activityIndicator) // or use  webView.addSubview(activityIndicator)
    activityIndicator.startAnimating()
    
}


func removeSubview(view:UIView){
   // println("Start remove sibview")
    if let viewWithTag =  view.viewWithTag(100) {
        viewWithTag.removeFromSuperview()
    }else{
       // println("No!")
    }
}
