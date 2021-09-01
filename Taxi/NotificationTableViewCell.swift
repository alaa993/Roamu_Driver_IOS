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
        //        postTextView.text = notification.text
        print(notification.text)
        let elements = ["notification_request",
                        "notification_request_approve",
                        "notification_accepted",
                        "notification_completed",
                        "notification_cancelled",
                        "notification_started",
                        "notification_offline_request",
                        "notification_offline_approved"]
        if elements.contains("notification_\(notification.text)") {
            print("notification_\(notification.text)")
            postTextView.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "notification_\(notification.text)", comment: "")
        }
        else{
            postTextView.text = notification.text
        }
        subtitleLabel.text = notification.createdAt.calenderTimeSinceNow()
        subtitleLabel.isHidden = true
    }
}
