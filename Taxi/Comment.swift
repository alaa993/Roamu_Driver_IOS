//
//  Comment.swift
//  Taxi
//
//  Created by ibrahim.marie on 6/13/20.
//  Copyright © 2020 icanStudioz. All rights reserved.
//

import Foundation

class Comment {
    
    var id:String
    var username:String
    var text:String
    var createdAt:Date
    
    init(id:String, username:String, text:String ,timestamp:Double) {
        self.id = id
        self.username = username
        self.text = text
        self.createdAt = Date(timeIntervalSince1970: timestamp / 1000)
    }
    
    static func parse(_ key:String, _ data:[String:Any]) -> Comment? {
        
        if let text = data["text"] as? String,
            let username = data["username"] as? String,
            let timestamp = data["timestamp"] as? Double{
            return Comment(id: key, username:username, text:text, timestamp:timestamp)
        }
        return nil
    }
}
