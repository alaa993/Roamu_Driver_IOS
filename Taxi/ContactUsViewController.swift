//
//  ContactUsViewController.swift
//  Taxi
//
//  Created by ibrahim.marie on 11/21/20.
//  Copyright © 2020 icanStudioz. All rights reserved.
//

import UIKit
import MessageUI

class ContactUsViewController: UIViewController, MFMailComposeViewControllerDelegate {
    
    @IBOutlet var TextFieldName: UITextField!
//    @IBOutlet var TextFieldEmail: UITextField!
    @IBOutlet var TextFieldDetails: UITextField!
    @IBOutlet var ButtonSend: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = LocalizationSystem.sharedInstance.localizedStringForKey(key: "MenuItem16", comment: "")
        
        // -- setup revealview (side menu) --
        if LocalizationSystem.sharedInstance.getLanguage() == "ar" {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            // Here menuViewController is SideDrawer ViewCOntroller
            let sidemenuViewController = storyboard.instantiateViewController(withIdentifier: "MenuViewController") as? MenuViewController
            revealViewController().rightViewController = sidemenuViewController
            self.revealViewController().rightViewRevealWidth = self.view.frame.width * 0.8
            let menuButton = UIBarButtonItem(image: UIImage(named: "menu"),
                                             style: .plain, target: SWRevealViewController(),
                                             action: #selector(SWRevealViewController.rightRevealToggle(_:)))
            self.navigationItem.leftBarButtonItem = menuButton
        }
        else{
            if let revealController = self.revealViewController() {
                revealController.panGestureRecognizer()
                let menuButton = UIBarButtonItem(image: UIImage(named: "menu"),
                                                 style: .plain, target: revealController,
                                                 action: #selector(SWRevealViewController.revealToggle(_:)))
                self.navigationItem.leftBarButtonItem = menuButton
            }
        }
        
        
        self.TextFieldName.cornerRadius(radius: 20.0, andPlaceholderString: NSLocalizedString(LocalizationSystem.sharedInstance.localizedStringForKey(key: "ContactUsVC_Name", comment: ""),comment: ""))
        self.TextFieldName.paddedTextField(frame: CGRect(x: 0, y: 0, width: 25, height: self.TextFieldName.frame.height))
        
//
        
        self.TextFieldDetails.cornerRadius(radius: 20.0, andPlaceholderString: NSLocalizedString(LocalizationSystem.sharedInstance.localizedStringForKey(key: "ContactUsVC_Details", comment: ""),comment: ""))
        self.TextFieldDetails.paddedTextField(frame: CGRect(x: 0, y: 0, width: 25, height: TextFieldDetails.frame.height))
        
        self.ButtonSend.corner(radius: 20.0, color: UIColor.white, width: 1.0)
        
        ButtonSend.setTitle(LocalizationSystem.sharedInstance.localizedStringForKey(key: "ContactUsVC_Send", comment: ""), for: .normal)

        // Do any additional setup after loading the view.
    }
    
    @IBAction func sendMailClicked(_ sender: Any) {
        print("sendMailClicked")
        
        let subject = "Call us"
//        let body = "Name: \(String(describing: TextFieldName.text))\n Description:  \(String(describing: TextFieldDetails.text))"
        let body = "Name: " + TextFieldName.text! + "\n" + "Description: " + TextFieldDetails.text!
        
        let encodedParams = "subject=\(subject)&body=\(body)"
        let mailtoString = "mailto:info@roamu.net?\(encodedParams)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        print(mailtoString)
        let mailtoUrl = URL(string: mailtoString!)!
        if UIApplication.shared.canOpenURL(mailtoUrl) {
            UIApplication.shared.open(mailtoUrl, options: [:])
        }
        
//        let subject = "Call us"
//        let body = "The awesome body"
//        let encodedParams = "subject=\(subject)&body=\(body)"
//        let url = "mailto:info@roamu.com?\(encodedParams)"
//
//        print(url)
//
//        if let emailURL = NSURL(string: url) {
//            if UIApplication.shared.canOpenURL(emailURL as URL) {
//                UIApplication.shared.open(emailURL as URL)
//            }
//        }
    }
}
