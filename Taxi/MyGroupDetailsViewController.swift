//
//  MyGroupDetailsViewController.swift
//  TaxiDriver
//
//  Created by ibrahim.marie on 11/22/20.
//  Copyright © 2020 icanStudioz. All rights reserved.
//

import UIKit
import Alamofire

class MyGroupDetailsViewController: UIViewController {
    
    @IBOutlet var GroupNameVar: UILabel!
    @IBOutlet var AdminNameVar: UILabel!
    
    @IBOutlet var GroupNamelbl: UILabel!
    @IBOutlet var AdminNamelbl: UILabel!
    @IBOutlet var MembersButton: UIButton!
    
    @IBOutlet var tableView: UITableView!
    
    
    var groups = [Group]()
    
    override func viewDidLoad() {
        
        self.title = LocalizationSystem.sharedInstance.localizedStringForKey(key: "GroupManagementVC_Title", comment: "")
        
        super.viewDidLoad()
        
        let backButton = UIBarButtonItem(image: UIImage(named: "arrow-left"),
                                         style: .plain,
                                         target: self,
                                         action: #selector(MyGroupsViewController.cancelWasClicked(_:)))
        self.navigationItem.leftBarButtonItem = backButton
        
        GroupNamelbl.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "GroupManagementVC_GroupName", comment: "")
        AdminNamelbl.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "GroupManagementVC_AdminName", comment: "")
        MembersButton.setTitle(LocalizationSystem.sharedInstance.localizedStringForKey(key: "GroupManagementVC_GroupMembers", comment: ""), for: .normal)
        //
        
        loadMyGroupList()
        
        loadGroupList()
    }
    
    @IBAction func cancelWasClicked(_ sender: UIButton) {
        print("back button pressed")
        _ = self.navigationController?.popToRootViewController(animated: true)
    }
    
    @IBAction func MembersButtonCliked(_ sender: Any) {
        loadGroupList()
    }
    
    func loadGroupList(){
        let params = ["admin_id":Common.instance.getUserId()]
        let headers = ["X-API-KEY":Common.instance.getAPIKey()]
        
        //HUD.show(to: view)
        _ = Alamofire.request(APIRouters.getGroupList(params,headers)).responseObject { (response: DataResponse<Groups>) in
            //HUD.hide(to: self.view)
            print("ibrahim")
            print(response)
            if response.result.isSuccess{
                if response.result.value?.status == true , ((response.result.value?.groups) != nil) {
                    print(response.result.value)
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
                        self.AdminNameVar.text = self.groups[0].admin_name
                        self.GroupNameVar.text = self.groups[0].group_name
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
}

extension MyGroupDetailsViewController: UITableViewDelegate,UITableViewDataSource {
    
    //------------------------------------------------------------------------------------------------------------------------------------------
    // MARK:- TableView Delegates And Datasources
    //------------------------------------------------------------------------------------------------------------------------------------------
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
        cell.DriverNameVar.text = currentObj.group_name
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
