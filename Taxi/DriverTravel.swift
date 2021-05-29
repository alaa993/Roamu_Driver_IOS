//
//  DriverTravel.swift
//  TaxiDriver
//
//  Created by ibrahim.marie on 3/31/21.
//  Copyright © 2021 icanStudioz. All rights reserved.
//

import Foundation
import UIKit

struct DriverTravel: ResponseObjectSerializable, ResponseCollectionSerializable {
    var travel_id = ""
    //var userId = ""
    var driverId = ""
    var pickupAddress = ""
    var dropAddress = ""
    var pickLocation = ""
    var dropLocation = ""
    var pickup_point = ""
    var distance = ""
    var amount = ""
    var available_set = ""
    var booked_set = ""
    var empty_set = ""
    var date = ""
    var time = ""
    var smoked = ""
    var driverName = ""
    var driverMobile = ""
    var driverVehicle = ""
    var vehicle_no = ""
    var model = ""
    var color = ""
    var avatar = ""
    var vehicle_info = ""
    var DriverRate = ""
    var FareRate = ""
    var Travels_Count = ""
    var Travel_Status = ""
    var car_type = ""
    
    init?(response: HTTPURLResponse, representation: Any) {
        guard let json = representation as? [String: String]
            else { return nil }
        
        //rideId = json["ride_id"] ?? ""
        //userId  = json["user_id"] ?? ""
        travel_id = json["travel_id"] ?? ""
        driverId = json["driver_id"] ?? ""
        pickupAddress = json["pickup_address"] ?? ""
        dropAddress = json["drop_address"] ?? ""
        pickLocation = json["pickup_location"] ?? ""
        dropLocation = json["drop_location"] ?? ""
        pickup_point = json["pickup_point"] ?? ""
        distance = json["distance"] ?? ""
        amount = json["amount"] ?? ""
        available_set = json["available_set"] ?? ""
        booked_set = json["booked_set"] ?? ""
        empty_set = json["empty_set"] ?? ""
        date = json["date"] ?? ""
        time = json["time"] ?? ""
        smoked = json["smoked"] ?? ""
        driverName = json["driver_name"] ?? ""
        driverMobile = json["driver_mobile"] ?? ""
        driverVehicle = json["driverVehicle"] ?? ""
        model = json["model"] ?? ""
        color = json["color"] ?? ""
        avatar = json["avatar"] ?? ""
        vehicle_info = json["vehicle_info"] ?? ""
        DriverRate = json["DriverRate"] ?? ""
        FareRate = json["FareRate"] ?? ""
        Travels_Count = json["Travels_Count"] ?? ""
        vehicle_no = json["vehicle_no"] ?? ""
        Travel_Status = json["status"] ?? ""
        car_type = json["car_type"] ?? ""
        
    }
    
    static func collection(response: HTTPURLResponse, representation: Any) -> [DriverTravel] {
        let drivertravels = representation as! [[String:String]]
        return drivertravels.map({ DriverTravel(response: response, representation: $0)! })
    }
}

struct DriverTravels: ResponseObjectSerializable {
    var drivertravels:[DriverTravel]?
    var status:Bool
    var error:String?
    
    init?(response: HTTPURLResponse, representation: Any) {
        guard let representation = representation as? [String: Any]
            else { return nil }
        
        if let stat = representation["status"] as? String {
            if stat == "success" {
                self.status = true
            } else {
                self.status = false
            }
        } else {
            self.status = false
        }
        
        if let err = representation["error"] as? String{
            self.error = err
        }
        
        if let json = representation["data"] as? [[String:String]] {
            //self.travels = Travel.collection(response: response, representation: json)
            self.drivertravels = DriverTravel.collection(response: response, representation: json)
        }
    }
}

