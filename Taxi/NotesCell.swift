//
//  NotesCell.swift
//  TaxiDriver
//
//  Created by ibrahim.marie on 8/15/21.
//  Copyright © 2021 icanStudioz. All rights reserved.
//

import UIKit

class NotesCell: UITableViewCell {
    
    @IBOutlet var UserNamelbl: UILabel!
    @IBOutlet var UserNotelbl: UILabel!
    
    @IBOutlet var UserNameVar: UILabel!
    @IBOutlet var UserNoteVar: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
