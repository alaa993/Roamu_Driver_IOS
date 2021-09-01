//
//  Notification.swift
//  Taxi
//
//  Created by ibrahim.marie on 11/21/20.
//  Copyright © 2020 icanStudioz. All rights reserved.
//

import Foundation
class Notification {
    var id:String
    var text:String
    var readStatus:String
    var uid:String
    var createdAt:Date
    var ride_id:String
    var travel_id:String
    
    init(id:String, text:String, uid:String, ride_id:String, travel_id:String, readStatus:String, timestamp:Double) {
        self.id = id
        self.text = text
        self.readStatus = readStatus
        self.uid = uid
        self.ride_id = ride_id
        self.travel_id = travel_id
        self.createdAt = Date(timeIntervalSince1970: timestamp / 1000)
    }
    
    static func parse(_ key:String, _ data:[String:Any]) -> Notification? {
        if let uid = data["uid"] as? String,
            let text = data["text"] as? String,
            let readStatus = data["readStatus"] as? String,
            let ride_id = data["ride_id"] as? String,
            let travel_id = data["travel_id"] as? String,
            let timestamp = data["timestamp"] as? Double {
            return Notification(id: key, text: text, uid: uid, ride_id: ride_id, travel_id: travel_id, readStatus: readStatus, timestamp: timestamp)
        }
        return nil
    }
}
