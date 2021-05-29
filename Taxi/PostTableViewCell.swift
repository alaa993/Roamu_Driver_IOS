
//
//  PostTableViewCell.swift
//  Taxi
//
//  Created by ibrahim.marie on 6/13/20.
//  Copyright © 2020 icanStudioz. All rights reserved.
//

import Foundation
import UIKit

class PostTableViewCell: UITableViewCell {

    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var commentsLabel: UILabel!
    @IBOutlet var AboutButton: UIButton!
    @IBOutlet var postTextView: UITextView!
    
    @IBOutlet weak var iii: UIView!
    
    var aStoryboard = UIStoryboard()
    var aNavVC = UINavigationController()
    
    
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
    
    
    func set(post:Post, CommentsNo:Int, subStoryboard:UIStoryboard, subNavigationVC: UINavigationController) {
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
        
        aNavVC = subNavigationVC
        aStoryboard = subStoryboard
        
        usernameLabel.text = post.author.username
        postTextView.text = post.text
        subtitleLabel.text = post.createdAt.calenderTimeSinceNow()
        commentsLabel.text = "\(LocalizationSystem.sharedInstance.localizedStringForKey(key: "DetailReqVCCommentslbl", comment: "")) (\(CommentsNo))"
        AboutButton.setTitle(LocalizationSystem.sharedInstance.localizedStringForKey(key: "PostTableVC_aboutButton", comment: ""), for: .normal)
        
    }
    
    func set1(post:Post) {
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
        postTextView.isEditable = false
        postTextView.isUserInteractionEnabled = false
        postTextView.text = post.text
        subtitleLabel.text = post.createdAt.calenderTimeSinceNow()
//        commentsLabel.text = "\(LocalizationSystem.sharedInstance.localizedStringForKey(key: "DetailReqVCCommentslbl", comment: "")) (\(CommentsNo))"
        
    }
    
    @IBAction func AboutButtonClicked(_ sender: Any) {
        print(String(self.post?.travel_id ??  1))
        let vcConfirm = aStoryboard.instantiateViewController(withIdentifier: "ConfirmRideVC") as! ConfirmRideVC
        vcConfirm.confirmRequestPage = confirmRequestView.PlatformViewController
        print(String(self.post?.travel_id ?? 995))
        vcConfirm.travel_id_var = String(self.post?.travel_id ?? 995)
        aNavVC.pushViewController(vcConfirm, animated: true)
    }
    
    
    
}
