//
//  TransactionsViewController.swift
//  TaxiDriver
//
//  Created by Priyesh on 17/04/17.
//  Copyright © 2017 icanStudioz. All rights reserved.
//

import UIKit
import Alamofire

class TransactionsViewController: UIViewController {
    @IBOutlet var tableView: UITableView!

    var rides = [Ride]()
    
    //------------------------------------------------------------------------------------------------------------------------------------------
    // MARK:- View Controller Life Cycle
    //------------------------------------------------------------------------------------------------------------------------------------------
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.title = LocalizationSystem.sharedInstance.localizedStringForKey(key: "TransactionsVC_Title", comment: "")
        
        if LocalizationSystem.sharedInstance.getLanguage() == "ar" {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            
            // Here menuViewController is SideDrawer ViewCOntroller
            let sidemenuViewController = storyboard.instantiateViewController(withIdentifier: "MenuViewController") as? MenuViewController
            revealViewController().rightViewController = sidemenuViewController
            self.revealViewController().rightViewRevealWidth = self.view.frame.width * 0.8
            let menuButton = UIBarButtonItem(image: UIImage(named: "menu"),
                                             style: .plain, target: SWRevealViewController(),
                                             action: #selector(SWRevealViewController.rightRevealToggle(_:)))
            self.navigationItem.leftBarButtonItem = menuButton
        }
        else{
            if let revealController = self.revealViewController() {
                revealController.panGestureRecognizer()
                let menuButton = UIBarButtonItem(image: UIImage(named: "menu"),
                                                 style: .plain, target: revealController,
                                                 action: #selector(SWRevealViewController.revealToggle(_:)))
                self.navigationItem.leftBarButtonItem = menuButton
                
            }
        }
        
        loadRequests()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //------------------------------------------------------------------------------------------------------------------------------------------
    // MARK:- API
    //------------------------------------------------------------------------------------------------------------------------------------------
    func loadRequests(){
        let params = ["driver_id":Common.instance.getUserId()]
        let headers = ["X-API-KEY":Common.instance.getAPIKey()]
        
        HUD.show(to: view)
        _ = Alamofire.request(APIRouters.GetTransactions(params,headers)).responseObject { (response: DataResponse<Rides>) in
            HUD.hide(to: self.view)
            if response.result.isSuccess{
                if response.result.value?.status == true{
                    self.rides = (response.result.value?.rides)!
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                } else {
                    Common.showAlert(with: NSLocalizedString("Alert!!", comment: ""), message: NSLocalizedString("No data found.",comment: ""), for: self)
                }
            }
            if response.result.isFailure{
                Common.showAlert(with: NSLocalizedString("Error!!" ,comment: ""), message: response.error?.localizedDescription, for: self)
            }
        }
    }
}

//----------------------------------------------------------------------------------------------------------------------------------------------
// MARK:- Extensions
//----------------------------------------------------------------------------------------------------------------------------------------------
extension TransactionsViewController: UITableViewDelegate,UITableViewDataSource {
    
    //------------------------------------------------------------------------------------------------------------------------------------------
    // MARK:- TableView Delegates And Datasources
    //------------------------------------------------------------------------------------------------------------------------------------------
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rides.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RequestsCell") as! RequestsCell
        
        cell.Fromlbl.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "RequestsCell_Fromlbl", comment: "")
        cell.Tolbl.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "RequestsCell_Tolbl", comment: "")
        cell.Datelbl.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "RequestsCell_Datelbl", comment: "")
        cell.TotalFarelbl.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "RequestsCell_TotalFare", comment: "")
        
        // -- get current Rides Object --
        let currentObj = rides[indexPath.row]
        
        // -- set user name to cell --
        cell.name.text = currentObj.amount
        
        // -- set date and time to cell --
        let currentDate = currentObj.date
        let currentTime = currentObj.time
        ///************************************
        let date = Common.instance.getFormattedDateOnly(date: currentDate)
        let time = Common.instance.getFormattedTimeOnly(date: currentTime)
        cell.dateLabel.text = date
        cell.timeLabel.text = time
        
        // -- set pickup location --
        let origin = currentObj.pickupAdress.components(separatedBy: ",")
        if origin.count > 1{
            cell.streetFrom.text = origin.first
            var addr = origin.dropFirst().joined(separator: ", ")
            cell.detailAdrsFrom.text = String(addr.dropFirst())
        }
        else{
            cell.streetFrom.text = origin.first
            cell.detailAdrsFrom.text = ""
        }
        
        // -- set drop location --
        let destination = currentObj.dropAdress.components(separatedBy: ",")
        if destination.count > 1{
            cell.streetTo.text = destination.first
            var addr = destination.dropFirst().joined(separator: ", ")
            cell.detailAdrsTo.text = String(addr.dropFirst())
        }
        else{
            cell.streetTo.text = destination.first
            cell.detailAdrsTo.text = ""
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // -- push to detail view with required data --
        //let vc = self.storyboard?.instantiateViewController(withIdentifier: "DetailReqViewController") as! DetailReqViewController
        //vc.requestPage = requestPage
        //vc.rideDetail = rides[indexPath.row]
        //self.navigationController?.pushViewController(vc, animated: true)
    }
}
