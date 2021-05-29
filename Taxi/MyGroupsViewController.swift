//
//  MyGroupsViewController.swift
//  TaxiDriver
//
//  Created by ibrahim.marie on 11/22/20.
//  Copyright © 2020 icanStudioz. All rights reserved.
//

import UIKit
import Alamofire

class MyGroupsViewController: UIViewController {
    
    @IBOutlet var tableView: UITableView!
    
    
    var groups = [Group]()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = LocalizationSystem.sharedInstance.localizedStringForKey(key: "GroupManagementVC_Title", comment: "")
        
        let backButton = UIBarButtonItem(image: UIImage(named: "arrow-left"),
                                         style: .plain,
                                         target: self,
                                         action: #selector(MyGroupsViewController.cancelWasClicked(_:)))
        self.navigationItem.leftBarButtonItem = backButton
        
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
    
    @IBAction func cancelWasClicked(_ sender: UIButton) {
        print("back button pressed")
        _ = self.navigationController?.popToRootViewController(animated: true)
    }
}

extension MyGroupsViewController: UITableViewDelegate,UITableViewDataSource {
    
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
        
        cell.DriveMobilelbl.isHidden = true
        cell.DriverMaillbl.isHidden = true
        cell.DriverStatuslbl.isHidden = true
        cell.DriveMobileVar.isHidden = true
        cell.DriverMailVar.isHidden = true
        cell.DriverStatusVar.isHidden = true
        
        // -- get current Rides Object --
        let currentObj = groups[indexPath.row]
        cell.DriverNameVar.text = currentObj.groupName
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
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "MyGroupDetailsViewController") as! MyGroupDetailsViewController
//            vc.DriverData = ["driver_id": groups[indexPath.row].driverID]
            self.navigationController?.pushViewController(vc, animated: true)
            
        }
}
