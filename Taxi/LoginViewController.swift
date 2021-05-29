//
//  LoginViewController.swift
//  Taxi
//
//  Created by Bhavin on 04/03/17.
//  Copyright © 2017 icanStudioz. All rights reserved.
//

import UIKit
import Firebase

class LoginViewController: UIViewController {
    // -- IBOutlests --
    @IBOutlet var emailText: UITextField!
    @IBOutlet var passwordText: UITextField!
    @IBOutlet var loginButton: UIButton!
    @IBOutlet var signUpbutton: UIButton!
    @IBOutlet var backButton: UIButton!

    
    //------------------------------------------------------------------------------------------------------------------------------------------
    // MARK:- View Controller Life Cycle
    //------------------------------------------------------------------------------------------------------------------------------------------

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        emailText.cornerRadius(radius: 20.0, andPlaceholderString: NSLocalizedString("Email",comment: ""))
        emailText.paddedTextField(frame: CGRect(x: 0, y: 0, width: 25, height: emailText.frame.height))
        passwordText.cornerRadius(radius: 20.0, andPlaceholderString: NSLocalizedString("Password",comment: ""))
        passwordText.paddedTextField(frame: CGRect(x: 0, y: 0, width: 25, height: passwordText.frame.height))
        
        loginButton.corner(radius: 20.0, color: UIColor.white, width: 1.0)
        signUpbutton.corner(radius: 20.0, color: UIColor.white, width: 2.0)
        backButton.corner(radius: 5.0, color: UIColor.white, width: 1.0)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //------------------------------------------------------------------------------------------------------------------------------------------
    // MARK:- IBActions
    //------------------------------------------------------------------------------------------------------------------------------------------

    @IBAction func backWasPressed(_ sender: Any) {
        _ = self.navigationController?.popViewController(animated: true)
    }

    @IBAction func loginWasPressed(_ sender: UIButton) {
        HUD.show(to: self.view)
        let manager = LocationManager.sharedInstance
        manager.reverseGeocodeLocationWithLatLong(latitude: manager.latitude, longitude: manager.longitude) { (response, placemark, str) in
            if response != nil {
                if self.emailText.text?.count == 0 || self.passwordText.text?.count == 0 {
                    HUD.hide(to: self.view)
                    Common.showAlert(with: NSLocalizedString("Alert!!", comment: ""), message: NSLocalizedString("email and password is required to login.", comment: "") , for: self)
                }
                else{
                    if self.validateTextFields() {
                        var params = [String:Any]()
                        params["mobile"] = self.emailText.text
                        params["password"] = self.passwordText.text
                        params["utype"] = "1" // utype = "0" means user and "1" = driver
                        
                        APIRequestManager.request(apiRequest: APIRouters.LoginUser(params), success: { (responseData) in
                            HUD.hide(to: self.view)
                            if let data = responseData as? [String:Any] {
                                let userData = User(userData: data)
                                let encodedData = NSKeyedArchiver.archivedData(withRootObject: userData)
                                UserDefaults.standard.set(encodedData, forKey: "user")
                                UserDefaults.standard.set(data["key"], forKey: "key")
                                
                                Auth.auth().signIn(withEmail: "eng.ibrahim.meree@gmail.com", password: "123456") { user, error in
                                    if error == nil && user != nil {
                                        self.dismiss(animated: false, completion: nil)
                                        print("success")
                                        print(Auth.auth().currentUser?.uid)
                                    } else {
                                        print("Error logging in: \(error!.localizedDescription)")
                                    }
                                }
                                
                                
                                self.moveToDashboard()
//                                if userData.brand?.count == 0 {
//                                    self.setVehicleInfo()
//                                } else {
//                                    self.moveToDashboard()
//                                }
                            }
                        }, failure: { (message) in
                            HUD.hide(to: self.view)
                            self.moveToSignUpPage(mobileParam: self.emailText.text!, passwordParam: self.passwordText.text! , token : "")
                        }, error: { (err) in
                            HUD.hide(to: self.view)
                            Common.showAlert(with: NSLocalizedString("Error!!" ,comment: ""), message: err.localizedDescription, for: self)
                        })
                    }
                    else{
                        HUD.hide(to: self.view)
                    }
                }
            }
            else{
                HUD.hide(to: self.view)
            }
        }
    }
    
    @IBAction func forgotPassPressed(_ sender: UIButton) {
        let alertController = UIAlertController(title: NSLocalizedString("Password Reset", comment: ""), message: NSLocalizedString("Enter your email address you used to sign in.", comment: ""), preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: NSLocalizedString("Reset my password", comment: ""), style: .default, handler: {
            alert -> Void in
            let textField = alertController.textFields?.first
            
            if textField?.text?.count == 0 {
                return
            } else {
                self.resetPassword(email: (textField!.text)!)
            }
        }))
        
        alertController.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .destructive, handler: nil))
        
        alertController.addTextField(configurationHandler: {(textField : UITextField!) -> Void in
            textField.placeholder = "Enter your email"
        })
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func resetPassword(email:String){
        APIRequestManager.request(apiRequest: APIRouters.ForgotPassword(["email":email]), success: { (responseData) in
            if let data = responseData as? String {
                Common.showAlert(with: "", message: data, for: self)
            }
        }, failure: { (message) in
            Common.showAlert(with: NSLocalizedString("Alert!!", comment: ""), message: message, for: self)
        }, error: { (err) in
            Common.showAlert(with: NSLocalizedString("Error!!" ,comment: ""), message: err.localizedDescription, for: self)
        })
    }
    
    func getVehicleInfo(){
        
    }
    
    //------------------------------------------------------------------------------------------------------------------------------------------
    // MARK:- Other Methods
    //------------------------------------------------------------------------------------------------------------------------------------------
    
    func moveToDashboard(){
        let menu = self.storyboard?.instantiateViewController(withIdentifier: "MenuViewController") as! MenuViewController
        let dashboard = self.storyboard?.instantiateViewController(withIdentifier: "HomeViewController") as! HomeViewController
        let dashboardNav = UINavigationController(rootViewController: dashboard)
        let revealController = SWRevealViewController(rearViewController: menu, frontViewController: dashboardNav)
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.window?.rootViewController = revealController
    }
    
    func moveToSignUpPage(mobileParam:String , passwordParam:String , token:String){
    let vc = self.storyboard?.instantiateViewController(withIdentifier: "SignUpViewController") as! SignUpViewController
        vc.UserData = ["mobile":mobileParam, "password":passwordParam]
    self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func setVehicleInfo() {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "VehicleTableViewController") as! VehicleTableViewController
        vc.isFromLogin = true
        let nav = UINavigationController(rootViewController: vc)
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.window?.rootViewController = nav
    }
    
    func validateTextFields() -> Bool {
        if emailText.text?.count == 0 ||
            passwordText.text?.count == 0 {
            Common.showAlert(with: NSLocalizedString("Alert!!", comment: ""), message: NSLocalizedString("Please fill all the fields.",comment: ""), for: self)
            return false
        } else {
            return true
        }
    }
}
