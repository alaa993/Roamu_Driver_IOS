//
//  CommentTableViewCell.swift
//  Taxi
//
//  Created by ibrahim.marie on 11/21/20.
//  Copyright © 2020 icanStudioz. All rights reserved.
//

import Foundation
import UIKit

class CommentTableViewCell: UITableViewCell {

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
    
    weak var post:Post?
    
    
    func set(post:Post) {
        self.post = post
        
        self.profileImageView.image = nil
        ImageService.getImage(withURL: post.author.photoURL) { image, url in
            guard let _post = self.post else { return }
            if _post.author.photoURL.absoluteString == url.absoluteString {
                self.profileImageView.image = image
            } else {
                print("Not the right image")
            }
        }
        
        usernameLabel.text = post.author.username
        postTextView.text = post.text
        subtitleLabel.text = post.createdAt.calenderTimeSinceNow()
        postTextView.text = postTextView.text
    }
}
