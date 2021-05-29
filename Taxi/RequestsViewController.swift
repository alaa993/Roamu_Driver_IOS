//
//  RequestsViewController.swift
//  Taxi
//
//  Created by Bhavin on 07/03/17.
//  Copyright © 2017 icanStudioz. All rights reserved.
//

import UIKit
import Alamofire

enum RequestView: String {
    case pending
    case accepted
    case completed
    case cancelled
    case searchTravel
    case DriverInfo
    case all_requests
}

class RequestsViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    @IBOutlet var tableView: UITableView!
    
    @IBOutlet var LabelReq: UILabel!
    @IBOutlet var TextFieldReqType: UITextField!
    
    
    var requestPage:RequestView?
    var rides = [Ride]()
//    var travels = [Travel]()
    var SearchData = [String:Any]()
    var DriverData = [String:Any]()
    
    @objc let PlatformPicker = UIPickerView()
    let PlatformPickerData = [String](arrayLiteral: "All","PENDING","ACCEPTED","COMPLETED","CANCELLED")
    var PlatformString = "All"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if requestPage == RequestView.searchTravel{
            requestPage = RequestView.searchTravel
        }
        else if requestPage == RequestView.DriverInfo{
            requestPage = RequestView.DriverInfo
        }
        else if requestPage == RequestView.all_requests{
            LabelReq.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "RequestsVCReqlbl", comment: "")
            self.TextFieldReqType.cornerRadius(radius: 20.0, andPlaceholderString: "All")
            self.TextFieldReqType.paddedTextField(frame: CGRect(x: 0, y: 0, width: 25, height: self.TextFieldReqType.frame.height))
            self.TextFieldReqType.text = PlatformString
        }
        else{
            //            requestPage = RequestView.pending
            LabelReq.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "RequestsVCReqlbl", comment: "")
            self.TextFieldReqType.cornerRadius(radius: 20.0, andPlaceholderString: "PENDING")
            self.TextFieldReqType.paddedTextField(frame: CGRect(x: 0, y: 0, width: 25, height: self.TextFieldReqType.frame.height))
            self.TextFieldReqType.text = PlatformString
            //            loadRequests(with: "PENDING")
        }
        if requestPage == RequestView.searchTravel
        {
            let backButton = UIBarButtonItem(image: UIImage(named: "arrow-left"),
                                             style: .plain,
                                             target: self,
                                             action: #selector(RequestsViewController.cancelWasClicked(_:)))
            self.navigationItem.leftBarButtonItem = backButton
        }
        else if requestPage == RequestView.DriverInfo
        {
            let backButton = UIBarButtonItem(image: UIImage(named: "arrow-left"),
                                             style: .plain,
                                             target: self,
                                             action: #selector(RequestsViewController.cancelWasClicked1(_:)))
            self.navigationItem.leftBarButtonItem = backButton
        }
        else
        {
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
        }
        
        PlatformPicker.delegate = self
        createPlatformPicker()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func cancelWasClicked(_ sender: UIButton) {
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func cancelWasClicked1(_ sender: UIButton) {
        _ = self.navigationController?.popToRootViewController(animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if requestPage == RequestView.all_requests{
            LabelReq.isHidden = false
            TextFieldReqType.isHidden = false
            self.title = LocalizationSystem.sharedInstance.localizedStringForKey(key: "RequestsVCAllTitle", comment: "")
            loadRequests(with: "All")
        } else if requestPage == RequestView.accepted{
            LabelReq.isHidden = false
            TextFieldReqType.isHidden = false
            self.title = LocalizationSystem.sharedInstance.localizedStringForKey(key: "RequestsVCAcceptTitle", comment: "")
            loadRequests(with: "ACCEPTED")
        } else if requestPage == RequestView.pending{
            LabelReq.isHidden = false
            TextFieldReqType.isHidden = false
            self.title = LocalizationSystem.sharedInstance.localizedStringForKey(key: "RequestsVCPendingTitle", comment: "")
            loadRequests(with: "PENDING")
        } else if requestPage == RequestView.completed{
            LabelReq.isHidden = false
            TextFieldReqType.isHidden = false
            self.title = LocalizationSystem.sharedInstance.localizedStringForKey(key: "RequestsVCCompletedTitle", comment: "")
            loadRequests(with: "COMPLETED")
        } else if requestPage == RequestView.cancelled{
            LabelReq.isHidden = false
            TextFieldReqType.isHidden = false
            self.title = LocalizationSystem.sharedInstance.localizedStringForKey(key: "RequestsVCCancelledTitle", comment: "")
            loadRequests(with: "CANCELLED")
        } else if requestPage == RequestView.searchTravel{
            LabelReq.isHidden = true
            TextFieldReqType.isHidden = true
            self.title = LocalizationSystem.sharedInstance.localizedStringForKey(key: "RequestsVCSearchTitle", comment: "")
            //            print("Search Travel")
            loadRequests(with: "searchTravel")
        } else if requestPage == RequestView.DriverInfo{
            LabelReq.isHidden = true
            TextFieldReqType.isHidden = true
            self.title = LocalizationSystem.sharedInstance.localizedStringForKey(key: "GroupManagementVC_Title", comment: "")
            loadRequests(with: "DriverStatus")
        }
    }
    
    func loadRequests(with status:String){
        if status == "searchTravel"
        {
            let params = ["travel_id":"-1",
                          "ride_id":"-1",
                          "car_type":Common.instance.getCarType(),
                          "pickup_address":SearchData["PickupAddress"]!,
                          "pickup_location":SearchData["pickupLocation"]!,
                          "drop_address":SearchData["DropAddress"]!,
                          "drop_location":SearchData["DropLocation"]!,
                          "time":SearchData["time"]!]
            let headers = ["X-API-KEY":Common.instance.getAPIKey()]
            Alamofire.request(APIRouters.getRequestedRides(params,headers)).responseObject { (response: DataResponse<Rides>) in
                HUD.hide(to: self.view)
                if response.result.isSuccess{
                    print(response.result.value!)
                    if response.result.value?.status == true , ((response.result.value?.rides) != nil) {
                        print("rides")
                        print(response.result.value?.rides)
                        self.rides = (response.result.value?.rides)!
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                        }
                    }
                    else {
                        Common.showAlert(with: NSLocalizedString("Alert!!", comment: ""), message: "No data found.", for: self)
                    }
                }
            }
        }
        else if status == "DriverStatus"//DriverData["DriverTravelStatus"]
        {
            let params = ["id":DriverData["DriverID"]!,"status":DriverData["DriverTravelStatus"]!,"utype":"1"]
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
        else
        {
            let params = ["id":Common.instance.getUserId(),"status":status,"utype":"1"]
            let headers = ["X-API-KEY":Common.instance.getAPIKey()]
            //            print(Common.instance.getUserId())
            HUD.show(to: view)
            _ = Alamofire.request(APIRouters.GetRides(params,headers)).responseObject { (response: DataResponse<Rides>) in
                HUD.hide(to: self.view)
                //                print("ibrahim was here")
                //                print(response)
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
    }
    
    func createPlatformPicker(){
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        let doneButton = UIBarButtonItem(title: LocalizationSystem.sharedInstance.localizedStringForKey(key: "FindTravelVC_Done", comment: ""), style: UIBarButtonItem.Style.done, target: self, action: #selector(self.donePlatformButton))
        TextFieldReqType.inputAccessoryView = toolBar;
        TextFieldReqType.inputView = PlatformPicker
        toolBar.setItems([doneButton], animated: true)
        //        datePicker.datePickerMode = .dateAndTime
    }
    
    @objc func donePlatformButton (){
        self.TextFieldReqType.text = PlatformString//"Yes"
        switch PlatformString {
        case "All":
            self.requestPage = RequestView.all_requests
        case "PENDING":
            self.requestPage = RequestView.pending
        case "ACCEPTED":
            self.requestPage = RequestView.accepted
        case "COMPLETED":
            self.requestPage = RequestView.completed
        case "CANCELLED":
            self.requestPage = RequestView.cancelled
        default:
            self.requestPage = RequestView.pending
        }
        loadRequests(with: PlatformString)
        self.view.endEditing(true)
        PlatformPicker.endEditing(true)
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        //        return SmokedPickerData.count
        return PlatformPickerData.count
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        PlatformString = PlatformPickerData[row]
        self.TextFieldReqType.text = PlatformPickerData[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
        return PlatformPickerData[row]
    }
    
}
extension RequestsViewController: UITableViewDelegate,UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if requestPage == RequestView.searchTravel
        {
            return rides.count
        }
        else if requestPage == RequestView.DriverInfo
        {
            return rides.count
        }
        return rides.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "RequestsCell") as! RequestsCell
        if requestPage == RequestView.searchTravel
        {
            cell = tableView.dequeueReusableCell(withIdentifier: "RequestsCell") as! RequestsCell
            
            cell.Fromlbl.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "RequestsCell_Fromlbl", comment: "")
            cell.Tolbl.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "RequestsCell_Tolbl", comment: "")
            cell.Datelbl.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "RequestsCell_Datelbl", comment: "")
            cell.DriverNamelbl.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "RequestsCell_Namelbl", comment: "")
            cell.ReqTypelbl.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "RequestsVCReqlbl", comment: "")
            
            // -- get current Rides Object --
            let currentObj = rides[indexPath.row]
            
            // -- set driver name to cell --
            cell.name.text = currentObj.userName
            cell.ReqTypeVal.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "RequestsVCSearchlbl", comment: "")
            
            // -- set date and time to cell --
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
        }
        else if requestPage == RequestView.DriverInfo
        {
            cell = tableView.dequeueReusableCell(withIdentifier: "RequestsCell") as! RequestsCell
            
            cell.Fromlbl.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "RequestsCell_Fromlbl", comment: "")
            cell.Tolbl.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "RequestsCell_Tolbl", comment: "")
            cell.Datelbl.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "RequestsCell_Datelbl", comment: "")
            cell.DriverNamelbl.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "RequestsCell_Namelbl", comment: "")
            cell.ReqTypelbl.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "RequestsVCReqlbl", comment: "")
            
            // -- get current Rides Object --
            let currentObj = rides[indexPath.row]
            
            // -- set driver name to cell --
            cell.name.text = currentObj.userName
            cell.ReqTypeVal.text = currentObj.status
            
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
        }
        else
        {
            cell = tableView.dequeueReusableCell(withIdentifier: "RequestsCell") as! RequestsCell
            
            cell.Fromlbl.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "RequestsCell_Fromlbl", comment: "")
            cell.Tolbl.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "RequestsCell_Tolbl", comment: "")
            cell.Datelbl.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "RequestsCell_Datelbl", comment: "")
            cell.DriverNamelbl.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "RequestsCell_Namelbl", comment: "")
            cell.ReqTypelbl.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "RequestsVCReqlbl", comment: "")
            
            // -- get current Rides Object --
            let currentObj = rides[indexPath.row]
            // -- set driver name to cell --
            cell.name.text = currentObj.userName
            cell.ReqTypeVal.text = currentObj.status
            
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
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if requestPage == RequestView.searchTravel
        {
            // -- move to next view --
            let vcConfirm = self.storyboard?.instantiateViewController(withIdentifier: "ConfirmRideVC") as! ConfirmRideVC
            vcConfirm.confirmRequestPage = confirmRequestView.RequestsViewController
            vcConfirm.rideData = ["rideId":rides[indexPath.row].rideId,
                                  "userId": rides[indexPath.row].userId,
                                  "travelId": rides[indexPath.row].travelId,
                                  "driverId": rides[indexPath.row].driverId,
                                  "pickup": rides[indexPath.row].pickupAdress,
                                  "drop": rides[indexPath.row].dropAdress,
                                  "pickup_point": rides[indexPath.row].pickup_point,
                                  "pickup_location": rides[indexPath.row].pickLocation,
                                  "drop_location": rides[indexPath.row].dropLocation,
                                  "driverName": rides[indexPath.row].driverName,
                                  "userName": rides[indexPath.row].userName,
                                  "distance":rides[indexPath.row].distance,
                                  "booked_set":rides[indexPath.row].bookedSeat,
                                  "emptySet":rides[indexPath.row].emptySet,
                                  "travel_date":rides[indexPath.row].date,
                                  "travel_time":rides[indexPath.row].time,
                                  "userAvatar":rides[indexPath.row].userAvatar,
                                  "city":rides[indexPath.row].city,
                                  "amount":rides[indexPath.row].amount]
            self.navigationController?.pushViewController(vcConfirm, animated: true)
        }
        else if requestPage == RequestView.DriverInfo
        {
            
        }
        else
        {
            // -- push to detail view with required data --
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "DetailReqViewController") as! DetailReqViewController
            if rides[indexPath.row].status == "PENDING"
            {
                requestPage = RequestView.pending
                self.TextFieldReqType.text = "PENDING"
            }
            if rides[indexPath.row].status == "ACCEPTED"
            {
                requestPage = RequestView.accepted
                self.TextFieldReqType.text = "ACCEPTED"
            }
            if rides[indexPath.row].status == "COMPLETED"
            {
                requestPage = RequestView.completed
                self.TextFieldReqType.text = "COMPLETED"
            }
            if rides[indexPath.row].status == "CANCELLED"
            {
                requestPage = RequestView.cancelled
                self.TextFieldReqType.text = "CANCELLED"
            }
            vc.requestPage = requestPage
            vc.rideDetail = rides[indexPath.row]
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
    }
}
