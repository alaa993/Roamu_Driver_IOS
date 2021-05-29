//
//  RequestsCell.swift
//  Taxi
//
//  Created by Bhavin on 07/03/17.
//  Copyright © 2017 icanStudioz. All rights reserved.
//

import UIKit

class RequestsCell: UITableViewCell {

    @IBOutlet var streetFrom: UILabel!
    @IBOutlet var streetTo: UILabel!
    @IBOutlet var detailAdrsFrom: UILabel!
    @IBOutlet var detailAdrsTo: UILabel!
    @IBOutlet var timeLabel: UILabel!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var name: UILabel!
    @IBOutlet var ReqTypeVal: UILabel!
    
    
    
    @IBOutlet var DriverNameVar: UILabel!
    @IBOutlet var DriveMobileVar: UILabel!
    @IBOutlet var DriverMailVar: UILabel!
    @IBOutlet var DriverStatusVar: UILabel!
    
    //@IBOutlet var DriverNamelbl: UILabel!
    @IBOutlet var DriveMobilelbl: UILabel!
    @IBOutlet var DriverMaillbl: UILabel!
    @IBOutlet var DriverStatuslbl: UILabel!
    
    @IBOutlet var Fromlbl: UILabel!
    @IBOutlet var Tolbl: UILabel!
    @IBOutlet var Datelbl: UILabel!
    @IBOutlet var DriverNamelbl: UILabel!
    @IBOutlet var TotalFarelbl: UILabel!
    @IBOutlet var ReqTypelbl: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
