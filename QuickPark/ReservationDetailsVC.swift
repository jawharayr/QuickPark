//
//  ReservationDetailsVC.swift
//  QuickPark
//
//  Created by Deema on 27/08/1443 AH.
//

import Foundation

//
//  ReservationDetailsVC.swift
//  QuickPark
//
//  Created by Deema on 25/08/1443 AH.
//

import UIKit

class ReservationDetailsVC: UIViewController {
    
    
    
    
    @IBOutlet weak var Logo: UIImageView!
    @IBOutlet weak var Areaname: UILabel!
    @IBOutlet weak var Date: UILabel!
    @IBOutlet weak var StartTime: UILabel!
    @IBOutlet weak var EndTime: UILabel!
    @IBOutlet weak var Price: UILabel!
    @IBOutlet weak var ExtraCharges: UILabel!
    @IBOutlet weak var Total: UILabel!
    
    var img = UIImage()
    var areaname = " "
    var date = ""
    var Stime = 0.0
    var Etime = 0.0
    var price = " "
    var extra = " "
    var total = " "
    var curSelectedRes : Reservation?


    override func viewDidLoad() {
        super.viewDidLoad()
        
        Areaname.text = areaname
        Price.text = price
        ExtraCharges.text = extra + " SAR"
        Date.text = date
        Logo.image = img
        
        StartTime.text = TimeInterval.init(Stime).dateFromTimeinterval()
        EndTime.text = TimeInterval.init(Etime).dateFromTimeinterval()

        let x = (extra as NSString).doubleValue
        let y =  (price as NSString).doubleValue
        let z = x + y
        let d = String(z)
        Total.text = d + " SAR"
    }
    



    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Do any additional setup after loading the view.

        }
    
    }
    

    
