//
//  MenuViewController.swift
//  Taxi
//
//  Created by Bhavin on 06/03/17.
//  Copyright © 2017 icanStudioz. All rights reserved.
//

import UIKit
import Firebase

class MenuViewController: UIViewController {
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var onlineStatus: UILabel!
    @IBOutlet var nameText: UILabel!
    @IBOutlet var avatar: UIImageView!
    @IBOutlet var statusSwitch: UISwitch!
    
    var menuItems = [String]()
    var selectedIndex = 0
    var photoURL = ""
    
    //----------------------------------------------------------------------------------------------------------------------------------------------
    // MARK:- ViewController Lifecycle
    //----------------------------------------------------------------------------------------------------------------------------------------------
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        menuItems = [LocalizationSystem.sharedInstance.localizedStringForKey(key: "MenuItem0", comment: ""),//0
            LocalizationSystem.sharedInstance.localizedStringForKey(key: "MenuItem21", comment: ""),//maps
            LocalizationSystem.sharedInstance.localizedStringForKey(key: "MenuItem20", comment: ""),
            LocalizationSystem.sharedInstance.localizedStringForKey(key: "MenuItem1", comment: ""),//1
            LocalizationSystem.sharedInstance.localizedStringForKey(key: "MenuItem7", comment: ""),//2transaction history
            LocalizationSystem.sharedInstance.localizedStringForKey(key: "MenuItem5", comment: ""),//3profile
            LocalizationSystem.sharedInstance.localizedStringForKey(key: "MenuItem6", comment: ""),//4 vehicle info
            LocalizationSystem.sharedInstance.localizedStringForKey(key: "MenuItem8", comment: ""),//5 group management
            LocalizationSystem.sharedInstance.localizedStringForKey(key: "MenuItem12", comment: ""),//6social media
            LocalizationSystem.sharedInstance.localizedStringForKey(key: "MenuItem13", comment: ""),//7user comments
            LocalizationSystem.sharedInstance.localizedStringForKey(key: "MenuItem9", comment: ""),//8General Provisions
            LocalizationSystem.sharedInstance.localizedStringForKey(key: "MenuItem15", comment: ""),//9 success
            LocalizationSystem.sharedInstance.localizedStringForKey(key: "MenuItem10", comment: ""),//10about us
            LocalizationSystem.sharedInstance.localizedStringForKey(key: "MenuItem16", comment: ""),//11 contact us
            LocalizationSystem.sharedInstance.localizedStringForKey(key: "MenuItem17", comment: ""),//12Nominate
            LocalizationSystem.sharedInstance.localizedStringForKey(key: "MenuItem11", comment: ""),//13language
            LocalizationSystem.sharedInstance.localizedStringForKey(key: "MenuItem18", comment: ""),//14notification
            LocalizationSystem.sharedInstance.localizedStringForKey(key: "MenuItem19", comment: ""),//15share app
            LocalizationSystem.sharedInstance.localizedStringForKey(key: "MenuItem14", comment: "")]
        tableView.tableFooterView = UIView()
        
        // -- make circle imageview --
        avatar.corner(radius: avatar.frame.width / 2, color: .black, width: 0.0)
        
        //        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        //        view.addGestureRecognizer(tap)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.isUserInteractionEnabled = true
        
        if let data = UserDefaults.standard.data(forKey: "user"){
            let userData = NSKeyedUnarchiver.unarchiveObject(with: data) as? User
            nameText.text = userData?.name
            
            getImgProfile()
            
            //ImageService.getImage(withURL: self.photoURL){ image, url in
            // self.avatar.kf.setImage(with: url)
            // }
            
            
            if Common.instance.isOnline() {
                statusSwitch.isOn = true
                onlineStatus.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "onlineStatus", comment: "")
            } else {
                statusSwitch.isOn = false
                onlineStatus.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "offlineStatus", comment: "")
            }
        }
    }
    func getImgProfile() {
        
        Database
            .database()
            .reference()
            .child("users")
            .child("profile")
            .child(Auth.auth().currentUser!.uid)
            .queryOrderedByKey()
            .observeSingleEvent(of: .value, with: { snapshot in
                
                guard let dict = snapshot.value as? [String:Any] else {
                    print("Error")
                    return
                }
                
                self.photoURL = (dict["photoURL"] as? String)!
                if let urlString = URL(string: (self.photoURL)){
                    
                    self.avatar.kf.setImage(with: urlString)
                }
                print("tttttttt",self.photoURL)
                // let priceAd = dict["priceAd"] as? String
            })
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func switchValueChanged(_ sender: UISwitch) {
        if sender.isOn {
            onlineStatus.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "onlineStatus", comment: "")
            updateStatus(status: "1")
        }
        else{
            onlineStatus.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "offlineStatus", comment: "")
            updateStatus(status: "0")
        }
    }
    
    //----------------------------------------------------------------------------------------------------------------------------------------------
    // MARK:- API Requests
    //----------------------------------------------------------------------------------------------------------------------------------------------
    func updateStatus(status:String){
        var params = [String:String]()
        params["user_id"] = Common.instance.getUserId()
        params["is_online"] = status
        
        let headers = ["X-API-KEY":Common.instance.getAPIKey()]
        
        APIRequestManager.request(apiRequest: APIRouters.UpdateUser(params,headers), success: { (responseData) in
            if let data = responseData as? [String:String] {
                if let user = UserDefaults.standard.data(forKey: "user"){
                    let userData = NSKeyedUnarchiver.unarchiveObject(with: user) as? User
                    userData?.onlineStatus = data["is_online"]
                    let encodedData = NSKeyedArchiver.archivedData(withRootObject: userData!)
                    UserDefaults.standard.set(encodedData, forKey: "user")
                }
            }
        }, failure: { (message) in
            Common.showAlert(with: NSLocalizedString("Alert!!", comment: ""), message: message, for: self)
        }, error: { (err) in
            Common.showAlert(with: NSLocalizedString("Error!!" ,comment: ""), message: err.localizedDescription, for: self)
        })
    }
    
}

//--------------------------------------------------------------------------------------------------------------------------------------------------
// MARK:- Extensions
//--------------------------------------------------------------------------------------------------------------------------------------------------
extension MenuViewController: UITableViewDelegate,UITableViewDataSource {
    
    //----------------------------------------------------------------------------------------------------------------------------------------------
    // MARK:- UITableView Delegate And DataSource
    //----------------------------------------------------------------------------------------------------------------------------------------------
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        
        let textLabel = cell?.contentView.viewWithTag(10) as? UILabel
        textLabel?.text = menuItems[indexPath.row]
        
        if selectedIndex == indexPath.row {
            textLabel?.textColor = UIColor(red: 255/255.0, green: 202/255.0, blue: 38/255.0, alpha: 1.0)
        }
        else{
            textLabel?.textColor = UIColor.darkGray
        }
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedIndex = indexPath.row
        tableView.reloadData()
        
        tableView.isUserInteractionEnabled = false
        switch indexPath.row {
            //        case 0:
            //            let vc  = self.storyboard?.instantiateViewController(withIdentifier: "MapViewController") as! MapViewController
            //            let nav = UINavigationController(rootViewController: vc)
            //            nav.setViewControllers([vc], animated:true)
            //            self.revealViewController().setFront(nav, animated: true)
        //            self.revealViewController().pushFrontViewController(nav, animated: true)
        case 0:
            let vc  = self.storyboard?.instantiateViewController(withIdentifier: "HomeViewController") as! HomeViewController
            let nav = UINavigationController(rootViewController: vc)
            nav.setViewControllers([vc], animated:true)
            self.revealViewController().setFront(nav, animated: true)
            self.revealViewController().pushFrontViewController(nav, animated: true)
        case 1:
            let vc  = self.storyboard?.instantiateViewController(withIdentifier: "MapViewController") as! MapViewController
            let nav = UINavigationController(rootViewController: vc)
            nav.setViewControllers([vc], animated:true)
            self.revealViewController().setFront(nav, animated: true)
            self.revealViewController().pushFrontViewController(nav, animated: true)
        case 2:
            let vc  = self.storyboard?.instantiateViewController(withIdentifier: "AcceptRequestsViewController") as! AcceptRequestsViewController
            let nav = UINavigationController(rootViewController: vc)
            nav.setViewControllers([vc], animated:true)
            self.revealViewController().setFront(nav, animated: true)
            self.revealViewController().pushFrontViewController(nav, animated: true)
        case 3:
//            let vc  = self.storyboard?.instantiateViewController(withIdentifier: "RequestsViewController") as! RequestsViewController
            let vc  = self.storyboard?.instantiateViewController(withIdentifier: "TravelsReqViewController") as! TravelsReqViewController
            vc.requestPage = TravelRequestView.all_requests
            let nav = UINavigationController(rootViewController: vc)
            nav.setViewControllers([vc], animated:true)
            self.revealViewController().setFront(nav, animated: true)
            self.revealViewController().pushFrontViewController(nav, animated: true)
        case 4:
            let vc  = self.storyboard?.instantiateViewController(withIdentifier: "TransactionsViewController") as! TransactionsViewController
            let nav = UINavigationController(rootViewController: vc)
            nav.setViewControllers([vc], animated:true)
            self.revealViewController().setFront(nav, animated: true)
            self.revealViewController().pushFrontViewController(nav, animated: true)
        case 5:
            let vc  = self.storyboard?.instantiateViewController(withIdentifier: "ProfileVC") as! ProfileVC
            let nav = UINavigationController(rootViewController: vc)
            nav.setViewControllers([vc], animated:true)
            self.revealViewController().setFront(nav, animated: true)
            self.revealViewController().pushFrontViewController(nav, animated: true)
        case 6:
            let vc  = self.storyboard?.instantiateViewController(withIdentifier: "VehicleTableViewController") as! VehicleTableViewController
            let nav = UINavigationController(rootViewController: vc)
            nav.setViewControllers([vc], animated:true)
            self.revealViewController().setFront(nav, animated: true)
            self.revealViewController().pushFrontViewController(nav, animated: true)
        case 7:
            let vc  = self.storyboard?.instantiateViewController(withIdentifier: "GroupManagementViewController") as! GroupManagementViewController
            let nav = UINavigationController(rootViewController: vc)
            nav.setViewControllers([vc], animated:true)
            self.revealViewController().setFront(nav, animated: true)
            self.revealViewController().pushFrontViewController(nav, animated: true)
        case 8:
            let vc  = self.storyboard?.instantiateViewController(withIdentifier: "PlatformViewController") as! PlatformViewController
            let nav = UINavigationController(rootViewController: vc)
            nav.setViewControllers([vc], animated:true)
            self.revealViewController().setFront(nav, animated: true)
            self.revealViewController().pushFrontViewController(nav, animated: true)
        case 9:
            if #available(iOS 11.0, *) {
                let vc  = self.storyboard?.instantiateViewController(withIdentifier: "UserCommentsViewController") as! UserCommentsViewController
                let nav = UINavigationController(rootViewController: vc)
                nav.setViewControllers([vc], animated:true)
                self.revealViewController().setFront(nav, animated: true)
                self.revealViewController().pushFrontViewController(nav, animated: true)
            }
        case 10:
            let vc  = self.storyboard?.instantiateViewController(withIdentifier: "ProvisionsViewController") as! ProvisionsViewController
            let nav = UINavigationController(rootViewController: vc)
            nav.setViewControllers([vc], animated:true)
            self.revealViewController().setFront(nav, animated: true)
            self.revealViewController().pushFrontViewController(nav, animated: true)
        case 11:
            let vc  = self.storyboard?.instantiateViewController(withIdentifier: "ProfitViewController") as! ProfitViewController
            let nav = UINavigationController(rootViewController: vc)
            nav.setViewControllers([vc], animated:true)
            self.revealViewController().setFront(nav, animated: true)
            self.revealViewController().pushFrontViewController(nav, animated: true)
        case 12:
            let vc  = self.storyboard?.instantiateViewController(withIdentifier: "AboutUsViewController") as! AboutUsViewController
            let nav = UINavigationController(rootViewController: vc)
            nav.setViewControllers([vc], animated:true)
            self.revealViewController().setFront(nav, animated: true)
            self.revealViewController().pushFrontViewController(nav, animated: true)
        case 13:
            let vc  = self.storyboard?.instantiateViewController(withIdentifier: "ContactUsViewController") as! ContactUsViewController
            let nav = UINavigationController(rootViewController: vc)
            nav.setViewControllers([vc], animated:true)
            self.revealViewController().setFront(nav, animated: true)
            self.revealViewController().pushFrontViewController(nav, animated: true)
        case 14:
            let vc  = self.storyboard?.instantiateViewController(withIdentifier: "NominateDriverViewController") as! NominateDriverViewController
            let nav = UINavigationController(rootViewController: vc)
            nav.setViewControllers([vc], animated:true)
            self.revealViewController().setFront(nav, animated: true)
            self.revealViewController().pushFrontViewController(nav, animated: true)
        case 15:
            let vc  = self.storyboard?.instantiateViewController(withIdentifier: "LanguageViewController") as! LanguageViewController
            let nav = UINavigationController(rootViewController: vc)
            nav.setViewControllers([vc], animated:true)
            self.revealViewController().setFront(nav, animated: true)
            self.revealViewController().pushFrontViewController(nav, animated: true)
        case 16:
            let vc  = self.storyboard?.instantiateViewController(withIdentifier: "NotificationsViewController") as! NotificationsViewController
            let nav = UINavigationController(rootViewController: vc)
            nav.setViewControllers([vc], animated:true)
            self.revealViewController().setFront(nav, animated: true)
            self.revealViewController().pushFrontViewController(nav, animated: true)
        case 17:
            let items = ["Let me recommend you this application\n","https://apps.apple.com/us/app/roamu-driver/id1509211736"]
            let ac = UIActivityViewController(activityItems: items, applicationActivities: nil)
            present(ac, animated: true)
        case 18:
            Common.instance.removeUserdata()
            self.revealViewController().revealToggle(nil)
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "SplashViewController") as! SplashViewController
            let nav = UINavigationController(rootViewController: vc)
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.window?.rootViewController = nav
        default:
            break;
        }
    }
}
