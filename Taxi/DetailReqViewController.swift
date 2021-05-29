//
//  DetailReqViewController.swift
//  Taxi
//
//  Created by Bhavin on 10/03/17.
//  Copyright © 2017 icanStudioz. All rights reserved.
//

import UIKit
import Firebase

class DetailReqViewController: UIViewController {
    
    @IBOutlet var UserAvatar: UIImageView!
    
    @IBOutlet var name: UILabel!
    @IBOutlet var pickupLoc: UILabel!
    @IBOutlet var dropLoc: UILabel!
    @IBOutlet var fare: UILabel!
    @IBOutlet var status: UILabel!
    @IBOutlet var acceptButton: UIButton!
    @IBOutlet var cancelButton: UIButton!
    @IBOutlet var offlinePaymentButton: UIButton!
    
    @IBOutlet var time: UILabel!
    @IBOutlet var PickUpPoint: UILabel!
    @IBOutlet var date: UILabel!
    
    @IBOutlet var Namelbl: UILabel!
    @IBOutlet var PickupAddlbl: UILabel!
    @IBOutlet var DropAddlbl: UILabel!
    @IBOutlet var Farelbl: UILabel!
    @IBOutlet var PaymentStatuslbl: UILabel!
    
    @IBOutlet var Timelbl: UILabel!
    @IBOutlet var PickupPointlbl: UILabel!
    @IBOutlet var datelbl: UILabel!
    
    var requestPage:RequestView?
    var rideDetail:Ride?
    
    var travel_status = ""
    var paymentMode = ""
    var paymentStatus = ""
    
    var seeNewPostsButton:SeeNewPostsButton!
    var seeNewPostsButtonTopAnchor:NSLayoutConstraint!
    var postListenerHandle:UInt?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Passenger Information"
        
        let homeButton = UIBarButtonItem(image: UIImage(named: "homeButton"),
                                         style: .plain,
                                         target: self,
                                         action: #selector(self.homeWasClicked(_:)))
        self.navigationItem.rightBarButtonItem = homeButton
        
        Namelbl.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "DetailReqVCNamelbl", comment: "")
        PickupAddlbl.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "DetailReqVCPickupAddlbl", comment: "")
        DropAddlbl.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "DetailReqVCDropAddlbl", comment: "")
        Farelbl.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "DetailReqVCFarelbl", comment: "")
        PaymentStatuslbl.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "DetailReqVCPaymentStatuslbl", comment: "")
        Timelbl.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "DetailReqVCTimelbl", comment: "")
        datelbl.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "DetailReqVCdatelbl", comment: "")
        PickupPointlbl.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "DetailReqVCPickupPointlbl", comment: "")
        
        var layoutGuide:UILayoutGuide!
        
        if #available(iOS 11.0, *) {
            layoutGuide = view.safeAreaLayoutGuide
        } else {
            // Fallback on earlier versions
            layoutGuide = view.layoutMarginsGuide
        }
        
        seeNewPostsButton = SeeNewPostsButton()
        seeNewPostsButton.button.setTitle(LocalizationSystem.sharedInstance.localizedStringForKey(key: "DetailReqVC_refreshButton", comment: ""), for: .normal)
        view.addSubview(seeNewPostsButton)
        seeNewPostsButton.translatesAutoresizingMaskIntoConstraints = false
        seeNewPostsButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        seeNewPostsButtonTopAnchor = seeNewPostsButton.topAnchor.constraint(equalTo: layoutGuide.topAnchor, constant: -44)
        seeNewPostsButtonTopAnchor.isActive = true
        seeNewPostsButton.heightAnchor.constraint(equalToConstant: 32.0).isActive = true
        seeNewPostsButton.widthAnchor.constraint(equalToConstant: seeNewPostsButton.button.bounds.width).isActive = true
        seeNewPostsButton.button.addTarget(self, action: #selector(handleRefresh), for: .touchUpInside)
        
        //
        self.travel_status = rideDetail?.Travel_Status as! String
        self.paymentMode = rideDetail?.paymentMode as! String
        self.paymentStatus = rideDetail?.paymentStatus as! String
        setupData()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        listenForNewRefresh()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func homeWasClicked(_ sender: UIButton) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "HomeViewController") as! HomeViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func setupData(){
        // -- setup title for button according to page requests --
        
        if requestPage == RequestView.accepted {
            if (travel_status == "PENDING")
            {
                //                print("yes")
                acceptButton.setTitle(LocalizationSystem.sharedInstance.localizedStringForKey(key: "DetailReqVC_Start", comment: ""), for: .normal)
            }
            else
            {
                
                //                print("no")
                acceptButton.isHidden = true
                acceptButton.setTitle(LocalizationSystem.sharedInstance.localizedStringForKey(key: "DetailReqVC_Track", comment: ""), for: .normal)
                cancelButton.setTitle(LocalizationSystem.sharedInstance.localizedStringForKey(key: "DetailReqVC_Cancel", comment: ""), for: .normal)
            }
        }
        
        if requestPage == RequestView.pending {
            acceptButton.setTitle(LocalizationSystem.sharedInstance.localizedStringForKey(key: "DetailReqVC_Accept", comment: ""), for: .normal)
            cancelButton.setTitle(LocalizationSystem.sharedInstance.localizedStringForKey(key: "DetailReqVC_Cancel", comment: ""), for: .normal)
        }
        
        // Buttons
        if requestPage == RequestView.accepted || requestPage == RequestView.pending
        {
            if (travel_status == "PENDING")
            {
                //                print("buttons pending")
                cancelButton.isHidden = true
                acceptButton.isHidden = false
            }
            else
            {
                //                print("buttons not pending")
                 acceptButton.isHidden = false
                cancelButton.isHidden = false
            }
        }
        else
        {
            //            print("buttons else")
            acceptButton.isHidden = true
            cancelButton.isHidden = true
        }
        
        // ibrahim commented on this code
        
        if requestPage == RequestView.cancelled || requestPage == RequestView.completed {
            //            print("request page cancelled or completed")
            offlinePaymentButton.isHidden = true
            acceptButton.isHidden = true
            cancelButton.isHidden = true
        }
        
        // -- setup back button --
        let backButton = UIBarButtonItem(image: UIImage(named: "arrow-left"),
                                         style: .plain, target: self,
                                         action: #selector(self.backWasPressed))
        self.navigationItem.leftBarButtonItem = backButton
        
        // -- setup ride data --
        name.text = rideDetail?.userName
        
        pickupLoc.text = rideDetail?.pickupAdress
        dropLoc.text = rideDetail?.dropAdress
        fare.text = rideDetail?.amount
        status.text = self.paymentStatus
        time.text = rideDetail?.time ?? ""
        date.text = rideDetail?.date ?? ""
        //by ibrahim
        PickUpPoint.text = rideDetail?.pickup_point ?? ""
        
        if let urlString = URL(string: (rideDetail?.userAvatar)!){
            UserAvatar.kf.setImage(with: urlString)
        }
        
        // ibrahim was here
        // offline button
        if self.paymentMode != "OFFLINE"
        {
            offlinePaymentButton.isHidden = true
        }
        else
        {
            if (travel_status == "PENDING")
            {
                offlinePaymentButton.isHidden = true
            }
            else
            {
                offlinePaymentButton.isHidden = false
                offlinePaymentButton.setTitle(LocalizationSystem.sharedInstance.localizedStringForKey(key: "DetailReqVC_offlinePayment", comment: ""), for: .normal)
                if self.paymentStatus == "PAID"
                {
                    offlinePaymentButton.isHidden = true
                }
            }
        }
        
        if self.paymentStatus != "" {
            if self.paymentMode == "OFFLINE" && self.paymentStatus != "PAID" {
                status.text = "Cash On Hand (Driver)"
                acceptButton.isHidden = false
                cancelButton.isHidden = false
            }
            else {
                //----------------------------------------------
                // edit by ibrahim, to handle complete case
                //acceptButton.isHidden = true
                acceptButton.isHidden = false
                acceptButton.setTitle(LocalizationSystem.sharedInstance.localizedStringForKey(key: "DetailReqVC_Complete", comment: ""), for: .normal)
                //----------------------------------------------
                cancelButton.isHidden = true
                status.text = self.paymentStatus
            }
        }
        
        if requestPage == RequestView.cancelled || requestPage == RequestView.completed {
            //            print("request page cancelled or completed")
            offlinePaymentButton.isHidden = true
            acceptButton.isHidden = true
            cancelButton.isHidden = true
        }
        
    }
    
    @IBAction func acceptWasPressed(_ sender: UIButton) {
        if requestPage == RequestView.pending{
            sendRequests(with: "ACCEPTED")
            //            print("ACCEPTED")
        }
            //----------------------------------------------
            // edit by ibrahim, to handle complete case
        else if self.paymentMode == "OFFLINE" && self.paymentStatus == "PAID"
        {
            //            print("COMPLETED")
            sendRequests(with: "COMPLETED")
        }
            //----------------------------------------------
        else
        {
            if (travel_status == "PENDING")
            {
                sendRequests(with: "ACCEPTED")
                //let vc
            }
            else
            {
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "TrackRideViewController") as! TrackRideViewController
                vc.currentRide = rideDetail
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    @IBAction func offlinePaymentWasPressed(_ sender: Any) {
        sendPaymentRequests(with: "PAID")
    }
    
    @IBAction func cancelWasPressed(_ sender: UIButton) {
        sendRequests(with: "CANCELLED")
    }
    
    @objc func backWasPressed(){
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    func sendRequests(with status:String){
        var params = [String:String]()
        if (requestPage == RequestView.accepted && travel_status == "PENDING")
        {
            print("sendRequests pending")
            travel_status = "STARTED"
            params = ["ride_id":rideDetail!.rideId,"status":status, "travel_id":rideDetail!.travelId, "travel_status":self.travel_status]
        }
        else
        {
            if status == "ACCEPTED"{
                print("status accepted")
                travel_status = "PENDING"
            }
            else if status == "COMPLETED"
            {
                travel_status = "COMPLETED"
            }
            else{
                print("status not accepted")
                travel_status = "PENDING" // for later to be fixed by ibrahim
            }
            print("sendRequests not pending")
            params = ["ride_id":rideDetail!.rideId,"status":status, "travel_id":rideDetail!.travelId, "travel_status":self.travel_status]
        }
        print("ibrahim before params")
        print(params)
        let headers = ["X-API-KEY":Common.instance.getAPIKey()]
        
        HUD.show(to: view)
        APIRequestManager.request(apiRequest: APIRouters.UpdateRides(params, headers), success: { (response) in
            HUD.hide(to: self.view)
            if response is String {
                let alert = UIAlertController(title: NSLocalizedString("Success!!", comment: ""), message: response as? String, preferredStyle: .alert)
                let done = UIAlertAction(title: NSLocalizedString("Done", comment: ""), style: .default, handler: { (action) in
//                    self.backWasPressed()
                    print("status by ibrahim")
                    print(status)
                    print(self.requestPage?.rawValue)
                    print(self.travel_status)
                    if (self.requestPage == RequestView.accepted && self.travel_status == "STARTED"){
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "AcceptDetailReqViewController") as! AcceptDetailReqViewController
                        vc.requestPage = RequestView.accepted
                        vc.rideDetail = self.rideDetail
                        vc.rideDetail?.Travel_Status = self.travel_status
                        vc.rideDetail?.paymentMode = self.paymentMode
                        vc.rideDetail?.paymentStatus = self.paymentStatus
                        
                        self.navigationController?.pushViewController(vc, animated: true)
                    }
                    else if (self.travel_status == "COMPLETED"){
                        let vc = self.storyboard?.instantiateViewController(withIdentifier: "HomeViewController") as! HomeViewController
                         self.navigationController?.pushViewController(vc, animated: true)
                    }
                    self.updateRideFirebase(with:status,travel_status: self.travel_status, paymentStatus: self.paymentStatus, paymentMode: self.paymentMode)
                    self.updateNotificationFirebase(with:status)
                    
                    if status == "ACCEPTED"{
                        print("ibrahim_accepted")
                        self.updateTravelFirebase()
                    }
                    
                    
                })
                alert.addAction(done)
                self.present(alert, animated: true, completion: nil)
            }
        }, failure: { (message) in
            HUD.hide(to: self.view)
            Common.showAlert(with: NSLocalizedString("Alert!!", comment: ""), message: message, for: self)
        }, error: { (err) in
            HUD.hide(to: self.view)
            Common.showAlert(with: NSLocalizedString("Error!!" ,comment: ""), message: err.localizedDescription, for: self)
        })
    }
    
    func sendPaymentRequests(with status:String){
        let params = ["ride_id":rideDetail!.rideId,"payment_status":status]
        let headers = ["X-API-KEY":Common.instance.getAPIKey()]
        
        HUD.show(to: view)
        APIRequestManager.request(apiRequest: APIRouters.UpdateRides(params, headers), success: { (response) in
            HUD.hide(to: self.view)
            if response is String {
                let alert = UIAlertController(title: NSLocalizedString("Success!!", comment: ""), message: response as? String, preferredStyle: .alert)
                let done = UIAlertAction(title: NSLocalizedString("Done", comment: ""), style: .default, handler: { (action) in
//                    self.backWasPressed()
                })
                self.updateRideFirebase(with: self.requestPage!.rawValue, travel_status: self.travel_status, paymentStatus: status, paymentMode: self.paymentMode)
                self.updateNotificationFirebase(with: self.requestPage!.rawValue)
                alert.addAction(done)
                self.present(alert, animated: true, completion: nil)
            }
        }, failure: { (message) in
            HUD.hide(to: self.view)
            Common.showAlert(with: NSLocalizedString("Alert!!", comment: ""), message: message, for: self)
        }, error: { (err) in
            HUD.hide(to: self.view)
            Common.showAlert(with: NSLocalizedString("Error!!" ,comment: ""), message: err.localizedDescription, for: self)
        })
    }
    
    @objc func handleRefresh() {
//        toggleSeeNewPostsButton(hidden: true)
    }
    
    func toggleSeeNewPostsButton(hidden:Bool) {
        if hidden {
            // hide it
            UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseOut, animations: {
                self.seeNewPostsButtonTopAnchor.constant = -44.0
                self.view.layoutIfNeeded()
            }, completion: nil)
        } else {
            // show it
            UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseOut, animations: {
                self.seeNewPostsButtonTopAnchor.constant = 12
                self.view.layoutIfNeeded()
            }, completion: nil)
        }
    }
    
    func listenForNewRefresh() {
        postListenerHandle = Database.database().reference().child("rides").child(rideDetail!.rideId).observe(.childChanged, with: { snapshot in
            print("ibrahim snapshot")
            print(snapshot.value)
            if let data = snapshot.value as? String{
                if snapshot.key == "ride_status"
                {
                    if data == "PENDING"
                    {
                        self.requestPage = RequestView.pending
                    }
                    else if data == "ACCEPTED"
                    {
                        self.requestPage = RequestView.accepted
                    }
                    else if data == "COMPLETED"
                    {
                        self.requestPage = RequestView.completed
                    }
                    else if data == "CANCELLED"
                    {
                        self.requestPage = RequestView.cancelled
                    }
                }
                else if snapshot.key == "travel_status"
                {
                    self.travel_status = data
                }
                else if snapshot.key == "payment_status"
                {
                    self.paymentStatus = data
                }
                else if snapshot.key == "payment_mode"
                {
                    self.paymentMode = data
                }
                else if snapshot.key == "timestamp"
                {
                    print("timestamp")
                }
//                self.toggleSeeNewPostsButton(hidden: false)
                self.setupData()
            }
        })
    }
    
    func updateRideFirebase(with status:String, travel_status:String, paymentStatus:String, paymentMode:String) {
        let postRef = Database.database().reference().child("rides").child(rideDetail!.rideId)
        let postObject = [
            "timestamp": [".sv":"timestamp"],
            "ride_status": status,
            "travel_status": travel_status,
            "payment_status": paymentStatus,
            "payment_mode": paymentMode] as [String:Any]
        postRef.setValue(postObject, withCompletionBlock: { error, ref in
            if error == nil {
            } else {
            }
        })
    }
    
    func updateNotificationFirebase(with status:String) {
        let postRef = Database.database().reference().child("Notifications").child(rideDetail!.userId).childByAutoId()
        let postObject = [
            "ride_id": rideDetail!.rideId,
            "text": LocalizationSystem.sharedInstance.localizedStringForKey(key: "Notification_ride_updated", comment: "") + status,
            "readStatus": "0",
            "timestamp": [".sv":"timestamp"],
            "uid": Auth.auth().currentUser?.uid] as [String:Any]
        postRef.setValue(postObject, withCompletionBlock: { error, ref in
            if error == nil {
            } else {
            }
        })
    }
    
    func updateTravelFirebase() {
        print("updateTravelFirebase")
        let postRef = Database.database().reference().child("Travels").child(rideDetail!.travelId).child("Clients").child(rideDetail!.userId)
        postRef.setValue(rideDetail!.userId, withCompletionBlock: { error, ref in
            if error == nil {
            } else {
            }
        })
    }
}
