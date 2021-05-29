//
//  NotificationTableViewCell.swift
//  Taxi
//
//  Created by ibrahim.marie on 11/21/20.
//  Copyright © 2020 icanStudioz. All rights reserved.
//

import Foundation
import UIKit

class NotificationTableViewCell: UITableViewCell {

    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet var postTextView: UITextView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        profileImageView.layer.cornerRadius = profileImageView.bounds.height / 2
        profileImageView.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    var notification:Notification?
    
    
    func set(notification:Notification, username:String, url_: URL) {
        
        self.notification = notification
        self.profileImageView.image = nil
        ImageService.getImage(withURL: url_) { image, url in
            self.profileImageView.image = image
        }
        
        
        usernameLabel.text = username
        postTextView.text = notification.text
        subtitleLabel.text = ""
        subtitleLabel.isHidden = true
    }
}
