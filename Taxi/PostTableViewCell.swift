
//
//  PostTableViewCell.swift
//  Taxi
//
//  Created by ibrahim.marie on 6/13/20.
//  Copyright © 2020 icanStudioz. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class PostTableViewCell: UITableViewCell {
    @IBOutlet weak var edit_post: UIButton!
    
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
        if(post!.travel_id > 0){
            let vcConfirm = aStoryboard.instantiateViewController(withIdentifier: "ConfirmRideVC") as! ConfirmRideVC
            vcConfirm.confirmRequestPage = confirmRequestView.PlatformViewController
            vcConfirm.travel_id_var = String(self.post!.travel_id)
            aNavVC.pushViewController(vcConfirm, animated: true)
        }
    }
    
    
    @IBAction func edit_post_action(_ sender: Any) {
        
        let title = LocalizationSystem.sharedInstance.localizedStringForKey(key: "Profile_settings", comment: "")
        let alert = UIAlertController(title: nil, message: title, preferredStyle: .actionSheet)
        
        //Profile_sharePost
        alert.addAction(UIAlertAction(title: LocalizationSystem.sharedInstance.localizedStringForKey(key: "Profile_sharePost", comment: ""), style: .destructive, handler: { (_) in
            do{
                let screen = UIScreen.main
                
                if let window = UIApplication.shared.keyWindow {
                    UIGraphicsBeginImageContextWithOptions(screen.bounds.size, false, 0);
                    window.drawHierarchy(in: window.bounds, afterScreenUpdates: false)
                    let image = UIGraphicsGetImageFromCurrentImageContext();
                    UIGraphicsEndImageContext();
                    let share = UIActivityViewController(activityItems: [image], applicationActivities: [])
                    self.aNavVC.present(share, animated: true, completion: nil)
                }
            } catch {
                debugPrint("Error Occurred while logging out!")
            }
        }))
        //Profile_editPost
        alert.addAction(UIAlertAction(title: LocalizationSystem.sharedInstance.localizedStringForKey(key:
            "Profile_editPost", comment: ""), style: .destructive, handler: { [self] (_) in
                do{
                    var alertController:UIAlertController?
                    alertController = UIAlertController(title:
                        NSLocalizedString(LocalizationSystem.sharedInstance.localizedStringForKey(key: "Profile_editPost", comment: ""),comment: ""),
                                                        message: NSLocalizedString(LocalizationSystem.sharedInstance.localizedStringForKey(key: "", comment: ""),comment: ""),
                                                        preferredStyle: .alert)
                    
                    
                    
                    alertController!.addTextField(
                        configurationHandler: {(textField: UITextField!) in
                            textField.placeholder = NSLocalizedString(LocalizationSystem.sharedInstance.localizedStringForKey(key: "SharePost_TextBody", comment: ""),comment: "")
                            //                textField.keyboardType = UIKeyboardType.numberPad
                            textField.keyboardType = .default
                            
                    })
                    
                    let action = UIAlertAction(title: NSLocalizedString(LocalizationSystem.sharedInstance.localizedStringForKey(key: "Submit", comment: ""),comment: ""),
                                               style: UIAlertAction.Style.default,
                                               handler: {[weak self]
                                                (paramAction:UIAlertAction!) in
                                                if let textFields = alertController?.textFields{
                                                    let theTextFields = textFields as [UITextField]
                                                    if theTextFields[0].text!.count == 0{
                                                        return
                                                    }
                                                    Database.database().reference().child("posts").child(self!.post!.id).observeSingleEvent(of: .value, with: { (snapshot) in
                                                        // Get user value
                                                        if snapshot.value is NSNull {
                                                            return
                                                        }
                                                        let value = snapshot.value as? NSDictionary
                                                        let refrence = Database.database().reference().child("posts").child(self!.post!.id)
                                                        //                                                    let autoID = refrence.key!
                                                        let values: [String: Any] = ["text": theTextFields[0].text]
                                                        refrence.updateChildValues(values, withCompletionBlock: { (_, _) in
                                                            Database.database().reference().child("posts").child(self!.post!.id).observeSingleEvent(of: .value, with: { snapshot in
                                                                print("ibrahim")
                                                                print(snapshot)
                                                                if let childSnapshot = snapshot as? DataSnapshot,
                                                                    let dict = childSnapshot.value as? [String:Any],
                                                                    let text = dict["text"] as? String{
                                                                    self!.postTextView.text = text
                                                                }
                                                            })
                                                        })
                                                    })
                                                    
                                                }
                    })
                    let action2 = UIAlertAction(title: NSLocalizedString(LocalizationSystem.sharedInstance.localizedStringForKey(key: "Cancel", comment: ""),comment: ""),style: UIAlertAction.Style.default,handler: {[weak self] (paramAction:UIAlertAction!) in
                    })
                    alertController?.addAction(action)
                    alertController?.addAction(action2)
                    self.aNavVC.present(alertController!,
                                        animated: true,
                                        completion: nil)
                } catch {
                    debugPrint("Error Occurred while logging out!")
                }
        }))
        //Profile_delPost
        alert.addAction(UIAlertAction(title: LocalizationSystem.sharedInstance.localizedStringForKey(key: "Profile_delPost", comment: ""), style: .destructive, handler: { [self] (_) in
            do{
                Database.database().reference().child("posts").child(String(self.post!.id)).removeValue{ error, _ in
                    if error == nil {
                        //                        _ = self.aNavVC.popToRootViewController(animated: true)
                        
                        let vc = self.aStoryboard.instantiateViewController(withIdentifier: "PlatformViewController") as! PlatformViewController
                        self.aNavVC.pushViewController(vc, animated: true)
                    }else {
                        print(error)
                    }
                }
            } catch {
                debugPrint("Error Occurred while logging out!")
            }
        }))
        alert.addAction(UIAlertAction(title: LocalizationSystem.sharedInstance.localizedStringForKey(key: "Profile_cancel", comment: ""), style: .cancel, handler: nil))
        aNavVC.present(alert, animated: true, completion: nil)
    }
}
