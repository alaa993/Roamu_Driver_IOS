//
//  GoogleSearchViewController.swift
//  TaxiDriver
//
//  Created by ibrahim.marie on 7/5/20.
//  Copyright © 2020 icanStudioz. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class GoogleSearchViewController: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet weak var textfieldAddress: UITextField!
    @IBOutlet weak var tableviewSearch: UITableView!
    @IBOutlet weak var constraintSearchIconWidth: NSLayoutConstraint!
    @IBOutlet weak var searchView: UIView!
    @IBOutlet weak var mapview: MKMapView!
    
    @IBOutlet var ConfirmButton: UIButton!
    
    
    var autocompleteResults :[GApiResponse.Autocomplete] = []
    
    var MKLocalSearchDictionary = [String:Any]()
    var delegate: isAbleToReceiveData?
    var PassData = false
    
    override func viewDidLoad() {

        super.viewDidLoad()
        ConfirmButton.setTitle(LocalizationSystem.sharedInstance.localizedStringForKey(key: "GoogleSearchVC_ConfirmButton", comment: ""), for: .normal)
        

    }
    
    
    
    override func viewWillDisappear(_ animated: Bool) {
        if PassData
        {
            print(MKLocalSearchDictionary)
            delegate!.pass(ResultSearchDictionary: MKLocalSearchDictionary)
        }
    }

    @IBAction func searchButtonPressed(_ sender: Any) {
        textfieldAddress.becomeFirstResponder()
    }
    
    func showResults(string:String){
        var input = GInput()
        input.keyword = string
        GoogleApi.shared.callApi(input: input) { (response) in
            if response.isValidFor(.autocomplete) {
                DispatchQueue.main.async {
                    self.searchView.isHidden = false
                    self.autocompleteResults = response.data as! [GApiResponse.Autocomplete]
                    self.tableviewSearch.reloadData()
                }
            } else { print(response.error ?? "ERROR") }
        }
    }
    
    func hideResults(){
        searchView.isHidden = true
        autocompleteResults.removeAll()
        tableviewSearch.reloadData()
    }
    
    @IBAction func ConfirmButtonClicked(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
}

extension GoogleSearchViewController : UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        hideResults() ; return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let text = textField.text! as NSString
        let fullText = text.replacingCharacters(in: range, with: string)
        if fullText.count > 2 {
            showResults(string:fullText)
        }else{
            hideResults()
        }
        return true
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        constraintSearchIconWidth.constant = 0.0 ; return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        constraintSearchIconWidth.constant = 38.0 ; return true
    }
}

extension GoogleSearchViewController : MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        var input = GInput()
        let destination = GLocation.init(latitude: mapview.region.center.latitude, longitude: mapview.region.center.longitude)
//        let destination = GLocation.init(latitude: 33.50094, longitude: 36.245515)
        input.destinationCoordinate = destination
        GoogleApi.shared.callApi(.reverseGeo , input: input) { (response) in
            if let places = response.data as? [GApiResponse.ReverseGio], response.isValidFor(.reverseGeo) {
                DispatchQueue.main.async {
                    self.textfieldAddress.text = places.first?.formattedAddress
                   // by ibrahim
                    self.PassData = true
                    print("Places from ibrahim")
                    print(places.first)
                    self.MKLocalSearchDictionary = ["title": places.first?.formattedAddress ?? "",
                        "latitude": self.mapview.region.center.latitude,
                        "longitude": self.mapview.region.center.longitude]
                }
            } else { print(response.error ?? "ERROR") }
        }
    }
}

extension GoogleSearchViewController : UITableViewDataSource,UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return autocompleteResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "searchResultCell")
        let label = cell?.viewWithTag(1) as! UILabel
        label.text = autocompleteResults[indexPath.row].formattedAddress
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        textfieldAddress.text = autocompleteResults[indexPath.row].formattedAddress
        
        textfieldAddress.resignFirstResponder()
        var input = GInput()
        input.keyword = autocompleteResults[indexPath.row].placeId
        GoogleApi.shared.callApi(.placeInformation,input: input) { (response) in
            if let place =  response.data as? GApiResponse.PlaceInfo, response.isValidFor(.placeInformation) {
                DispatchQueue.main.async {
                    self.searchView.isHidden = true
                    if let lat = place.latitude, let lng = place.longitude{
                        let center  = CLLocationCoordinate2D(latitude: lat, longitude: lng)
                        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
                        // by ibrahim
                        self.PassData = true
                        self.MKLocalSearchDictionary = ["title": self.autocompleteResults[indexPath.row].formattedAddress ,
                        "latitude": lat,
                        "longitude": lng]
                        
                        self.mapview.setRegion(region, animated: true)
                    }
                    print("ibrahim latlng")
                    print(place.latitude!)
                    print(place.longitude!)
                    self.tableviewSearch.reloadData()
                }
            } else { print(response.error ?? "ERROR") }
        }
    }
}
