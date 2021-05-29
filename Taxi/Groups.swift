import UIKit

struct Group: ResponseObjectSerializable, ResponseCollectionSerializable {
    var groupId = ""
    var adminId = ""
    var groupName = ""
    var driverID = ""
    
    var group_name = ""
    var admin_name = ""
    var driver_name = ""
    var driver_mobile = ""
    var driver_email = ""
    var driver_country = ""
    var driver_is_online = ""
    var driver_vehicle_no = ""
    
    
    init?(response: HTTPURLResponse, representation: Any) {
        guard let json = representation as? [String: String]
            else { return nil }
        
        groupId = json["group_id"] ?? ""
        adminId  = json["admin_id"] ?? ""
        groupName = json["group_name"] ?? ""
        driverID = json["driver_id"] ?? ""
        
        group_name = json["group_name"] ?? ""
        admin_name = json["admin_name"] ?? ""
        driver_name = json["driver_name"] ?? ""
        driver_mobile = json["driver_mobile"] ?? ""
        driver_email = json["driver_email"] ?? ""
        driver_country = json["driver_country"] ?? ""
        driver_is_online = json["driver_is_online"] ?? ""
        driver_vehicle_no = json["driver_vehicle_no"] ?? ""
    }
    
    static func collection(response: HTTPURLResponse, representation: Any) -> [Group] {
        let groups = representation as! [[String:String]]
        return groups.map({ Group(response: response, representation: $0)! })
    }
}

struct Groups: ResponseObjectSerializable {
    var groups:[Group]?
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
            self.groups = Group.collection(response: response, representation: json)
        }
    }
}
