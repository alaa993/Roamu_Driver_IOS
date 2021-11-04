//
//  SignUpViewController.swift
//  Taxi
//
//  Created by Bhavin on 04/03/17.
//  Copyright © 2017 icanStudioz. All rights reserved.
//

import UIKit
import Firebase

class SignUpViewController: UIViewController, UIPickerViewDelegate {
    @IBOutlet var nameText: UITextField!
    @IBOutlet var lastNameText: UITextField!
    @IBOutlet var emailText: UITextField!
    @IBOutlet var SocialStatus: UITextField!
    @IBOutlet var signUpButton: UIButton!
    @IBOutlet var backButton: UIButton!
    @IBOutlet var OptionalLbl: UILabel!
    
    
    @IBOutlet var profileImageView: UIImageView!
    
    let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
    
    var imagePicker:UIImagePickerController!
    
    var UserData = [String:Any]()
    
    var urlImage = ""
    
    @objc let SocialStatusPicker = UIPickerView()
    let SocialStatusPickerData = [String](arrayLiteral: LocalizationSystem.sharedInstance.localizedStringForKey(key: "SignUpVC_SocialStatusEmployess", comment: ""),LocalizationSystem.sharedInstance.localizedStringForKey(key: "SignUpVC_SocialStatusStudent", comment: ""),LocalizationSystem.sharedInstance.localizedStringForKey(key: "SignUpVC_SocialStatusRegular", comment: ""))//["Yes","No"]
    var SocialStatusString = LocalizationSystem.sharedInstance.localizedStringForKey(key: "SignUpVC_SocialStatusRegular", comment: "")
    
    var is_image_selected = false
    
    
    //------------------------------------------------------------------------------------------------------------------------------------------
    // MARK:- View Controller Life Cycle
    //------------------------------------------------------------------------------------------------------------------------------------------
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        signUpButton.setTitle(LocalizationSystem.sharedInstance.localizedStringForKey(key: "SignUpVC_signUpButton", comment: ""), for: .normal)
        backButton.setTitle(LocalizationSystem.sharedInstance.localizedStringForKey(key: "BackButton", comment: ""), for: .normal)
        // Do any additional setup after loading the view.
        nameText.cornerRadius(radius: 20.0, andPlaceholderString: NSLocalizedString(LocalizationSystem.sharedInstance.localizedStringForKey(key: "SignUpVC_nameText", comment: ""),comment: ""))
        nameText.paddedTextField(frame: CGRect(x: 0, y: 0, width: 25, height: nameText.frame.height))
        
        lastNameText.cornerRadius(radius: 20.0, andPlaceholderString: NSLocalizedString(LocalizationSystem.sharedInstance.localizedStringForKey(key: "SignUpVC_last_nameText", comment: ""),comment: ""))
        lastNameText.paddedTextField(frame: CGRect(x: 0, y: 0, width: 25, height: lastNameText.frame.height))
        
        emailText.cornerRadius(radius: 20.0, andPlaceholderString: NSLocalizedString(LocalizationSystem.sharedInstance.localizedStringForKey(key: "SignUpVC_emailText", comment: ""),comment: ""))
        emailText.paddedTextField(frame: CGRect(x: 0, y: 0, width: 25, height: emailText.frame.height))
        
        SocialStatus.cornerRadius(radius: 20.0, andPlaceholderString: NSLocalizedString(LocalizationSystem.sharedInstance.localizedStringForKey(key: "SignUpVC_SocialStatusRegular", comment: ""),comment: ""))
        SocialStatus.paddedTextField(frame: CGRect(x: 0, y: 0, width: 25, height: emailText.frame.height))
        
        signUpButton.corner(radius: 20.0, color: UIColor.white, width: 1.0)
        backButton.corner(radius: 5.0, color: UIColor.white, width: 1.0)
        OptionalLbl.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "SignUpVC_OptionalText", comment: "")
        
        SocialStatusPicker.delegate = self
        createSocialStatusPicker()
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        let imageTap = UITapGestureRecognizer(target: self, action: #selector(openImagePicker))
        profileImageView.isUserInteractionEnabled = true
        profileImageView.addGestureRecognizer(imageTap)
        profileImageView.layer.cornerRadius = profileImageView.bounds.height / 2
        profileImageView.clipsToBounds = true
        //tapToChangeProfileButton.addTarget(self, action: #selector(openImagePicker), for: .touchUpInside)
        
        imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = true
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        
        //UserData = ["mobile": "123456789", "password": "123456", "gcm_token": "12345678987654321234567876543234567"]
        
        
    }
    
    func createSocialStatusPicker(){
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        let doneButton = UIBarButtonItem(title: LocalizationSystem.sharedInstance.localizedStringForKey(key: "FindTravelVC_Done", comment: ""), style: UIBarButtonItem.Style.done, target: self, action: #selector(doneSocialStatusButton))
        SocialStatus.inputAccessoryView = toolBar;
        SocialStatus.inputView = SocialStatusPicker
        toolBar.setItems([doneButton], animated: true)
    }
    
    @objc func openImagePicker(_ sender:Any) {
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    @objc func doneSocialStatusButton (){
        self.SocialStatus.text = SocialStatusString
        self.view.endEditing(true)
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return SocialStatusPickerData.count
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        SocialStatus.text = SocialStatusPickerData[row]
        SocialStatusString = SocialStatusPickerData[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
        SocialStatusPickerData[row]
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func backWasPressed(_ sender: Any) {
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func registerWasPressed(_ sender: Any) {
        if (nameText.text?.count == 0 || lastNameText.text?.count == 0) {
            Common.showAlert(with: NSLocalizedString("Alert!!", comment: ""), message: NSLocalizedString("Please fill required fields.",comment: ""), for: self)
            
        }
        else if (is_image_selected == false){
            Common.showAlert(with: NSLocalizedString("Alert!!", comment: ""), message: NSLocalizedString(LocalizationSystem.sharedInstance.localizedStringForKey(key: "SignUpVC_pickup_image", comment: ""),comment: ""), for: self)
            
        }
        else {
            handleSignUp()
        }
    }
    
    func requsetSignupForDB(photoURL:String){
        var socialStatusVar = ""
        if self.SocialStatus.text! == LocalizationSystem.sharedInstance.localizedStringForKey(key: "SignUpVC_SocialStatusRegular", comment: "")
        {
            socialStatusVar = "General"
        }
        else if self.SocialStatus.text! == LocalizationSystem.sharedInstance.localizedStringForKey(key: "SignUpVC_SocialStatusEmployess", comment: "")
        {
            socialStatusVar = "Employee"
        }
        else if self.SocialStatus.text! == LocalizationSystem.sharedInstance.localizedStringForKey(key: "SignUpVC_SocialStatusStudent", comment: "")
        {
            socialStatusVar = "Student"
        }
        if (nameText.text?.count == 0 || lastNameText.text?.count == 0) {
            Common.showAlert(with: NSLocalizedString("Alert!!", comment: ""), message: NSLocalizedString("Please fill required fields.",comment: ""), for: self)
            
        }
        else if (is_image_selected == false){
            Common.showAlert(with: NSLocalizedString("Alert!!", comment: ""), message: NSLocalizedString(LocalizationSystem.sharedInstance.localizedStringForKey(key: "SignUpVC_pickup_image", comment: ""),comment: ""), for: self)
            
        }
        else {
            let manager = LocationManager.sharedInstance
            manager.reverseGeocodeLocationWithLatLong(latitude: manager.latitude, longitude: manager.longitude) { (response, placemark, str) in
                if response != nil {
                    //                           print("test")
                    //                           print(response?["latitude"])
                    //                           print(response?["longitude"])
                    //                           print(response?["country"])
                    //                           print(response?["administrativeArea"])
                    //                           print(response?["locality"])
                    
                    var params = [String:Any]()
                    params["email"] = self.emailText.text!
                    params["name"]  = self.nameText.text! + " " + self.lastNameText.text!
                    params["mobile"] = self.UserData["mobile"]!//self.mobileNumText.text self.changeRequest?.photoURL
                    params["password"] = self.UserData["password"]!//self.passwordText.text
                    params["latitude"] = response?["latitude"]
                    params["longitude"] = response?["longitude"]
                    params["country"] = response?["country"]
                    params["state"] = response?["administrativeArea"]
                    params["city"] = response?["locality"]
                    params["avatar"] = photoURL
                    
                    params["gcm_token"] = self.UserData["gcm_token"]!//gcm_token
                    params["utype"] = "1" // utype = "0" means user and "1" = driver
                    params["mtype"] = "0" // mtype = "0" means iOS  and "1" = Android
                    params["socialStatus"] = socialStatusVar
                    HUD.show(to: self.view)
                    APIRequestManager.request(apiRequest: APIRouters.RegisterUser(params), success: { (responseData) in
                        HUD.hide(to: self.view)
                        print("ibrahim was here")
                        print(responseData)
                        if let data = responseData as? [String:Any] {
                            print(data["user_id"]!);
                            //
                            self.savePrivatePost(DriverId: data["user_id"]! as! String)
                        }
                        let alert = UIAlertController(title: NSLocalizedString("Success!!", comment: ""), message: NSLocalizedString("You are successfully registered", comment: ""), preferredStyle: .alert)
                        let done = UIAlertAction(title: NSLocalizedString("Done", comment: ""), style: .default, handler: { (action) in
                            self.loginByMobile(mobileNumber: self.UserData["mobile"]! as! String ,password: self.UserData["password"]! as! String)
                        })
                        alert.addAction(done)
                        self.present(alert, animated: true, completion: nil)
                    }, failure: { (message) in
                        HUD.hide(to: self.view)
                        Common.showAlert(with: NSLocalizedString("Alert!!", comment: ""), message: message, for: self)
                    }, error: { (err) in
                        HUD.hide(to: self.view)
                        Common.showAlert(with: NSLocalizedString("Error!!" ,comment: ""), message: err.localizedDescription, for: self)
                    })
                }
            }
        }
    }
    
    func handleSignUp() {
        HUD.show(to: self.view)
        print("h1")
        
        //        just for testing----------------
        //        Auth.auth().signIn(withEmail: "eng.ibrahim.meree@gmail.com", password: "1234!@#$") { user, error in
        //            if error == nil && user != nil {
        //                //                self.dismiss(animated: false, completion: nil)
        //                print("h2")
        //            } else {
        //                print("Error logging in: \(error!.localizedDescription)")
        //            }
        //        }
        //        just for testing----------------
        //            print("h3")
        guard let image = profileImageView.image else { return }
        self.uploadProfileImage(image) { url in
            print("dddddddd",url)
            if url != nil {
                // let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
                self.changeRequest?.displayName = self.nameText.text! + " " + self.lastNameText.text!
                self.changeRequest?.photoURL = url
                
                
                self.changeRequest?.commitChanges { error in
                    if error == nil {
                        print("User display name changed!")
                        print("h4")
                        HUD.hide(to: self.view)
                        self.saveProfile(username: self.nameText.text! + " " + self.lastNameText.text!, profileImageURL: url!) { success in
                            if success {
                                print("success")
                                print("h5")
                                //  self.requsetSignupForDB(photoURL: (self.changeRequest?.photoURL!.absoluteString)!)
                                //self.dismiss(animated: true, completion: nil)
                            } else {
                                print("error")
                            }
                        }
                    } else {
                        //                        print("Error: \(error!.localizedDescription)")
                        print("error")
                    }
                }
            } else {
                print("error")
            }
        }
    }
    
    func loginByMobile(mobileNumber:String ,password:String){
        var params = [String:Any]()
        params["mobile"] = mobileNumber
        params["password"] = password
        params["utype"] = "1"  // utype = "0" means user and "1" = driver
        
        APIRequestManager.request(apiRequest: APIRouters.LoginUser(params), success: { (responseData) in
            HUD.hide(to: self.view)
            print(responseData)
            if let data = responseData as? [String:Any] {
                let userData = User(userData: data)
                let encodedData = NSKeyedArchiver.archivedData(withRootObject: userData)
                UserDefaults.standard.set(encodedData, forKey: "user")
                UserDefaults.standard.set(data["key"], forKey: "key")
//                self.moveToDashboard()
                if userData.brand?.count == 0 {
                    self.setVehicleInfo()
                } else {
                    self.moveToDashboard()
                }
            }
        }, failure: { (message) in
            HUD.hide(to: self.view)
            Common.showAlert(with: NSLocalizedString("Alert!!", comment: ""), message: message, for: self)
            //self.moveToSignUpPage(mobileParam: mobileNumber , passwordParam: password)
        }, error: { (err) in
            HUD.hide(to: self.view)
            Common.showAlert(with: NSLocalizedString("Error!!", comment: ""), message: err.localizedDescription, for: self)
        })
    }
    
    func moveToDashboard(){
        let menu = self.storyboard?.instantiateViewController(withIdentifier: "MenuViewController") as! MenuViewController
        let dashboard = self.storyboard?.instantiateViewController(withIdentifier: "HomeViewController") as! HomeViewController
        let dashboardNav = UINavigationController(rootViewController: dashboard)
        let revealController = SWRevealViewController(rearViewController: menu, frontViewController: dashboardNav)
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.window?.rootViewController = revealController
    }
    
    func setVehicleInfo() {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "VehicleTableViewController") as! VehicleTableViewController
        vc.isFromLogin = true
        let nav = UINavigationController(rootViewController: vc)
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.window?.rootViewController = nav
    }
    
    func saveProfile(username:String, profileImageURL:URL, completion: @escaping ((_ success:Bool)->())) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let databaseRef = Database.database().reference().child("users/profile/\(uid)")
        
        let userObject = [
            "username": username,
            "photoURL": profileImageURL.absoluteString
            ] as [String:Any]
        
        databaseRef.setValue(userObject) { error, ref in
            if let error = error {
                print("Data could not be saved: \(error).")
            } else {
                print("Data saved successfully!",profileImageURL.absoluteString)
                self.requsetSignupForDB(photoURL: profileImageURL.absoluteString)
                
                
            }
        }
    }
    
    func savePrivatePost(DriverId:String) {
        
        print("Post button clicked")
        
        guard let userProfile = UserService.currentUserProfile else { return }
        // Firebase code here
        
        let postRef = Database.database().reference().child("private_posts").child(DriverId)
        
        let postObject = [
            "author": [
                "uid": userProfile.uid,
                "username": userProfile.username,
                "photoURL": userProfile.photoURL.absoluteString
            ],
            "text": "",
            "timestamp": [".sv":"timestamp"],
            "type": "0",
            "travel_id": 0,
            "privacy": "0"
            ] as [String:Any]
        
        postRef.setValue(postObject, withCompletionBlock: { error, ref in
            if error == nil {
            } else {
                // Handle the error
            }
        })
    }
    
    func uploadProfileImage(_ image:UIImage, completion: @escaping ((_ url:URL?)->())) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let storageRef = Storage.storage().reference().child("user/\(uid)")
        
        guard let imageData = image.jpegData(compressionQuality: 0.75) else { return }
        
        
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpg"
        
        storageRef.putData(imageData, metadata: metaData) { metaData, error in
            if error == nil, metaData != nil {
                
                storageRef.downloadURL { url, error in
                    completion(url)
                    self.urlImage = url!.absoluteString
                    print("adadadad",self.urlImage)
                }
            } else {
                // failed
                completion(nil)
            }
        }
    }
    
    func validateTextFields() -> Bool {
        if (nameText.text?.count == 0 || lastNameText.text?.count == 0) {
            Common.showAlert(with: NSLocalizedString("Alert!!", comment: ""), message: NSLocalizedString("Please fill required fields.",comment: ""), for: self)
            return false
        }
        else if (is_image_selected == false){
            Common.showAlert(with: NSLocalizedString("Alert!!", comment: ""), message: NSLocalizedString(LocalizationSystem.sharedInstance.localizedStringForKey(key: "SignUpVC_pickup_image", comment: ""),comment: ""), for: self)
            return false
        }
        else {
            return true
        }
    }
}
extension SignUpViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        is_image_selected = false;
        picker.dismiss(animated: true, completion: nil)
    }
    
    internal func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        self.profileImageView.image = pickedImage
        is_image_selected = true;
        picker.dismiss(animated: true, completion: nil)
    }
}
