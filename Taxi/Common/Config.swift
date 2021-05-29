//
//  Config.swift
//  Taxi
//
//  Created by Bhavin
//  skype : bhavin.bhadani
//

struct configs{
    static let googleAPIKey      = "AIzaSyAspMldDJRyiM5hh5Iy3M2RfqXFZcd2aX0"
    static let googlePlaceAPIKey = "AIzaSyCa3yhDGMZM2xHCc5ieYeyz87SuHYDzozU"//"AIzaSyAHNdoUOZOJcDrXS-o4FgUbtxOCF1VsNNg"
    
    static let googlePlaceAPIKey1 = "AIzaSyDQFAsFkYGDcH9SIayjQKtmCnmnDQDGP_U"
    static let mapBox = "pk.eyJ1IjoiaWNhbnN0dWRpb3oiLCJhIjoiY2oyMXQ3dGRpMDAwdDJ3bXpmZHRkdTBtNyJ9.PxslIcrVRj_gVgiv-Y-jog"
    
    static let hostUrl      = "https://roamu.net/"
    
    static let registerUser = "user/register/format/json"
    static let loginUser    = "user/loginByMobile/format/json"//"user/login/format/json"
    static let forgotPaswrd = "user/forgot_password/format/json"
    static let changePaswrd = "api/user/change_password/format/json"
    static let updateUser   = "api/user/update/format/json"
    static let getProfile   = "api/user/profile/format/json"
    static let updateRides = "api/user/rides/format/json"
    static let getRides     = "api/user/rides2/format/json"
    static let getRequestedRides = "api/user/requested_rides/format/json"
    static let requested_ride_id_get = "api/user/requested_ride_id/format/json"
    static let getEarnings  = "api/driver/earn/format/json"
    static let getTransactions = "api/driver/rides/format/json"
    static let addTravel    = "api/user/addTravel2/format/json"
    static let GetTravels   = "api/user/travels/format/json"
    static let GetDriverTravels   = "api/user/driver_travels/format/json"
    static let confirm_requested_rides = "api/user/confirm_requested_rides/format/json"
    static let addGroup = "api/driver/addgroup/format/json"
    static let addUserToGroup = "api/driver/addUserToGroup/format/json"
    static let delUserFromGroup = "api/driver/delUserFromGroup/format/json"
    static let getGroupList = "api/driver/getGroupList/format/json"
    static let getDriverInfo = "api/driver/getDriverInfo/format/json"
    static let getAdminGroupInfo = "api/driver/getAdminGroupInfo/format/json"
    static let updateToken = "user/updateToken/format/json"
    static let ChangeGruopName = "api/driver/editgroup/format/json"
    static let GET_MyGroupLIST = "api/driver/api/driver/getMyGroupList/format/json"
    //static let getGroupList = "api/driver/api/driver/getGroupList/format/json"
    static let updateLanguage = "api/user/updateLang/format/json"
    static let getSpecificRide     = "api/user/ride_specific/format/json"
    static let driverRidesUpdate     = "api/user/rides_update/format/json"
    
    //
    
}

struct customFont{
    static var normal  = "Avenir-Book"
    static var medium  = "Avenir-Medium"
    static var bold    = "Avenir-Black"
}

protocol UIViewLoading {}
extension UIView : UIViewLoading {}

extension UIViewLoading where Self : UIView {
    
    // note that this method returns an instance of type `Self`, rather than UIView
    static func loadFromNib() -> Self {
        let nibName = "\(self)".split{$0 == "."}.map(String.init).last!
        let nib = UINib(nibName: nibName, bundle: nil)
        return nib.instantiate(withOwner: self, options: nil).first as! Self
    }
}
