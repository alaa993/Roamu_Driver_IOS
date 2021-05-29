//
//  User.swift
//  Taxi
//
//  Created by Bhavin on 17/03/17.
//  Copyright © 2017 icanStudioz. All rights reserved.
//

import UIKit

class User: NSObject, NSCoding {
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
    var vehicle_info: String?
    var car_type: String?
    
    
    
    init(userData:[String:Any]) {
        super.init()
        setData(json: userData as! [String : String])
    }
    
    required init(coder decoder: NSCoder) {
        self.userId = decoder.decodeObject(forKey: "user_id") as? String ?? ""
        self.name   = decoder.decodeObject(forKey: "name") as? String ?? ""
        self.email  = decoder.decodeObject(forKey: "email") as? String ?? ""
        self.avatar = decoder.decodeObject(forKey: "avatar") as? String ?? ""
        self.mobile = decoder.decodeObject(forKey: "mobile") as? String ?? ""
        self.country = decoder.decodeObject(forKey: "country") as? String ?? ""
        self.state  = decoder.decodeObject(forKey: "state") as? String ?? ""
        self.city   = decoder.decodeObject(forKey: "city") as? String ?? ""
        self.lat    = decoder.decodeObject(forKey: "latitude") as? String ?? ""
        self.long   = decoder.decodeObject(forKey: "longitude") as? String ?? ""
        self.onlineStatus = decoder.decodeObject(forKey: "is_online") as? String ?? ""
        self.vehicle = decoder.decodeObject(forKey: "vehicle_info") as? String ?? ""
        self.brand   = decoder.decodeObject(forKey: "brand") as? String ?? ""
        self.model   = decoder.decodeObject(forKey: "model") as? String ?? ""
        self.year    = decoder.decodeObject(forKey: "year") as? String ?? ""
        self.color   = decoder.decodeObject(forKey: "color") as? String ?? ""
        self.vehicle_no = decoder.decodeObject(forKey: "vehicle_no") as? String ?? ""
        self.license = decoder.decodeObject(forKey: "license") as? String ?? ""
        self.insurance = decoder.decodeObject(forKey: "insurance") as? String ?? ""
        self.permit  = decoder.decodeObject(forKey: "permit") as? String ?? ""
        self.registration = decoder.decodeObject(forKey: "registration") as? String ?? ""
        self.vehicle_info = decoder.decodeObject(forKey: "vehicle_info") as? String ?? ""
        self.car_type = decoder.decodeObject(forKey: "car_type") as? String ?? ""
    }
    
    func encode(with coder: NSCoder) {
        coder.encode(userId, forKey: "user_id")
        coder.encode(name, forKey: "name")
        coder.encode(email, forKey: "email")
        coder.encode(avatar, forKey: "avatar")
        coder.encode(mobile, forKey: "mobile")
        coder.encode(country, forKey: "country")
        coder.encode(state, forKey: "state")
        coder.encode(city, forKey: "city")
        coder.encode(lat, forKey: "latitude")
        coder.encode(long, forKey: "longitude")
        coder.encode(onlineStatus, forKey: "is_online")
        coder.encode(vehicle, forKey: "vehicle_info")
        coder.encode(brand, forKey: "brand")
        coder.encode(model, forKey: "model")
        coder.encode(year, forKey: "year")
        coder.encode(color, forKey: "color")
        coder.encode(vehicle_no, forKey: "vehicle_no")
        coder.encode(license, forKey: "license")
        coder.encode(insurance, forKey: "insurance")
        coder.encode(permit, forKey: "permit")
        coder.encode(registration, forKey: "registration")
        coder.encode(vehicle_info, forKey: "vehicle_info")
        coder.encode(car_type, forKey: "car_type")
        
    }
    
    func setData(json:[String:String]){
        userId  = json["user_id"] ?? ""
        name    = json["name"] ?? ""
        email   = json["email"] ?? ""
        avatar  = json["avatar"] ?? ""
        mobile  = json["mobile"] ?? ""
        country = json["country"] ?? ""
        state   = json["state"] ?? ""
        city    = json["city"] ?? ""
        lat     = json["latitude"] ?? ""
        long    = json["longitude"] ?? ""
        onlineStatus = json["is_online"] ?? ""
        vehicle = json["vehicle_info"] ?? ""
        brand   = json["brand"] ?? ""
        model   = json["model"] ?? ""
        year    = json["year"] ?? ""
        color   = json["color"] ?? ""
        vehicle_no = json["vehicle_no"] ?? ""
        license = json["license"] ?? ""
        insurance = json["insurance"] ?? ""
        permit  = json["permit"] ?? ""
        registration = json["registration"] ?? ""
        vehicle_info = json["vehicle_info"] ?? ""
        car_type = json["car_type"] ?? ""
    }
}
