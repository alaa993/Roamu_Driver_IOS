//
//  ContactUsViewController.swift
//  Taxi
//
//  Created by ibrahim.marie on 11/21/20.
//  Copyright © 2020 icanStudioz. All rights reserved.
//

import UIKit

class ContactUsViewController: UIViewController {
    
    @IBOutlet var TextFieldName: UITextField!
    @IBOutlet var TextFieldEmail: UITextField!
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
        
        self.TextFieldEmail.cornerRadius(radius: 20.0, andPlaceholderString: NSLocalizedString(LocalizationSystem.sharedInstance.localizedStringForKey(key: "ContactUsVC_Email", comment: ""),comment: ""))
        self.TextFieldEmail.paddedTextField(frame: CGRect(x: 0, y: 0, width: 25, height: self.TextFieldEmail.frame.height))
        
        self.TextFieldDetails.cornerRadius(radius: 20.0, andPlaceholderString: NSLocalizedString(LocalizationSystem.sharedInstance.localizedStringForKey(key: "ContactUsVC_Details", comment: ""),comment: ""))
        self.TextFieldDetails.paddedTextField(frame: CGRect(x: 0, y: 0, width: 25, height: TextFieldDetails.frame.height))
        
        self.ButtonSend.corner(radius: 20.0, color: UIColor.white, width: 1.0)
        
        ButtonSend.setTitle(LocalizationSystem.sharedInstance.localizedStringForKey(key: "ContactUsVC_Send", comment: ""), for: .normal)

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
