//
//  Post.swift
//  Taxi
//
//  Created by ibrahim.marie on 6/13/20.
//  Copyright © 2020 icanStudioz. All rights reserved.
//

import Foundation


class Post {
    var id:String
    var author:UserProfile
    var text:String
    var type:String
    var createdAt:Date
    var travel_id:Int
    
    init(id:String, author:UserProfile, text:String, timestamp:Double, type:String, travel_id:Int) {
        self.id = id
        self.author = author
        self.text = text
        self.createdAt = Date(timeIntervalSince1970: timestamp / 1000)
        self.type = type
        self.travel_id = travel_id
    }
    
    static func parse(_ key:String, _ data:[String:Any]) -> Post? {
        
        if let author = data["author"] as? [String:Any],
            let uid = author["uid"] as? String,
            let username = author["username"] as? String,
            let photoURL = author["photoURL"] as? String,
            let url = URL(string:photoURL),
            let text = data["text"] as? String,
            let type = data["type"] as? String,
            let travel_id = data["travel_id"] as? Int,
            let timestamp = data["timestamp"] as? Double {
            
            let userProfile = UserProfile(uid: uid, username: username, photoURL: url)
            return Post(id: key, author: userProfile, text: text, timestamp: timestamp, type: type, travel_id: travel_id)
            
        }
        
        return nil
    }
}
