//
//  ChangePassViewController.swift
//  Taxi
//
//  Created by Bhavin on 06/04/17.
//  Copyright © 2017 icanStudioz. All rights reserved.
//

import UIKit

class ChangePassViewController: UITableViewController {
    @IBOutlet var currentPass: UITextField!
    @IBOutlet var newPass: UITextField!
    @IBOutlet var confirmPass: UITextField!
    @IBOutlet var ChangePassButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        ChangePassButton.setTitle(LocalizationSystem.sharedInstance.localizedStringForKey(key: "ChangePassVC_changePass", comment: ""), for: .normal)
        
        self.currentPass.cornerRadius(radius: 20.0, andPlaceholderString: NSLocalizedString(LocalizationSystem.sharedInstance.localizedStringForKey(key: "ChangePassVC_currentPass", comment: ""),comment: ""))
        self.currentPass.paddedTextField(frame: CGRect(x: 0, y: 0, width: 25, height: self.currentPass.frame.height))
        
        self.newPass.cornerRadius(radius: 20.0, andPlaceholderString: NSLocalizedString(LocalizationSystem.sharedInstance.localizedStringForKey(key: "ChangePassVC_newPass", comment: ""),comment: ""))
        self.newPass.paddedTextField(frame: CGRect(x: 0, y: 0, width: 25, height: self.newPass.frame.height))
        
        self.confirmPass.cornerRadius(radius: 20.0, andPlaceholderString: NSLocalizedString(LocalizationSystem.sharedInstance.localizedStringForKey(key: "ChangePassVC_confirmPass", comment: ""),comment: ""))
        self.confirmPass.paddedTextField(frame: CGRect(x: 0, y: 0, width: 25, height: self.confirmPass.frame.height))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //------------------------------------------------------------------------------------------------------------------------------------------
    // MARK: - Table view data source
    //------------------------------------------------------------------------------------------------------------------------------------------
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 3
        case 1:
            return 1
        default:
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        // Configure the cell...
        return cell
    }

    @IBAction func changeWasClicked(_ sender: UIButton) {
        if validateTextFields(){
            let alert = UIAlertController(title: nil, message: NSLocalizedString("Are you sure to change password?", comment: ""), preferredStyle: .actionSheet)
            let done = UIAlertAction(title: NSLocalizedString("Yes", comment: ""), style: .destructive, handler: { (action) in
                self.updatePassword()
            })
            alert.addAction(done)
            
            let cancel = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler:nil)
            alert.addAction(cancel)
            
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    //------------------------------------------------------------------------------------------------------------------------------------------
    // MARK:- API Requests
    //------------------------------------------------------------------------------------------------------------------------------------------
    func updatePassword(){
        var params = [String:String]()
        params["user_id"] = Common.instance.getUserId()
        params["old_password"] = currentPass.text
        params["new_password"] = newPass.text
        
        let headers = ["X-API-KEY":Common.instance.getAPIKey()]
        
        HUD.show(to: view)
        APIRequestManager.request(apiRequest: APIRouters.ChangePassword(params,headers), success: { (responseData) in
            // -- hide loading --
            HUD.hide(to: self.view)
            
            // -- show message --
            let alert = UIAlertController(title: "", message: NSLocalizedString("Password successfully changed.", comment: ""), preferredStyle: .alert)
            let done = UIAlertAction(title: NSLocalizedString("Done", comment: ""), style: .default, handler: { (action) in
                _ = self.navigationController?.popViewController(animated: true)
            })
            alert.addAction(done)
            DispatchQueue.main.async {
                self.present(alert, animated: true, completion: nil)
            }
            
        }, failure: { (message) in
            HUD.hide(to: self.view)
            Common.showAlert(with: NSLocalizedString("Alert!!", comment: ""), message: message, for: self)
        }, error: { (err) in
            HUD.hide(to: self.view)
            Common.showAlert(with: NSLocalizedString("Error!!" ,comment: ""), message: err.localizedDescription, for: self)
        })
    }
    
    //------------------------------------------------------------------------------------------------------------------------------------------
    // MARK:- Other Methods
    //------------------------------------------------------------------------------------------------------------------------------------------
    func validateTextFields() -> Bool {
        if currentPass.text?.count == 0 ||
            newPass.text?.count == 0 ||
            confirmPass.text?.count == 0 {
            Common.showAlert(with: NSLocalizedString("Alert!!", comment: ""), message: NSLocalizedString("Please fill all the fields.", comment: ""), for: self)
            return false
        } else {
            if (newPass.text?.count)! >= 6 {
                if newPass.text == confirmPass.text {
                    return true
                } else {
                    Common.showAlert(with: NSLocalizedString("Alert!!", comment: ""), message: NSLocalizedString("Passwords does not match.", comment: ""), for: self)
                    return false
                }
            } else {
                Common.showAlert(with: NSLocalizedString("Alert!!", comment: ""), message: NSLocalizedString("Password must be more than 6 characters.", comment: ""), for: self)
                return false
            }
        }
    }

}
