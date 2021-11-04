//
//  GoogleDistanceMatrix.swift
//  TaxiDriver
//
//  Created by ibrahim.marie on 9/1/21.
//  Copyright © 2021 icanStudioz. All rights reserved.
//

import Foundation

class GoogleDistanceMatrix: UIView {
    @IBOutlet var distance_info: UILabel!
    @IBOutlet var distance1_info: UILabel!
    @IBOutlet var distance_time_info: UILabel!
    @IBOutlet var distance1_info_var: UILabel!
    @IBOutlet var distance_time_info_var: UILabel!
    
    class func instanceFromNib() -> UIView {
        return UINib(nibName: "GoogleDistanceMatrix", bundle: nil).instantiate(withOwner: nil, options: nil).first as! UIView
    }
}
