//
//  TravelsNotesReqViewController.swift
//  TaxiDriver
//
//  Created by ibrahim.marie on 8/15/21.
//  Copyright © 2021 icanStudioz. All rights reserved.
//

import UIKit
import Alamofire

class TravelsNotesReqViewController: UIViewController {
    
    @IBOutlet var tableView: UITableView!
    
    var rides = [Ride]()
    var travel_id = "0"

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.getTravelNotes(with: travel_id)
        
    }
    
    func getTravelNotes(with travel_id:String){
            print("ibrahim")
            print("getMyTravel")
            print(travel_id)
            let params = ["travel_id":travel_id]
            let headers = ["X-API-KEY":Common.instance.getAPIKey()]
            //            print(Common.instance.getUserId())
            //HUD.show(to: view)
            _ = Alamofire.request(APIRouters.rides_notes(params,headers)).responseObject { (response: DataResponse<Rides>) in
                //hud.hide(to: self.view)
                print("ibrahim was here")
                print(response)
                if response.result.isSuccess{
                    if response.result.value?.status == true , ((response.result.value?.rides) != nil) {
                        print("rides")
                        self.rides = (response.result.value?.rides)!
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                        }
                    } else {
                        Common.showAlert(with: NSLocalizedString("Alert!!", comment: ""), message: "No data found.", for: self)
                    }
                }
                
                if response.result.isFailure{
                    Common.showAlert(with: NSLocalizedString("Error!!", comment: ""), message: response.error?.localizedDescription, for: self)
                }
            }
        }
}

extension TravelsNotesReqViewController: UITableViewDelegate,UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rides.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "NotesCell") as! NotesCell
        cell = tableView.dequeueReusableCell(withIdentifier: "NotesCell") as! NotesCell
        
        cell.UserNamelbl.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "ContactUsVC_Name", comment: "")
        cell.UserNotelbl.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "notes", comment: "")
        
        // -- get current Rides Object --
        let currentObj = rides[indexPath.row]
        // -- set driver name to cell --
        cell.UserNameVar.text = currentObj.userName
        
        cell.UserNoteVar.text = currentObj.ride_notes
        return cell
    }
}
