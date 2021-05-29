//
//  NewPostViewController.swift
//  Taxi
//
//  Created by ibrahim.marie on 6/13/20.
//  Copyright © 2020 icanStudioz. All rights reserved.
//

import Foundation
import UIKit
import Firebase

protocol NewPostVCDelegate {
    func didUploadPost(withID id:String)
}

class NewPostViewController:UIViewController, UITextViewDelegate {
    
    @IBOutlet weak var textView:UITextView!
    @IBOutlet weak var placeHolderLabel: UILabel!
    
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var doneButton: UIButton!
    
    var delegate:NewPostVCDelegate?
    
    @IBAction func handlePostButton() {
        
        print("Post button clicked")
        
        guard let userProfile = UserService.currentUserProfile else { return }
        // Firebase code here
        
        let postRef = Database.database().reference().child("posts").childByAutoId()
        
        let postObject = [
            "author": [
                "uid": userProfile.uid,
                "username": userProfile.username,
                "photoURL": userProfile.photoURL.absoluteString
            ],
            "text": textView.text!,
            "timestamp": [".sv":"timestamp"],
            "type": "0",
            "travel_id": 0,
            "privacy": "1"
        ] as [String:Any]
        
        postRef.setValue(postObject, withCompletionBlock: { error, ref in
            if error == nil {
                self.delegate?.didUploadPost(withID: ref.key!)
                self.dismiss(animated: true, completion: nil)
            } else {
                // Handle the error
            }
        })
    }
    
    @IBAction func handleCancelButton() {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        textView.resignFirstResponder()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25, execute: {
            super.dismiss(animated: flag, completion: completion)
        })
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        doneButton.setTitle(LocalizationSystem.sharedInstance.localizedStringForKey(key: "NewPostVC_PostButton", comment: ""), for: .normal)
        placeHolderLabel.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "NewPostVC_placeHolderLabel", comment: "")
        
        cancelButton.tintColor = secondaryColor
        
        doneButton.backgroundColor = secondaryColor
        doneButton.layer.cornerRadius = doneButton.bounds.height / 2
        doneButton.clipsToBounds = true
        
        textView.delegate = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        textView.becomeFirstResponder()
        
        // Remove the nav shadow underline
        navigationController?.navigationBar.shadowImage = UIImage()
    }
    
    func textViewDidChange(_ textView: UITextView) {
        placeHolderLabel.isHidden = !textView.text.isEmpty
    }
}
