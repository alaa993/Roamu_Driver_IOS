import UIKit
import GoogleMaps
import Firebase
import MapboxDirections
import MapboxNavigation
import MapboxCoreNavigation
import Alamofire


class AcceptDetailReqViewController: UIViewController {
    
    @IBOutlet var mapView: GMSMapView!
    var mapTasks = MapTasks()
    var originMarker: GMSMarker!
    var destinationMarker: GMSMarker!
    var markerView = MarkerView()
    
    // -- IBOutlets --
    @IBOutlet var name: UILabel!
    @IBOutlet var pickupLoc: UILabel!
    @IBOutlet var dropLoc: UILabel!
    @IBOutlet var PickUpPoint: UILabel!
    @IBOutlet var date: UILabel!
    @IBOutlet var time: UILabel!
    
    @IBOutlet var Namelbl: UILabel!
    @IBOutlet var PickupAddlbl: UILabel!
    @IBOutlet var DropAddlbl: UILabel!
    @IBOutlet var PickupPointlbl: UILabel!
    @IBOutlet var datelbl: UILabel!
    @IBOutlet var Timelbl: UILabel!
    
    
    @IBOutlet var acceptButton: UIButton!
    @IBOutlet var cancelButton: UIButton!
    @IBOutlet var offlinePaymentButton: UIButton!
    
    // -- Instance variables --
    var requestPage:RequestView?
    var rideDetail:Ride?
    
    var travel_status = ""
    var paymentMode = ""
    var paymentStatus = ""
    
    var seeNewPostsButton:SeeNewPostsButton!
    var seeNewPostsButtonTopAnchor:NSLayoutConstraint!
    var postListenerHandle:UInt?
    
    var locationListenerHandle:UInt?
    var TravelListenerHandle:UInt?
    var latitude = 0.0
    var longitude = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = LocalizationSystem.sharedInstance.localizedStringForKey(key: "DetailReqVCTitle", comment: "")
        
        let homeButton = UIBarButtonItem(image: UIImage(named: "homeButton"),
                                         style: .plain,
                                         target: self,
                                         action: #selector(self.homeWasClicked(_:)))
        self.navigationItem.rightBarButtonItem = homeButton
        
        Namelbl.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "DetailReqVCNamelbl", comment: "")
        PickupAddlbl.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "DetailReqVCPickupAddlbl", comment: "")
        DropAddlbl.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "DetailReqVCDropAddlbl", comment: "")
        Timelbl.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "DetailReqVCTimelbl", comment: "")
        datelbl.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "DetailReqVCdatelbl", comment: "")
        PickupPointlbl.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "DetailReqVCPickupPointlbl", comment: "")
        
        var layoutGuide:UILayoutGuide!
        
        if #available(iOS 11.0, *) {
            layoutGuide = view.safeAreaLayoutGuide
        }
        else {
            // Fallback on earlier versions
            layoutGuide = view.layoutMarginsGuide
        }
        
        seeNewPostsButton = SeeNewPostsButton()
        seeNewPostsButton.button.setTitle(LocalizationSystem.sharedInstance.localizedStringForKey(key: "DetailReqVC_refreshButton", comment: ""), for: .normal)
        view.addSubview(seeNewPostsButton)
        seeNewPostsButton.translatesAutoresizingMaskIntoConstraints = false
        seeNewPostsButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        seeNewPostsButtonTopAnchor = seeNewPostsButton.topAnchor.constraint(equalTo: layoutGuide.topAnchor, constant: -44)
        seeNewPostsButtonTopAnchor.isActive = true
        seeNewPostsButton.heightAnchor.constraint(equalToConstant: 32.0).isActive = true
        seeNewPostsButton.widthAnchor.constraint(equalToConstant: seeNewPostsButton.button.bounds.width).isActive = true
        seeNewPostsButton.button.addTarget(self, action: #selector(handleRefresh), for: .touchUpInside)
        
        
        //
        self.travel_status = rideDetail?.Travel_Status as! String
        self.paymentMode = rideDetail?.paymentMode as! String
        self.paymentStatus = rideDetail?.paymentStatus as! String
        setupData()
        
        mapView.delegate = self
        
        // -- call required API --
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0 ) {
            // -- get current coordintes --
            let manager = LocationManager.sharedInstance
            self.latitude = manager.latitude
            self.longitude = manager.longitude
            self.loadData(with:self.latitude, longitude:self.longitude)
            self.listenForLocationUpdate()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        listenForNewRefresh()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func homeWasClicked(_ sender: UIButton) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "HomeViewController") as! HomeViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func setupData(){
        // -- setup title for button according to page requests --
        //        print("ibrahim from detail")
        print("travel status")
        print(travel_status)
        print("request page")
        print(requestPage!)
        
        if requestPage == RequestView.accepted {
            if (travel_status == "PENDING")
            {
                //                print("yes")
                acceptButton.setTitle(LocalizationSystem.sharedInstance.localizedStringForKey(key: "DetailReqVC_Start", comment: ""), for: .normal)
            }
            else
            {
                //                print("no")
                acceptButton.setTitle(LocalizationSystem.sharedInstance.localizedStringForKey(key: "DetailReqVC_Track", comment: ""), for: .normal)
                cancelButton.setTitle(LocalizationSystem.sharedInstance.localizedStringForKey(key: "DetailReqVC_Cancel", comment: ""), for: .normal)
            }
        }
        
        if requestPage == RequestView.pending {
            acceptButton.setTitle(LocalizationSystem.sharedInstance.localizedStringForKey(key: "DetailReqVC_Accept", comment: ""), for: .normal)
            cancelButton.setTitle(LocalizationSystem.sharedInstance.localizedStringForKey(key: "DetailReqVC_Cancel", comment: ""), for: .normal)
        }
        
        // Buttons
        if requestPage == RequestView.accepted || requestPage == RequestView.pending
        {
            if (travel_status == "PENDING")
            {
                //                print("buttons pending")
                cancelButton.isHidden = true
                acceptButton.isHidden = false
            }
            else
            {
                //                print("buttons not pending")
                acceptButton.isHidden = true
                cancelButton.isHidden = false
            }
        }
        else
        {
            //            print("buttons else")
            acceptButton.isHidden = true
            cancelButton.isHidden = true
        }
        
        // ibrahim commented on this code
        
        if requestPage == RequestView.cancelled || requestPage == RequestView.completed {
            //            print("request page cancelled or completed")
            offlinePaymentButton.isHidden = true
            acceptButton.isHidden = true
            cancelButton.isHidden = true
        }
        
        // -- setup back button --
        let backButton = UIBarButtonItem(image: UIImage(named: "arrow-left"),
                                         style: .plain, target: self,
                                         action: #selector(self.backWasPressed))
        self.navigationItem.leftBarButtonItem = backButton
        
        // -- setup ride data --
        name.text = rideDetail?.userName
        
        pickupLoc.text = rideDetail?.pickupAdress
        dropLoc.text = rideDetail?.dropAdress
        time.text = rideDetail?.time ?? ""
        date.text = rideDetail?.date ?? ""
        PickUpPoint.text = rideDetail?.pickup_point ?? ""
        
        // ibrahim was here
        // offline button
        if self.paymentMode != "OFFLINE"
        {
            offlinePaymentButton.isHidden = true
        }
        else
        {
            if (travel_status == "PENDING")
            {
                offlinePaymentButton.isHidden = true
            }
            else
            {
                offlinePaymentButton.isHidden = false
                offlinePaymentButton.setTitle(LocalizationSystem.sharedInstance.localizedStringForKey(key: "DetailReqVC_offlinePayment", comment: ""), for: .normal)
                if self.paymentStatus == "PAID"
                {
                    offlinePaymentButton.isHidden = true
                }
            }
        }
        
        if self.paymentStatus != "" {
            if self.paymentMode == "OFFLINE" && self.paymentStatus != "PAID" {
                acceptButton.isHidden = false
                cancelButton.isHidden = false
            }
            else {
                //----------------------------------------------
                // edit by ibrahim, to handle complete case
                //acceptButton.isHidden = true
                acceptButton.isHidden = false
                acceptButton.setTitle(LocalizationSystem.sharedInstance.localizedStringForKey(key: "DetailReqVC_Complete", comment: ""), for: .normal)
                //----------------------------------------------
                cancelButton.isHidden = true
            }
        }
        
        if requestPage == RequestView.cancelled || requestPage == RequestView.completed {
            //            print("request page cancelled or completed")
            offlinePaymentButton.isHidden = true
            acceptButton.isHidden = true
            cancelButton.isHidden = true
        }
        
    }
    
    func loadData(with latitude:Double, longitude:Double){
        
        
        // -- set camera position --
        let camera = GMSCameraPosition.camera(withLatitude: latitude,
                                              longitude: longitude,
                                              zoom:12)
        //        mapView.clear()
        mapView.animate(to: camera)
        mapView.isMyLocationEnabled = true
        getDirections()
        
    }
    
    @IBAction func acceptWasPressed(_ sender: UIButton) {
        if requestPage == RequestView.pending{
            sendRequests(with: "ACCEPTED")
            print("ACCEPTED")
        }
            //----------------------------------------------
            // edit by ibrahim, to handle complete case
        else if self.paymentMode == "OFFLINE" && self.paymentStatus == "PAID"
        {
            print("COMPLETED")
            sendRequests(with: "COMPLETED")
        }
            //----------------------------------------------
        else
        {
            if (rideDetail?.Travel_Status == "PENDING")
            {
                sendRequests(with: "ACCEPTED")
                //let vc
            }
            else
            {
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "TrackRideViewController") as! TrackRideViewController
                vc.currentRide = rideDetail
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    @IBAction func offlinePaymentWasPressed(_ sender: Any) {
        sendPaymentRequests(with: "PAID")
    }
    
    @IBAction func cancelWasPressed(_ sender: UIButton) {
        sendRequests(with: "CANCELLED")
    }
    
    @objc func backWasPressed(){
        _ = self.navigationController?.popToRootViewController(animated: true)
    }
    
    func sendRequests(with status:String){
        var params = [String:String]()
        if (requestPage == RequestView.accepted && travel_status == "PENDING")
        {
            print("sendRequests pending")
            travel_status = "STARTED"
            params = ["ride_id":rideDetail!.rideId,"status":status, "travel_id":rideDetail!.travelId, "travel_status":self.travel_status]
        }
        else
        {
            if status == "ACCEPTED"{
                print("status accepted")
                travel_status = "PENDING"
            }
            else if status == "COMPLETED"
            {
                travel_status = "COMPLETED"
            }
            else{
                print("status not accepted")
                travel_status = "PENDING" // for later to be fixed by ibrahim
            }
            print("sendRequests not pending")
            params = ["ride_id":rideDetail!.rideId,"status":status, "travel_id":rideDetail!.travelId, "travel_status":self.travel_status]
        }
        print("ibrahim before params")
        print(params)
        let headers = ["X-API-KEY":Common.instance.getAPIKey()]
        
        HUD.show(to: view)
        APIRequestManager.request(apiRequest: APIRouters.UpdateRides(params, headers), success: { (response) in
            HUD.hide(to: self.view)
            if response is String {
                let alert = UIAlertController(title: NSLocalizedString("Success!!", comment: ""), message: response as? String, preferredStyle: .alert)
                let done = UIAlertAction(title: NSLocalizedString("Done", comment: ""), style: .default, handler: { (action) in
                    //                    self.backWasPressed()
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "RequestsViewController") as! RequestsViewController
                    if status == "ACCEPTED"{
                        print("ibrahim_accepted")
                        vc.requestPage = RequestView.accepted
                        vc.PlatformString = "ACCEPTED"
                        self.updateTravelFirebase()
                    }
                    else if status == "COMPLETED"{
                        vc.requestPage = RequestView.completed
                        vc.PlatformString = "COMPLETED"
                    }
                    else if status == "CANCELLED"{
                        vc.requestPage = RequestView.cancelled
                        vc.PlatformString = "CANCELLED"
                    }
                    //self.navigationController?.pushViewController(vc, animated: true)
                })
                self.updateRideFirebase(with:status,travel_status: self.travel_status, paymentStatus: self.paymentStatus, paymentMode: self.paymentMode)
                self.updateNotificationFirebase(with:status)
                print(status)
                if status == "ACCEPTED"{
                    print("ibrahim_accepted")
                    self.updateTravelFirebase()
                }
                if status == "COMPLETED"{
                    print("ibrahim_accepted")
                    self.updateTravelFirebase()
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "HomeViewController") as! HomeViewController
                     self.navigationController?.pushViewController(vc, animated: true)
                }
                alert.addAction(done)
                
                self.present(alert, animated: true, completion: nil)
            }
        }, failure: { (message) in
            HUD.hide(to: self.view)
            Common.showAlert(with: NSLocalizedString("Alert!!", comment: ""), message: message, for: self)
        }, error: { (err) in
            HUD.hide(to: self.view)
            Common.showAlert(with: NSLocalizedString("Error!!" ,comment: ""), message: err.localizedDescription, for: self)
        })
    }
    
    func sendPaymentRequests(with status:String){
        let params = ["ride_id":rideDetail!.rideId,"payment_status":status]
        let headers = ["X-API-KEY":Common.instance.getAPIKey()]
        
        HUD.show(to: view)
        APIRequestManager.request(apiRequest: APIRouters.UpdateRides(params, headers), success: { (response) in
            HUD.hide(to: self.view)
            if response is String {
                let alert = UIAlertController(title: NSLocalizedString("Success!!", comment: ""), message: response as? String, preferredStyle: .alert)
                let done = UIAlertAction(title: NSLocalizedString("Done", comment: ""), style: .default, handler: { (action) in
                    //                    self.backWasPressed()
                })
                self.updateRideFirebase(with: self.requestPage!.rawValue, travel_status: self.travel_status, paymentStatus: status, paymentMode: self.paymentMode)
                self.updateNotificationFirebase(with: self.requestPage!.rawValue)
                alert.addAction(done)
                self.present(alert, animated: true, completion: nil)
            }
        }, failure: { (message) in
            HUD.hide(to: self.view)
            Common.showAlert(with: NSLocalizedString("Alert!!", comment: ""), message: message, for: self)
        }, error: { (err) in
            HUD.hide(to: self.view)
            Common.showAlert(with: NSLocalizedString("Error!!" ,comment: ""), message: err.localizedDescription, for: self)
        })
    }
    
    @objc func handleRefresh() {
        
        print("Refresh!")
        
        //        toggleSeeNewPostsButton(hidden: true)
    }
    
    func toggleSeeNewPostsButton(hidden:Bool) {
        if hidden {
            // hide it
            
            UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseOut, animations: {
                self.seeNewPostsButtonTopAnchor.constant = -44.0
                self.view.layoutIfNeeded()
            }, completion: nil)
        } else {
            // show it
            UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseOut, animations: {
                self.seeNewPostsButtonTopAnchor.constant = 12
                self.view.layoutIfNeeded()
            }, completion: nil)
        }
    }
    
    func listenForNewRefresh() {
        postListenerHandle = Database.database().reference().child("rides").child(rideDetail!.rideId).observe(.childChanged, with: { snapshot in
            print("ibrahim snapshot")
            
            print(snapshot.value)
            if let data = snapshot.value as? String{
                if snapshot.key == "ride_status"
                {
                    if data == "PENDING"
                    {
                        self.requestPage = RequestView.pending
                    }
                    else if data == "ACCEPTED"
                    {
                        self.requestPage = RequestView.accepted
                    }
                    else if data == "COMPLETED"
                    {
                        self.requestPage = RequestView.completed
                    }
                    else if data == "CANCELLED"
                    {
                        self.requestPage = RequestView.cancelled
                    }
                }
                else if snapshot.key == "travel_status"
                {
                    self.travel_status = data
                }
                else if snapshot.key == "payment_status"
                {
                    self.paymentStatus = data
                }
                else if snapshot.key == "payment_mode"
                {
                    self.paymentMode = data
                }
                else if snapshot.key == "timestamp"
                {
                    print("timestamp")
                }
                
                //self.toggleSeeNewPostsButton(hidden: false)
                self.setupData()
            }
        })
    }
    
    func listenForLocationUpdate(){
        Database.database().reference().child("Location").child(Common.instance.getUserId()).observeSingleEvent(of: .value, with: { snapshot in
            if let dict = snapshot.value as? [String:Any],
                let latitude_ = dict["latitude"] as? Double,
                let longitude_ = dict["longitude"] as? Double {
                self.loadData(with: latitude_, longitude: longitude_)
                
            }
            //            if let data = snapshot.value as? Double{
            //                if snapshot.key == "latitude"
            //                {
            //                    self.latitude = data
            //                }
            //                if snapshot.key == "longitude"
            //                {
            //                    self.longitude = data
            //                }
            //                self.loadData(with: self.latitude, longitude: self.longitude)
            //            }
            self.listenForFirebaseTravelUpdate()
        })
    }
    
    func listenForFirebaseTravelUpdate(){
        print("listenForFirebaseTravelUpdate")
        Database.database().reference().child("Travels").child(rideDetail!.travelId).child("Clients").observeSingleEvent(of: .value, with: { snapshot in
            //            print("snapshot")
            //            print(snapshot)
            for child in snapshot.children {
                //                print("child")
                //                print(child)
                if let childSnapshot = child as? DataSnapshot,
                    let data = childSnapshot.value as? String
                {
                    //                    print("client")
                    //                    print(data)
                    Database.database().reference().child("Location").child(data).observeSingleEvent(of: .value, with: { snapshot in
                        if let dict = snapshot.value as? [String:Any],
                            let latitude = dict["latitude"] as? Double,
                            let longitude = dict["longitude"] as? Double {
                            //                            print("ibrahim")
                            //                            print("latitude")
                            //                            print(latitude)
                            //                            print(longitude)
                            
                            let originCoordinate = CLLocationCoordinate2DMake(latitude, longitude)
                            let clientMarker = GMSMarker(position: originCoordinate)
                            clientMarker.map = self.mapView
                            clientMarker.icon = GMSMarker.markerImage(with: UIColor.blue)
                            clientMarker.title = "User"
                        }
                    })
                }
            }
        })
    }
    
    func updateRideFirebase(with status:String, travel_status:String, paymentStatus:String, paymentMode:String) {
        let postRef = Database.database().reference().child("rides").child(rideDetail!.rideId)
        let postObject = [
            "timestamp": [".sv":"timestamp"],
            "ride_status": status,
            "travel_status": travel_status,
            "payment_status": paymentStatus,
            "payment_mode": paymentMode] as [String:Any]
        postRef.setValue(postObject, withCompletionBlock: { error, ref in
            if error == nil {
            } else {
            }
        })
    }
    
    func updateNotificationFirebase(with status:String) {
        let postRef = Database.database().reference().child("Notifications").child(rideDetail!.userId).childByAutoId()
        let postObject = [
            "ride_id": rideDetail!.rideId,
            "text": LocalizationSystem.sharedInstance.localizedStringForKey(key: "Notification_ride_updated", comment: "") + status,
            //"Ride Updated",
            "readStatus": "0",
            "timestamp": [".sv":"timestamp"],
            "uid": Auth.auth().currentUser?.uid] as [String:Any]
        postRef.setValue(postObject, withCompletionBlock: { error, ref in
            if error == nil {
            } else {
            }
        })
    }
    
    func updateTravelFirebase() {
        print("updateTravelFirebase")
        let postRef = Database.database().reference().child("Travels").child(rideDetail!.travelId).child("Clients").child(rideDetail!.userId)
        postRef.setValue(rideDetail!.userId, withCompletionBlock: { error, ref in
            if error == nil {
            } else {
            }
        })
    }
    
    // mapView
    func getDirections(){
        mapTasks.getDirections(rideDetail?.pickLocation, destination: rideDetail?.dropLocation, waypoints: nil, travelMode: nil) { (status, result, success) in
            if success {
                if let response = result {
                    self.configureMapAndMarkersForRoute(results: response)
                    //                    self.totalDistance = response["distance"] as! Double
                    //                    self.distance.text = String(format: "%.2f", self.totalDistance) + " km"
                    if let polylines = response["polylines"] as? [String:Any],
                        let pts = polylines["points"] as? String{
                        self.drawRoute(points: pts)
                    }
                    //                    self.fare.text =   String(format: "%.2f", (self.totalDistance * Double((self.rideFare?.cost)!)!)) + " " + (self.rideFare?.unit)!
                }
            } else {
                //print(status)
                //print(result?.description)
            }
        }
    }
    
    func configureMapAndMarkersForRoute(results:[String:Any]) {
        let originAddress = results["startLocation"] as! String
        let destinationAddress = results["endLocation"] as! String
        let originCoordinate = results["startCoordinate"] as! CLLocationCoordinate2D
        let destinationCoordinate = results["endCoordinate"] as! CLLocationCoordinate2D
        
        mapView.camera = GMSCameraPosition.camera(withTarget: originCoordinate, zoom: 12.0)
        originMarker = GMSMarker(position: originCoordinate)
        originMarker.map = mapView
        originMarker.icon = GMSMarker.markerImage(with: UIColor.red)
        originMarker.title = originAddress
        
        destinationMarker = GMSMarker(position: destinationCoordinate)
        destinationMarker.map = mapView
        destinationMarker.icon = GMSMarker.markerImage(with: UIColor.green)
        destinationMarker.title = destinationAddress
    }
    
    func drawRoute(points:String) {
        let path = GMSPath(fromEncodedPath: points)!
        let routePolyline = GMSPolyline(path: path)
        routePolyline.strokeWidth = 2.0
        routePolyline.map = mapView
    }
}
extension AcceptDetailReqViewController:GMSMapViewDelegate,UITextFieldDelegate {
    
    func mapView(_ mapView: GMSMapView, markerInfoWindow marker: GMSMarker) -> UIView? {
        markerView = MarkerView.loadFromNib()
        markerView.titleText.text = marker.title
        markerView.descriptionText.text = marker.snippet
        return markerView
    }
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        //        removeUnwantedViews()
        return false
    }
    
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        UIView.animate(withDuration: 0.4, animations: {
            //            self.infoView.layer.position.y += 200
            //            self.pickupView.layer.position.y -= 150
        }) { (finished) in
            if finished {
                //                self.infoView.removeFromSuperview()
                //                self.pickupView.removeFromSuperview()
            }
        }
    }
    
    func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker) {
    }
}
