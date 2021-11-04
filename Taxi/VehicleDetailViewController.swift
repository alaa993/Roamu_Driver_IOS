//
//  VehicleDetailViewController.swift
//  TaxiDriver
//
//  Created by Bhavin on 10/04/17.
//  Copyright © 2017 icanStudioz. All rights reserved.
//

import UIKit
import Firebase

class VehicleDetailViewController: UITableViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    
    // -- instance variables --
    let picker = UIImagePickerController()
    var selectedRow:Int = 0
    
    @IBOutlet var DrivingLicencelbl: UILabel!
    @IBOutlet var personalIdlbl: UILabel!
    @IBOutlet var VehicleReglbl: UILabel!
    var avatar: UIImage!
    var imgName = ""
    
    //------------------------------------------------------------------------------------------------------------------------------------------
    // MARK:- View Controller Life Cycle
    //------------------------------------------------------------------------------------------------------------------------------------------
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = LocalizationSystem.sharedInstance.localizedStringForKey(key: "VehicleDetailVC_Titel", comment: "")
        DrivingLicencelbl.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "VehicleDetailVC_DrivingLicence", comment: "")
        personalIdlbl.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "VehicleDetailVC_personalId", comment: "")
        VehicleReglbl.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "VehicleDetailVC_VehicleReg", comment: "")
        
        // -- setup back button --
        let backButton = UIBarButtonItem(image: UIImage(named: "arrow-left"),
                                         style: .plain, target: self,
                                         action: #selector(VehicleDetailViewController.backWasPressed))
        self.navigationItem.leftBarButtonItem = backButton
        
        picker.delegate = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //------------------------------------------------------------------------------------------------------------------------------------------
    // MARK: - Table view data source
    //------------------------------------------------------------------------------------------------------------------------------------------
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3//4
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        // Configure the cell...
        
        if let user = UserDefaults.standard.data(forKey: "user"){
            let userData = NSKeyedUnarchiver.unarchiveObject(with: user) as? User
            
            if indexPath.row == 0 && (userData?.license?.count)! > 0 {
                cell.accessoryType = .checkmark
            } else if indexPath.row == 1 && (userData?.permit?.count)! > 0 {
                cell.accessoryType = .checkmark
            } else if indexPath.row == 2 && (userData?.vehicle_info?.count)! > 0 {
                cell.accessoryType = .checkmark
            }
                
                //                else if indexPath.row == 3 && (userData?.registration?.count)! > 0 {
                //                    cell.accessoryType = .checkmark
                //                }
                
            else {
                cell.accessoryType = .none
            }
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedRow = indexPath.row
        openPickerController()
    }
    
    //--------------------------------------------------------------------------------------------------------------------------------------
    // MARK:- UIImagePickerControllerDelegate
    //--------------------------------------------------------------------------------------------------------------------------------------
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let img = info[UIImagePickerController.InfoKey.originalImage.rawValue] as! UIImage
        avatar = img.resizeImage(newWidth: 400)
        
        
        if selectedRow == 0 {
            imgName = "license"
        } else if selectedRow == 1 {
            imgName = "permit"
        } else if selectedRow == 2 {
            imgName = "vehicle_info"
        }
        //        else if selectedRow == 3 {
        //            imgName = "registration"
        //        }
        
        updateVehicleInfo(with: img.resizeImage(newWidth: 400), and: imgName)
//        handleUpdate()
        
        dismiss(animated: true, completion: nil)
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
        //guard let image = avatar else { return }
        self.uploadProfileImage(avatar) { url in
            //            print("dddddddd",url)
            if url != nil {
                let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
                
                changeRequest?.photoURL = url
                
                
                changeRequest?.commitChanges { error in
                    if error == nil {
                        print("User display name changed!")
                        print("h4")
                        HUD.hide(to: self.view)
                        //                        self.saveProfile(profileImageURL: url!) { success in
                        //                            if success {
                        //                                print("success")
                        //                                print("h5")
                        //                                //  self.requsetSignupForDB(photoURL: (self.changeRequest?.photoURL!.absoluteString)!)
                        //                                //self.dismiss(animated: true, completion: nil)
                        //                            } else {
                        //                                print("error")
                        //                            }
                        //                        }
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
    
    func saveProfile(profileImageURL:URL, completion: @escaping ((_ success:Bool)->())) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let databaseRef = Database.database().reference().child("users/profile/\(uid)")
        
        let userObject = [
            "photoURL": profileImageURL.absoluteString
            ] as [String:Any]
        
        databaseRef.setValue(userObject) { error, ref in
            if let error = error {
                print("Data could not be saved: \(error).")
            } else {
                print("Data saved successfully!",profileImageURL.absoluteString)
                //self.requsetSignupForDB(photoURL: profileImageURL.absoluteString)
                self.updateProfileData1(photoUrl: profileImageURL.absoluteString)
                
                
                
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
    
    func updateProfileData1(photoUrl:String){
        var params = [String:String]()
        params["user_id"] = Common.instance.getUserId()
        params[imgName] = photoUrl
        
        let headers = ["X-API-KEY":Common.instance.getAPIKey()]
        
        HUD.show(to: view)
        APIRequestManager.request(apiRequest: APIRouters.UpdateUser(params,headers), success: { (responseData) in
            HUD.hide(to: self.view)
            if let data = responseData as? [String:String] {
                // -- set updated data --
                // -- change User data --
                if let user = UserDefaults.standard.data(forKey: "user"){
                    let userData = NSKeyedUnarchiver.unarchiveObject(with: user) as? User
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
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    //------------------------------------------------------------------------------------------------------------------------------------------
    // MARK:- API Requests
    //------------------------------------------------------------------------------------------------------------------------------------------
    func updateVehicleInfo(with image:UIImage, and imageName:String){
        let params  = ["user_id" : Common.instance.getUserId()]
        let headers = ["X-API-KEY":Common.instance.getAPIKey()]
        
        HUD.show(to: self.view)
        APIRequestManager.upload(with: configs.hostUrl + configs.updateUser,
                                 parameters: params,
                                 headers: headers,
                                 image: image,
                                 imgName: imageName,
                                 success: { (response) in
                                    HUD.hide(to: self.view)
                                    if let result = response as? [String:Any], let status = result["status"] as? String {
                                        if status == "success"{
                                            if let data = result["data"] as? [String:String] {
                                                if let user = UserDefaults.standard.data(forKey: "user"){
                                                    let userData = NSKeyedUnarchiver.unarchiveObject(with: user) as? User
                                                    
                                                    if self.selectedRow == 0 {
                                                        userData?.license = data["license"]
                                                    } else if self.selectedRow == 1 {
                                                        userData?.permit = data["permit"]
                                                    } else if self.selectedRow == 2 {
                                                        userData?.vehicle_info = data["vehicle_info"]
                                                    }
                                                    //                                                    else if self.selectedRow == 3 {
                                                    //                                                        userData?.registration = data["registration"]
                                                    //                                                    }
                                                    
                                                    let encodedData = NSKeyedArchiver.archivedData(withRootObject: userData!)
                                                    UserDefaults.standard.set(encodedData, forKey: "user")
                                                    DispatchQueue.main.async {
                                                        self.tableView.reloadData()
                                                    }
                                                }
                                            }
                                        } else if status ==  "fail" {
                                            if let message = result["data"] as? String {
                                                Common.showAlert(with: "", message: message, for: self)
                                            }
                                        }
                                    }
        }) { (error) in
            HUD.hide(to: self.view)
            print(error.localizedDescription)
        }
    }
    
    //------------------------------------------------------------------------------------------------------------------------------------------
    // MARK:- other methods
    //------------------------------------------------------------------------------------------------------------------------------------------
    func openPickerController(){
        picker.allowsEditing = false
        picker.sourceType = .photoLibrary
        self.present(picker, animated: true, completion: nil)
    }
    
    @objc func backWasPressed(){
        _ = self.navigationController?.popViewController(animated: true)
    }
    
}
