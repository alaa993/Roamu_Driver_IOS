import UIKit
import GoogleMaps
import GooglePlaces
import Alamofire
import Firebase

enum confirmRequestView: Int {
    case RequestsViewController
    case MapViewController
    case PlatformViewController
}

class ConfirmRideVC: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    // -- IBOutlets --
    var confirmRequestPage:confirmRequestView?
    
    @IBOutlet var DriverAvatar: UIImageView!
    
    
    @IBOutlet var driverName: UILabel!
    @IBOutlet var pickupLocation: UILabel!
    @IBOutlet var dropLocation: UILabel!
    
    @IBOutlet var driverCity: UILabel!
    @IBOutlet var time: UILabel!
    @IBOutlet var empty_Set_var: UILabel!
    @IBOutlet var date: UILabel!
    @IBOutlet var notes: UILabel!
    //    @IBOutlet var mapView: GMSMapView!
    
    @IBOutlet var Namelbl: UILabel!
    @IBOutlet var PickupAddlbl: UILabel!
    @IBOutlet var DropAddlbl: UILabel!
    
    @IBOutlet var Citylbl: UILabel!
    @IBOutlet var EmptySetlbl: UILabel!
    @IBOutlet var Timelbl: UILabel!
    //    @IBOutlet var PickupPointlbl: UILabel!
    @IBOutlet var datelbl: UILabel!
    @IBOutlet var notelbl: UILabel!
    
    
    @IBOutlet var confirmButton: UIButton!
    @IBOutlet var cancelButton: UIButton!
    
    // -- Instance Variables --
    var mapTasks = MapTasks()
    var originMarker: GMSMarker!
    var destinationMarker: GMSMarker!
    var rideData = [String:Any]()
    //var rideFare:Fare?
    //var ride:NearBy?
    var totalDistance:Double = 0.0
    
    var travel_id_var:String = "0"
    var rides = [Ride]()
    
    var TextFieldPlatform2: UITextField!
    var TextFieldPickupPoint: UITextField!
    var TextFieldPassengersNum: UITextField!
    var TextFieldTripPrice: UITextField!
    var enteredText = ""
    var amount = ""
    var pickUpPoint = ""
    var travelDate = ""
    var isPickupPoint = Bool()
    var pickupPointLocation = ""
    
    @objc let PlatformPicker = UIPickerView()
    let PlatformPickerData = [String](arrayLiteral: LocalizationSystem.sharedInstance.localizedStringForKey(key: "FindTravelVC_PlatformYes", comment: ""),LocalizationSystem.sharedInstance.localizedStringForKey(key: "FindTravelVC_PlatformNo", comment: ""))//["Yes","No"]
    var PlatformString = LocalizationSystem.sharedInstance.localizedStringForKey(key: "FindTravelVC_PlatformYes", comment: "")
    
    var PassengersStr = "Passenger"
    var PassengersCount = 1
    var bagsNotes = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        PlatformPicker.delegate = self
        createPlatformPicker()
        
        // Do any additional setup after loading the view.
        self.title = NSLocalizedString("Request Ride",comment: "")
        let backButton = UIBarButtonItem(image: UIImage(named: "arrow-left"),
                                         style: .plain,
                                         target: self,
                                         action: #selector(self.cancelWasClicked(_:)))
        self.navigationItem.leftBarButtonItem = backButton
        
        let homeButton = UIBarButtonItem(image: UIImage(named: "homeButton"),
                                         style: .plain,
                                         target: self,
                                         action: #selector(self.homeWasClicked(_:)))
        self.navigationItem.rightBarButtonItem = homeButton
        
        Namelbl.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "DetailReqVCNamelbl", comment: "")
        Citylbl.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "ConfirmRideVC_city", comment: "")
        //MobileNlbl.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "DetailReqVCMobileNlbl", comment: "")
        PickupAddlbl.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "DetailReqVCPickupAddlbl", comment: "")
        DropAddlbl.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "DetailReqVCDropAddlbl", comment: "")
        //
        Namelbl.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "DetailReqVCNamelbl", comment: "")
        PickupAddlbl.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "DetailReqVCPickupAddlbl", comment: "")
        DropAddlbl.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "DetailReqVCDropAddlbl", comment: "")
        
        Timelbl.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "DetailReqVCTimelbl", comment: "")//
        EmptySetlbl.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "DetailReqVCPassengersNlbl", comment: "")
        //        PickupPointlbl.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "DetailReqVCPickupPointlbl", comment: "")
        
        datelbl.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "DetailReqVCdatelbl", comment: "")
        
        notelbl.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "ConfirmRideVC_Notes", comment: "")
        
        //
        
        confirmButton.setTitle(LocalizationSystem.sharedInstance.localizedStringForKey(key: "ConfirmRideVC_confirmButton", comment: ""), for: .normal)
        cancelButton.setTitle(LocalizationSystem.sharedInstance.localizedStringForKey(key: "DetailReqVC_Cancel", comment: ""), for: .normal)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if confirmRequestPage == confirmRequestView.RequestsViewController
        {
            driverName.text = rideData["userName"] as? String ?? "" //ride?.userId
            pickupLocation.text = rideData["pickup"] as? String ?? ""
            dropLocation.text = rideData["drop"] as? String ?? ""
            
            self.driverCity.text = rideData["city"] as? String ?? ""
            //            self.PickUpPoint_Var.text = rideData["pickup_point"] as? String ?? ""
            self.empty_Set_var.text = rideData["booked_set"] as? String ?? ""
            self.date.text = rideData["travel_date"] as? String ?? ""
            self.time.text = rideData["travel_time"] as? String ?? ""
            self.notes.text = rideData["ride_notes"] as? String ?? ""
            
            if let urlString = URL(string: (rideData["userAvatar"] as? String ?? "")){
                self.DriverAvatar.kf.setImage(with: urlString)
            }
            //            vehicle.text = rideData["driverVehicle"] as? String ?? ""
            
        }
        else if confirmRequestPage == confirmRequestView.MapViewController
        {
            pickupLocation.text = rideData["pickup"] as? String
            dropLocation.text = rideData["drop"] as? String
        }
        else if confirmRequestPage == confirmRequestView.PlatformViewController
        {
            print(travel_id_var)
            let params = ["ride_id":travel_id_var]
            let headers = ["X-API-KEY":Common.instance.getAPIKey()]
            Alamofire.request(APIRouters.requested_ride_id_get(params,headers)).responseObject { (response: DataResponse<Rides>) in
                HUD.hide(to: self.view)
                if response.result.isSuccess{
                    if (response.result.value?.status == true && (response.result.value?.rides) != nil) {
                        print(response.result.value as Any)
                        self.rides = (response.result.value?.rides)!
                        if( self.rides.isEmpty){Common.showAlert(with: NSLocalizedString("Alert!!", comment: ""), message: "No data found.", for: self)}else{
                            self.driverName.text = self.rides[0].userName
                            self.pickupLocation.text = self.rides[0].pickupAdress
                            self.dropLocation.text = self.rides[0].dropAdress
                            self.driverCity.text = self.rides[0].city
                            //                        self.PickUpPoint_Var.text = self.rides[0].pickup_point
                            self.empty_Set_var.text = self.rides[0].bookedSeat
                            self.date.text = self.rides[0].date
                            self.time.text = self.rides[0].time
                            self.notes.text = self.rides[0].ride_notes
                            
                            if let urlString = URL(string: (self.rides[0].userAvatar)){
                                self.DriverAvatar.kf.setImage(with: urlString)
                            }
                        }}
                    else {
                        Common.showAlert(with: NSLocalizedString("Alert!!", comment: ""), message: "No data found.", for: self)
                    }
                }
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func homeWasClicked(_ sender: UIButton) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "HomeViewController") as! HomeViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func confirmWasClicked(_ sender: UIButton) {
        openAlert()
    }
    
    func openAlert() -> Bool {
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
                //                textField.keyboardType = UIKeyboardType.numberPad
                textField.keyboardType = .asciiCapableNumberPad
                
        })
        // trip price
        alertController!.addTextField(
            configurationHandler: {(textField: UITextField!) in
                //                    self.TextFieldTripPrice = textField
                textField.placeholder = NSLocalizedString(LocalizationSystem.sharedInstance.localizedStringForKey(key: "Trip price", comment: ""),comment: "")
                //                textField.keyboardType = UIKeyboardType.numberPad
                textField.keyboardType = .asciiCapableNumberPad
                
        })
        //notes
        alertController!.addTextField(
            configurationHandler: {(textField: UITextField!) in
                textField.placeholder = NSLocalizedString(LocalizationSystem.sharedInstance.localizedStringForKey(key: "notes_bags_weights", comment: ""),comment: "")
                //                textField.keyboardType = UIKeyboardType.numberPad
                textField.keyboardType = .default
                
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
                                        let empty_set = self!.empty_Set_var.text
                                        
                                        if theTextFields[1].text!.count == 0{
                                            self?.enteredText = "1"
                                        }
                                        else if Int(theTextFields[1].text!)! < Int(empty_set!)!
                                        {
                                            print("ibrahim 2")
                                            Common.showAlert(with: NSLocalizedString(LocalizationSystem.sharedInstance.localizedStringForKey(key: "ConfirmRideVC_Alert", comment: ""), comment: ""), message: NSLocalizedString(LocalizationSystem.sharedInstance.localizedStringForKey(key: "ConfirmRideVC_AlertDetail", comment: ""), comment: ""), for: self!)
                                            return
                                        }
                                        else{
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
                                        self?.bagsNotes = theTextFields[3].text!
                                        self!.confirmRequest()
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
    
    func handlePostButton(travel_id: NSNumber) {
        guard let userProfile = UserService.currentUserProfile else { return }
        
        let postRef = Database.database().reference().child("posts").childByAutoId()
        let postObject = [
            "author": [
                "uid": userProfile.uid,
                "username": userProfile.username,
                "photoURL": userProfile.photoURL.absoluteString
            ],
            "text": "\(LocalizationSystem.sharedInstance.localizedStringForKey(key: "Travel_is_going_from", comment: ""))\n\(LocalizationSystem.sharedInstance.localizedStringForKey(key: "Travel_from", comment: "")) \(pickupLocation.text!)\n\(LocalizationSystem.sharedInstance.localizedStringForKey(key: "Travel_to", comment: "")) \(dropLocation.text!)\n\(LocalizationSystem.sharedInstance.localizedStringForKey(key: "Travel_on", comment: "")) \(date.text!)\n\(LocalizationSystem.sharedInstance.localizedStringForKey(key: "the_clock", comment: ""))\(time.text!)",
            "timestamp": [".sv":"timestamp"],
            "type": "0",
            "privacy": "1",
            "travel_id": travel_id
            ] as [String:Any]
        postRef.setValue(postObject, withCompletionBlock: { error, ref in
            if error == nil {
            } else {
            }
        })
    }
    
    @objc func pickupPointFunction(textField: UITextField) {
        isPickupPoint = true
        dismiss(animated: true, completion: nil)
        print("ibrahim auto complete")
        autocompleteClicked()
    }
    
    func autocompleteClicked() {
        let acController = GMSAutocompleteViewController()
        acController.delegate = self
        present(acController, animated: true, completion: nil)
    }
    
    func createPlatformPicker(){
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        let doneButton = UIBarButtonItem(title: LocalizationSystem.sharedInstance.localizedStringForKey(key: "FindTravelVC_Done", comment: ""), style: UIBarButtonItem.Style.done, target: self, action: #selector(self.donePlatformButton))
        //        TextFieldPlatform2.inputAccessoryView = toolBar;
        //        TextFieldPlatform2.inputView = PlatformPicker
        toolBar.setItems([doneButton], animated: true)
        //        datePicker.datePickerMode = .dateAndTime
    }
    
    @objc func donePlatformButton (){
        self.TextFieldPlatform2.text = PlatformString
        self.view.endEditing(true)
        PlatformPicker.endEditing(true)
    }
    
    @objc func myTargetFunction(textField: UITextField) {
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        let doneButton = UIBarButtonItem(title: LocalizationSystem.sharedInstance.localizedStringForKey(key: "FindTravelVC_Done", comment: ""), style: UIBarButtonItem.Style.done, target: self, action: #selector(self.donePlatformButton))
        textField.inputAccessoryView = toolBar;
        textField.inputView = self.PlatformPicker
        toolBar.setItems([doneButton], animated: true)
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return PlatformPickerData.count
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        TextFieldPlatform2.text = PlatformPickerData[row]
        PlatformString = PlatformPickerData[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return PlatformPickerData[row]
    }
    
    @IBAction func cancelWasClicked(_ sender: UIButton) {
        _ = self.navigationController?.popToRootViewController(animated: true)
    }
    
    func getDirections(){
        mapTasks.getDirections(pickupLocation.text, destination: dropLocation.text, waypoints: nil, travelMode: nil) { (status, result, success) in
            if success {
                if let response = result {
                    self.configureMapAndMarkersForRoute(results: response)
                    self.totalDistance = response["distance"] as! Double
                    //                    self.distance.text = String(format: "%.2f", self.totalDistance) + " km"
                    if let polylines = response["polylines"] as? [String:Any],
                        let pts = polylines["points"] as? String{
                        self.drawRoute(points: pts)
                    }
                    //                    self.fare.text =  ""//String(format: "%.2f", (self.totalDistance * Double((self.rideFare?.cost)!)!)) + " " + (self.rideFare?.unit)!
                }
            } else {
                //                print(status)
                //                print(result?.description)
            }
        }
    }
    
    func confirmRequest(){
        
        if confirmRequestPage == confirmRequestView.RequestsViewController
        {
            // -- manage parameters --
            var parameters = [String:Any]()
            parameters["driver_id"] = Common.instance.getUserId()
            parameters["pickup_address"] =  rideData["pickup"] as? String ?? ""
            parameters["drop_address"] = rideData["drop"] as? String ?? ""
            parameters["pickup_location"] = rideData["pickup_location"] as? String ?? ""
            parameters["drop_location"] = rideData["drop_location"] as? String ?? ""
            parameters["pickup_point"] = self.pickUpPoint
            parameters["distance"] = "0"
            parameters["amount"] = self.amount
            parameters["available_set"] = self.enteredText
            parameters["booked_set"] = rideData["booked_set"] as? String ?? ""
            parameters["travel_date"] = rideData["travel_date"] as? String ?? ""
            parameters["travel_time"] = rideData["travel_time"] as? String ?? ""
            parameters["smoked"] = "1"
            parameters["status"] = "0"
            
            parameters["user_id"] = rideData["userId"] as? String ?? ""
            parameters["ride_id"] = rideData["rideId"]!
            parameters["ride_status"] = "WAITED"
            parameters["tr_notes"] = self.bagsNotes
            
            let headers = ["X-API-KEY":Common.instance.getAPIKey()]
            // -- show loading --
            HUD.show(to: view)
            // -- send request --
            APIRequestManager.request(apiRequest: APIRouters.confirm_requested_rides(parameters, headers), success: { (response) in
                // -- hide loading --
                HUD.hide(to: self.view)
                // -- parse response --
                if response is [String : Any] {
                    let alert = UIAlertController(title: NSLocalizedString("success",comment: ""), message: "", preferredStyle: .alert)
                    let done = UIAlertAction(title: NSLocalizedString("Done", comment: ""), style: .default, handler: { (action) in
                        if let data = response as? [String:Any] {
                            print(data["travel_id"]!);
                            //                    self.savePrivatePost(DriverId: data["user_id"]! as! String)
                            if self.TextFieldPlatform2.text  == LocalizationSystem.sharedInstance.localizedStringForKey(key: "FindTravelVC_PlatformYes", comment: "")
                            {
                                
                                self.handlePostButton(travel_id: data["travel_id"]! as! NSNumber )
                            }
                            self.addTravelToFireBase(travel_id: data["travel_id"]! as! NSNumber)
                            self.updateNotificationFirebase(with:"WAITED", ride_id:self.rideData["rideId"]! as! String, travel_id: (data["travel_id"]! as! NSNumber).stringValue, user_id:self.rideData["userId"] as! String)
                            self.deletePost(with:self.rideData["rideId"]! as! String)
                        }
                        _ = self.navigationController?.popToRootViewController(animated: true)
                        //                        let vc = self.storyboard?.instantiateViewController(withIdentifier: "RequestsViewController") as! RequestsViewController
                        //                        vc.requestPage = RequestView.pending
                        //                        vc.PlatformString = "PENDING"
                        //                        self.navigationController?.pushViewController(vc, animated: true)
                    })
                    self.updateRideFirebase(with:"WAITED", ride_id: self.rideData["rideId"]! as! String)
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
        else if confirmRequestPage == confirmRequestView.PlatformViewController
        {
            // -- manage parameters --
            let headers = ["X-API-KEY":Common.instance.getAPIKey()]
            
            var parameters = [String:Any]()
            parameters["driver_id"] = Common.instance.getUserId()
            parameters["pickup_address"] =   self.rides[0].pickupAdress
            parameters["drop_address"] = self.rides[0].dropAdress
            parameters["pickup_location"] = self.rides[0].pickLocation
            parameters["drop_location"] = self.rides[0].dropLocation
            parameters["pickup_point"] = self.pickUpPoint
            parameters["distance"] = "0"
            parameters["amount"] = self.amount
            parameters["available_set"] = self.enteredText
            parameters["booked_set"] = self.rides[0].bookedSeat
            parameters["travel_date"] = self.rides[0].date
            parameters["travel_time"] = self.rides[0].time
            parameters["smoked"] = "1"
            parameters["status"] = "0"
            
            parameters["user_id"] = self.rides[0].userId
            parameters["ride_id"] = self.rides[0].rideId
            parameters["ride_status"] = "WAITED"
            parameters["tr_notes"] = self.bagsNotes
            
            // -- show loading --
            HUD.show(to: view)
            // -- send request --
            APIRequestManager.request(apiRequest: APIRouters.confirm_requested_rides(parameters, headers), success: { (response) in
                // -- hide loading --
                HUD.hide(to: self.view)
                // -- parse response --
                if response is [String : Any] {
                    let alert = UIAlertController(title: NSLocalizedString("success",comment: ""), message: "", preferredStyle: .alert)
                    let done = UIAlertAction(title: NSLocalizedString("Done", comment: ""), style: .default, handler: { (action) in
                        if let data = response as? [String:Any] {
                            print(data["travel_id"]!);
                            //                    self.savePrivatePost(DriverId: data["user_id"]! as! String)
                            if self.TextFieldPlatform2.text  == LocalizationSystem.sharedInstance.localizedStringForKey(key: "FindTravelVC_PlatformYes", comment: "")
                            {
                                self.handlePostButton(travel_id: data["travel_id"]! as! NSNumber )
                            }
                            self.addTravelToFireBase(travel_id: data["travel_id"]! as! NSNumber)
                        }
                        _ = self.navigationController?.popViewController(animated: true)
                    })
                    self.updateRideFirebase(with:"WAITED", ride_id: self.rides[0].rideId)
                    self.updateNotificationFirebase(with:"WAITED", ride_id:self.rides[0].rideId, travel_id: self.rides[0].travelId, user_id:self.rides[0].userId)
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
    }
    
    func deletePost(with travel_id:String) {
        let commentsRef = Database.database().reference().child("posts")
        commentsRef.observe(.value, with: { snapshot in
            
            for child in snapshot.children {
                if let childSnapshot = child as? DataSnapshot,
                    let data = childSnapshot.value as? [String:Any],
                    let post = Post.parse(childSnapshot.key, data){
                    if (String(post.travel_id) == travel_id){
                        childSnapshot.ref.removeValue { error, _ in
                            print(error)
                        }
                    }
                }
            }
        })
    }
    
    func updateRideFirebase(with status:String, ride_id:String) {
        let postRef = Database.database().reference().child("rides").child(ride_id)
        let postObject = [
            "timestamp": [".sv":"timestamp"],
            "ride_status": status,
            "travel_status": "PENDING",
            "payment_status": "",
            "payment_mode": ""] as [String:Any]
        postRef.setValue(postObject, withCompletionBlock: { error, ref in
            if error == nil {
            } else {
            }
        })
    }
    
    func updateNotificationFirebase(with status:String, ride_id:String, travel_id:String, user_id:String) {
        let postRef = Database.database().reference().child("Notifications").child(user_id).childByAutoId()
        let postObject = [
            "ride_id": ride_id,
            "travel_id": travel_id,
            //            "text": LocalizationSystem.sharedInstance.localizedStringForKey(key: "Notification_accepted_request", comment: ""),
            "text": "request_approve",
            "readStatus": "0",
            "timestamp": [".sv":"timestamp"],
            "uid": Auth.auth().currentUser?.uid] as [String:Any]
        postRef.setValue(postObject, withCompletionBlock: { error, ref in
            if error == nil {
            } else {
            }
        })
    }
    
    func addTravelToFireBase(travel_id: NSNumber) {
        print("addTravelToFireBase")
        print(travel_id)
        
        guard let userProfile = UserService.currentUserProfile else { return }
        
        let postRef = Database.database().reference().child("Travels").child(travel_id.stringValue)
        let postObject = [
            "Counters":[
                "ACCEPTED":0,
                "COMPLETED":0,
                "OFFLINE":0,
                "PAID":0
            ],
            "driver_id": Common.instance.getUserId()
            ] as [String:Any]
        
        postRef.setValue(postObject, withCompletionBlock: { error, ref in
            if error == nil {
                print("error_nil")
            } else {
                print("error_else")
            }
        })
        
    }
    
    func configureMapAndMarkersForRoute(results:[String:Any]) {
        let originAddress = results["startLocation"] as! String
        let destinationAddress = results["endLocation"] as! String
        let originCoordinate = results["startCoordinate"] as! CLLocationCoordinate2D
        let destinationCoordinate = results["endCoordinate"] as! CLLocationCoordinate2D
        
        //        mapView.camera = GMSCameraPosition.camera(withTarget: originCoordinate, zoom: 12.0)
        originMarker = GMSMarker(position: originCoordinate)
        //        originMarker.map = mapView
        originMarker.icon = GMSMarker.markerImage(with: UIColor.red)
        originMarker.title = originAddress
        
        destinationMarker = GMSMarker(position: destinationCoordinate)
        //        destinationMarker.map = mapView
        destinationMarker.icon = GMSMarker.markerImage(with: UIColor.green)
        destinationMarker.title = destinationAddress
    }
    
    func drawRoute(points:String) {
        let path = GMSPath(fromEncodedPath: points)!
        let routePolyline = GMSPolyline(path: path)
        routePolyline.strokeWidth = 2.0
        //        routePolyline.map = mapView
    }
}

extension ConfirmRideVC: GMSAutocompleteViewControllerDelegate {
    
    // Handle the user's selection.
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        dismiss(animated: true, completion: nil)
        if isPickupPoint{
            if openAlert(){
                self.TextFieldPickupPoint.text = place.formattedAddress
                let pickupLat = place.coordinate.latitude
                let pickupLog = place.coordinate.longitude
                self.pickupPointLocation = "\(pickupLat),\(pickupLog)"
                isPickupPoint = false
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
