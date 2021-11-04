//
//  Distance.swift
//  TaxiDriver
//
//  Created by ibrahim.marie on 9/1/21.
//  Copyright © 2021 icanStudioz. All rights reserved.
//

import Foundation
class Distance
{
    func find(origin : String, destination : String, success : (String,String) -> Void)
    {
        let url = "https://maps.googleapis.com/maps/api/distancematrix/json?origins="+origin+"&destinations="+destination+"&mode=bus&language=en-EN&key=AIzaSyCa3yhDGMZM2xHCc5ieYeyz87SuHYDzozU"
        if let url = URL(string: url) {
            if let data = try? String(contentsOf: url) {
                let json = JSON(parseJSON: data)
                let rows = json["rows"].arrayValue
                for row in rows
                {
                    let elements = row["elements"].arrayValue
                    for element in elements
                    {
                        let distance = element["distance"]["text"].stringValue
                        let duration = element["duration"]["text"].stringValue
                        success(distance,duration)
                    }
                }
            }
        }
    }
}
