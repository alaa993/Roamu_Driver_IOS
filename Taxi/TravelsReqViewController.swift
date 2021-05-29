//
//  TravelsReqViewController.swift
//  TaxiDriver
//
//  Created by ibrahim.marie on 3/30/21.
//  Copyright © 2021 icanStudioz. All rights reserved.
//

import UIKit
import Alamofire

enum TravelRequestView: String {
    case pending
    case started
    case completed
    case cancelled
    case all_requests
}

class TravelsReqViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var LabelReq: UILabel!
    @IBOutlet var TextFieldReqType: UITextField!
    
    var requestPage:TravelRequestView?
    var travels = [DriverTravel]()
    
    @objc let PlatformPicker = UIPickerView()
    let PlatformPickerData = [String](arrayLiteral: "All","PENDING","STARTED","COMPLETED","CANCELLED")
    var PlatformString = "All"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        
        LabelReq.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "RequestsVCReqlbl", comment: "")
        self.TextFieldReqType.cornerRadius(radius: 20.0, andPlaceholderString: "All")
        self.TextFieldReqType.paddedTextField(frame: CGRect(x: 0, y: 0, width: 25, height: self.TextFieldReqType.frame.height))
        self.TextFieldReqType.text = PlatformString
        
        PlatformPicker.delegate = self
        createPlatformPicker()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if requestPage == TravelRequestView.all_requests{
            LabelReq.isHidden = false
            TextFieldReqType.isHidden = false
            self.title = LocalizationSystem.sharedInstance.localizedStringForKey(key: "RequestsVCAllTitle", comment: "")
            loadRequests(with: "All")
        } else if requestPage == TravelRequestView.started{
            LabelReq.isHidden = false
            TextFieldReqType.isHidden = false
            self.title = LocalizationSystem.sharedInstance.localizedStringForKey(key: "RequestsVCAcceptTitle", comment: "")
            loadRequests(with: "STARTED")
        } else if requestPage == TravelRequestView.pending{
            LabelReq.isHidden = false
            TextFieldReqType.isHidden = false
            self.title = LocalizationSystem.sharedInstance.localizedStringForKey(key: "RequestsVCPendingTitle", comment: "")
            loadRequests(with: "PENDING")
        } else if requestPage == TravelRequestView.completed{
            LabelReq.isHidden = false
            TextFieldReqType.isHidden = false
            self.title = LocalizationSystem.sharedInstance.localizedStringForKey(key: "RequestsVCCompletedTitle", comment: "")
            loadRequests(with: "COMPLETED")
        } else if requestPage == TravelRequestView.cancelled{
            LabelReq.isHidden = false
            TextFieldReqType.isHidden = false
            self.title = LocalizationSystem.sharedInstance.localizedStringForKey(key: "RequestsVCCancelledTitle", comment: "")
            loadRequests(with: "CANCELLED")
        }
    }
    
    func loadRequests(with status:String){
        let params = ["id":Common.instance.getUserId(),"status":status,"utype":"1"]
        let headers = ["X-API-KEY":Common.instance.getAPIKey()]
        //            print(Common.instance.getUserId())
        HUD.show(to: view)
        _ = Alamofire.request(APIRouters.GetDriverTravels(params,headers)).responseObject { (response: DataResponse<DriverTravels>) in
            HUD.hide(to: self.view)
            print("ibrahim was here")
            print(response)
            if response.result.isSuccess{
                if response.result.value?.status == true , ((response.result.value?.drivertravels) != nil) {
                    self.travels = (response.result.value?.drivertravels)!
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
            self.requestPage = TravelRequestView.all_requests
        case "PENDING":
            self.requestPage = TravelRequestView.pending
        case "STARTED":
            self.requestPage = TravelRequestView.started
        case "COMPLETED":
            self.requestPage = TravelRequestView.completed
        case "CANCELLED":
            self.requestPage = TravelRequestView.cancelled
        default:
            self.requestPage = TravelRequestView.pending
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
extension TravelsReqViewController: UITableViewDelegate,UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return travels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "RequestsCell") as! RequestsCell
        
        cell = tableView.dequeueReusableCell(withIdentifier: "RequestsCell") as! RequestsCell
        
        cell.Fromlbl.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "RequestsCell_Fromlbl", comment: "")
        cell.Tolbl.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "RequestsCell_Tolbl", comment: "")
        cell.Datelbl.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "RequestsCell_Datelbl", comment: "")
        cell.DriverNamelbl.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "RequestsCell_customerslbl", comment: "")
        cell.ReqTypelbl.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "RequestsVCReqlbl", comment: "")
        
        // -- get current Rides Object --
        let currentObj = travels[indexPath.row]
        
        // -- set driver name to cell --
        cell.name.text = "0" // by ibrahim static for now
        cell.ReqTypeVal.text = currentObj.Travel_Status //LocalizationSystem.sharedInstance.localizedStringForKey(key: "RequestsVCSearchlbl", comment: "")
        
        // -- set date and time to cell --
        //            cell.dateLabel.text = currentObj.travel_date
        //            cell.timeLabel.text = currentObj.travel_time
        let currentDate = currentObj.date
        //let date = Common.instance.getFormattedDate(date: currentDate).components(separatedBy: "-")
        let currentTime = currentObj.time
        print("ibrahim was here")
        print(currentObj.time)
        
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
//
//        // -- set pickup location --
        let origin = currentObj.pickupAddress.components(separatedBy: ",")
        if origin.count > 1{
            cell.streetFrom.text = origin.first
            var addr = origin.dropFirst().joined(separator: ", ")
            cell.detailAdrsFrom.text = String(addr.dropFirst())
        } else {
            cell.streetFrom.text = origin.first
            cell.detailAdrsFrom.text = ""
        }
//
//        // -- set drop location --
        let destination = currentObj.dropAddress.components(separatedBy: ",")
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
        // -- push to detail view with required data --
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "TravelsDetailReqViewController") as! TravelsDetailReqViewController
        if travels[indexPath.row].Travel_Status == "PENDING"
        {
            requestPage = TravelRequestView.pending
            self.TextFieldReqType.text = "PENDING"
        }
        if travels[indexPath.row].Travel_Status == "STARTED"
        {
            requestPage = TravelRequestView.started
            self.TextFieldReqType.text = "STARTED"
        }
        if travels[indexPath.row].Travel_Status == "COMPLETED"
        {
            requestPage = TravelRequestView.completed
            self.TextFieldReqType.text = "COMPLETED"
        }
        if travels[indexPath.row].Travel_Status == "CANCELLED"
        {
            requestPage = TravelRequestView.cancelled
            self.TextFieldReqType.text = "CANCELLED"
        }
//        vc.requestPage = requestPage
        vc.travelDetail = travels[indexPath.row]
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
