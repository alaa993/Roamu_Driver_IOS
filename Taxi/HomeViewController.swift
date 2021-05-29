//
//  HomeViewController.swift
//  TaxiDriver
//
//  Created by Syria.Apple on 4/20/20.
//  Copyright © 2020 icanStudioz. All rights reserved.
// is the main controller by ibrahim

import UIKit
import Alamofire
import MapKit
import GooglePlaces
import Firebase

protocol isAbleToReceiveData {
    func pass(ResultSearchDictionary: [String:Any]!)  //data: string is an example parameter
}

protocol NoOfPassengers {
    func NoOfPassengersPass(NoOfPassengersVar: Int!)  //data: string is an example parameter
}

class HomeViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, isAbleToReceiveData, NoOfPassengers {
    var resultsViewController: GMSAutocompleteResultsViewController?
    var searchController: UISearchController?
    var resultView: UITextView?
    
    
    
    @IBOutlet var TextFieldPickupAddress: UITextField!
    @IBOutlet var TextFieldDropAddress: UITextField!
    @IBOutlet var TextFieldTravelTime: UITextField!
    //    @IBOutlet var TextFieldSmoked: UITextField!
    @IBOutlet var NoOfPassengersButton: UIButton!
    
    @IBOutlet var tableView: UITableView!
    var requestPage:RequestView?
    var rides = [Ride]()
    
    @IBOutlet var earnOverall: UILabel!
    @IBOutlet var AddTravelButton: UIButton!
    @IBOutlet var FindTravelButton: UIButton!
    
    var button = UIButton(type: .system)
    
    @IBOutlet var PickupAddressButton: UIButton!
    @IBOutlet var DropAddressButton: UIButton!
    @IBOutlet var TextFieldPlatform: UITextField!
    
    var TextFieldPlatform2: UITextField!
    var TextFieldPickupPoint: UITextField!
    var TextFieldPassengersNum: UITextField!
    var TextFieldTripPrice: UITextField!
    
    var isPickup = Bool()
    var isDrop = Bool()
    var isPickupPoint = Bool()
    var PickupLocation = ""
    var DropLocation = ""
    var pickupPointLocation = ""
    //var place1 : GMSPlace = GMSPlace
    var place1: GMSPlace!
    var travelTimeDate = ""
    var travelTime = ""
    
    var enteredText = ""
    var amount = ""
    var pickUpPoint = ""
    var travelDate = ""
    
    
    let datePicker = UIDatePicker()
    
    @objc let SmokedPicker = UIPickerView()
    @objc let PlatformPicker = UIPickerView()
    let PlatformPickerData = [String](arrayLiteral: LocalizationSystem.sharedInstance.localizedStringForKey(key: "FindTravelVC_PlatformYes", comment: ""),LocalizationSystem.sharedInstance.localizedStringForKey(key: "FindTravelVC_PlatformNo", comment: ""))//["Yes","No"]
    var PlatformString = LocalizationSystem.sharedInstance.localizedStringForKey(key: "FindTravelVC_PlatformYes", comment: "")
    
    let SmokedPickerData = [String](arrayLiteral: LocalizationSystem.sharedInstance.localizedStringForKey(key: "FindTravelVC_SmokedYes", comment: ""),LocalizationSystem.sharedInstance.localizedStringForKey(key: "FindTravelVC_SmokedNo", comment: ""))//["Yes","No"]
    var smokedString = LocalizationSystem.sharedInstance.localizedStringForKey(key: "FindTravelVC_SmokedYes", comment: "")
    
    var PassengersStr = "Passenger"
    var PassengersCount = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        getImgProfile()
        
        self.title = LocalizationSystem.sharedInstance.localizedStringForKey(key: "HomeVC_Title", comment: "")
        
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
        else {
            if let revealController = self.revealViewController() {
                revealController.panGestureRecognizer()
                let menuButton = UIBarButtonItem(image: UIImage(named: "menu"),
                                                 style: .plain, target: revealController,
                                                 action: #selector(SWRevealViewController.revealToggle(_:)))
                self.navigationItem.leftBarButtonItem = menuButton
                
            }
        }
        getNotificationsCount()
        
        
        var PlatformString = LocalizationSystem.sharedInstance.localizedStringForKey(key: "FindTravelVC_PlatformYes", comment: "")
        //------------------------------------------------------
        self.TextFieldPickupAddress.cornerRadius(radius: 20.0, andPlaceholderString: NSLocalizedString(LocalizationSystem.sharedInstance.localizedStringForKey(key: "FindTravelVC_Pickup_Add", comment: ""),comment: ""))
        self.TextFieldPickupAddress.paddedTextField(frame: CGRect(x: 0, y: 0, width: 25, height: self.TextFieldPickupAddress.frame.height))
        
        self.TextFieldDropAddress.cornerRadius(radius: 20.0, andPlaceholderString: NSLocalizedString(LocalizationSystem.sharedInstance.localizedStringForKey(key: "FindTravelVC_Drop_Add", comment: ""),comment: ""))
        self.TextFieldDropAddress.paddedTextField(frame: CGRect(x: 0, y: 0, width: 25, height: self.TextFieldDropAddress.frame.height))
        
        self.FindTravelButton.corner(radius: 20.0, color: UIColor.white, width: 1.0)
        self.AddTravelButton.corner(radius: 20.0, color: UIColor.white, width: 1.0)
        
        self.TextFieldTravelTime.cornerRadius(radius: 20.0, andPlaceholderString: NSLocalizedString(LocalizationSystem.sharedInstance.localizedStringForKey(key: "FindTravelVC_TravelTime", comment: ""),comment: ""))
        self.TextFieldTravelTime.paddedTextField(frame: CGRect(x: 0, y: 0, width: 25, height: TextFieldTravelTime.frame.height))
        
        TextFieldPlatform.cornerRadius(radius: 20.0, andPlaceholderString: NSLocalizedString(LocalizationSystem.sharedInstance.localizedStringForKey(key: "FindTravelVC_Platform", comment: ""),comment: ""))
        TextFieldPlatform.paddedTextField(frame: CGRect(x: 0, y: 0, width: 25, height: TextFieldPlatform.frame.height))
        TextFieldPlatform.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "FindTravelVC_PlatformNo", comment: "")
        
        NoOfPassengersButton.setTitle("\(String(PassengersCount)) \(LocalizationSystem.sharedInstance.localizedStringForKey(key: "FindTravelVC_Passengers", comment: ""))", for: .normal)
        
        
        FindTravelButton.setTitle(LocalizationSystem.sharedInstance.localizedStringForKey(key: "FindTravelVC_FindTravel", comment: ""), for: .normal)
        AddTravelButton.setTitle(LocalizationSystem.sharedInstance.localizedStringForKey(key: "FindTravelVC_AddTravel", comment: ""), for: .normal)
        
        //------------------------------------------------------
        
        
        
        SmokedPicker.delegate = self
        //Looks for single or multiple taps.
//        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
//        view.addGestureRecognizer(tap)
        
        createDatePicker()
        createSmokedPicker()
        
        PlatformPicker.delegate = self
        createPlatformPicker()
        
    }
    
    func getImgProfile() {
        Database
            .database()
            .reference()
            .child("users")
            .child("profile")
            .child(Auth.auth().currentUser!.uid)
            .queryOrderedByKey()
            .observe(.childAdded, with: { (snapshot) in
                guard let dict = snapshot.value as? [String:Any] else {
                    //                 print("oooooooooooooooooo","Error")
                    return
                }
                let photoURL = dict["photoURL"] as? String
                //           print("tttttttiiiiiiiiiiiikkkkkkkt",photoURL)
                // let priceAd = dict["priceAd"] as? String
            })
    }
    
    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    @objc func showNotifications() {
        let vc  = self.storyboard?.instantiateViewController(withIdentifier: "NotificationsViewController") as! NotificationsViewController
        let nav = UINavigationController(rootViewController: vc)
        nav.setViewControllers([vc], animated:true)
        self.revealViewController().setFront(nav, animated: true)
        self.revealViewController().pushFrontViewController(nav, animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        loadRequests(with: "ACCEPTED")
        //getEarnings()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func FindTravelButton(_ sender: UIButton) {
        // -- move to next view --
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "RequestsViewController") as! RequestsViewController
        vc.requestPage = RequestView.searchTravel
        vc.SearchData = ["PickupAddress":TextFieldPickupAddress.text!,
                         "pickupLocation": PickupLocation,
                         "DropAddress": TextFieldDropAddress.text!,
                         "DropLocation": DropLocation,
                         "time": TextFieldTravelTime.text!
            
        ]
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func AddTravelBtn(_ sender: Any) {
        openAlert()
    }
    
    func openAlert() -> Bool {
        if validateTextFields() {
            var alertController:UIAlertController?
            alertController = UIAlertController(title:
                NSLocalizedString(LocalizationSystem.sharedInstance.localizedStringForKey(key: "Enter number of passengers,Trip price", comment: ""),comment: ""),message: NSLocalizedString(LocalizationSystem.sharedInstance.localizedStringForKey(key: "Enter number of passengers,Trip price", comment: ""),comment: ""),preferredStyle: .alert)
            
            // pickup point
            alertController!.addTextField(
                configurationHandler: {(textField: UITextField!) in
                    self.TextFieldPickupPoint = textField
                    textField.placeholder = NSLocalizedString(LocalizationSystem.sharedInstance.localizedStringForKey(key: "PickUpPoint", comment: ""),comment: "")
                    textField.keyboardType = UIKeyboardType.default
                    self.TextFieldPickupPoint.addTarget(self, action: #selector(self.pickupPointFunction), for: .touchDown)
            })
            // passengers number
            alertController!.addTextField(
                configurationHandler: {(textField: UITextField!) in
                    //                    self.TextFieldPassengersNum = textField
                    textField.placeholder = NSLocalizedString(LocalizationSystem.sharedInstance.localizedStringForKey(key: "number of passengers 1", comment: ""),comment: "")
                    //                    textField.keyboardType = UIKeyboardType.numberPad
                    textField.keyboardType = .asciiCapableNumberPad
                    
            })
            // trip price
            alertController!.addTextField(
                configurationHandler: {(textField: UITextField!) in
                    //                    self.TextFieldTripPrice = textField
                    textField.placeholder = NSLocalizedString(LocalizationSystem.sharedInstance.localizedStringForKey(key: "Trip price", comment: ""),comment: "")
                    //                    textField.keyboardType = UIKeyboardType.numberPad
                    textField.keyboardType = .asciiCapableNumberPad
                    
            })
            // platform
            alertController!.addTextField(
                configurationHandler: {(textField: UITextField!) in
                    self.TextFieldPlatform2 = textField
                    self.TextFieldPlatform2.placeholder = NSLocalizedString(LocalizationSystem.sharedInstance.localizedStringForKey(key: "FindTravelVC_PlatformYes", comment: ""),comment: "")
                    self.TextFieldPlatform2.text  = LocalizationSystem.sharedInstance.localizedStringForKey(key: "FindTravelVC_PlatformYes", comment: "")
                    self.TextFieldPlatform2.addTarget(self, action: #selector(self.myTargetFunction), for: .touchDown)
            })
            
            let action = UIAlertAction(title: NSLocalizedString(LocalizationSystem.sharedInstance.localizedStringForKey(key: "Submit", comment: ""),comment: ""),
                                       style: UIAlertAction.Style.default,
                                       handler: {[weak self]
                                        (paramAction:UIAlertAction!) in
                                        if let textFields = alertController?.textFields{
                                            let theTextFields = textFields as [UITextField]
                                            if theTextFields[1].text!.count == 0{
                                                self?.enteredText = "1"
                                            }else{
                                                self?.enteredText = theTextFields[1].text!
                                            }
                                            if theTextFields[2].text!.count == 0{
                                                Common.showAlert(with: NSLocalizedString("Alert!!", comment: ""), message: NSLocalizedString("Please fill all the fields.", comment: ""), for: self!)
                                                return
                                                
                                            }else{
                                                self?.amount = theTextFields[2].text!
                                            }
                                            if theTextFields[0].text!.count == 0
                                            {
                                                Common.showAlert(with: NSLocalizedString("Alert!!", comment: ""), message: NSLocalizedString("Please fill all the fields.", comment: ""), for: self!)
                                                return
                                                
                                            }else{
                                                self?.pickUpPoint = theTextFields[0].text!
                                            }
                                            self!.AddTravel_Func()
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
        }
        return true
    }
    
    @objc func myTargetFunction(textField: UITextField) {
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        let doneButton = UIBarButtonItem(title: LocalizationSystem.sharedInstance.localizedStringForKey(key: "FindTravelVC_Done", comment: ""), style: UIBarButtonItem.Style.done, target: self, action: #selector(self.donePlatformButton))
        textField.inputAccessoryView = toolBar;
        textField.inputView = self.PlatformPicker
        toolBar.setItems([doneButton], animated: true)
    }
    
    @objc func pickupPointFunction(textField: UITextField) {
        isPickupPoint = true
        dismiss(animated: true, completion: nil)
        print("ibrahim auto complete")
        autocompleteClicked()
    }
    
    func AddTravel_Func(){
        if self.validateTextFields1() {
            // -- manage parameters --
            var parameters = [String:Any]()
            parameters["driver_id"] = Common.instance.getUserId()
            parameters["pickup_address"] =  TextFieldPickupAddress.text
            parameters["drop_address"] = TextFieldDropAddress.text //"Maysat"
            parameters["pickup_location"] = PickupLocation//TextFieldPickupAddress.text  //"Maysat"
            parameters["drop_location"] = DropLocation//TextFieldDropAddress.text //"Maysat"
            parameters["pickup_point"] = self.pickUpPoint
            parameters["distance"] = "0"
            parameters["amount"] = self.amount
            parameters["available_set"] = self.enteredText // at least equals to the number of booked Set
            parameters["booked_set"] = "0"
            parameters["travel_date"] = travelDate
            parameters["travel_time"] = travelTime
            parameters["smoked"] = "1"
            parameters["status"] = 0
            
            let headers = ["X-API-KEY":Common.instance.getAPIKey()]
            // -- show loading --
            HUD.show(to: view)
            
            // -- send request --
            // response object by ibrahim without encapculation
            // 12345
            APIRequestManager.request(apiRequest: APIRouters.AddTravel(parameters, headers), success: { (response) in
                // -- hide loading --
                HUD.hide(to: self.view)
                print("start")
                print(response)
                if let data = response as? [String:Any] {
                    print(data["travel_id"]!);
                    //                    self.savePrivatePost(DriverId: data["user_id"]! as! String)
                    if self.TextFieldPlatform2.text  == LocalizationSystem.sharedInstance.localizedStringForKey(key: "FindTravelVC_PlatformYes", comment: "")
                    {
                        self.handlePostButton(travel_id: data["travel_id"]! as! NSNumber )
                    }
                    self.addTravelToFireBase(travel_id: data["travel_id"]! as! NSNumber)
                }
                // -- parse response --
                let alert = UIAlertController(title: NSLocalizedString("Success!!",comment: ""), message: "", preferredStyle: .alert)
                
                let done = UIAlertAction(title: NSLocalizedString("Done", comment: ""), style: .default, handler: { (action) in
                    _ = self.navigationController?.popViewController(animated: true)
                })
                alert.addAction(done)
                self.present(alert, animated: true, completion: nil)
            }, failure: { (message) in
                HUD.hide(to: self.view)
                Common.showAlert(with: NSLocalizedString("Alert!!", comment: ""), message: message, for: self)
                print("failure")
            }, error: { (err) in
                HUD.hide(to: self.view)
                Common.showAlert(with: NSLocalizedString("Error!!", comment: ""), message: err.localizedDescription, for: self)
                print("error")
            })
        }
        else{
            HUD.hide(to: self.view)
        }
    }
    
    func getNotificationsCount(){
        let userRef = Database.database().reference().child("Notifications").child(Common.instance.getUserId())
        userRef.observe(.value, with: { snapshot in
            var count = 0
            for child in snapshot.children {
                if let childSnapshot = child as? DataSnapshot,
                    let data = childSnapshot.value as? [String:Any],
                    let notification = Notification.parse(childSnapshot.key, data),
                    notification.readStatus == "0" {
                    count = count+1
                }
            }
            print(count)
            
            //let button = UIButton(type: .system)
            self.button.setImage(UIImage(named: "notification"), for: .normal)
            self.button.setTitle(String(count), for: .normal)
            self.button.setTitleColor(UIColor.red, for: .normal)
            self.button.sizeToFit()
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: self.button)
            self.button.addTarget(self, action: #selector(self.showNotifications), for: .touchUpInside)
            
        })
    }
    
    func handlePostButton(travel_id: NSNumber) {
        guard let userProfile = UserService.currentUserProfile else { return }
        
        let postRef = Database.database().reference().child("posts").childByAutoId()
        let postObject = [
            "author": [
                "uid": userProfile.uid,
                "username": userProfile.username,
                "photoURL": userProfile.photoURL.absoluteString
            ],
            "text": "\(LocalizationSystem.sharedInstance.localizedStringForKey(key: "Travel_is_going_from", comment: ""))\n\(LocalizationSystem.sharedInstance.localizedStringForKey(key: "Travel_from", comment: "")) \(TextFieldPickupAddress.text!)\n\(LocalizationSystem.sharedInstance.localizedStringForKey(key: "Travel_to", comment: "")) \(TextFieldDropAddress.text!)\n\(LocalizationSystem.sharedInstance.localizedStringForKey(key: "Travel_on", comment: "")) \(travelDate)\n\(LocalizationSystem.sharedInstance.localizedStringForKey(key: "the_clock", comment: ""))\(travelTime)",
            "timestamp": [".sv":"timestamp"],
            "type": "0",
            "privacy": "1",
            "travel_id": travel_id
            ] as [String:Any]
        postRef.setValue(postObject, withCompletionBlock: { error, ref in
            if error == nil {
                //                self.delegate?.didUploadPost(withID: ref.key!)the_clock
                //                self.dismiss(animated: true, completion: nil)
                self.TextFieldPickupAddress.text = ""
                self.TextFieldDropAddress.text = ""
                self.TextFieldTravelTime.text = ""
            } else {
            }
        })
    }
    
    func addTravelToFireBase(travel_id: NSNumber) {
        guard let userProfile = UserService.currentUserProfile else { return }
        
        let postRef = Database.database().reference().child("Travels").child(travel_id.stringValue)
        let postObject = [
            "driver_id": Common.instance.getUserId()
            ] as [String:Any]
        postRef.setValue(postObject, withCompletionBlock: { error, ref in
            if error == nil {
            } else {
            }
        })
    }
    
    func validateTextFields1() -> Bool {
        if TextFieldPickupAddress.text?.count == 0 ||
            TextFieldDropAddress.text?.count == 0 ||
            //   TextFieldAmount.text?.count == 0 ||
            TextFieldTravelTime.text?.count == 0
        {
            Common.showAlert(with: NSLocalizedString("Alert!!", comment: ""), message: NSLocalizedString("Please fill all the fields.", comment: ""), for: self)
            return false
        }
        else{
            return true
        }
    }
    
    @IBAction func TextFieldPickupAddressTouchDown(_ sender: Any) {
        isPickup = true
        autocompleteClicked()
        //        print("sss",place1)
        
    }
    
    @IBAction func TextFieldDropAddressTouchDown(_ sender: Any) {
        isDrop = true
        autocompleteClicked()
    }
    
    @IBAction func ButtonPickupAddressTouchDown(_ sender: Any) {
        isPickup = true
        GoogleSearchClicked()
    }
    
    @IBAction func ButtonDropAddressTouchDown(_ sender: Any) {
        isDrop = true
        GoogleSearchClicked()
    }
    
    @IBAction func NoOfPassengersButtonTouchDown(_ sender: Any) {
        let PassengersViewController_ = self.storyboard?.instantiateViewController(withIdentifier: "PassengersViewController") as!
        PassengersViewController
        PassengersViewController_.delegate = self
        PassengersViewController_.PassengersCount = PassengersCount
        PassengersViewController_.modalPresentationStyle = .fullScreen
        self.present(PassengersViewController_, animated: true, completion: nil)
    }
    
    func autocompleteClicked() {
        /*let SearchViewController_ = self.storyboard?.instantiateViewController(withIdentifier: "SearchViewController") as!
         SearchViewController
         //SearchViewController_.delegate = self
         SearchViewController_.modalPresentationStyle = .fullScreen
         self.present(SearchViewController_, animated: true, completion: nil)
         
         */
        
        let acController = GMSAutocompleteViewController()
        acController.delegate = self
        present(acController, animated: true, completion: nil)
    }
    
    func GoogleSearchClicked() {
        let GoogleSearchViewController_ = self.storyboard?.instantiateViewController(withIdentifier: "GoogleSearchViewController") as! GoogleSearchViewController
        GoogleSearchViewController_.delegate = self
        GoogleSearchViewController_.modalPresentationStyle = .fullScreen
        self.present(GoogleSearchViewController_, animated: true, completion: nil)
    }
    
    func loadRequests(with status:String){
        let params = ["id":Common.instance.getUserId(),"status":status,"utype":"1"]
        let headers = ["X-API-KEY":Common.instance.getAPIKey()]
        
        //HUD.show(to: view)
        _ = Alamofire.request(APIRouters.GetRides(params,headers)).responseObject { (response: DataResponse<Rides>) in
            //HUD.hide(to: self.view)
            
            if response.result.isSuccess{
                if response.result.value?.status == true , ((response.result.value?.rides) != nil) {
                    self.rides = (response.result.value?.rides)!
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }
                else{
                    //Common.showAlert(with: NSLocalizedString("Alert!!", comment: ""), message: NSLocalizedString("No data found.", comment: ""), for: self)
                }
            }
            
            if response.result.isFailure{
                //                Common.showAlert(with: NSLocalizedString("Error!!" ,comment: ""), message: response.error?.localizedDescription, for: self)
            }
        }
    }
    
    func getEarnings(){
        HUD.show(to: self.view)
        
        // -- set parameters for request --
        var params = [String:String]()
        params["driver_id"] = Common.instance.getUserId()
        
        // -- set headers for requests --
        let headers = ["X-API-KEY":Common.instance.getAPIKey()]
    }
    
    func pass(ResultSearchDictionary: [String:Any]!) {
       /*
        if isPickup  {
            self.TextFieldPickupAddress.text = place1.formattedAddress
            let pickupLat = place1.coordinate.latitude
            let pickupLog = place1.coordinate.longitude
            self.PickupLocation = "\(pickupLat),\(pickupLog)"
            isPickup = false
        }
        else if isDrop {
            self.TextFieldDropAddress.text = place1.formattedAddress
            let pickupLat = place1.coordinate.latitude
            let pickupLog = place1.coordinate.longitude
            self.DropLocation = "\(pickupLat),\(pickupLog)"
            isDrop = false
        }
        else if isPickupPoint{
            self.TextFieldPickupPoint.text = place1.formattedAddress
            let pickupLat = place1.coordinate.latitude
            let pickupLog = place1.coordinate.longitude
            self.pickupPointLocation = "\(pickupLat),\(pickupLog)"
            isPickupPoint = false
        }
 */
        if isPickup  {
            print("latlong from findtravel view controller:")
            print(ResultSearchDictionary["latitude"]!)
            print(ResultSearchDictionary["longitude"]!)
            self.TextFieldPickupAddress.text = (ResultSearchDictionary["title"] as! String)
            let pickupLat = ResultSearchDictionary["latitude"]!
            let pickupLog = ResultSearchDictionary["longitude"]!
            self.PickupLocation = "\(pickupLat),\(pickupLog)"
            isPickup = false
            
        } else if isDrop {
            self.TextFieldDropAddress.text = (ResultSearchDictionary["title"] as! String)
            let pickupLat = ResultSearchDictionary["latitude"]!
            let pickupLog = ResultSearchDictionary["longitude"]!
            self.DropLocation = "\(pickupLat),\(pickupLog)"
            isDrop = false
        }
    }
    
    func NoOfPassengersPass(NoOfPassengersVar: Int!) {
        PassengersCount = NoOfPassengersVar
        if PassengersCount == 1{
            PassengersStr = "Passenger"
        }
        else{
            PassengersStr = "Passengers"
        }
        NoOfPassengersButton.setTitle("\(String(PassengersCount)) \(LocalizationSystem.sharedInstance.localizedStringForKey(key: "FindTravelVC_Passengers", comment: ""))", for: .normal)
    }
    
    func createDatePicker(){
        let loc = Locale(identifier: "us")
        self.datePicker.locale = loc
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(donePressedButton))
        TextFieldTravelTime.inputAccessoryView = toolBar;
        TextFieldTravelTime.inputView = datePicker
        toolBar.setItems([doneButton], animated: true)
        datePicker.datePickerMode = .dateAndTime
    }
    
    func createPlatformPicker(){
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        let doneButton = UIBarButtonItem(title: LocalizationSystem.sharedInstance.localizedStringForKey(key: "FindTravelVC_Done", comment: ""), style: UIBarButtonItem.Style.done, target: self, action: #selector(self.donePlatformButton))
        TextFieldPlatform.inputAccessoryView = toolBar;
        TextFieldPlatform.inputView = PlatformPicker
        toolBar.setItems([doneButton], animated: true)
        //        datePicker.datePickerMode = .dateAndTime
    }
    
    func createSmokedPicker(){
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        let doneButton = UIBarButtonItem(title: LocalizationSystem.sharedInstance.localizedStringForKey(key: "FindTravelVC_Done", comment: ""), style: UIBarButtonItem.Style.done, target: self, action: #selector(doneSmokedButton))
        //        TextFieldSmoked.inputAccessoryView = toolBar;
        //        TextFieldSmoked.inputView = SmokedPicker
        toolBar.setItems([doneButton], animated: true)
        //        datePicker.datePickerMode = .dateAndTime
        
    }
    
    @objc func donePressedButton (){
        let formatter = DateFormatter()
        //formatter.dateStyle = .short
        formatter.dateFormat = "YYYY-MM-dd HH:mm"
        travelTimeDate = formatter.string(from: datePicker.date)
        let formatter1 = DateFormatter()
        formatter1.dateFormat = "YYYY-MM-dd"
        let loc1 = Locale(identifier: "us")
        formatter1.locale = loc1
        travelDate = formatter1.string(from: datePicker.date)
        let formatter2 = DateFormatter()
        formatter2.dateFormat = "HH:mm"
        let loc2 = Locale(identifier: "us")
        formatter2.locale = loc1
        travelTime = formatter2.string(from: datePicker.date)
        TextFieldTravelTime.text = travelTimeDate
        self.view.endEditing(true)
    }
    
    @objc func doneSmokedButton (){
        //        self.TextFieldSmoked.text = smokedString//"Yes"
        self.view.endEditing(true)
    }
    
    @objc func donePlatformButton (){
        self.TextFieldPlatform.text = PlatformString//"Yes"
        self.TextFieldPlatform2.text = PlatformString
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
        //         return SmokedPickerData.count
        return PlatformPickerData.count
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        //         TextFieldSmoked.text = SmokedPickerData[row]
        smokedString = SmokedPickerData[row]
        TextFieldPlatform2.text = PlatformPickerData[row]
        PlatformString = PlatformPickerData[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
        //         return SmokedPickerData[row]
        return PlatformPickerData[row]
    }
    
    func validateTextFields() -> Bool {
        if TextFieldPickupAddress.text?.count == 0 ||
            TextFieldDropAddress.text?.count == 0 {
            Common.showAlert(with: NSLocalizedString("Alert!!", comment: ""), message: NSLocalizedString("Please fill all the fields.", comment: ""), for: self)
            return false
        }
        else{
            return true
        }
    }
}

extension HomeViewController: UITableViewDelegate,UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rides.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RequestsCell") as! RequestsCell
        
        cell.Fromlbl.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "RequestsCell_Fromlbl", comment: "")
        cell.Tolbl.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "RequestsCell_Tolbl", comment: "")
        cell.Datelbl.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "RequestsCell_Datelbl", comment: "")
        cell.DriverNamelbl.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "RequestsCell_Namelbl", comment: "")
        
        // -- get current Rides Object --
        let currentObj = rides[indexPath.row]
        
        // -- set user name to cell --
        cell.name.text = currentObj.userName
        
        // -- set date and time to cell --
        let date = Common.instance.getFormattedDateOnly(date: currentObj.date)
        let time = Common.instance.getFormattedTimeOnly(date: currentObj.time)
        cell.dateLabel.text = date
        cell.timeLabel.text = time
        
        // -- set pickup location --
        let origin = currentObj.pickupAdress.components(separatedBy: ",")
        if origin.count > 1{
            cell.streetFrom.text = origin.first
            var addr = origin.dropFirst().joined(separator: ", ")
            cell.detailAdrsFrom.text = String(addr.dropFirst())
        }
        else{
            cell.streetFrom.text = origin.first
            cell.detailAdrsFrom.text = ""
        }
        
        // -- set drop location --
        let destination = currentObj.dropAdress.components(separatedBy: ",")
        if destination.count > 1{
            cell.streetTo.text = destination.first
            var addr = destination.dropFirst().joined(separator: ", ")
            cell.detailAdrsTo.text = String(addr.dropFirst())
        }
        else{
            cell.streetTo.text = destination.first
            cell.detailAdrsTo.text = ""
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("tableView clicked")
        // -- push to detail view with required data --
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "DetailReqViewController") as! DetailReqViewController
        vc.requestPage = RequestView.accepted
        vc.rideDetail = rides[indexPath.row]
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension HomeViewController: GMSAutocompleteViewControllerDelegate {
    
    // Handle the user's selection.
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        //    print("Place name: \(place.name)")
        //    print("Place address: \(place.formattedAddress)")
        //    print("Place attributions: \(place.attributions)")
        //    print("Place coordinate: \(place.coordinate)")
        dismiss(animated: true, completion: nil)
        if isPickup  {
            self.TextFieldPickupAddress.text = place.formattedAddress
            let pickupLat = place.coordinate.latitude
            let pickupLog = place.coordinate.longitude
            self.PickupLocation = "\(pickupLat),\(pickupLog)"
            isPickup = false
        }
        else if isDrop {
            self.TextFieldDropAddress.text = place.formattedAddress
            let pickupLat = place.coordinate.latitude
            let pickupLog = place.coordinate.longitude
            self.DropLocation = "\(pickupLat),\(pickupLog)"
            isDrop = false
        }
        else if isPickupPoint{
            if openAlert(){
                self.TextFieldPickupPoint.text = place.formattedAddress
                let pickupLat = place.coordinate.latitude
                let pickupLog = place.coordinate.longitude
                self.pickupPointLocation = "\(pickupLat),\(pickupLog)"
                isPickupPoint = false
                //                self.TextFieldTripPrice.text = self.TextFieldTripPrice.text
                //                self.TextFieldPassengersNum.text = self.TextFieldPassengersNum.text
                //                self.TextFieldPlatform2.text = self.TextFieldPlatform2.text
            }
        }
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        // TODO: handle the error.
        print("Error: \(error)")
        definesPresentationContext = true
        dismiss(animated: true, completion: nil)
    }
    
    // User cancelled the operation.
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        print("Autocomplete was cancelled.")
        definesPresentationContext = true
        dismiss(animated: true, completion: nil)
    }
}
