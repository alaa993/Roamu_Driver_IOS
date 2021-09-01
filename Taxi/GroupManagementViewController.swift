//
//  GroupManagementViewController.swift
//  TaxiDriver
//
//  Created by Syria.Apple on 5/10/20.
//  Copyright © 2020 icanStudioz. All rights reserved.
//

import UIKit
import Alamofire
import Firebase

class GroupManagementViewController: UIViewController {
    
    @IBOutlet var groupName: UILabel!
    
    @IBOutlet var AdminAvatar: UIImageView!
    
    @IBOutlet var tableView: UITableView!
    
    //    @IBOutlet var TextFieldDriverNumber: UITextField!
    //    @IBOutlet var TextFieldGroupName: UITextField!
    
    @IBOutlet var AddGroupButton: UIButton!
    @IBOutlet var AddDriverToGroupButton: UIButton!
    @IBOutlet var DeleteDriverFromGroupButton: UIButton!
    @IBOutlet var ChangeGroupNameButton: UIButton!
    @IBOutlet var MyGroupsButton: UIButton!
    
    var TextFieldGroup: UITextField!
    var group_bool: Bool!
    var group_indecator_number: Int!
    
    var groups = [Group]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = LocalizationSystem.sharedInstance.localizedStringForKey(key: "GroupManagementVC_Title", comment: "")
        
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
        //        self.TextFieldDriverNumber.cornerRadius(radius: 20.0, andPlaceholderString: NSLocalizedString("+",comment: ""))
        //        self.TextFieldDriverNumber.paddedTextField(frame: CGRect(x: 0, y: 0, width: 25, height: self.TextFieldDriverNumber.frame.height))
        self.AddDriverToGroupButton.setTitle(LocalizationSystem.sharedInstance.localizedStringForKey(key: "GroupManagementVC_AddDriver", comment: ""), for: .normal)
        self.DeleteDriverFromGroupButton.setTitle(LocalizationSystem.sharedInstance.localizedStringForKey(key: "GroupManagementVC_DeleteDriver", comment: ""), for: .normal)
        self.ChangeGroupNameButton.setTitle(LocalizationSystem.sharedInstance.localizedStringForKey(key: "GroupManagementVC_ChangeGroupName", comment: ""), for: .normal)
        self.MyGroupsButton.setTitle(LocalizationSystem.sharedInstance.localizedStringForKey(key: "GroupManagementVC_MyGroups", comment: ""), for: .normal)
        self.AddDriverToGroupButton.corner(radius: 20.0, color: UIColor.white, width: 1.0)
        self.DeleteDriverFromGroupButton.corner(radius: 20.0, color: UIColor.white, width: 1.0)
        self.ChangeGroupNameButton.corner(radius: 20.0, color: UIColor.white, width: 1.0)
        self.MyGroupsButton.corner(radius: 20.0, color: UIColor.white, width: 1.0)
        
        //        self.TextFieldGroupName.cornerRadius(radius: 20.0, andPlaceholderString: NSLocalizedString(LocalizationSystem.sharedInstance.localizedStringForKey(key: "GroupManagementVC_GroupName", comment: ""),comment: ""))
        //        self.TextFieldGroupName.paddedTextField(frame: CGRect(x: 0, y: 0, width: 25, height: self.TextFieldGroupName.frame.height))
        self.AddGroupButton.setTitle(LocalizationSystem.sharedInstance.localizedStringForKey(key: "GroupManagementVC_AddGroup", comment: ""), for: .normal)
        self.AddGroupButton.corner(radius: 20.0, color: UIColor.white, width: 1.0)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.loadAdminGroupInfo()
        //        self.loadGroupList()
        loadMyGroupList()
        getImgProfileAdmin()
    }
    
    func loadGroupList(){
        let params = ["admin_id":Common.instance.getUserId()]
        let headers = ["X-API-KEY":Common.instance.getAPIKey()]
        
        //HUD.show(to: view)
        _ = Alamofire.request(APIRouters.getGroupList(params,headers)).responseObject { (response: DataResponse<Groups>) in
            //HUD.hide(to: self.view)
            if response.result.isSuccess{
                if response.result.value?.status == true , ((response.result.value?.groups) != nil) {
                    self.groups = (response.result.value?.groups)!
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                } else {
                    Common.showAlert(with: NSLocalizedString("Alert!!", comment: ""), message: "No data found.", for: self)
                }
            }
            
            if response.result.isFailure{
                Common.showAlert(with: NSLocalizedString("Error!!", comment: ""), message: response.error?.localizedDescription, for: self)
            }
        }
    }
    func getImgProfileAdmin() {
        
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
        if let urlString = URL(string: (photoURL)){
                                 
            self.AdminAvatar.kf.setImage(with: urlString)
                             }
        print("tttttttt",photoURL)
         // let priceAd = dict["priceAd"] as? String
      })
    }
    func loadMyGroupList(){
        let params = ["user_id":Common.instance.getUserId()]
        let headers = ["X-API-KEY":Common.instance.getAPIKey()]
        print("ibrahim123")
        print(Common.instance.getUserId())
        //HUD.show(to: view)
        _ = Alamofire.request(APIRouters.getMyGroupList(params,headers)).responseObject { (response: DataResponse<Groups>) in
            //HUD.hide(to: self.view)
            print("ibrahim")
            print(response)
            if response.result.isSuccess{
                if response.result.value?.status == true , ((response.result.value?.groups) != nil) {
                    print(response.result.value)
                    self.groups = (response.result.value?.groups)!
                    if self.groups.count > 0 {
                        self.groupName.text = self.groups[0].group_name
                        
                        //if let urlString = URL(string: (self.groups[0].admin_avatar)){
                            //print(self.groups[0].admin_avatar)
                          //  self.AdminAvatar.kf.setImage(with: urlString)
                        //}
                        
                    }
                } else {
                    Common.showAlert(with: NSLocalizedString("Alert!!", comment: ""), message: "No data found.", for: self)
                }
            }
            
            if response.result.isFailure{
                Common.showAlert(with: NSLocalizedString("Error!!", comment: ""), message: response.error?.localizedDescription, for: self)
            }
        }
    }
    
    func loadAdminGroupInfo(){
        let params = ["admin_id":Common.instance.getUserId()]
        let headers = ["X-API-KEY":Common.instance.getAPIKey()]
        HUD.show(to: view)
        _ = Alamofire.request(APIRouters.getAdminGroupInfo(params,headers)).responseObject { (response: DataResponse<Groups>) in
            HUD.hide(to: self.view)
            
            if response.result.value?.status == true{
                //                self.TextFieldGroupName.isHidden = true
                self.AddGroupButton.isHidden = true
                
                self.AddDriverToGroupButton.isHidden = false
                self.DeleteDriverFromGroupButton.isHidden = false
                self.ChangeGroupNameButton.isHidden = false
                self.MyGroupsButton.isHidden = false
                self.AdminAvatar.isHidden = false
                self.groupName.isHidden = false
                
                print("successfully")
                print(response)
            }
            if response.result.value?.status == false{
                //                self.TextFieldDriverNumber.isHidden = false
                self.AddGroupButton.isHidden = false
                self.AddDriverToGroupButton.isHidden = true
                self.DeleteDriverFromGroupButton.isHidden = true
                self.ChangeGroupNameButton.isHidden = true
                self.MyGroupsButton.isHidden = true
                self.AdminAvatar.isHidden = true
                self.groupName.isHidden = true
                print(response)
            }
        }
    }
    
    @IBAction func AddGroupButtonClicked(_ sender: Any) {
        group_bool = true
        group_indecator_number = 1
        openAlert()
        //        if openAlert() {
        //            AddGroupFunc()
        //        }
    }
    
    @IBAction func ChangeGroupNameButtonClicked(_ sender: Any) {
        group_bool = true
        group_indecator_number = 2
        openAlert()
        //        if openAlert() {
        //            changeGroupNameFunc()
        //        }
    }
    
    @IBAction func AddDriverToGroupButtonClicked(_ sender: Any) {
        group_bool = false
        group_indecator_number = 3
        openAlert()
        //        if openAlert(){
        //            AddDriverToGroupFunc()
        //        }
    }
    
    @IBAction func DeleteDriverFromGroupButtonClicked(_ sender: Any) {
        false
        group_indecator_number = 4
        openAlert()
        //        if openAlert() {
        //            DeleteDriverFromGroupFunc()
        //        }
    }
    
    @IBAction func MyGroupsButtonClicked(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "MyGroupsViewController") as! MyGroupsViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func AddGroupFunc() {
        let refreshAlert = UIAlertController(title: "Add Group", message: "Please Confirm!", preferredStyle: UIAlertController.Style.alert)
        refreshAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
            
        }))
        refreshAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
            var parameters = [String:Any]()
            parameters["admin_id"] = Common.instance.getUserId()
            parameters["group_name"] = self.TextFieldGroup.text//self.TextFieldGroupName.text
            let headers = ["X-API-KEY":Common.instance.getAPIKey()]
            // -- show loading --
            HUD.show(to: self.view)
            // -- send request --
            APIRequestManager.request(apiRequest: APIRouters.addGroup(parameters, headers), success: { (response) in
                HUD.hide(to: self.view)
                print("response from addgroup func")
                print(response)
                self.loadAdminGroupInfo()
                self.loadMyGroupList()
                if response is [String : Any] {
                    let alert = UIAlertController(title: NSLocalizedString("Success!!",comment: ""), message: "", preferredStyle: .alert)
                    let done = UIAlertAction(title: NSLocalizedString("Done", comment: ""), style: .default, handler: { (action) in
                        _ = self.navigationController?.popViewController(animated: true)
                        //                        self.TextFieldGroupName.isHidden = true
                        self.AddGroupButton.isHidden = true
                        self.loadAdminGroupInfo()
                    })
                    alert.addAction(done)
                    self.present(alert, animated: true, completion: nil)
                }
            }, failure: { (message) in
                HUD.hide(to: self.view)
                Common.showAlert(with: NSLocalizedString("Alert!!", comment: ""), message: message, for: self)
            }, error: { (err) in
                HUD.hide(to: self.view)
                Common.showAlert(with: NSLocalizedString("Error!!", comment: ""), message: err.localizedDescription, for: self)
            })
        }))
        present(refreshAlert, animated: true, completion: nil)
    }
    
    func changeGroupNameFunc(){
        print("ChangeGroupNameButtonClicked")
        var parameters = [String:String]()
        parameters["admin_id"] = Common.instance.getUserId()
        parameters["group_name"] = self.TextFieldGroup.text//self.TextFieldGroupName.text
        let headers = ["X-API-KEY":Common.instance.getAPIKey()]
        // -- show loading --
        HUD.show(to: self.view)
        // -- send request --
        APIRequestManager.request(apiRequest: APIRouters.ChangeGruopName(parameters, headers), success: { (response) in
            HUD.hide(to: self.view)
            print("response")
            print(response)
            self.loadMyGroupList()
            if response is [String : String] {
                let alert = UIAlertController(title: NSLocalizedString("Success!!",comment: ""), message: "", preferredStyle: .alert)
                let done = UIAlertAction(title: NSLocalizedString("Done", comment: ""), style: .default, handler: { (action) in
                    _ = self.navigationController?.popViewController(animated: true)
                    //                        self.TextFieldGroupName.isHidden = true
                    self.AddGroupButton.isHidden = true
                })
                alert.addAction(done)
                self.present(alert, animated: true, completion: nil)
            }
        }, failure: { (message) in
            HUD.hide(to: self.view)
            Common.showAlert(with: NSLocalizedString("Alert!!", comment: ""), message: message, for: self)
        }, error: { (err) in
            HUD.hide(to: self.view)
            Common.showAlert(with: NSLocalizedString("Error!!", comment: ""), message: err.localizedDescription, for: self)
        })
    }
    
    func AddDriverToGroupFunc() {
        let refreshAlert = UIAlertController(title: "Add Driver", message: "Please Confirm!", preferredStyle: UIAlertController.Style.alert)
        
        refreshAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
            var parameters = [String:Any]()
            parameters["admin_id"] = Common.instance.getUserId()
            parameters["mobile"] = self.TextFieldGroup.text//self.TextFieldDriverNumber.text
            let headers = ["X-API-KEY":Common.instance.getAPIKey()]
            // -- show loading --
            HUD.show(to: self.view)
            // -- send request --
            APIRequestManager.request(apiRequest: APIRouters.addUserToGroup(parameters, headers), success: { (response) in
                HUD.hide(to: self.view)
                if response is [String : Any] {
                    let alert = UIAlertController(title: NSLocalizedString("success",comment: ""), message: "Driver Added Successfully!"
                        , preferredStyle: .alert)
                    let done = UIAlertAction(title: NSLocalizedString("Done", comment: ""), style: .default, handler: { (action) in
                        _ = self.navigationController?.popViewController(animated: true)
                    })
                    alert.addAction(done)
                    self.present(alert, animated: true, completion: nil)
                }
            }, failure: { (message) in
                HUD.hide(to: self.view)
                Common.showAlert(with: NSLocalizedString("Alert!!", comment: ""), message: message, for: self)
            }, error: { (err) in
                HUD.hide(to: self.view)
                Common.showAlert(with: NSLocalizedString("Error!!", comment: ""), message: err.localizedDescription, for: self)
            })
            
        }))
        
        refreshAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
        }))
        
        present(refreshAlert, animated: true, completion: nil)
    }
    
    func DeleteDriverFromGroupFunc() {
        let refreshAlert = UIAlertController(title: "Delete Driver", message: "Please Confirm!", preferredStyle: UIAlertController.Style.alert)
        
        refreshAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
            var parameters = [String:Any]()
            parameters["mobile"] = self.TextFieldGroup.text//self.TextFieldDriverNumber.text
            let headers = ["X-API-KEY":Common.instance.getAPIKey()]
            // -- show loading --
            HUD.show(to: self.view)
            // -- send request --
            APIRequestManager.request(apiRequest: APIRouters.delUserFromGroup(parameters, headers), success: { (response) in
                HUD.hide(to: self.view)
                if response is [String : Any] {
                    let alert = UIAlertController(title: NSLocalizedString("success",comment: "Driver Deleted Successfully"), message: "", preferredStyle: .alert)
                    let done = UIAlertAction(title: NSLocalizedString("Done", comment: ""), style: .default, handler: { (action) in
                        _ = self.navigationController?.popViewController(animated: true)
                    })
                    alert.addAction(done)
                    self.present(alert, animated: true, completion: nil)
                }
            }, failure: { (message) in
                HUD.hide(to: self.view)
                Common.showAlert(with: NSLocalizedString("Alert!!", comment: ""), message: message, for: self)
            }, error: { (err) in
                HUD.hide(to: self.view)
                Common.showAlert(with: NSLocalizedString("Error!!", comment: ""), message: err.localizedDescription, for: self)
            })
        }))
        
        refreshAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
        }))
        
        present(refreshAlert, animated: true, completion: nil)
    }
    
    func openAlert() -> Bool {
        var alertController:UIAlertController?
        alertController = UIAlertController(title:
            NSLocalizedString(LocalizationSystem.sharedInstance.localizedStringForKey(key: "", comment: ""),comment: ""),message: NSLocalizedString(LocalizationSystem.sharedInstance.localizedStringForKey(key: "", comment: ""),comment: ""),preferredStyle: .alert)
        
        // pickup point
        alertController!.addTextField(
            configurationHandler: {(textField: UITextField!) in
                self.TextFieldGroup = textField
                
                if self.group_bool == true{
                    textField.placeholder = NSLocalizedString(LocalizationSystem.sharedInstance.localizedStringForKey(key: "GroupManagementVC_GroupName", comment: ""),comment: "")
                    textField.keyboardType = UIKeyboardType.default
                }
                else{
                    textField.placeholder = NSLocalizedString(LocalizationSystem.sharedInstance.localizedStringForKey(key: "hint: +9641231231231", comment: ""),comment: "")
                    textField.keyboardType = .phonePad
                }
                
                //                    textField.placeholder = NSLocalizedString(LocalizationSystem.sharedInstance.localizedStringForKey(key: "PickUpPoint", comment: ""),comment: "")
        })
        
        let action = UIAlertAction(title: NSLocalizedString(LocalizationSystem.sharedInstance.localizedStringForKey(key: "Submit", comment: ""),comment: ""),
                                   style: UIAlertAction.Style.default,
                                   handler: {[weak self]
                                    (paramAction:UIAlertAction!) in
                                    if let textFields = alertController?.textFields{
                                        let theTextFields = textFields as [UITextField]
                                        if theTextFields[0].text!.count == 0{
                                            Common.showAlert(with: NSLocalizedString("Alert!!", comment: ""), message: NSLocalizedString("Please fill all the fields.", comment: ""), for: self!)
                                            return
                                        }
                                        else{
                                            if self!.group_indecator_number == 1
                                            {
                                                self!.AddGroupFunc()
                                            }else if self!.group_indecator_number == 2
                                            {
                                                self!.changeGroupNameFunc()
                                            }else if self!.group_indecator_number == 3
                                            {
                                                if self!.validatePhoneNumber(value: theTextFields[0].text!){
                                                    print("Validate validatePhoneNumber")
                                                    self!.AddDriverToGroupFunc()
                                                }else{
                                                    Common.showAlert(with: NSLocalizedString("Alert!!", comment: ""), message: NSLocalizedString("invalid_phone_number", comment: ""), for: self!)
                                                    print("invalide validatePhoneNumber")
                                                    return
                                                    
                                                }
                                            }else if self!.group_indecator_number == 4
                                            {
                                                if self!.validatePhoneNumber(value: theTextFields[0].text!){
                                                    print("Validate validatePhoneNumber")
                                                    self!.DeleteDriverFromGroupFunc()
                                                }else{
                                                    Common.showAlert(with: NSLocalizedString("Alert!!", comment: ""), message: NSLocalizedString("invalid_phone_number", comment: ""), for: self!)
                                                    print("invalide validatePhoneNumber")
                                                    return
                                                }
                                            }
                                        }
                                    }
        })
        let action2 = UIAlertAction(title: NSLocalizedString(LocalizationSystem.sharedInstance.localizedStringForKey(key: "Cancel", comment: ""),comment: ""),
                                    style: UIAlertAction.Style.default,
                                    handler: {[weak self]
                                        (paramAction:UIAlertAction!) in
        })
        alertController?.addAction(action)
        alertController?.addAction(action2)
        self.present(alertController!,
                     animated: true,
                     completion: nil)
        return true
    }
    
    func validatePhoneNumber(value: String) -> Bool {
        let PHONE_REGEX = "^(\\+)[0-9]{6,14}$";
        let phoneTest = NSPredicate(format: "SELF MATCHES %@", PHONE_REGEX)
        let result =  phoneTest.evaluate(with: value)
        return result
    }
}

extension GroupManagementViewController: UITableViewDelegate,UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groups.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "RequestsCell") as! RequestsCell
        cell = tableView.dequeueReusableCell(withIdentifier: "RequestsCell") as! RequestsCell
        
        cell.DriverNamelbl.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "GroupManagementVC_DriverName", comment: "")
        cell.DriveMobilelbl.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "GroupManagementVC_DriverPh", comment: "")
        cell.DriverMaillbl.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "GroupManagementVC_DriverMail", comment: "")
        cell.DriverStatuslbl.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "GroupManagementVC_DriverStatus", comment: "")
        
        
        // -- get current Rides Object --
        let currentObj = groups[indexPath.row]
        cell.DriverNameVar.text = currentObj.driver_name
        cell.DriveMobileVar.text = currentObj.driver_mobile
        cell.DriverMailVar.text = currentObj.driver_email
        cell.DriverStatusVar.text = currentObj.driver_is_online
        
        if currentObj.driver_is_online == "1"{
            cell.DriverStatusVar.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "DriverInfoVC_Online", comment: "")
            cell.DriverStatusVar.textColor = .green
        }
        else{
            cell.DriverStatusVar.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "DriverInfoVC_Offline", comment: "")
            cell.DriverStatusVar.textColor = .red
        }
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // -- push to detail view with required data --
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "DriverInfoViewController") as! DriverInfoViewController
        vc.DriverData = ["driver_id": groups[indexPath.row].driverID]
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
}
