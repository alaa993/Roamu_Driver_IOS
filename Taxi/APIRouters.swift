//
//  APIRouters.swift
//
//  Created by Bhavin
//  skype : bhavin.bhadani
//

import Alamofire

enum APIRouters: URLRequestConvertible {
    static let baseURLString  = configs.hostUrl
    
    static let registerUser   = configs.registerUser
    static let loginUser      = configs.loginUser
    static let forgotPaswrd   = configs.forgotPaswrd
    static let changePaswrd   = configs.changePaswrd
    static let updateUser     = configs.updateUser
    static let getProfile     = configs.getProfile
    static let getRides       = configs.getRides
    static let updateRides    = configs.updateRides//configs.getRides
    static let getEarnings    = configs.getEarnings
    static let getTransactions = configs.getTransactions
    static let addTravel     = configs.addTravel
    static let GetTravels     = configs.GetTravels
    static let getRequestedRides = configs.getRequestedRides
    static let requested_ride_id_get = configs.requested_ride_id_get
    static let confirm_requested_rides = configs.confirm_requested_rides
    static let addGroup = configs.addGroup
    static let addUserToGroup = configs.addUserToGroup
    static let delUserFromGroup = configs.delUserFromGroup
    static let getGroupList = configs.getGroupList
    static let getDriverInfo = configs.getDriverInfo
    static let getAdminGroupInfo = configs.getAdminGroupInfo
    static let updateToken    = configs.updateToken
    static let ChangeGruopName = configs.ChangeGruopName
    static let updateLanguage    = configs.updateLanguage
    static let getSpecificRide    = configs.getSpecificRide
    static let GetDriverTravels    = configs.GetDriverTravels
    static let driverRidesUpdate    = configs.driverRidesUpdate
    
    
    
    
    
    
    case RegisterUser([String:Any])
    case LoginUser([String:Any])
    case ForgotPassword([String:String])
    case ChangePassword([String:String],[String:String])
    case UpdateUser([String:String],[String:String])
    case GetProfile([String:String],[String:String])
    case GetRides([String:Any],[String:String])
    case UpdateRides([String:Any],[String:String])
    case GetEarnings([String:Any],[String:String])
    case GetTransactions([String:Any],[String:String])
    case AddTravel([String:Any],[String:String])
    case GetTravels([String:Any],[String:String])
    case getRequestedRides([String:Any],[String:String])
    case requested_ride_id_get([String:Any],[String:String])
    case confirm_requested_rides([String:Any],[String:String])
    case addGroup([String:Any],[String:String])
    case addUserToGroup([String:Any],[String:String])
    case delUserFromGroup([String:Any],[String:String])
    case getGroupList([String:Any],[String:String])
    case getDriverInfo([String:Any],[String:String])
    case getAdminGroupInfo([String:Any],[String:String])
    case UpdateToken([String:String],[String:String])
    case ChangeGruopName([String:Any],[String:String])
    case GET_MyGroupLIST([String:Any],[String:String])
    case UpdateLanguage([String:String],[String:String])
    case getSpecificRide([String:String],[String:String])
    case GetDriverTravels([String:Any],[String:String])
    case driverRidesUpdate([String:Any],[String:String])
    //requested_ride_id_get
    
    
    public func asURLRequest() throws -> URLRequest {
        
        let (path, parameters, method, headers) : (String, [String: Any]?, HTTPMethod, HTTPHeaders?) = {
            switch self {
            case .RegisterUser(let params):
                return (APIRouters.registerUser, params, .post, nil)
                
            case .LoginUser(let params):
                return (APIRouters.loginUser, params, .post, nil)
                
            case .ForgotPassword(let params):
                return (APIRouters.forgotPaswrd, params, .post, nil)
                
            case .ChangePassword(let params, let headers):
                return (APIRouters.changePaswrd, params, .post, headers)
                
            case .UpdateUser(let params, let headers):
                return (APIRouters.updateUser, params, .post, headers)
                
            case .GetProfile(let params, let headers):
                return (APIRouters.getProfile, params, .get, headers)
                
            case .GetRides(let params, let headers):
                return (APIRouters.getRides, params, .get, headers)
                
            case .UpdateRides(let params, let headers):
                return (APIRouters.updateRides, params, .post, headers)
                
            case .GetEarnings(let params, let headers):
                return (APIRouters.getEarnings, params, .get, headers)
                
            case .GetTransactions(let params, let headers):
                return (APIRouters.getTransactions, params, .get, headers)
                
            case .AddTravel(let params, let headers):
                return (APIRouters.addTravel, params, .post, headers)
                
            case .GetTravels(let params, let headers):
                return (APIRouters.GetTravels, params, .get, headers)
                
            case .getRequestedRides(let params, let headers):
                return (APIRouters.getRequestedRides, params, .get, headers)
           
            case .requested_ride_id_get(let params, let headers):
                return (APIRouters.requested_ride_id_get, params, .get, headers)
                
            case .confirm_requested_rides(let params, let headers):
                return (APIRouters.confirm_requested_rides, params, .post, headers)
                
            case .addGroup(let params, let headers):
                return (APIRouters.addGroup, params, .post, headers)
                
            case .addUserToGroup(let params, let headers):
                return (APIRouters.addUserToGroup, params, .post, headers)
            
            case .delUserFromGroup(let params, let headers):
                return (APIRouters.delUserFromGroup, params, .post, headers)
                
            case .getGroupList(let params, let headers):
                return (APIRouters.getGroupList, params, .get, headers)
                
            case .getDriverInfo(let params, let headers):
                return (APIRouters.getDriverInfo, params, .get, headers)
                
            case .getAdminGroupInfo(let params, let headers):
                return (APIRouters.getAdminGroupInfo, params, .get, headers)
                
            case .UpdateToken(let params, let headers):
                return (APIRouters.updateToken, params, .post, headers)
                
            case .ChangeGruopName(let params, let headers):
                return (APIRouters.ChangeGruopName, params, .post, headers)
                
            case .GET_MyGroupLIST(let params, let headers):
                return (APIRouters.GetTravels, params, .get, headers)
                
            case .UpdateLanguage(let params, let headers):
                return (APIRouters.updateLanguage, params, .post, headers)
                
            case .getSpecificRide(let params, let headers):
                return (APIRouters.getSpecificRide, params, .get, headers)
                
            case .GetDriverTravels(let params, let headers):
                return (APIRouters.GetDriverTravels, params, .get, headers)
                
            case .driverRidesUpdate(let params, let headers):
                return (APIRouters.driverRidesUpdate, params, .post, headers)
            }
            
            
            
        }()
        
        let url = try APIRouters.baseURLString.asURL()
        var urlRequest = URLRequest(url: url.appendingPathComponent(path))
        urlRequest.httpMethod = method.rawValue
        if let headers = headers {
            for (headerField, headerValue) in headers {
                urlRequest.setValue(headerValue, forHTTPHeaderField: headerField)
            }
        }
        
        return try URLEncoding.default.encode(urlRequest, with: parameters)
    }
}
