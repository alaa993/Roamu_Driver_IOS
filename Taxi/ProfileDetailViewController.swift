//
//  ProfileDetailViewController.swift
//  Taxi
//
//  Created by Bhavin on 06/04/17.
//  Copyright © 2017 icanStudioz. All rights reserved.
//

import UIKit

protocol ProfileDataDelegate {
    func profileDataChanged(data: [String:String])
}

class ProfileDetailViewController: UIViewController {
    
    @IBOutlet var textfield: UITextField!
    
    var data = [String:String]()
    var delegate:ProfileDataDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        if data["from"] == "email" {
            textfield.placeholder = NSLocalizedString("Email", comment: "")
            textfield.keyboardType = .default
        } else if data["from"] == "name" {
            textfield.placeholder = NSLocalizedString("Name", comment: "")
            textfield.keyboardType = .default
        } else if data["from"] == "mobile"{
            textfield.placeholder = NSLocalizedString("Mobile", comment: "")
            textfield.keyboardType = .phonePad
        } else {
            textfield.placeholder = NSLocalizedString("Paypal ID", comment: "")
            textfield.keyboardType = .numberPad
        }
        
        textfield.text = data["text"]
        textfield.becomeFirstResponder()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.view.endEditing(true)
        if let delegate = delegate {
            delegate.profileDataChanged(data: ["from":data["from"]!,"text":textfield.text!])
        }
    }

}
