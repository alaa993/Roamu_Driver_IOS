//
//  DriverInfoViewController.swift
//  TaxiDriver
//
//  Created by Syria.Apple on 5/13/20.
//  Copyright © 2020 icanStudioz. All rights reserved.
//

import UIKit
import Alamofire

class DriverInfoViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    
    @IBOutlet var NameVar: UILabel!
    @IBOutlet var MobileVar: UILabel!
    @IBOutlet var EmailVar: UILabel!
    @IBOutlet var CountryVar: UILabel!
    @IBOutlet var StatusVar: UILabel!
    @IBOutlet var VehicleVar: UILabel!
    
    @IBOutlet var TextFieldTravelType: UITextField!
    @IBOutlet var Namelbl: UILabel!
    @IBOutlet var Mobilelbl: UILabel!
    @IBOutlet var Emaillbl: UILabel!
    @IBOutlet var Countrylbl: UILabel!
    @IBOutlet var Statuslbl: UILabel!
    @IBOutlet var Vehiclelbl: UILabel!
    @IBOutlet var TravelTypelbl: UILabel!
    @IBOutlet var DriverInfo: UILabel!
    
    @IBOutlet var ApproveButton: UIButton!
    
    var drivers = [Driver]()
    var DriverData = [String:Any]()
    
    var rides = [Ride]()
    @IBOutlet var tableView: UITableView!
    
    @objc let TravelPicker = UIPickerView()
    let TravelPickerData = [String](arrayLiteral: LocalizationSystem.sharedInstance.localizedStringForKey(key: "DriverInfoVC_ACCEPTED", comment: ""),LocalizationSystem.sharedInstance.localizedStringForKey(key: "DriverInfoVC_PENDING", comment: ""),LocalizationSystem.sharedInstance.localizedStringForKey(key: "DriverInfoVC_COMPLETED", comment: ""),LocalizationSystem.sharedInstance.localizedStringForKey(key: "DriverInfoVC_CANCELLED", comment: ""))
    var TravelString = LocalizationSystem.sharedInstance.localizedStringForKey(key: "DriverInfoVC_ACCEPTED", comment: "")
    

    override func viewDidLoad() {
        
        super.viewDidLoad()
        DriverInfo.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "DriverInfoVC_Title", comment: "")
        Namelbl.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "DriverInfoVC_Name", comment: "")
        Mobilelbl.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "DriverInfoVC_Mobile", comment: "")
        Emaillbl.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "DriverInfoVC_Email", comment: "")
        Countrylbl.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "DriverInfoVC_Country", comment: "")
        Statuslbl.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "DriverInfoVC_Status", comment: "")
        Vehiclelbl.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "DriverInfoVC_Vehicle", comment: "")
        TravelTypelbl.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "DriverInfoVC_TravelType", comment: "")
        ApproveButton.setTitle(LocalizationSystem.sharedInstance.localizedStringForKey(key: "DriverInfoVC_Approve", comment: ""), for: .normal)
        self.TextFieldTravelType.text = TravelString
        loadDriverInfo()
        TravelPicker.delegate = self
        //Looks for single or multiple taps.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        createTravelPicker()
        
    }
    
    
    @IBAction func ApproveButtonTouch(_ sender: Any) {
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        view.addGestureRecognizer(tap)
        self.view.endEditing(true)
        
        if TravelString == LocalizationSystem.sharedInstance.localizedStringForKey(key: "DriverInfoVC_ACCEPTED", comment: "")
        {
            GetDriverRides(with: "ACCEPTED")
        }
        else if TravelString == LocalizationSystem.sharedInstance.localizedStringForKey(key: "DriverInfoVC_PENDING", comment: "")
        {
            GetDriverRides(with: "PENDING")
        }
        else if TravelString == LocalizationSystem.sharedInstance.localizedStringForKey(key: "DriverInfoVC_COMPLETED", comment: "")
        {
            GetDriverRides(with: "COMPLETED")
        }
        else if TravelString == LocalizationSystem.sharedInstance.localizedStringForKey(key: "DriverInfoVC_CANCELLED", comment: "")
        {
            GetDriverRides(with: "CANCELLED")
        }
        
//        let vc  = self.storyboard?.instantiateViewController(withIdentifier: "RequestsViewController") as! RequestsViewController
//        vc.requestPage = RequestView.DriverInfo
//
//        if TravelString == LocalizationSystem.sharedInstance.localizedStringForKey(key: "DriverInfoVC_ACCEPTED", comment: "")
//        {
//            vc.DriverData = ["DriverTravelStatus":"ACCEPTED","DriverID":drivers[0].userId!]
//        }
//        else if TravelString == LocalizationSystem.sharedInstance.localizedStringForKey(key: "DriverInfoVC_PENDING", comment: "")
//        {
//            vc.DriverData = ["DriverTravelStatus":"PENDING","DriverID":drivers[0].userId!]
//        }
//        else if TravelString == LocalizationSystem.sharedInstance.localizedStringForKey(key: "DriverInfoVC_COMPLETED", comment: "")
//        {
//            vc.DriverData = ["DriverTravelStatus":"COMPLETED","DriverID":drivers[0].userId!]
//        }
//        else if TravelString == LocalizationSystem.sharedInstance.localizedStringForKey(key: "DriverInfoVC_CANCELLED", comment: "")
//        {
//            vc.DriverData = ["DriverTravelStatus":"CANCELLED","DriverID":drivers[0].userId!]
//        }
//
//        let nav = UINavigationController(rootViewController: vc)
//        nav.setViewControllers([vc], animated:true)
//        self.revealViewController().setFront(nav, animated: true)
//        self.revealViewController().pushFrontViewController(nav, animated: true)
    }
    
    func GetDriverRides(with status:String)
    {
        let params = ["id":drivers[0].userId!,"status":status,"utype":"1"]
        let headers = ["X-API-KEY":Common.instance.getAPIKey()]
        
        HUD.show(to: view)
        _ = Alamofire.request(APIRouters.GetRides(params,headers)).responseObject { (response: DataResponse<Rides>) in
            HUD.hide(to: self.view)
            if response.result.isSuccess{
                if response.result.value?.status == true , ((response.result.value?.rides) != nil) {
                    self.rides = (response.result.value?.rides)!
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
    
    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    func loadDriverInfo(){
        
        let params = ["driver_id" : DriverData["driver_id"]!]
        let headers = ["X-API-KEY" : Common.instance.getAPIKey()]
        
        HUD.show(to: view)
        _ = Alamofire.request(APIRouters.getDriverInfo(params,headers)).responseObject { (response: DataResponse<Drivers>) in
            HUD.hide(to: self.view)
            if response.result.isSuccess{
                if response.result.value?.status == true , ((response.result.value?.drivers) != nil) {
                    self.drivers = (response.result.value?.drivers)!
                    self.drivers = (response.result.value?.drivers)!
                    self.NameVar.text = self.drivers[0].name
                    self.MobileVar.text = self.drivers[0].mobile
                    self.EmailVar.text = self.drivers[0].email
                    self.CountryVar.text = self.drivers[0].country
                    
                    if self.drivers[0].onlineStatus == "1"{
                        self.StatusVar.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "DriverInfoVC_Online", comment: "")
                        self.StatusVar.textColor = .green
                    }
                    else{
                        self.StatusVar.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "DriverInfoVC_Offline", comment: "")
                        self.StatusVar.textColor = .red
                    }
                    self.VehicleVar.text = self.drivers[0].vehicle_no
                    DispatchQueue.main.async {
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
    
    func createTravelPicker(){
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        let doneButton = UIBarButtonItem(title: LocalizationSystem.sharedInstance.localizedStringForKey(key: "FindTravelVC_Done", comment: ""), style: UIBarButtonItem.Style.done, target: self, action: #selector(doneSTravelButton))
        TextFieldTravelType.inputAccessoryView = toolBar;
        TextFieldTravelType.inputView = TravelPicker
        toolBar.setItems([doneButton], animated: true)
    }
    
    @objc func doneSTravelButton (){
        self.TextFieldTravelType.text = TravelString//"Yes"
        self.view.endEditing(true)
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
         return 1
     }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
     func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
         return TravelPickerData.count
     }
    
     func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        TextFieldTravelType.text = TravelPickerData[row]
        TravelString = TravelPickerData[row]
     }
    
     func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
         return TravelPickerData[row]
     }
    
}


extension DriverInfoViewController: UITableViewDelegate,UITableViewDataSource {
    
    //------------------------------------------------------------------------------------------------------------------------------------------
    // MARK:- TableView Delegates And Datasources
    //------------------------------------------------------------------------------------------------------------------------------------------
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rides.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "RequestsCell") as! RequestsCell
        cell = tableView.dequeueReusableCell(withIdentifier: "RequestsCell") as! RequestsCell
        
        cell.Fromlbl.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "RequestsCell_Fromlbl", comment: "")
        cell.Tolbl.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "RequestsCell_Tolbl", comment: "")
        cell.Datelbl.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "RequestsCell_Datelbl", comment: "")
        cell.DriverNamelbl.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "RequestsCell_Namelbl", comment: "")
        
        // -- get current Rides Object --
        let currentObj = rides[indexPath.row]
        
        // -- set driver name to cell --
        cell.name.text = currentObj.userName
        
        // -- set date and time to cell --
        ///************************************
        let currentDate = currentObj.date
        let currentTime = currentObj.time
        ///************************************
        let date = Common.instance.getFormattedDateOnly(date: currentDate)
        let time = Common.instance.getFormattedTimeOnly(date: currentTime)
        cell.dateLabel.text = date
        let inFormatter = DateFormatter()
        inFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX") as Locale
        inFormatter.dateFormat = "HH:mm:ss"

        let outFormatter = DateFormatter()
        outFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX") as Locale
        outFormatter.dateFormat = "HH:mm"

        let date_ = inFormatter.date(from: time)!
        let outStr = outFormatter.string(from: date_)

        cell.timeLabel.text = outStr
        
        // -- set pickup location --
        let origin = currentObj.pickupAdress.components(separatedBy: ",")
        if origin.count > 1{
            cell.streetFrom.text = origin.first
            var addr = origin.dropFirst().joined(separator: ", ")
            cell.detailAdrsFrom.text = String(addr.dropFirst())
        } else {
            cell.streetFrom.text = origin.first
            cell.detailAdrsFrom.text = ""
        }
        
        // -- set drop location --
        let destination = currentObj.dropAdress.components(separatedBy: ",")
        if destination.count > 1{
            cell.streetTo.text = destination.first
            var addr = destination.dropFirst().joined(separator: ", ")
            cell.detailAdrsTo.text = String(addr.dropFirst())
        } else {
            cell.streetTo.text = destination.first
            cell.detailAdrsTo.text = ""
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }
}
