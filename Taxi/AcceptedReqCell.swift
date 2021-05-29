//
//  AcceptedReqCell.swift
//  Taxi
//
//  Created by Bhavin on 10/03/17.
//  Copyright © 2017 icanStudioz. All rights reserved.
//

import UIKit

protocol AcceptedReqCellDelegate {
    func trackWasClicked(cell:UITableViewCell)
}

class AcceptedReqCell: UITableViewCell {

    var delegate:AcceptedReqCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    @IBAction func trackWasClicked(_ sender: UIButton) {
        if let delegate = delegate {
            delegate.trackWasClicked(cell: self)
        }
    }
}
