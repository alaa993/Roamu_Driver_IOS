//
//  TrackRideViewController.swift
//  Taxi
//
//  Created by Bhavin on 10/03/17.
//  Copyright © 2017 icanStudioz. All rights reserved.
//

import UIKit
import GoogleMaps

enum TravelModes: Int {
    case driving
    case walking
    case bicycling
}

class TrackRideViewController: UIViewController {
    @IBOutlet var mapView: GMSMapView!
    
    var currentRide:Ride?
    var mapTasks = MapTasks()
    var originMarker: GMSMarker!
    var destinationMarker: GMSMarker!
    
    //------------------------------------------------------------------------------------------------------------------------------------------
    // MARK:- View Controller Life Cycle
    //------------------------------------------------------------------------------------------------------------------------------------------
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.title = "T A X I"
        let backButton = UIBarButtonItem(image: UIImage(named: "arrow-left"),
                                         style: .plain, target: self,
                                         action: #selector(TrackRideViewController.backWasPressed))
        self.navigationItem.leftBarButtonItem = backButton
        // get Current location
        getCurrentLocation()
        
        // -- make route from direction api --
        getDirections()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func backWasPressed(){
        _ = self.navigationController?.popViewController(animated: true)
    }
    //------------------------------------------------------------------------------------------------------------------------------------------
    // MARK:- CurrentLocation Requests
    //------------------------------------------------------------------------------------------------------------------------------------------
    func getCurrentLocation() {
        // -- get current coordintes --
        let manager = LocationManager.sharedInstance
        let latitude = manager.latitude
        let longitude = manager.longitude

        // -- set camera position --
        let camera = GMSCameraPosition.camera(withLatitude: latitude,
                                              longitude: longitude,
                                              zoom:19)
        mapView.animate(to: camera)
    }
    
    //------------------------------------------------------------------------------------------------------------------------------------------
    // MARK:- API Requests
    //------------------------------------------------------------------------------------------------------------------------------------------
    func getDirections(){
        mapTasks.getDirections(currentRide?.pickupAdress, destination: currentRide?.dropAdress, waypoints: nil, travelMode: nil) { (status, result, success) in
            if success {
                if let response = result {
                    self.configureMapAndMarkersForRoute(results: response)
                    
                    if let polylines = response["polylines"] as? [String:Any],
                        let pts = polylines["points"] as? String{
                        self.drawRoute(points: pts)
                    }
                }
            } else {
//                print(status)
            }
        }
    }
    
    //------------------------------------------------------------------------------------------------------------------------------------------
    // MARK:- Draw Route
    //------------------------------------------------------------------------------------------------------------------------------------------
    func configureMapAndMarkersForRoute(results:[String:Any]) {
        let originAddress = results["startLocation"] as! String
        let destinationAddress = results["endLocation"] as! String
        let originCoordinate = results["startCoordinate"] as! CLLocationCoordinate2D
        let destinationCoordinate = results["endCoordinate"] as! CLLocationCoordinate2D
        
        originMarker = GMSMarker(position: originCoordinate)
        originMarker.map = mapView
        originMarker.icon = GMSMarker.markerImage(with: .red)
        originMarker.title = originAddress
        
        destinationMarker = GMSMarker(position: destinationCoordinate)
        destinationMarker.map = mapView
        destinationMarker.icon = GMSMarker.markerImage(with: .green)
        destinationMarker.title = destinationAddress
        
        let coBounds =  GMSCoordinateBounds(coordinate: originCoordinate, coordinate: destinationCoordinate)
        mapView.animate(with: GMSCameraUpdate.fit(coBounds, withPadding: 50))
    }
    
    func drawRoute(points:String) {
        let path = GMSPath(fromEncodedPath: points)!
        let routePolyline = GMSPolyline(path: path)
        routePolyline.strokeWidth = 2.0
        routePolyline.map = mapView
    }
    
}

