//
//  VehicleTableViewController.swift
//  TaxiDriver
//
//  Created by Bhavin on 08/04/17.
//  Copyright © 2017 icanStudioz. All rights reserved.
//

import UIKit

class VehicleTableViewController: UITableViewController, UIPickerViewDelegate {
    @IBOutlet var brandText: UITextField!
    @IBOutlet var modelText: UITextField!
    @IBOutlet var yearText: UITextField!
    @IBOutlet var colorText: UITextField!
    @IBOutlet var vehicleNum: UITextField!
    @IBOutlet var AddVehicleDocslbl: UILabel!
    @IBOutlet var updateButton: UIButton!
    
    @IBOutlet var LabelCarType: UILabel!
    @IBOutlet var TextFieldCarType: UITextField!
    
    
    var isFromLogin = false
    
    @objc let SmokedPicker = UIPickerView()
    
    let SmokedPickerData = [String](arrayLiteral: LocalizationSystem.sharedInstance.localizedStringForKey(key: "FindTravelVC_Car", comment: ""),LocalizationSystem.sharedInstance.localizedStringForKey(key: "FindTravelVC_Minibus", comment: ""), LocalizationSystem.sharedInstance.localizedStringForKey(key: "FindTravelVC_Bus", comment: ""))
    var smokedString = LocalizationSystem.sharedInstance.localizedStringForKey(key: "FindTravelVC_Car", comment: "")
    var car_type = "car"
    
    //------------------------------------------------------------------------------------------------------------------------------------------
    // MARK:- View Controller Life Cycle
    //------------------------------------------------------------------------------------------------------------------------------------------
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = LocalizationSystem.sharedInstance.localizedStringForKey(key: "VehicleTableVC_Title", comment: "")
        
        AddVehicleDocslbl.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "VehicleTableVC_AddVehicleDocslbl", comment: "")
        updateButton.setTitle(LocalizationSystem.sharedInstance.localizedStringForKey(key: "VehicleTableVC_updateButton", comment: ""), for: .normal)
        
        self.TextFieldCarType.cornerRadius(radius: 20.0, andPlaceholderString: NSLocalizedString(LocalizationSystem.sharedInstance.localizedStringForKey(key: "FindTravelVC_Car", comment: ""),comment: ""))
        self.TextFieldCarType.paddedTextField(frame: CGRect(x: 0, y: 0, width: 25, height: TextFieldCarType.frame.height))
        LabelCarType.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "FindTravelVC_CarType", comment: "")
        self.TextFieldCarType.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "FindTravelVC_Car", comment: "")
        SmokedPicker.delegate = self
        createSmokedPicker()
        
        setupUI()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func createSmokedPicker(){
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        let doneButton = UIBarButtonItem(title: LocalizationSystem.sharedInstance.localizedStringForKey(key: "FindTravelVC_Done", comment: ""), style: UIBarButtonItem.Style.done, target: self, action: #selector(doneSmokedButton))
        TextFieldCarType.inputAccessoryView = toolBar;
        TextFieldCarType.inputView = SmokedPicker
        toolBar.setItems([doneButton], animated: true)
        
    }
    
    @objc func doneSmokedButton (){
        //        self.TextFieldSmoked.text = smokedString//"Yes"
        self.view.endEditing(true)
    }
    
    //------------------------------------------------------------------------------------------------------------------------------------------
    // MARK: - Table view data source
    //------------------------------------------------------------------------------------------------------------------------------------------
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 6
        case 1:
            return 1
        case 2:
            return 1
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
        if indexPath.section == 1 {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "VehicleDetailViewController")  as! VehicleDetailViewController
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return SmokedPickerData.count
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        TextFieldCarType.text = SmokedPickerData[row]
        smokedString = SmokedPickerData[row]
        
        if smokedString == LocalizationSystem.sharedInstance.localizedStringForKey(key: "FindTravelVC_Car", comment: "")
        {
            car_type = "car"
        }
        else if smokedString == LocalizationSystem.sharedInstance.localizedStringForKey(key: "FindTravelVC_Minibus", comment: "")
        {
            car_type = "minibus"
        }
        else if smokedString == LocalizationSystem.sharedInstance.localizedStringForKey(key: "FindTravelVC_Bus", comment: "")
        {
            car_type = "bus"
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
        return SmokedPickerData[row]
    }
    
    //------------------------------------------------------------------------------------------------------------------------------------------
    // MARK:- IBActions
    //------------------------------------------------------------------------------------------------------------------------------------------
    @IBAction func continueWasPressed(_ sender: UIButton) {
        if isFromLogin == true {
            if validateDocuments() {
                if validateTextFields() {
                    view.endEditing(true)
                    addVehicleData()
                }
            }
        }
        else {
            if validateTextFields() {
                view.endEditing(true)
                addVehicleData()
            }
        }
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
    
    // -- update vehicle info --
    
    func addVehicleData(){
        var params = [String:String]()
        params["user_id"] = Common.instance.getUserId()
        params["brand"] = brandText.text
        params["model"] = modelText.text
        params["year"]  = yearText.text
        params["color"] = colorText.text
        params["vehicle_no"] = vehicleNum.text
        params["car_type"] = self.car_type
        
        let headers = ["X-API-KEY":Common.instance.getAPIKey()]
        
        HUD.show(to: view)
        APIRequestManager.request(apiRequest: APIRouters.UpdateUser(params,headers), success: { (responseData) in
            HUD.hide(to: self.view)
            if let data = responseData as? [String:String] {
                // -- change User data --
                if let user = UserDefaults.standard.data(forKey: "user"){
                    let userData = NSKeyedUnarchiver.unarchiveObject(with: user) as? User
                    userData?.brand = data["brand"]
                    userData?.model = data["model"]
                    userData?.year  = data["year"]
                    userData?.color = data["color"]
                    userData?.vehicle_no = data["vehicle_no"]
                    let encodedData = NSKeyedArchiver.archivedData(withRootObject: userData!)
                    UserDefaults.standard.set(encodedData, forKey: "user")
                    
                    if self.isFromLogin == true {
                        self.moveToDashboard()
                    }
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
    
    func setupUI(){
        if isFromLogin == false {
            // -- setup revealview --
            if LocalizationSystem.sharedInstance.getLanguage() == "ar" {
                let revealController = self.revealViewController()
                revealController!.panGestureRecognizer().isEnabled = false
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
            
            // -- fill data --
            fillData()
            
            if brandText.text?.count == 0 {
                getProfile()
            }
        }
    }
    
    func fillData(){
        // -- set other info --
        if let data = UserDefaults.standard.data(forKey: "user"){
            let userData = NSKeyedUnarchiver.unarchiveObject(with: data) as? User
            brandText.text = userData?.brand
            modelText.text = userData?.model
            yearText.text  = userData?.year
            colorText.text = userData?.color
            vehicleNum.text = userData?.vehicle_no
        }
    }
    
    //------------------------------------------------------------------------------------------------------------------------------------------
    func validateTextFields() -> Bool {
        if brandText.text?.count == 0 ||
            modelText.text?.count == 0 ||
            yearText.text?.count == 0 ||
            colorText.text?.count == 0 ||
            vehicleNum.text?.count == 0 {
            Common.showAlert(with: NSLocalizedString("Alert!!", comment: ""), message: NSLocalizedString("Please fill all the fields.", comment: ""), for: self)
            return false
        } else {
            return true
        }
    }
    
    func validateDocuments() -> Bool {
        if let data = UserDefaults.standard.data(forKey: "user"){
            let userData = NSKeyedUnarchiver.unarchiveObject(with: data) as? User
            
            if userData?.license?.count == 0 ||
                userData?.permit?.count == 0 ||
                userData?.insurance?.count == 0 ||
                userData?.registration?.count == 0 {
                Common.showAlert(with: NSLocalizedString("Alert!!", comment: ""), message: NSLocalizedString("Please upload all the documents to continue.", comment: ""), for: self)
                return false
            } else {
                return true
            }
        } else { return false }
    }
    
    func moveToDashboard(){
        let menu = self.storyboard?.instantiateViewController(withIdentifier: "MenuViewController") as! MenuViewController
        let dashboard = self.storyboard?.instantiateViewController(withIdentifier: "MapViewController") as! MapViewController
        let dashboardNav = UINavigationController(rootViewController: dashboard)
        let revealController = SWRevealViewController(rearViewController: menu, frontViewController: dashboardNav)
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.window?.rootViewController = revealController
    }
}
