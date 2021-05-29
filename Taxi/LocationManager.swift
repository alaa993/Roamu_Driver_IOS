//
//  LocationManager.swift
//  Taxi
//
//  Created by Bhavin
//  skype : bhavin.bhadani
//

import UIKit
import CoreLocation
import MapKit
import Firebase

typealias ReverseGeocodeCompletionHandler = ((_ reverseGecodeInfo:[String:String]?,_ placemark:CLPlacemark?, _ error:String?)->Void)?
typealias GeocodeCompletionHandler = ((_ gecodeInfo:[String:String]?,_ placemark:CLPlacemark?, _ error:String?)->Void)?
typealias LocationCompletionHandler = ((_ latitude:Double, _ longitude:Double, _ status:String, _ verboseMessage:String, _ error:String?)->())?

// Todo: Keep completion handler differerent for all services, otherwise only one will work
enum GeoCodingType{
    case geocoding
    case reverseGeocoding
}

class LocationManager: NSObject,CLLocationManagerDelegate {
    
    fileprivate var locationManager: CLLocationManager!
    fileprivate var reverseGeocodingCompletionHandler:ReverseGeocodeCompletionHandler = nil
    fileprivate var geocodingCompletionHandler:GeocodeCompletionHandler = nil
    fileprivate var timer : Timer? = nil {
        willSet {
            timer?.invalidate()
        }
    }
    
    var latitude:Double = 0.0
    var longitude:Double = 0.0
    var autoUpdate:Bool = false
    
    class var sharedInstance : LocationManager {
        struct Static {
            static let instance : LocationManager = LocationManager()
        }
        return Static.instance
    }
    
//    fileprivate override init(){
//        super.init()
//    }
    
    func startUpdatingLocation(){
        initLocationManager()
    }
    
    func stopUpdatingLocation(){
        locationManager.stopUpdatingLocation()
    }
    
    fileprivate func initLocationManager() {
        
        // App might be unreliable if someone changes autoupdate status in between and stops it
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        // locationManager.locationServicesEnabled
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        if #available(iOS 8.0, *) {
            locationManager.requestWhenInUseAuthorization()
        }
        
        startLocationManger()
    }
    
    fileprivate func startLocationManger(){
        locationManager.startUpdatingLocation()
    }
    
    fileprivate func stopLocationManger(){
        locationManager.stopUpdatingLocation()
    }
    
    internal func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        stopLocationManger()
    }
    
    internal func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let arrayOfLocation = locations
        if let location = arrayOfLocation.last {
            let coordLatLon = location.coordinate
            
            latitude  = coordLatLon.latitude
            longitude = coordLatLon.longitude
            
            if (Auth.auth().currentUser != nil && Common.instance.getUserId().count > 0) {
                self.updateLocationFirebase(with: latitude, longitude:longitude);
            }
            
            if Common.instance.isOnline() {
                if timer == nil {
                    timer = Timer.scheduledTimer(timeInterval: 60, target: self,
                                                 selector: #selector(updateLocation), userInfo: nil, repeats: true)
                }
            } else {
                timer?.invalidate()
                timer = nil
            }
        }
    }
    
    func updateLocationFirebase(with latitude:Double, longitude:Double) {
        print("ibrahim")
        print(latitude)
        print(longitude)
        print(Common.instance.getUserId())
        let postRef = Database.database().reference().child("Location").child(Common.instance.getUserId())
        let postObject = [
            "latitude": latitude,
            "longitude": longitude,
            "uid": Auth.auth().currentUser?.uid] as [String:Any]
        postRef.setValue(postObject, withCompletionBlock: { error, ref in
            if error == nil {
                
            } else {
            }
        })
    }
    
    // Reverse geocode
    func reverseGeocodeLocationWithLatLong(latitude:Double, longitude: Double,onReverseGeocodingCompletionHandler:ReverseGeocodeCompletionHandler){
        let location = CLLocation(latitude:latitude, longitude: longitude)
        reverseGeocodeLocationWithCoordinates(location,onReverseGeocodingCompletionHandler: onReverseGeocodingCompletionHandler)
    }
    
    func reverseGeocodeLocationWithCoordinates(_ coord:CLLocation, onReverseGeocodingCompletionHandler:ReverseGeocodeCompletionHandler){
        self.reverseGeocodingCompletionHandler = onReverseGeocodingCompletionHandler
        reverseGocode(coord)
    }
    
    fileprivate func reverseGocode(_ location:CLLocation){
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location, completionHandler: {(placemarks, error)->Void in
            if (error != nil) {
                self.reverseGeocodingCompletionHandler!(nil,nil, error!.localizedDescription)
            }
            else{
                if let placemark = placemarks?.first {
                    let address = AddressParser()
                    address.parseAppleLocationData(placemark)
                    let addressDict = address.getAddressDictionary()
                    self.reverseGeocodingCompletionHandler!(addressDict,placemark,nil)
                }
                else {
                    self.reverseGeocodingCompletionHandler!(nil,nil,"No Placemarks Found!")
                    return
                }
            }
        })
    }
    
    // geocode
    func geocodeAddressString(address:String, onGeocodingCompletionHandler:GeocodeCompletionHandler){
        self.geocodingCompletionHandler = onGeocodingCompletionHandler
        geoCodeAddress(address)
    }
    
    fileprivate func geoCodeAddress(_ address:String){
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(address) { (placemarks, error) in
            if error != nil {
                self.geocodingCompletionHandler!(nil,nil,error!.localizedDescription)
            }
            else{
                if let placemark = placemarks?.first {
                    let address = AddressParser()
                    address.parseAppleLocationData(placemark)
                    let addressDict = address.getAddressDictionary()
                    self.geocodingCompletionHandler!(addressDict,placemark,nil)
                }
                else {
                    self.geocodingCompletionHandler!(nil,nil,"invalid address: \(address)")
                }
            }
        }
    }
    
    func geocodeUsingGoogleAddressString(address:String, onGeocodingCompletionHandler:GeocodeCompletionHandler){
        self.geocodingCompletionHandler = onGeocodingCompletionHandler
        geoCodeUsignGoogleAddress(address)
    }
    
    fileprivate func geoCodeUsignGoogleAddress(_ address:String){
        var urlString = "http://maps.googleapis.com/maps/api/geocode/json?address=\(address)&sensor=true"
        urlString = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        performOperationForURL(urlString, type: GeoCodingType.geocoding)
    }
    
    fileprivate func performOperationForURL(_ urlString:String,type:GeoCodingType){
        let url = URL(string:urlString)
        
        let request = URLRequest(url:url!)
        
        let task = URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) in
            
            if(error != nil){
                self.setCompletionHandler(responseInfo:nil, placemark:nil, error:error!.localizedDescription, type:type)
            }
            else{
                let kStatus = "status"
                let kOK = "ok"
                let kZeroResults = "ZERO_RESULTS"
                let kAPILimit = "OVER_QUERY_LIMIT"
                let kRequestDenied = "REQUEST_DENIED"
                let kInvalidRequest = "INVALID_REQUEST"
                let kInvalidInput =  "Invalid Input"
                
                do {
                    let jsonResult = try JSONSerialization.jsonObject(with: data!, options: []) as! [String:Any]
                    var status = jsonResult[kStatus] as! String
                    status = status.lowercased()
                    
                    if(status == kOK){
                        let address = AddressParser()
                        address.parseGoogleLocationData(jsonResult)
                        let addressDict = address.getAddressDictionary()
                        let placemark = address.getPlacemark()
                        self.setCompletionHandler(responseInfo:addressDict, placemark:placemark, error: nil, type:type)
                        
                    }else if((status != kZeroResults) && (status != kAPILimit) && (status != kRequestDenied) && (status != kInvalidRequest)){
                        self.setCompletionHandler(responseInfo:nil, placemark:nil, error:kInvalidInput, type:type)
                    }
                    else{
                        self.setCompletionHandler(responseInfo:nil, placemark:nil, error:status as String, type:type)
                    }
                } catch let e {
                    self.setCompletionHandler(responseInfo:nil, placemark:nil, error:e.localizedDescription, type:type)
                }
            }
        })
        
        task.resume()
    }
    
    fileprivate func setCompletionHandler(responseInfo:[String:String]?,placemark:CLPlacemark?, error:String?,type:GeoCodingType){
        if(type == GeoCodingType.geocoding){
            self.geocodingCompletionHandler!(responseInfo,placemark,error)
        }else{
            self.reverseGeocodingCompletionHandler!(responseInfo,placemark,error)
        }
    }
    
    //------------------------------------------------------------------------------------------------------------------------------------------
    // MARK:- API Requests
    //------------------------------------------------------------------------------------------------------------------------------------------
    @objc fileprivate func updateLocation(){
        var params = [String:String]()
        params["user_id"] = Common.instance.getUserId()
        params["latitude"] = String(latitude)
        params["longitude"] = String(longitude)
        
        let headers = ["X-API-KEY":Common.instance.getAPIKey()]
        
        APIRequestManager.request(apiRequest: APIRouters.UpdateUser(params,headers), success: { (responseData) in
            if let data = responseData as? [String:String] {
                if let user = UserDefaults.standard.data(forKey: "user"){
                    let userData = NSKeyedUnarchiver.unarchiveObject(with: user) as? User
                    userData?.lat = data["latitude"]
                    userData?.long = data["longitude"]
                    let encodedData = NSKeyedArchiver.archivedData(withRootObject: userData!)
                    UserDefaults.standard.set(encodedData, forKey: "user")
                }
            }
        }, failure: { (message) in
//            print(message)
        }, error: { (err) in
//            print(err.localizedDescription)
        })
    }
}

private class AddressParser: NSObject{
    
    fileprivate var latitude = String()
    fileprivate var longitude  = String()
    fileprivate var streetNumber = String()
    fileprivate var route = String()
    fileprivate var locality = String()
    fileprivate var subLocality = String()
    fileprivate var formattedAddress = String()
    fileprivate var administrativeArea = String()
    fileprivate var administrativeAreaCode = String()
    fileprivate var subAdministrativeArea = String()
    fileprivate var postalCode = String()
    fileprivate var country = String()
    fileprivate var subThoroughfare = String()
    fileprivate var thoroughfare = String()
    fileprivate var ISOcountryCode = String()
    fileprivate var state = String()
    
    
    override init(){
        super.init()
    }
    
    fileprivate func getAddressDictionary()-> [String:String]{
        var addressDict = [String:String]()
        addressDict["latitude"] = latitude
        addressDict["longitude"] = longitude
        addressDict["streetNumber"] = streetNumber
        addressDict["locality"] = locality
        addressDict["subLocality"] = subLocality
        addressDict["administrativeArea"] = administrativeArea
        addressDict["postalCode"] = postalCode
        addressDict["country"] = country
        addressDict["formattedAddress"] = formattedAddress
        
        return addressDict
    }
    
    fileprivate func parseAppleLocationData(_ placemark:CLPlacemark){
        let addressLines = placemark.addressDictionary!["FormattedAddressLines"] as! [String]
        
        if let stf    = placemark.subThoroughfare { self.streetNumber = stf }
        if let lcl    = placemark.locality { self.locality = lcl }
        if let postal = placemark.postalCode { self.postalCode = postal }
        if let slcl   = placemark.subLocality { self.subLocality = slcl }
        if let aa     = placemark.administrativeArea { self.administrativeArea = aa }
        if let cntry  = placemark.country { self.country = cntry }
        self.longitude  = placemark.location!.coordinate.longitude.description
        self.latitude   = placemark.location!.coordinate.latitude.description
        if addressLines.count > 0 {
            self.formattedAddress = addressLines.joined(separator: ", ")
        } else {
            self.formattedAddress = ""
        }
    }
    
    fileprivate func parseGoogleLocationData(_ resultDict:[String:Any]){
        if let locations = resultDict["results"] as? [[String:Any]] {
            let locationDict = locations.first
            
            let formattedAddrs = locationDict?["formatted_address"] as! String
            
            let geometry = locationDict?["geometry"] as! [String:Any]
            let location = geometry["location"] as! [String:Double]
            self.latitude = String(location["lat"]!)
            self.longitude = String(location["lng"]!)
            
            let addressComponents = locationDict?["address_components"] as! [[String:Any]]
            
            self.subThoroughfare = component("street_number", inArray: addressComponents, ofType: "long_name")
            self.thoroughfare = component("route", inArray: addressComponents, ofType: "long_name")
            self.streetNumber = self.subThoroughfare
            self.locality = component("locality", inArray: addressComponents, ofType: "long_name")
            self.postalCode = component("postal_code", inArray: addressComponents, ofType: "long_name")
            self.route = component("route", inArray: addressComponents, ofType: "long_name")
            self.subLocality = component("subLocality", inArray: addressComponents, ofType: "long_name")
            self.administrativeArea = component("administrative_area_level_1", inArray: addressComponents, ofType: "long_name")
            self.administrativeAreaCode = component("administrative_area_level_1", inArray: addressComponents, ofType: "short_name")
            self.subAdministrativeArea = component("administrative_area_level_2", inArray: addressComponents, ofType: "long_name")
            self.country = component("country", inArray: addressComponents, ofType: "long_name")
            self.ISOcountryCode = component("country", inArray: addressComponents, ofType: "short_name")
            self.formattedAddress = formattedAddrs
        }
    }
    
    fileprivate func component(_ component:String,inArray:[[String:Any]],ofType:String) -> String{
        let index = (inArray as NSArray).indexOfObject(passingTest:) {obj, idx, stop in
            let objDict = obj as! NSDictionary
            let types = objDict.object(forKey: "types") as! NSArray
            let type = types.firstObject as! String
            return type.isEqual(component)
        }
        
        if (index == NSNotFound){
            return ""
        }
        
        if (index >= inArray.count){
            return ""
        }
        
        let type = inArray[index][ofType] as! String
        
        if (type.count > 0){
            return type
        }
        
        return ""
    }
    
    fileprivate func getPlacemark() -> CLPlacemark{
        var addressDict = [String : Any]()
        
        let formattedAddressArray = self.formattedAddress.components(separatedBy: ", ") as [Any]
        
        let kSubAdministrativeArea = "SubAdministrativeArea"
        let kSubLocality           = "SubLocality"
        let kState                 = "State"
        let kStreet                = "Street"
        let kThoroughfare          = "Thoroughfare"
        let kFormattedAddressLines = "FormattedAddressLines"
        let kSubThoroughfare       = "SubThoroughfare"
        let kPostCodeExtension     = "PostCodeExtension"
        let kCity                  = "City"
        let kZIP                   = "ZIP"
        let kCountry               = "Country"
        let kCountryCode           = "CountryCode"
        
        addressDict[kSubAdministrativeArea] = self.subAdministrativeArea
        addressDict[kSubLocality] = self.subLocality
        addressDict[kState] = self.administrativeAreaCode
        
        addressDict[kStreet] = formattedAddressArray.first!
        addressDict[kThoroughfare] = self.thoroughfare
        addressDict[kFormattedAddressLines] = formattedAddressArray
        addressDict[kSubThoroughfare] = self.subThoroughfare
        addressDict[kPostCodeExtension] = ""
        addressDict[kCity] = self.locality
        
        addressDict[kZIP] = self.postalCode
        addressDict[kCountry] = self.country
        addressDict[kCountryCode] = self.ISOcountryCode
        
        let lat = Double(self.latitude)
        let lng = Double(self.longitude)
        let coordinate = CLLocationCoordinate2D(latitude: lat!, longitude: lng!)
        
        let placemark = MKPlacemark(coordinate: coordinate, addressDictionary: addressDict)
        
        return (placemark as CLPlacemark)
    }
    
}

