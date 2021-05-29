//
//  AddTravelViewController.swift
//  Taxi
//
//  Created by Syria.Apple on 4/11/20.
//  Copyright © 2020 icanStudioz. All rights reserved.
//

import UIKit
import Firebase

class AddTravelViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, UITextViewDelegate, isAbleToReceiveData {
    
    @IBOutlet var TextFieldPickupAddress: UITextField!
    @IBOutlet var TextFieldDropAddress: UITextField!
    @IBOutlet var TextFieldAmount: UITextField!
    @IBOutlet var TextFieldBookedSet: UITextField!
    @IBOutlet var TextFieldTravelTime: UITextField!
    @IBOutlet var TextFieldSmoked: UITextField!
    @IBOutlet var TextFieldPlatform: UITextField!
    
    @IBOutlet var AddTravelButton: UIButton!
    var travelTimeDate = ""
    var travelTime = ""
    
    let datePicker = UIDatePicker()
    
    var isPickup = Bool()
    var isDrop = Bool()
    var PickupLocation = ""
    var DropLocation = ""
    
    var delegate:NewPostVCDelegate?
    
    @objc let SmokedPicker = UIPickerView()
    let SmokedPickerData = [String](arrayLiteral: LocalizationSystem.sharedInstance.localizedStringForKey(key: "FindTravelVC_SmokedYes", comment: ""),LocalizationSystem.sharedInstance.localizedStringForKey(key: "FindTravelVC_SmokedNo", comment: ""))//["Yes","No"]
    var smokedString = LocalizationSystem.sharedInstance.localizedStringForKey(key: "FindTravelVC_SmokedYes", comment: "")
    
    @objc let PlatformPicker = UIPickerView()
    let PlatformPickerData = [String](arrayLiteral: LocalizationSystem.sharedInstance.localizedStringForKey(key: "FindTravelVC_PlatformYes", comment: ""),LocalizationSystem.sharedInstance.localizedStringForKey(key: "FindTravelVC_PlatformNo", comment: ""))//["Yes","No"]
    var PlatformString = LocalizationSystem.sharedInstance.localizedStringForKey(key: "FindTravelVC_PlatformYes", comment: "")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = LocalizationSystem.sharedInstance.localizedStringForKey(key: "AddTravelVC_Title", comment: "")
        
        let backButton = UIBarButtonItem(image: UIImage(named: "arrow-left"),
                                         style: .plain,
                                         target: self,
                                         action: #selector(AddTravelViewController.cancelWasClicked(_:)))
        self.navigationItem.leftBarButtonItem = backButton
        
        
        
        TextFieldPickupAddress.cornerRadius(radius: 20.0, andPlaceholderString: NSLocalizedString(LocalizationSystem.sharedInstance.localizedStringForKey(key: "FindTravelVC_Pickup_Add", comment: ""),comment: ""))
        TextFieldPickupAddress.paddedTextField(frame: CGRect(x: 0, y: 0, width: 25, height: TextFieldPickupAddress.frame.height))
        
        TextFieldDropAddress.cornerRadius(radius: 20.0, andPlaceholderString: NSLocalizedString(LocalizationSystem.sharedInstance.localizedStringForKey(key: "FindTravelVC_Drop_Add", comment: ""),comment: ""))
        TextFieldDropAddress.paddedTextField(frame: CGRect(x: 0, y: 0, width: 25, height: TextFieldDropAddress.frame.height))
        
        TextFieldAmount.cornerRadius(radius: 20.0, andPlaceholderString: NSLocalizedString(LocalizationSystem.sharedInstance.localizedStringForKey(key: "AddTravelVC_Amount", comment: ""),comment: ""))
        TextFieldAmount.paddedTextField(frame: CGRect(x: 0, y: 0, width: 25, height: TextFieldAmount.frame.height))
        
        TextFieldBookedSet.cornerRadius(radius: 20.0, andPlaceholderString: NSLocalizedString(LocalizationSystem.sharedInstance.localizedStringForKey(key: "AddTravelVC_BookedSet", comment: ""),comment: ""))
        TextFieldBookedSet.paddedTextField(frame: CGRect(x: 0, y: 0, width: 25, height: TextFieldBookedSet.frame.height))
        
        TextFieldTravelTime.cornerRadius(radius: 20.0, andPlaceholderString: NSLocalizedString(LocalizationSystem.sharedInstance.localizedStringForKey(key: "FindTravelVC_TravelTime", comment: ""),comment: ""))
        TextFieldTravelTime.paddedTextField(frame: CGRect(x: 0, y: 0, width: 25, height: TextFieldTravelTime.frame.height))
        
        TextFieldSmoked.cornerRadius(radius: 20.0, andPlaceholderString: NSLocalizedString(LocalizationSystem.sharedInstance.localizedStringForKey(key: "FindTravelVC_Smoked", comment: ""),comment: ""))
        TextFieldSmoked.paddedTextField(frame: CGRect(x: 0, y: 0, width: 25, height: TextFieldSmoked.frame.height))
        TextFieldSmoked.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "FindTravelVC_SmokedNo", comment: "")
        
        TextFieldPlatform.cornerRadius(radius: 20.0, andPlaceholderString: NSLocalizedString(LocalizationSystem.sharedInstance.localizedStringForKey(key: "FindTravelVC_Platform", comment: ""),comment: ""))
        TextFieldPlatform.paddedTextField(frame: CGRect(x: 0, y: 0, width: 25, height: TextFieldSmoked.frame.height))
        TextFieldPlatform.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "FindTravelVC_PlatformNo", comment: "")
        AddTravelButton.corner(radius: 20.0, color: UIColor.white, width: 1.0)
        
        AddTravelButton.setTitle(LocalizationSystem.sharedInstance.localizedStringForKey(key: "FindTravelVC_AddTravel", comment: ""), for: .normal)
        
        //Looks for single or multiple taps.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        SmokedPicker.delegate = self
        createDatePicker()
        createSmokedPicker()
        
        PlatformPicker.delegate = self
        createPlatformPicker()
        
        // Do any additional setup after loading the view.
    }
    
    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    @IBAction func cancelWasClicked(_ sender: UIButton) {
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func AddTravelButton(_ sender: UIButton) {
        self.AddTravel_Func();
        if self.TextFieldPlatform.text  == LocalizationSystem.sharedInstance.localizedStringForKey(key: "FindTravelVC_PlatformYes", comment: "")
        {
            self.handlePostButton()
        }
    }
    
    func pass(ResultSearchDictionary: [String : Any]!) {
        
        if isPickup  {
            TextFieldPickupAddress.text = (ResultSearchDictionary["title"] as! String)
            let pickupLat = ResultSearchDictionary["latitude"]!
            let pickupLog = ResultSearchDictionary["longitude"]!
            PickupLocation = "\(pickupLat),\(pickupLog)"
            isPickup = false
            
        } else if isDrop {
            TextFieldDropAddress.text = (ResultSearchDictionary["title"] as! String)
            let pickupLat = ResultSearchDictionary["latitude"]!
            let pickupLog = ResultSearchDictionary["longitude"]!
            DropLocation = "\(pickupLat),\(pickupLog)"
            isDrop = false
        }
    }
    
    @IBAction func TextFieldPickupAddressTouchDown(_ sender: Any) {
        isPickup = true
        autocompleteClicked()
    }
    
    @IBAction func TextFieldDropAddressTouchDown(_ sender: Any) {
        isDrop = true
        autocompleteClicked()
    }
    
    func autocompleteClicked() {
        let SearchViewController_ = self.storyboard?.instantiateViewController(withIdentifier: "SearchViewController") as!
        SearchViewController
        //SearchViewController_.delegate = self
        SearchViewController_.modalPresentationStyle = .fullScreen
        self.present(SearchViewController_, animated: true, completion: nil)
    }
    
    // by ibrahim
    func AddTravel_Func(){
        if self.validateTextFields() {
            var smoked_string = 0
            if TextFieldSmoked.text! == LocalizationSystem.sharedInstance.localizedStringForKey(key: "FindTravelVC_SmokedYes", comment: "")
            {
                smoked_string = 1
            }
            else
            {
                smoked_string = 0
            }
            // -- manage parameters --
            var parameters = [String:Any]()
            parameters["driver_id"] = Common.instance.getUserId()
            parameters["pickup_address"] =  TextFieldPickupAddress.text
            parameters["drop_address"] = TextFieldDropAddress.text //"Maysat"
            parameters["pickup_location"] = PickupLocation//TextFieldPickupAddress.text  //"Maysat"
            parameters["drop_location"] = DropLocation//TextFieldDropAddress.text //"Maysat"
            parameters["distance"] = "0"
            parameters["amount"] = TextFieldAmount.text
            parameters["available_set"] = TextFieldBookedSet.text // at least equals to the number of booked Set
            parameters["booked_set"] = "0"
            parameters["travel_date"] = travelTimeDate
            parameters["smoked"] = smoked_string
            parameters["status"] = 0
            
            let headers = ["X-API-KEY":Common.instance.getAPIKey()]
            // -- show loading --
            HUD.show(to: view)
            
            // -- send request --
            APIRequestManager.request(apiRequest: APIRouters.AddTravel(parameters, headers), success: { (response) in
                // -- hide loading --
                HUD.hide(to: self.view)
                print("start")
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
    
    func handlePostButton() {
        
        guard let userProfile = UserService.currentUserProfile else { return }
        // Firebase code here
        
        let postRef = Database.database().reference().child("posts").childByAutoId()
        
        let postObject = [
            "author": [
                "uid": userProfile.uid,
                "username": userProfile.username,
                "photoURL": userProfile.photoURL.absoluteString
            ],
            "text": "\(userProfile.username) is going from \(TextFieldPickupAddress.text!) to \(TextFieldDropAddress.text!) on \(travelTime) \(travelTimeDate)" ,
            "timestamp": [".sv":"timestamp"],
            "type": "0",
            "travel_id": 0,
            "privacy": "1"
        ] as [String:Any]
        
        postRef.setValue(postObject, withCompletionBlock: { error, ref in
            if error == nil {
                self.delegate?.didUploadPost(withID: ref.key!)
                self.dismiss(animated: true, completion: nil)
            } else {
                // Handle the error
            }
        })
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
    
    func createSmokedPicker(){
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        let doneButton = UIBarButtonItem(title: LocalizationSystem.sharedInstance.localizedStringForKey(key: "FindTravelVC_Done", comment: ""), style: UIBarButtonItem.Style.done, target: self, action: #selector(doneSmokedButton))
        TextFieldSmoked.inputAccessoryView = toolBar;
        TextFieldSmoked.inputView = SmokedPicker
        toolBar.setItems([doneButton], animated: true)
//        datePicker.datePickerMode = .dateAndTime
    }
    
    func createPlatformPicker(){
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        let doneButton = UIBarButtonItem(title: LocalizationSystem.sharedInstance.localizedStringForKey(key: "FindTravelVC_Done", comment: ""), style: UIBarButtonItem.Style.done, target: self, action: #selector(donePlatformButton))
        TextFieldPlatform.inputAccessoryView = toolBar;
        TextFieldPlatform.inputView = PlatformPicker
        toolBar.setItems([doneButton], animated: true)
//        datePicker.datePickerMode = .dateAndTime
    }
    
    @objc func donePressedButton (){
        let formatter = DateFormatter()
        //formatter.dateStyle = .short
        formatter.dateFormat = "YYYY-MM-dd HH:mm:ss"
        let loc = Locale(identifier: "us")
        formatter.locale = loc
        travelTimeDate = formatter.string(from: datePicker.date)
        TextFieldTravelTime.text = travelTimeDate
        self.view.endEditing(true)
    }
    
    @objc func doneSmokedButton (){
        self.TextFieldSmoked.text = smokedString//"Yes"
        self.view.endEditing(true)
    }
    
    @objc func donePlatformButton (){
        self.TextFieldPlatform.text = PlatformString//"Yes"
        self.view.endEditing(true)
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        if pickerView == SmokedPicker
        {
            return 1
        }
        else{
            return 1
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        if pickerView == SmokedPicker
        {
            return 1
        }
        else{
            return 1
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == SmokedPicker
        {
            return SmokedPickerData.count
        }
        else{
            return PlatformPickerData.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == SmokedPicker
        {
            TextFieldSmoked.text = SmokedPickerData[row]
            smokedString = SmokedPickerData[row]
        }
        else
        {
            TextFieldPlatform.text = PlatformPickerData[row]
            PlatformString = PlatformPickerData[row]
        }
        
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
        
        if pickerView == SmokedPicker
        {
            return SmokedPickerData[row]
        }
        else
        {
            return PlatformPickerData[row]
        }
    }
    
    func validateTextFields() -> Bool {
        if TextFieldPickupAddress.text?.count == 0 ||
            TextFieldDropAddress.text?.count == 0 ||
            TextFieldAmount.text?.count == 0 ||
            TextFieldBookedSet.text?.count == 0 ||
            TextFieldTravelTime.text?.count == 0 ||
            TextFieldSmoked.text?.count == 0 {
            Common.showAlert(with: NSLocalizedString("Alert!!", comment: ""), message: NSLocalizedString("Please fill all the fields.", comment: ""), for: self)
            return false
        }
        else{
            return true
        }
    }
    
}
