//
//  Drivers.swift
//  TaxiDriver
//
//  Created by Syria.Apple on 5/13/20.
//  Copyright © 2020 icanStudioz. All rights reserved.
//
import UIKit

struct Driver: ResponseObjectSerializable, ResponseCollectionSerializable {
    
    var userId: String?
    var name: String?
    var email: String?
    var avatar: String?
    var mobile: String?
    var country: String?
    var state: String?
    var city: String?
    var lat: String?
    var long: String?
    var onlineStatus: String?
    var vehicle: String?
    var brand: String?
    var model: String?
    var year: String?
    var color: String?
    var vehicle_no: String?
    var license: String?
    var insurance: String?
    var permit: String?
    var registration: String?
    
    
    init?(response: HTTPURLResponse, representation: Any) {
        guard let json = representation as? [String: String]
            else { return nil }
        
        userId = json["user_id"] ?? ""
        name = json["name"] ?? ""
        email = json["email"] ?? ""
        avatar = json["avatar"] ?? ""
        mobile = json["mobile"] ?? ""
        country = json["country"] ?? ""
        state = json["state"] ?? ""
        city = json["city"] ?? ""
        lat = json["latitude"] ?? ""
        long = json["longitude"] ?? ""
        onlineStatus = json["is_online"] ?? ""
        vehicle = json["vehicle"] ?? ""
        brand = json["brand"] ?? ""
        model = json["model"] ?? ""
        year = json["year"] ?? ""
        color = json["color"] ?? ""
        vehicle_no = json["vehicle_no"] ?? ""
        license = json["license"] ?? ""
        insurance = json["insurance"] ?? ""
        permit = json["permit"] ?? ""
        registration = json["registration"] ?? ""
    }
    
    static func collection(response: HTTPURLResponse, representation: Any) -> [Driver] {
        let drivers = representation as! [[String:String]]
        return drivers.map({ Driver(response: response, representation: $0)! })
    }
}

struct Drivers: ResponseObjectSerializable {
    var drivers:[Driver]?
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
            self.drivers = Driver.collection(response: response, representation: json)
        }
    }
}
