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
    
    @IBOutlet var tableView: UITableView!
    var rides = [Ride]()
    
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
        if (travelDetail?.Travel_Status == "PENDING")
        {
            startCompleteButton.isHidden = false
            cancelButton.isHidden = false
            startCompleteButton.setTitle(LocalizationSystem.sharedInstance.localizedStringForKey(key: "DetailReqVC_Start", comment: ""), for: .normal)
        }
        else if (travelDetail?.Travel_Status == "CANCELLED")
        {
            startCompleteButton.isHidden = true
            cancelButton.isHidden = true
        }
        else if (travelDetail?.Travel_Status == "COMPLETED")
        {
            startCompleteButton.isHidden = true
            cancelButton.isHidden = true
        }
        else if (travelDetail?.Travel_Status == "STARTED")
        {
            startCompleteButton.isHidden = false
            cancelButton.isHidden = true
            startCompleteButton.setTitle(LocalizationSystem.sharedInstance.localizedStringForKey(key: "DetailReqVC_Complete", comment: ""), for: .normal)
        }
    }
    
    func loadRequests(with status:String){
        let params = ["id":Common.instance.getUserId(),"status":status,"utype":"1"]
        let headers = ["X-API-KEY":Common.instance.getAPIKey()]
        //            print(Common.instance.getUserId())
        HUD.show(to: view)
        _ = Alamofire.request(APIRouters.GetRides(params,headers)).responseObject { (response: DataResponse<Rides>) in
            HUD.hide(to: self.view)
            print("ibrahim was here")
            print(response)
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
    
    @IBAction func startCompleteWasPressed(_ sender: UIButton) {
        if travelDetail?.Travel_Status == "PENDING"{
            sendRequests(with: "STARTED")
            print("STARTED")
        }
        else if travelDetail?.Travel_Status == "STARTED"
        {
            print("COMPLETED")
            sendRequests(with: "COMPLETED")
        }
    }
    
    @IBAction func cancelWasPressed(_ sender: UIButton) {
        sendRequests(with: "CANCELLED")
    }
    
    func sendRequests(with status:String){
        
        print(travelDetail!.travel_id)
        print(travelDetail!.Travel_Status)
        
        var params = [String:String]()
        params = ["travel_id":travelDetail!.travel_id, "travel_status":status]
        let headers = ["X-API-KEY":Common.instance.getAPIKey()]
        
        HUD.show(to: view)
        APIRequestManager.request(apiRequest: APIRouters.driverRidesUpdate(params, headers), success: { (response) in
            HUD.hide(to: self.view)
            let alert = UIAlertController(title: NSLocalizedString("Success!!",comment: ""), message: "", preferredStyle: .alert)
            
            let done = UIAlertAction(title: NSLocalizedString("Done", comment: ""), style: .default, handler: { (action) in
                _ = self.navigationController?.popViewController(animated: true)
            })
            alert.addAction(done)
            self.present(alert, animated: true, completion: nil)
            //
            //
        }, failure: { (message) in
            HUD.hide(to: self.view)
            Common.showAlert(with: NSLocalizedString("Alert!!", comment: ""), message: message, for: self)
        }, error: { (err) in
            HUD.hide(to: self.view)
            Common.showAlert(with: NSLocalizedString("Error!!" ,comment: ""), message: err.localizedDescription, for: self)
        })
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
        var cell = tableView.dequeueReusableCell(withIdentifier: "RequestsCell") as! RequestsCell
        cell = tableView.dequeueReusableCell(withIdentifier: "RequestsCell") as! RequestsCell
        
        cell.Fromlbl.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "RequestsCell_Fromlbl", comment: "")
        cell.Tolbl.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "RequestsCell_Tolbl", comment: "")
        cell.Datelbl.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "RequestsCell_Datelbl", comment: "")
        cell.DriverNamelbl.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "RequestsCell_Namelbl", comment: "")
//        cell.ReqTypelbl.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "RequestsVCReqlbl", comment: "")
        
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
}
