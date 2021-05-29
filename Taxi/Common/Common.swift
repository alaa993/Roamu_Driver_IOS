//
//  Common.swift
//  Taxi
//
//  Created by Bhavin
//  skype : bhavin.bhadani
//

import UIKit

open class Common {

    static let instance = Common()
    public init(){}
    
    class func showAlert(with title:String?, message:String?, for viewController:UIViewController){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: nil)
        alert.addAction(cancelAction)
        viewController.present(alert, animated: true, completion: nil)
    }
    
    func isUserLoggedIn() -> Bool {
        if UserDefaults.standard.data(forKey: "user") != nil{
            return true
        } else {
            return false
        }
    }
    
    func getUserId() -> String {
        if let data = UserDefaults.standard.data(forKey: "user"){
            let userData = NSKeyedUnarchiver.unarchiveObject(with: data) as? User
            return (userData?.userId)!
        } else {
            return ""
        }
    }
    
    func getEmail() -> String {
        if let data = UserDefaults.standard.data(forKey: "user"){
            let userData = NSKeyedUnarchiver.unarchiveObject(with: data) as? User
            return (userData?.email)!
        } else {
            return ""
        }
    }
    
    func isOnline() -> Bool {
        if let data = UserDefaults.standard.data(forKey: "user"){
            let userData = NSKeyedUnarchiver.unarchiveObject(with: data) as? User
            if let status = userData?.onlineStatus {
                if status == "0" {
                    return false
                } else {
                    return true
                }
            } else { return false }
        } else {
            return false
        }
    }
    
    func getAPIKey() -> String {
        if let key = UserDefaults.standard.value(forKey: "key") as? String{
            return key
        } else {
            return ""
        }
    }
    
    func getCarType() -> String {
        if let data = UserDefaults.standard.data(forKey: "user"){
            let userData = NSKeyedUnarchiver.unarchiveObject(with: data) as? User
            return (userData?.car_type)!
        } else {
            return ""
        }
    }
    
    func removeUserdata() {
        UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
        UserDefaults.standard.synchronize()
    }
    
    func getFormattedDate(date: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let dateObj = dateFormatter.date(from: date)
        dateFormatter.dateFormat = "MMM d, yyyy-HH:mm a"
        return dateFormatter.string(from: dateObj!)
    }
    
    func getFormattedDateOnly(date: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateObj = dateFormatter.date(from: date)
        dateFormatter.dateFormat = "MMM d, yyyy"
        return dateFormatter.string(from: dateObj!)
    }
    
    func getFormattedTimeOnly(date: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US") as Locale
        dateFormatter.dateFormat = "HH:mm:ss"
        print("inside Formatted Time only")
        print(date)
        let dateObj = dateFormatter.date(from: date)
        print(dateObj)
        print(dateFormatter.string(from: dateObj!))
        //dateFormatter.dateFormat = "HH:mm a"
        return dateFormatter.string(from: dateObj!)
    }
}
