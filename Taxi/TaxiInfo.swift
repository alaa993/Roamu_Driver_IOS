//
//  TaxiInfo.swift
//  TaxiDriver
//
//  Created by ibrahim.marie on 3/31/21.
//  Copyright © 2021 icanStudioz. All rights reserved.
//

import UIKit

protocol TaxiInfoDelegate {
    func requestRideClicked()
}

class TaxiInfo: UIView {
    //MARK:- IBOutlets
    @IBOutlet var userName: UILabel!
    @IBOutlet var from: UILabel!
    @IBOutlet var to: UILabel!
//    @IBOutlet var currentLocation: UILabel!
    var markerData:Ride?
    
    // MARK:- Delegate
    var delegate:TaxiInfoDelegate?
    
    // MARK:- IBActions
    @IBAction func requestRideClicked(_ sender: Any) {
        if let delegate = delegate {
            delegate.requestRideClicked()
        }
    }
    
    // MARK:- Register Xib
    class func instanceFromNib() -> UIView {
        return UINib(nibName: "TaxiInfo", bundle: nil).instantiate(withOwner: nil, options: nil).first as! UIView
    }
    
}
