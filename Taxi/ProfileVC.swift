//
//  ProfileVC.swift
//  Taxi
//
//  Created by Bhavin on 06/04/17.
//  Copyright © 2017 icanStudioz. All rights reserved.
//

import UIKit
import Kingfisher
import Firebase

class ProfileVC: UITableViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate,ProfileDataDelegate {
    @IBOutlet var avatar: UIImageView!
    @IBOutlet var email: UILabel!
    @IBOutlet var name: UILabel!
    @IBOutlet var mobile: UILabel!
    @IBOutlet var paypal: UILabel!
    
    @IBOutlet var emailLabel: UILabel!
    @IBOutlet var NameLabel: UILabel!
    //@IBOutlet var password: UILabel!
    @IBOutlet var MobileLabel: UILabel!
    
    
    
    // -- instance variables --
    let picker = UIImagePickerController()
    
    //---------------------------------------------------------------------------------
    // MARK:- View Controller Life Cycle
    //---------------------------------------------------------------------------------
    override func viewDidLoad() {
        super.viewDidLoad()
        emailLabel.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "SignUpVC_emailText", comment: "")
        NameLabel.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "SignUpVC_nameText", comment: "")
        MobileLabel.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "ProcileVC_mobile", comment: "")
        //password.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "ProcileVC_Password", comment: "")
        //Profile
        self.title = NSLocalizedString(LocalizationSystem.sharedInstance.localizedStringForKey(key: "ProcileVCTitle", comment: ""), comment: "")
        getProfile()
        setupUI()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //---------------------------------------------------------------------------------
    // MARK: - Table view data source
    //---------------------------------------------------------------------------------
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 4
        default:
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        // Configure the cell...
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "ProfileDetailViewController") as! ProfileDetailViewController
            
            if indexPath.row == 0 {
                vc.data = ["from":"email","text":email.text!]
            }
            else if indexPath.row == 1 {
                vc.data = ["from":"name","text":name.text!]
            }
            else if indexPath.row == 2 {
                vc.data = ["from":"mobile","text":mobile.text!]
            }
            else if indexPath.row == 3 {
                vc.data = ["from":"paypal","text":paypal.text!]
            }
            
            vc.delegate = self
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    //---------------------------------------------------------------------------------
    // MARK:- ProfileDataDelegate
    //---------------------------------------------------------------------------------
    func profileDataChanged(data: [String : String]) {
        if data["from"] == "email" {
            if email.text == data["text"] { return }
            else if data["text"]?.count == 0 { return }
            else {
                updateProfileData(email: data["text"]!, name: name.text!, mobile: mobile.text!, paypalId: paypal.text!)
            }
        } else if data["from"] == "name" {
            if name.text == data["text"] { return }
            else if data["text"]?.count == 0 { return }
            else {
                updateProfileData(email: email.text! ,name: data["text"]!, mobile: mobile.text!, paypalId: paypal.text!)
            }
        } else if data["from"] == "mobile" {
            if mobile.text == data["text"] { return }
            else {
                updateProfileData(email: email.text!, name: name.text!, mobile: data["text"]!, paypalId: paypal.text!)
            }
        } else {
            if paypal.text == data["text"] { return }
            else {
                updateProfileData(email:email.text!, name: name.text!, mobile: mobile.text!, paypalId: data["text"]!)
            }
        }
    }
    
    //---------------------------------------------------------------------------------
    // MARK:- UIImagePickerControllerDelegate
    //---------------------------------------------------------------------------------
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let img = info[UIImagePickerController.InfoKey.originalImage.rawValue] as! UIImage
        avatar.image = img.resizeImage(newWidth: 200)
        HUD.show(to: self.view)
        handleUpdate()
        
        /*
         let params  = ["user_id" : Common.instance.getUserId()]
         let headers = ["X-API-KEY" : Common.instance.getAPIKey()]
         print("ibrahim1")
         HUD.show(to: self.view)
         APIRequestManager.upload(with: configs.hostUrl + configs.updateUser,
         parameters: params,
         headers: headers,
         image: self.avatar.image!,
         imgName: "avatar",
         success: { (response) in
         HUD.hide(to: self.view)
         print("ibrahim2")
         if let result = response as? [String:Any], let status = result["status"] as? String {
         if status == "success"{
         print("ibrahim3")
         if let data = result["data"] as? [String:String] {
         print("ibrahim4")
         if let user = UserDefaults.standard.data(forKey: "user"){
         print("ibrahim5")
         let userData = NSKeyedUnarchiver.unarchiveObject(with: user) as? User
         userData?.avatar = data["avatar"]
         let encodedData = NSKeyedArchiver.archivedData(withRootObject: userData!)
         UserDefaults.standard.set(encodedData, forKey: "user")
         }
         }
         } else if status == "fail" {
         print("ibrahim6")
         if let message = result["data"] as? String {
         Common.showAlert(with: "", message: message, for: self)
         }
         }
         }
         }) { (error) in
         HUD.hide(to: self.view)
         print("ibrahim7")
         //            print(error.localizedDescription)
         }
         */
        HUD.hide(to: self.view)
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    //----------------------------------------------------------------------------------
    // MARK:- API Requests
    //----------------------------------------------------------------------------------
    func updateProfileData(email:String, name:String, mobile:String, paypalId:String){
        var params = [String:String]()
        params["user_id"] = Common.instance.getUserId()
        params["email"] = email
        params["name"] = name
        params["mobile"] = mobile
        
        let headers = ["X-API-KEY":Common.instance.getAPIKey()]
        
        HUD.show(to: view)
        APIRequestManager.request(apiRequest: APIRouters.UpdateUser(params,headers), success: { (responseData) in
            HUD.hide(to: self.view)
            if let data = responseData as? [String:String] {
                // -- set updated data --
                self.name.text = data["name"]
                self.mobile.text = data["mobile"]
                self.email.text = data["email"]
                
                // -- change User data --
                if let user = UserDefaults.standard.data(forKey: "user"){
                    let userData = NSKeyedUnarchiver.unarchiveObject(with: user) as? User
                    userData?.mobile = data["mobile"]
                    userData?.name = data["name"]
                    self.email.text = data["email"]
                    let encodedData = NSKeyedArchiver.archivedData(withRootObject: userData!)
                    UserDefaults.standard.set(encodedData, forKey: "user")
                }
            }
        }, failure: { (message) in
            HUD.hide(to: self.view)
            Common.showAlert(with: NSLocalizedString("Alert!!", comment: ""), message: message, for: self)
        }, error: { (err) in
            HUD.hide(to: self.view)
            Common.showAlert(with: NSLocalizedString("Error!!" ,comment: ""), message: err.localizedDescription, for: self)
        })
    }
    
    func getProfile(){
        var params = [String:String]()
        params["user_id"] = Common.instance.getUserId()
        
        let headers = ["X-API-KEY":Common.instance.getAPIKey()]
        
        HUD.show(to: view)
        APIRequestManager.request(apiRequest: APIRouters.GetProfile(params,headers), success: { (responseData) in
            HUD.hide(to: self.view)
            if let data = responseData as? [String:String] {
                let userData = User(userData: data)
                let encodedData = NSKeyedArchiver.archivedData(withRootObject: userData)
                UserDefaults.standard.set(encodedData, forKey: "user")
                self.fillData()
            }
        }, failure: { (message) in
            HUD.hide(to: self.view)
            Common.showAlert(with: NSLocalizedString("Alert!!", comment: ""), message: message, for: self)
        }, error: { (err) in
            HUD.hide(to: self.view)
            Common.showAlert(with: NSLocalizedString("Error!!" ,comment: ""), message: err.localizedDescription, for: self)
        })
    }
    
    //----------------------------------------------------------------------------------
    // MARK:- other methods
    //----------------------------------------------------------------------------------
    func setupUI(){
        // -- setup revealview --
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
        
        fillData()
        
        // -- make circle imageview --
        avatar.corner(radius: avatar.frame.width / 2, color: .black, width: 0.0)
        
        // -- add gesture to button --
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(openPickerController))
        avatar.addGestureRecognizer(tapGesture)
        avatar.isUserInteractionEnabled = true
        
        picker.delegate = self
    }
    
    func fillData(){
        // -- set email --
        email.text = Common.instance.getEmail()
        
        // -- set other info --
        if let data = UserDefaults.standard.data(forKey: "user"){
            let userData = NSKeyedUnarchiver.unarchiveObject(with: data) as? User
            name.text = userData?.name
            mobile.text = userData?.mobile
            email.text = userData?.email
            
            getImgProfile()
        }
        
    }
    
    func getImgProfile() {
        
        Database
            .database()
            .reference()
            .child("users")
            .child("profile")
            .child(Auth.auth().currentUser!.uid)
            .queryOrderedByKey()
            .observeSingleEvent(of: .value, with: { snapshot in
                
                guard let dict = snapshot.value as? [String:Any] else {
                    print("Error")
                    return
                }
                
                let photoURL = (dict["photoURL"] as? String)!
                if let urlString = URL(string: ( photoURL)){
                    
                    self.avatar.kf.setImage(with: urlString)
                }
                print("tttttttt",photoURL)
                // let priceAd = dict["priceAd"] as? String
            })
    }
    
    func handleUpdate() {
        HUD.show(to: self.view)
        print("h1")
        
        //        just for testing----------------
        //       Auth.auth().signIn(withEmail: "eng.ibrahim.meree@gmail.com", password: "1234!@#$") { user, error in
        //            if error == nil && user != nil {
        //                //                self.dismiss(animated: false, completion: nil)
        //                print("h2")
        //            } else {
        //                print("Error logging in: \(error!.localizedDescription)")
        //            }
        //        }
        //        just for testing----------------
        print("h3")
        guard let image = avatar.image else { return }
        self.uploadProfileImage(image) { url in
            print("dddddddd",url)
            if url != nil {
                let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
                changeRequest?.displayName = self.name.text!
                changeRequest?.photoURL = url
                
                
                changeRequest?.commitChanges { error in
                    if error == nil {
                        print("User display name changed!")
                        print("h4")
                        HUD.hide(to: self.view)
                        self.saveProfile(username: self.name.text!, profileImageURL: url!) { success in
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
                //self.requsetSignupForDB(photoURL: profileImageURL.absoluteString)
                self.updateProfileData1(email: self.email.text!, name: self.name.text!, mobile: self.mobile.text!, paypalId: self.paypal.text!,photoUrl: profileImageURL.absoluteString)
                
                
                
            }
        }
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
                    let urlImage = url!.absoluteString
                    print("adadadad",urlImage)
                }
            } else {
                // failed
                completion(nil)
            }
        }
    }
    
    func updateProfileData1(email:String, name:String, mobile:String, paypalId:String,photoUrl:String){
        var params = [String:String]()
        params["user_id"] = Common.instance.getUserId()
        params["email"] = email
        params["name"] = name
        params["mobile"] = mobile
        params["avater"] = photoUrl
        
        let headers = ["X-API-KEY":Common.instance.getAPIKey()]
        
        HUD.show(to: view)
        APIRequestManager.request(apiRequest: APIRouters.UpdateUser(params,headers), success: { (responseData) in
            HUD.hide(to: self.view)
            if let data = responseData as? [String:String] {
                // -- set updated data --
                self.name.text = data["name"]
                self.mobile.text = data["mobile"]
                self.email.text = data["email"]
                
                // -- change User data --
                if let user = UserDefaults.standard.data(forKey: "user"){
                    let userData = NSKeyedUnarchiver.unarchiveObject(with: user) as? User
                    userData?.mobile = data["mobile"]
                    userData?.name = data["name"]
                    self.email.text = data["email"]
                    let encodedData = NSKeyedArchiver.archivedData(withRootObject: userData!)
                    UserDefaults.standard.set(encodedData, forKey: "user")
                }
            }
        }, failure: { (message) in
            HUD.hide(to: self.view)
            Common.showAlert(with: NSLocalizedString("Alert!!", comment: ""), message: message, for: self)
        }, error: { (err) in
            HUD.hide(to: self.view)
            //Common.showAlert(with: NSLocalizedString("Error!!" ,comment: ""), message: err.localizedDescription, for: self)
        })
    }
    
    @objc func openPickerController(){
        picker.allowsEditing = false
        picker.sourceType = .photoLibrary
        self.present(picker, animated: true, completion: nil)
    }
}
