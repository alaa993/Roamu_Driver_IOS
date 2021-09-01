//
//  TravelsDetailReqViewController.swift
//  TaxiDriver
//
//  Created by ibrahim.marie on 3/30/21.
//  Copyright © 2021 icanStudioz. All rights reserved.
//

import UIKit
import GoogleMaps
import Firebase
import MapboxDirections
import MapboxNavigation
import MapboxCoreNavigation
import Alamofire

class TravelsDetailReqViewController: UIViewController {
    
    @IBOutlet var startCompleteButton: UIButton!
    @IBOutlet var cancelButton: UIButton!
    
    @IBOutlet var notesButton: UIButton!
    
    @IBOutlet var tableView: UITableView!
    var rides = [Ride]()
    var rides1 = [Ride]()
    var rides2 = [Ride]()
    var travels = [Travel]()
    
    @IBOutlet var mapView: GMSMapView!
    var mapTasks = MapTasks()
    var originMarker: GMSMarker!
    var destinationMarker: GMSMarker!
    var markerView = MarkerView()
    
    var travelDetail:DriverTravel?
    
    var locationListenerHandle:UInt?
    var TravelListenerHandle:UInt?
    var latitude = 0.0
    var longitude = 0.0
    var didAllPaid = false
    var travel_status_st = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = LocalizationSystem.sharedInstance.localizedStringForKey(key: "DetailReqVCTitle", comment: "")
        
        let homeButton = UIBarButtonItem(image: UIImage(named: "homeButton"),
                                         style: .plain,
                                         target: self,
                                         action: #selector(self.homeWasClicked(_:)))
        self.navigationItem.rightBarButtonItem = homeButton
        
        startCompleteButton.setTitle(LocalizationSystem.sharedInstance.localizedStringForKey(key: "DetailReqVC_Start", comment: ""), for: .normal)
        cancelButton.setTitle(LocalizationSystem.sharedInstance.localizedStringForKey(key: "DetailReqVC_Cancel", comment: ""), for: .normal)
        
        var layoutGuide:UILayoutGuide!
        
        if #available(iOS 11.0, *) {
            layoutGuide = view.safeAreaLayoutGuide
        }
        else {
            // Fallback on earlier versions
            layoutGuide = view.layoutMarginsGuide
        }
        
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
    
    override func viewWillAppear(_ animated: Bool){
        travel_status_st = travelDetail?.Travel_Status as! String
        print("ibrahim123")
        print(travel_status_st)
        self.listenTravelFirebase(travel_id: travelDetail!.travel_id)
        setupData()
        loadRequests(with: "All")
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
        print("setupData")
        print(travel_status_st)
        if (travel_status_st == "PENDING")
        {
            startCompleteButton.isHidden = false
            cancelButton.isHidden = false
            startCompleteButton.setTitle(LocalizationSystem.sharedInstance.localizedStringForKey(key: "DetailReqVC_Start", comment: ""), for: .normal)
        }
        else if (travel_status_st == "CANCELLED")
        {
            startCompleteButton.isHidden = true
            cancelButton.isHidden = true
        }
        else if (travel_status_st == "COMPLETED")
        {
            startCompleteButton.isHidden = true
            cancelButton.isHidden = true
        }
        else if (travel_status_st == "STARTED")
        {
            checkPayments()
        }
        else if (travel_status_st == "PAID")
        {
            self.startCompleteButton.isHidden = false
            self.cancelButton.isHidden = true
            self.startCompleteButton.setTitle(LocalizationSystem.sharedInstance.localizedStringForKey(key: "DetailReqVC_Complete", comment: ""), for: .normal)
        }
    }
    
    func loadRequests(with status:String){
        let params = ["driver_id":Common.instance.getUserId(),"travel_id":travelDetail!.travel_id,"status":"All"]
        let headers = ["X-API-KEY":Common.instance.getAPIKey()]
        //            print(Common.instance.getUserId())
        //HUD.show(to: view)
        _ = Alamofire.request(APIRouters.driver_specific_travel(params,headers)).responseObject { (response: DataResponse<Rides>) in
            //hud.hide(to: self.view)
            print("ibrahim was here")
            print(response)
            if response.result.isSuccess{
                self.rides.removeAll()
                //                self.tableView.reloadData()
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
    
    func checkPayments(){
        print("checkPayments")
        print(travelDetail!.travel_id)
        print(travelDetail!.Travel_Status)
        
        var params = [String:String]()
        params = ["travel_id":travelDetail!.travel_id]
        let headers = ["X-API-KEY":Common.instance.getAPIKey()]
        
        //HUD.show(to: view)
        APIRequestManager.request(apiRequest: APIRouters.checkallpayments(params, headers), success: { (response) in
            print("response")
            print(response)
            //hud.hide(to: self.view)
            if let data = response as? String {
                print("data3")
                print(data);
                if data == "true"{
                    self.startCompleteButton.isHidden = false
                    self.cancelButton.isHidden = true
                    self.startCompleteButton.setTitle(LocalizationSystem.sharedInstance.localizedStringForKey(key: "DetailReqVC_Approve_All", comment: ""), for: .normal)
                    self.didAllPaid = true
                }else{
                    self.didAllPaid = false
                    self.startCompleteButton.isHidden = false
                    self.cancelButton.isHidden = true
                    self.startCompleteButton.isHidden = true
                }
            }
        }, failure: { (message) in
            //hud.hide(to: self.view)
            //            Common.showAlert(with: NSLocalizedString("Alert!!", comment: ""), message: message, for: self)
        }, error: { (err) in
            //hud.hide(to: self.view)
            //            Common.showAlert(with: NSLocalizedString("Error!!" ,comment: ""), message: err.localizedDescription, for: self)
        })
        
    }
    
    func approvePayment(){
        print("approvePayment")
        print(travelDetail!.travel_id)
        print(travelDetail!.Travel_Status)
        
        var params = [String:String]()
        params = ["travel_id":travelDetail!.travel_id]
        let headers = ["X-API-KEY":Common.instance.getAPIKey()]
        
        //HUD.show(to: view)
        _ = Alamofire.request(APIRouters.approve_payments(params,headers)).responseObject { (response: DataResponse<Rides>) in
            //hud.hide(to: self.view)
            if response.result.isSuccess{
                if response.result.value?.status == true , ((response.result.value?.rides) != nil) {
                    self.rides = (response.result.value?.rides)!
                    print("rides")
                    print(self.rides)
                    //
                    for ride in self.rides {
                        print("1")
                        print(ride.rideId)
                        print(ride.Travel_Status)
                        print(ride.paymentMode)
                        print(ride.paymentStatus)
                        self.travel_status_st = "PAID"
                        self.updateRideFirebase(with: ride.rideId, status: ride.status, travel_status: self.travel_status_st, paymentStatus: ride.paymentStatus, paymentMode: ride.paymentMode)
                        self.updateNotificationFirebase(with:"offline_approved",userId: ride.userId, rideId: ride.rideId,  travelId: self.travelDetail!.travel_id)
                    }
                    self.updateTravelCounterFirebase(with: "COMPLETED", travel_id: self.travelDetail!.travel_id)
                    //
                    let alert = UIAlertController(title: NSLocalizedString("Success!!",comment: ""), message: "", preferredStyle: .alert)
                    
                    let done = UIAlertAction(title: NSLocalizedString("Done", comment: ""), style: .default, handler: { (action) in
                        self.startCompleteButton.isHidden = false
                        self.cancelButton.isHidden = true
                        self.startCompleteButton.setTitle(LocalizationSystem.sharedInstance.localizedStringForKey(key: "DetailReqVC_Complete", comment: ""), for: .normal)
                        
                    })
                    alert.addAction(done)
                    self.present(alert, animated: true, completion: nil)
                }
                else{
                    Common.showAlert(with: NSLocalizedString("Alert!!", comment: ""), message: NSLocalizedString("No data found.", comment: ""), for: self)
                }
            }
            
            if response.result.isFailure{
                Common.showAlert(with: NSLocalizedString("Error!!" ,comment: ""), message: response.error?.localizedDescription, for: self)
            }
        }
    }
    
    @IBAction func startCompleteWasPressed(_ sender: UIButton) {
        if travel_status_st == "PENDING"{
            print("STARTED")
            sendRequests(with: "STARTED")
        }
        else if travel_status_st == "STARTED"
        {
            if didAllPaid == true
            {
                self.approvePayment()
            }
        }
        else if travel_status_st == "PAID"
        {
            print("COMPLETED")
            sendRequests(with: "COMPLETED")
            deletePost()
        }
    }
    
    @IBAction func cancelWasPressed(_ sender: UIButton) {
        sendRequests(with: "CANCELLED")
    }
    
    @IBAction func notesWasPressed(_ sender: UIButton) {
        print("ibrahim")
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "TravelsNotesReqViewController") as! TravelsNotesReqViewController
        vc.travel_id = travelDetail!.travel_id
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
    func sendRequests(with status:String){
        print("sendRequests")
        print("status")
        print(status)
        
        print(travelDetail!.travel_id)
        print(travelDetail!.Travel_Status)
        
        var params = [String:String]()
        params = ["travel_id":travelDetail!.travel_id, "travel_status":status]
        let headers = ["X-API-KEY":Common.instance.getAPIKey()]
        //HUD.show(to: view)
        _ = Alamofire.request(APIRouters.driverRidesUpdate(params,headers)).responseObject { (response: DataResponse<Rides>) in
            //hud.hide(to: self.view)
            if response.result.isSuccess{
                if response.result.value?.status == true , ((response.result.value?.rides) != nil) {
                    self.rides1 = (response.result.value?.rides)!
                    print("rides")
                    print(self.rides1)
                    for ride in self.rides1 {
                        self.updateRideFirebase(with: ride.rideId, status: ride.status, travel_status: status, paymentStatus: ride.paymentStatus, paymentMode: ride.paymentMode)
                        self.updateNotificationFirebase(with:status, userId: ride.userId, rideId: ride.rideId, travelId: self.travelDetail!.travel_id)
                        if status == "COMPLETED" || status == "CANCELLED"{
                            self.deleteNotificationFirebase(with: ride.userId);
                            self.deleteNotificationFirebase(with: ride.driverId);
                        }
                    }
                    self.updateTravelCounterFirebase(with: "COMPLETED", travel_id: self.travelDetail!.travel_id)
                    let alert = UIAlertController(title: NSLocalizedString("Success!!",comment: ""), message: "", preferredStyle: .alert)
                    let done = UIAlertAction(title: NSLocalizedString("Done", comment: ""), style: .default, handler: { (action) in
                        self.travel_status_st = status
                        self.setupData()
                    })
                    alert.addAction(done)
                    self.present(alert, animated: true, completion: nil)
                }
                else{
                    Common.showAlert(with: NSLocalizedString("Alert!!", comment: ""), message: NSLocalizedString("No data found.", comment: ""), for: self)
                }
            }
            
            if response.result.isFailure{
                Common.showAlert(with: NSLocalizedString("Error!!" ,comment: ""), message: response.error?.localizedDescription, for: self)
            }
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
        Database.database().reference().child("Travels").child(travelDetail!.travel_id).child("Clients").observeSingleEvent(of: .value, with: { snapshot in
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
    // mapView
    func getDirections(){
        mapTasks.getDirections(travelDetail?.pickLocation, destination: travelDetail?.dropLocation, waypoints: nil, travelMode: nil) { (status, result, success) in
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
    
    func updateRideFirebase(with ride_id:String, status:String, travel_status:String, paymentStatus:String, paymentMode:String) {
        print("updateRideFirebase")
        print(ride_id)
        print(status)
        print(travel_status)
        print(paymentStatus)
        print(paymentMode)
        let postRef = Database.database().reference().child("rides").child(ride_id)
        let postObject = [
            "timestamp": [".sv":"timestamp"],
            "ride_status": status,
            "travel_status": travel_status,
            "payment_status": paymentStatus,
            "payment_mode": paymentMode] as [String:Any]
        postRef.setValue(postObject, withCompletionBlock: { error, ref in
            if error == nil {
                print("nil")
            } else {
                print("not nil")
            }
        })
    }
}

extension TravelsDetailReqViewController:GMSMapViewDelegate,UITextFieldDelegate {
    
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

extension TravelsDetailReqViewController: UITableViewDelegate,UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rides.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "RidesCell") as! RidesCell
        cell = tableView.dequeueReusableCell(withIdentifier: "RidesCell") as! RidesCell
        
        cell.Fromlbl.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "RequestsCell_Fromlbl", comment: "")
        cell.Tolbl.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "RequestsCell_Tolbl", comment: "")
        cell.Datelbl.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "RequestsCell_Datelbl", comment: "")
        cell.DriverNamelbl.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "RequestsCell_Namelbl", comment: "")
        cell.ReqTypelbl.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "DriverInfoVC_Status", comment: "")
        
        // -- get current Rides Object --
        let currentObj = rides[indexPath.row]
        // -- set driver name to cell --
        cell.name.text = currentObj.userName
        //        cell.ReqTypeVal.text = currentObj.status
        
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
        
        cell.ReqTypeVal.text = currentObj.status
        
        // -- set pickup location --
        let origin = currentObj.pickupAdress.components(separatedBy: ",")
        if origin.count > 1{
            cell.streetFrom.text = origin.first
            var addr = origin.dropFirst().joined(separator: ", ")
            //            cell.detailAdrsFrom.text = String(addr.dropFirst())
        } else {
            cell.streetFrom.text = origin.first
            //            cell.detailAdrsFrom.text = ""
        }
        
        // -- set drop location --
        let destination = currentObj.dropAdress.components(separatedBy: ",")
        if destination.count > 1{
            cell.streetTo.text = destination.first
            var addr = destination.dropFirst().joined(separator: ", ")
            //            cell.detailAdrsTo.text = String(addr.dropFirst())
        } else {
            cell.streetTo.text = destination.first
            //            cell.detailAdrsTo.text = ""
        }
        
        //
        
        var paymentMode = currentObj.paymentMode
        var paymentStatus = currentObj.paymentStatus
        
        cell.acceptButton.isHidden = true
        if currentObj.status == "PENDING"
        {
            cell.acceptButton.isHidden = false
            cell.acceptButton.setTitle(LocalizationSystem.sharedInstance.localizedStringForKey(key: "DetailReqVC_Accept", comment: ""), for: .normal)
            cell.acceptButton.tag = indexPath.row
            cell.acceptButton.addTarget(self, action: #selector(sendRideRequests), for: .touchUpInside)
        }
        else if currentObj.Travel_Status == "STARTED"
        {
            if currentObj.paymentMode == "OFFLINE" && currentObj.paymentStatus != "PAID"{
                cell.acceptButton.isHidden = false
                cell.acceptButton.setTitle(LocalizationSystem.sharedInstance.localizedStringForKey(key: "DetailReqVC_offlinePayment", comment: ""), for: .normal)
                cell.acceptButton.tag = indexPath.row
                cell.acceptButton.addTarget(self, action: #selector(sendPaymentRequests), for: .touchUpInside)
            }
            else{
                cell.acceptButton.isHidden = true
            }
        }
        else
        {
            cell.acceptButton.isHidden = true
        }
        //        FIREBASE REALTIME STATUS UPDATE
        Database.database().reference().child("rides").child(currentObj.rideId).observe(.value, with: { snapshot in
            print("ibrahim snapshot")
            
            print(snapshot.value)
            if let data = snapshot.value as? String{
                if snapshot.key == "ride_status"
                {
                    if data == "PENDING"
                    {
                        cell.acceptButton.setTitle(LocalizationSystem.sharedInstance.localizedStringForKey(key: "DetailReqVC_Accept", comment: ""), for: .normal)
                        cell.acceptButton.tag = indexPath.row
                        cell.acceptButton.addTarget(self, action: #selector(self.sendRideRequests), for: .touchUpInside)
                    }
                    else if data == "ACCEPTED"
                    {
                        cell.acceptButton.isHidden = true
                    }
                    else if data == "COMPLETED"
                    {
                        cell.acceptButton.isHidden = true
                    }
                    else if data == "CANCELLED"
                    {
                        cell.acceptButton.isHidden = true
                    }
                    cell.ReqTypeVal.text = data
                }
                else if snapshot.key == "travel_status"
                {
                    cell.acceptButton.isHidden = true
                }
                else if snapshot.key == "payment_status"
                {
                    paymentStatus = data
                }
                else if snapshot.key == "payment_mode"
                {
                    paymentMode = data
                }
                
                if currentObj.paymentMode == "OFFLINE" && currentObj.paymentStatus != "PAID"{
                    cell.acceptButton.setTitle(LocalizationSystem.sharedInstance.localizedStringForKey(key: "DetailReqVC_offlinePayment", comment: ""), for: .normal)
                    cell.acceptButton.tag = indexPath.row
                    cell.acceptButton.addTarget(self, action: #selector(self.sendPaymentRequests), for: .touchUpInside)
                }
            }
        })
        //
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // -- push to detail view with required data --
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "DetailReqViewController") as! DetailReqViewController
        if rides[indexPath.row].status == "PENDING"
        {
            vc.requestPage = RequestView.pending
        }
        if rides[indexPath.row].status == "ACCEPTED"
        {
            vc.requestPage = RequestView.accepted
        }
        if rides[indexPath.row].status == "COMPLETED"
        {
            vc.requestPage = RequestView.completed
        }
        if rides[indexPath.row].status == "CANCELLED"
        {
            vc.requestPage = RequestView.cancelled
        }
        vc.rideDetail = rides[indexPath.row]
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func sendRideRequests(sender:UIButton){
        print("sendRideRequests")
        print(sender.tag)
        var params = [String:String]()
        params = ["ride_id":rides[sender.tag].rideId,"status":"ACCEPTED","by":"driver"]//, "by":"driver"
        
        let headers = ["X-API-KEY":Common.instance.getAPIKey()]
        
        //HUD.show(to: view)
        APIRequestManager.request(apiRequest: APIRouters.UpdateRides(params, headers), success: { (response) in
            //hud.hide(to: self.view)
            if response is String {
                self.updateRideFirebase(with: "ACCEPTED", travel_status: self.rides[sender.tag].Travel_Status, paymentStatus:self.rides[sender.tag].paymentStatus , paymentMode: self.rides[sender.tag].paymentMode, rideId: self.rides[sender.tag].rideId)
                
                self.updateNotificationFirebase(with: "ACCEPTED", userId: self.rides[sender.tag].userId, rideId: self.rides[sender.tag].rideId, travelId: self.rides[sender.tag].travelId)
                self.updateTravelCounterFirebase(with: "ACCEPTED", travel_id: self.rides[sender.tag].travelId)
                self.loadRequests(with: "All")
            }
        }, failure: { (message) in
            //hud.hide(to: self.view)
            Common.showAlert(with: NSLocalizedString("Alert!!", comment: ""), message: "لايوجد متسع لركاب جدد!", for: self)
        }, error: { (err) in
            //hud.hide(to: self.view)
            Common.showAlert(with: NSLocalizedString("Error!!" ,comment: ""), message: err.localizedDescription, for: self)
        })
    }
    
    @objc func sendPaymentRequests(sender:UIButton){
        print("sendPaymentRequests")
        print(sender.tag)
        
        let params = ["ride_id":rides[sender.tag].rideId,"travel_id":rides[sender.tag].travelId,"payment_status":"PAID","by":"driver"]//, "by":"driver"
        let headers = ["X-API-KEY":Common.instance.getAPIKey()]
        
        ////HUD.show(to: view)
        APIRequestManager.request(apiRequest: APIRouters.UpdateRides(params, headers), success: { (response) in
            //hud.hide(to: self.view)
            if response is String {
                //                let alert = UIAlertController(title: NSLocalizedString("Success!!", comment: ""), message: response as? String, preferredStyle: .alert)
                //                let done = UIAlertAction(title: NSLocalizedString("Done", comment: ""), style: .default, handler: { (action) in
                //                    //                    self.backWasPressed()
                //                })
                self.updateRideFirebase(with: self.rides[sender.tag].status, travel_status: self.rides[sender.tag].Travel_Status, paymentStatus: "PAID", paymentMode: self.rides[sender.tag].paymentMode, rideId: self.rides[sender.tag].rideId)
                self.updateNotificationFirebase(with: "offline_approved", userId: self.rides[sender.tag].userId, rideId: self.rides[sender.tag].rideId, travelId: self.rides[sender.tag].travelId)
                self.updateTravelCounterFirebase(with: "PAID", travel_id: self.rides[sender.tag].travelId)
                //                alert.addAction(done)
                //                self.present(alert, animated: true, completion: nil)
                self.loadRequests(with: "All")
            }
        }, failure: { (message) in
            //hud.hide(to: self.view)
            Common.showAlert(with: NSLocalizedString("Alert!!", comment: ""), message: message, for: self)
        }, error: { (err) in
            //hud.hide(to: self.view)
            Common.showAlert(with: NSLocalizedString("Error!!" ,comment: ""), message: err.localizedDescription, for: self)
        })
    }
    
    func updateRideFirebase(with status:String, travel_status:String, paymentStatus:String, paymentMode:String, rideId:String) {
        let postRef = Database.database().reference().child("rides").child(rideId)
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
    
    func updateNotificationFirebase(with status:String, userId:String, rideId:String, travelId:String) {
        let postRef = Database.database().reference().child("Notifications").child(userId).childByAutoId()
        let postObject = [
            "ride_id": rideId,
            "travel_id": travelId,
            "text": status.lowercased(),
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
    
    func updateTravelCounterFirebase(with status:String, travel_id:String) {
        print("updateTravelCounteR")
        print(status)
        if status == "ACCEPTED"{
            Database.database().reference().child("Travels").child(travel_id).child("Counters").child("ACCEPTED").observeSingleEvent(of: .value, with: { snapshot in
                print("snapshot")
                print(snapshot)
                if let data = snapshot.value as? Int{
                    print("ibrahim")
                    print("data")
                    print(data)
                    let postRef = Database.database().reference().child("Travels").child(travel_id).child("Counters").child("ACCEPTED")
                    postRef.setValue(data + 1, withCompletionBlock: { error, ref in
                        if error == nil {
                            print("error")
                        } else {
                            print("else")
                            // Handle the error
                        }
                    })
                }
            })
        }
        else if status == "COMPLETED"{
            Database.database().reference().child("Travels").child(travel_id).child("Counters").child("COMPLETED").observeSingleEvent(of: .value, with: { snapshot in
                print("snapshot")
                print(snapshot)
                if let data = snapshot.value as? Int{
                    print("ibrahim")
                    print("data")
                    print(data)
                    let postRef = Database.database().reference().child("Travels").child(travel_id).child("Counters").child("COMPLETED")
                    postRef.setValue(data + 1, withCompletionBlock: { error, ref in
                        if error == nil {
                            print("error")
                        } else {
                            print("else")
                            // Handle the error
                        }
                    })
                }
            })
        }
        else if status == "OFFLINE"{
            Database.database().reference().child("Travels").child(travel_id).child("Counters").child("OFFLINE").observeSingleEvent(of: .value, with: { snapshot in
                print("snapshot")
                print(snapshot)
                if let data = snapshot.value as? Int{
                    print("ibrahim")
                    print("data")
                    print(data)
                    let postRef = Database.database().reference().child("Travels").child(travel_id).child("Counters").child("OFFLINE")
                    postRef.setValue(data + 1, withCompletionBlock: { error, ref in
                        if error == nil {
                            print("error")
                        } else {
                            print("else")
                            // Handle the error
                        }
                    })
                }
            })
        }
        else if status == "PAID"{
            Database.database().reference().child("Travels").child(travel_id).child("Counters").child("PAID").observeSingleEvent(of: .value, with: { snapshot in
                print("snapshot")
                print(snapshot)
                if let data = snapshot.value as? Int{
                    print("ibrahim")
                    print("data")
                    print(data)
                    let postRef = Database.database().reference().child("Travels").child(travel_id).child("Counters").child("PAID")
                    postRef.setValue(data + 1, withCompletionBlock: { error, ref in
                        if error == nil {
                            print("error")
                        } else {
                            print("else")
                            // Handle the error
                        }
                    })
                }
            })
        }
    }
    
    func deletePost() {
        let commentsRef = Database.database().reference().child("posts")
        commentsRef.observe(.value, with: { snapshot in
            
            for child in snapshot.children {
                if let childSnapshot = child as? DataSnapshot,
                    let data = childSnapshot.value as? [String:Any],
                    let post = Post.parse(childSnapshot.key, data){
                    if (String(post.travel_id) == self.travelDetail!.travel_id){
                        childSnapshot.ref.removeValue { error, _ in
                            print(error)
                        }
                    }
                }
            }
        })
    }
    
    func deleteNotificationFirebase(with user_id:String) {
        let commentsRef = Database.database().reference().child("Notifications").child(user_id)
        commentsRef.observe(.value, with: { snapshot in
            
            for child in snapshot.children {
                if let childSnapshot = child as? DataSnapshot,
                    let data = childSnapshot.value as? [String:Any],
                    let notifiction = Notification.parse(childSnapshot.key, data){
                    if (String(notifiction.travel_id) == self.travelDetail!.travel_id){
                        childSnapshot.ref.removeValue { error, _ in
                            print(error)
                        }
                    }
                }
            }
        })
    }
    
    func getMyTravel(with travel_id:String){
        print("ibrahim")
        print("getMyTravel")
        print(travel_id)
        let params = ["id":travel_id]
        let headers = ["X-API-KEY":Common.instance.getAPIKey()]
        //            print(Common.instance.getUserId())
        //HUD.show(to: view)
        _ = Alamofire.request(APIRouters.driver_mytravel(params,headers)).responseObject { (response: DataResponse<Travels>) in
            //hud.hide(to: self.view)
            print("ibrahim was here")
            print(response)
            if response.result.isSuccess{
                if response.result.value?.status == true , ((response.result.value?.travels) != nil) {
                    self.travels = (response.result.value?.travels)!
                    DispatchQueue.main.async {
                        print("ibrahim1")
                        print(self.travels[0].travel_id)
                        self.travel_status_st = self.travels[0].Travel_Status
                        self.loadRequests(with: "All")
                        self.setupData()
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
    
    func listenTravelFirebase(travel_id:String) {
        print("updateTravelCounteR")
        Database.database().reference().child("Travels").child(travel_id).child("Counters").observe(.value, with: { snapshot in
            print("snapshot")
            print(snapshot)
            self.getMyTravel(with: travel_id)
        })
    }
}
