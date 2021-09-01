//
//  NominateDriverViewController.swift
//  Taxi
//
//  Created by ibrahim.marie on 11/21/20.
//  Copyright © 2020 icanStudioz. All rights reserved.
//

import UIKit

class NominateDriverViewController: UIViewController {
    
    @IBOutlet var TextFieldName: UITextField!
    //    @IBOutlet var TextFieldEmail: UITextField!
    @IBOutlet var TextFieldCity: UITextField!
    @IBOutlet var TextFieldCountry: UITextField!
    @IBOutlet var TextFieldPhone: UITextField!
    @IBOutlet var TextFieldVehicle: UITextField!
    @IBOutlet var TextFieldDescription: UITextField!
    @IBOutlet var ButtonSend: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = LocalizationSystem.sharedInstance.localizedStringForKey(key: "MenuItem17", comment: "")
        
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
        
        self.TextFieldName.cornerRadius(radius: 20.0, andPlaceholderString: NSLocalizedString(LocalizationSystem.sharedInstance.localizedStringForKey(key: "NominateDriverVC_Name", comment: ""),comment: ""))
        self.TextFieldName.paddedTextField(frame: CGRect(x: 0, y: 0, width: 25, height: self.TextFieldName.frame.height))
        
        //        self.TextFieldEmail.cornerRadius(radius: 20.0, andPlaceholderString: NSLocalizedString(LocalizationSystem.sharedInstance.localizedStringForKey(key: "NominateDriverVC_Email", comment: ""),comment: ""))
        //        self.TextFieldEmail.paddedTextField(frame: CGRect(x: 0, y: 0, width: 25, height: self.TextFieldEmail.frame.height))
        
        self.TextFieldCity.cornerRadius(radius: 20.0, andPlaceholderString: NSLocalizedString(LocalizationSystem.sharedInstance.localizedStringForKey(key: "NominateDriverVC_City", comment: ""),comment: ""))
        self.TextFieldCity.paddedTextField(frame: CGRect(x: 0, y: 0, width: 25, height: TextFieldCity.frame.height))
        
        self.TextFieldCountry.cornerRadius(radius: 20.0, andPlaceholderString: NSLocalizedString(LocalizationSystem.sharedInstance.localizedStringForKey(key: "NominateDriverVC_Country", comment: ""),comment: ""))
        self.TextFieldCountry.paddedTextField(frame: CGRect(x: 0, y: 0, width: 25, height: TextFieldCountry.frame.height))
        
        self.TextFieldPhone.cornerRadius(radius: 20.0, andPlaceholderString: NSLocalizedString(LocalizationSystem.sharedInstance.localizedStringForKey(key: "NominateDriverVC_Phone", comment: ""),comment: ""))
        self.TextFieldPhone.paddedTextField(frame: CGRect(x: 0, y: 0, width: 25, height: TextFieldPhone.frame.height))
        
        self.TextFieldVehicle.cornerRadius(radius: 20.0, andPlaceholderString: NSLocalizedString(LocalizationSystem.sharedInstance.localizedStringForKey(key: "NominateDriverVC_Vehicle", comment: ""),comment: ""))
        self.TextFieldVehicle.paddedTextField(frame: CGRect(x: 0, y: 0, width: 25, height: TextFieldVehicle.frame.height))
        
        self.TextFieldDescription.cornerRadius(radius: 20.0, andPlaceholderString: NSLocalizedString(LocalizationSystem.sharedInstance.localizedStringForKey(key: "NominateDriverVC_Description", comment: ""),comment: ""))
        self.TextFieldDescription.paddedTextField(frame: CGRect(x: 0, y: 0, width: 25, height: TextFieldDescription.frame.height))
        
        self.ButtonSend.corner(radius: 20.0, color: UIColor.white, width: 1.0)
        
        ButtonSend.setTitle(LocalizationSystem.sharedInstance.localizedStringForKey(key: "ContactUsVC_Send", comment: ""), for: .normal)
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func sendMailClicked(_ sender: Any) {
        print("sendMailClicked")
        
        let subject = "Call us"
        //        let body = "Name: \(String(describing: TextFieldName.text))\n Description:  \(String(describing: TextFieldDetails.text))"
        let body = "Name: " + TextFieldName.text! + "\n" +
            "City: " + TextFieldCity.text! + "\n" +
            "Country: " + TextFieldCountry.text! + "\n" +
            "Phone: " + TextFieldPhone.text! + "\n" +
            "Vehicle: " + TextFieldVehicle.text! + "\n" +
            "Description: " + TextFieldDescription.text!
        
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
