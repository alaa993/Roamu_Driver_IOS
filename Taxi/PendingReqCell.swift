//
//  PendingReqCell.swift
//  Taxi
//
//  Created by Bhavin on 10/03/17.
//  Copyright © 2017 icanStudioz. All rights reserved.
//

import UIKit

protocol PendingReqCellDelegate {
    func acceptWasPressed(cell:UITableViewCell)
}

class PendingReqCell: UITableViewCell {

    var delegate:PendingReqCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func acceptWasPressed(_ sender: UIButton) {
        if let delegate = delegate {
            delegate.acceptWasPressed(cell: self)
        }
    }
}
