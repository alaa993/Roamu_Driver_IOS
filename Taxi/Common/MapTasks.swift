//
//  Created by Bhavin
//  skype : bhavin.bhadani
//


import UIKit
import CoreLocation

class MapTasks: NSObject {
    
    let baseURLGeocode = "https://maps.googleapis.com/maps/api/geocode/json?"
    
    var lookupAddressResults: [String:Any]!
    
    var fetchedFormattedAddress: String!
    
    var fetchedAddressLongitude: Double!
    
    var fetchedAddressLatitude: Double!
    
    let baseURLDirections = "https://maps.googleapis.com/maps/api/directions/json?"
    
    override init() {
        super.init()
    }
    
    
    func geocodeAddress(_ address: String!, withCompletionHandler completionHandler: @escaping ((_ status: String, _ success: Bool) -> Void)) {
        if let lookupAddress = address {
            let geocodeURLString = baseURLGeocode + "address=" + lookupAddress
            let geocodeURL = URL(string: geocodeURLString)
            
            DispatchQueue.main.async(execute: { () -> Void in
                let geocodingResultsData = try? Data(contentsOf: geocodeURL!)
                
                do {
                    if let dictionary  = try JSONSerialization.jsonObject(with: geocodingResultsData!, options: .allowFragments) as? [String: Any]{
                        // Get the response status.
                        if let status = dictionary["status"] as? String {
                            if status == "OK" {
                                if let allResults = dictionary["results"] as? [[String:Any]]{
                                    self.lookupAddressResults = allResults.first
                                    
                                    // Keep the most important values.
                                    self.fetchedFormattedAddress = self.lookupAddressResults["formatted_address"] as! String
                                    let geometry = self.lookupAddressResults["geometry"] as! [String:Any]
                                    let location = geometry["location"] as! [String:Double]
                                    self.fetchedAddressLongitude = location["lng"]
                                    self.fetchedAddressLatitude = location["lat"]
                                }
                                completionHandler(status, true)
                            }
                            else {
                                completionHandler(status, false)
                            }
                        }
                    }
                    else{
                        completionHandler("", false)
                    }
                } catch {
//                    print("error in JSONSerialization")
                    completionHandler("", false)
                }
            })
        }
        else {
            completionHandler("No valid address.", false)
        }
    }
    
    
    func getDirections(_ origin: String!, destination: String!, waypoints: [String]?, travelMode: TravelModes!, completionHandler: @escaping ((_ status: String, _ result:[String:Any]?, _ success: Bool) -> Void)) {
        
        if let originLocation = origin {
            if let destinationLocation = destination {
                var directionsURLString = baseURLDirections + "origin=" + originLocation + "&destination=" + destinationLocation + "&key=\(configs.googlePlaceAPIKey)"
                
                if let routeWaypoints = waypoints {
                    directionsURLString += "&waypoints=optimize:true"
                    
                    for waypoint in routeWaypoints {
                        directionsURLString += "|" + waypoint
                    }
                }
                
                if (travelMode) != nil {
                    var travelModeString = ""
                    
                    switch travelMode.rawValue {
                    case TravelModes.walking.rawValue:
                        travelModeString = "walking"
                        
                    case TravelModes.bicycling.rawValue:
                        travelModeString = "bicycling"
                        
                    default:
                        travelModeString = "driving"
                    }
                    
                    directionsURLString += "&mode=" + travelModeString
                }
                
                let directionsURL = URL(string: directionsURLString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)
                
                DispatchQueue.main.async(execute: { () -> Void in
                    do {
                        let directionsData = try? Data(contentsOf: directionsURL!)
                        
                        if let dictionary = try JSONSerialization.jsonObject(with: directionsData!, options: .allowFragments) as? [String: Any]{
                            // Get the response status.
                            if let status = dictionary["status"] as? String {
                                if status == "OK" {
                                    if let routes = dictionary["routes"] as? [[String:Any]]{
                                        let selectedRoute = routes.first
                                        let overviewPolyline = selectedRoute?["overview_polyline"] as! [String:String]
                                        var results = [String:Any]()
                                        if let legs = selectedRoute?["legs"] as? [[String:Any]] {
                                            let startLocationDictionary = legs.first?["start_location"] as! [String:Double]
                                            let originCoordinate = CLLocationCoordinate2DMake(startLocationDictionary["lat"]!, startLocationDictionary["lng"]!)
                                            let endLocationDictionary = legs[legs.count - 1]["end_location"] as! [String:Double]
                                            let destinationCoordinate = CLLocationCoordinate2DMake(endLocationDictionary["lat"]!, endLocationDictionary["lng"]!)
                                            let originAddress = legs.first?["start_address"] as! String
                                            let destinationAddress = legs[legs.count - 1]["end_address"] as! String
                                            
                                            results = self.calculateTotalDistanceAndDuration(legs: legs)
                                            results["startLocation"] = originAddress
                                            results["endLocation"] = destinationAddress
                                            results["startCoordinate"] = originCoordinate
                                            results["endCoordinate"] = destinationCoordinate
                                            results["polylines"] = overviewPolyline
                                            completionHandler(status, results, true)
                                        }
                                        else{
                                            completionHandler(status, nil, false)
                                        }
                                    }
                                    completionHandler(status, nil, false)
                                }
                                else {
                                    completionHandler(status, nil, false)
                                }
                            }
                        }
                        else{
                            completionHandler("", nil, false)
                        }
                    } catch {
//                        print("error in JSONSerialization")
                        completionHandler("", nil, false)
                    }
                })
            }
            else {
                completionHandler("Destination is nil.", nil, false)
            }
        }
        else {
            completionHandler("Origin is nil", nil, false)
        }
    }
    
    
    func calculateTotalDistanceAndDuration(legs:[[String:Any]] ) -> [String:Any] {
        var totalDistanceInMeters:UInt = 0
        var totalDurationInSeconds:UInt = 0
        
        for leg in legs {
            let distance = leg["distance"] as! [String:Any]
            let duration = leg["duration"] as! [String:Any]
            totalDistanceInMeters += distance["value"] as! UInt
            totalDurationInSeconds += duration["value"] as! UInt
        }
        
        let distanceInKilometers = Double(totalDistanceInMeters / 1000)
        
        let mins = totalDurationInSeconds / 60
        let hours = mins / 60
        let days = hours / 24
        let remainingHours = hours % 24
        let remainingMins = mins % 60
        let remainingSecs = totalDurationInSeconds % 60
        
        let totalDuration = "Duration: \(days) d, \(remainingHours) h, \(remainingMins) mins, \(remainingSecs) secs"
        
        return ["distance":distanceInKilometers, "duration":totalDuration]
    }
    
    
}
