//
//  MarkerView.swift
//  TaxiDriver
//
//  Created by ibrahim.marie on 3/29/21.
//  Copyright © 2021 icanStudioz. All rights reserved.
//

import UIKit

class MarkerView: UIView {
    @IBOutlet var titleText: UILabel!
    @IBOutlet var descriptionText: UILabel!
    
    class func instanceFromNib() -> UIView {
        return UINib(nibName: "MarkerView", bundle: nil).instantiate(withOwner: nil, options: nil).first as! UIView
    }
}
