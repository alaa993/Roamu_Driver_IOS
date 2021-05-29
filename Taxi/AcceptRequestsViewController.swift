import UIKit
import Alamofire

class AcceptRequestsViewController: UIViewController{
    @IBOutlet var tableView: UITableView!
    
    var rides = [Ride]()
    var travels = [Travel]()
    var SearchData = [String:Any]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func cancelWasClicked(_ sender: UIButton) {
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func cancelWasClicked1(_ sender: UIButton) {
        _ = self.navigationController?.popToRootViewController(animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadRequests(with: "ACCEPTED")
    }
    
    func loadRequests(with status:String){
        let params = ["id":Common.instance.getUserId(),"status":status,"utype":"1"]
        let headers = ["X-API-KEY":Common.instance.getAPIKey()]
        //            print(Common.instance.getUserId())
        HUD.show(to: view)
        _ = Alamofire.request(APIRouters.GetRides(params,headers)).responseObject { (response: DataResponse<Rides>) in
            HUD.hide(to: self.view)
            //                print("ibrahim was here")
            //                print(response)
            if response.result.isSuccess{
                if response.result.value?.status == true , ((response.result.value?.rides) != nil) {
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

extension AcceptRequestsViewController: UITableViewDelegate,UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rides.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "RequestsCell") as! RequestsCell
        
        cell = tableView.dequeueReusableCell(withIdentifier: "RequestsCell") as! RequestsCell
        
        cell.Fromlbl.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "RequestsCell_Fromlbl", comment: "")
        cell.Tolbl.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "RequestsCell_Tolbl", comment: "")
        cell.Datelbl.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "RequestsCell_Datelbl", comment: "")
        cell.DriverNamelbl.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "RequestsCell_Namelbl", comment: "")
        cell.ReqTypelbl.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "RequestsVCReqlbl", comment: "")
        
        // -- get current Rides Object --
        let currentObj = rides[indexPath.row]
        // -- set driver name to cell --
        cell.name.text = currentObj.userName
        cell.ReqTypeVal.text = currentObj.status
        
        // -- set date and time to cell --
        ///************************************
        let currentDate = currentObj.date
        let currentTime = currentObj.time
        ///************************************
        let date = Common.instance.getFormattedDateOnly(date: currentDate)
        let time = Common.instance.getFormattedTimeOnly(date: currentTime)
        cell.dateLabel.text = date
        let inFormatter = DateFormatter()
        inFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX") as Locale
        inFormatter.dateFormat = "HH:mm:ss"
        
        let outFormatter = DateFormatter()
        outFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX") as Locale
        outFormatter.dateFormat = "HH:mm"
        
        let date_ = inFormatter.date(from: time)!
        let outStr = outFormatter.string(from: date_)
        
        cell.timeLabel.text = outStr
        
        // -- set pickup location --
        let origin = currentObj.pickupAdress.components(separatedBy: ",")
        if origin.count > 1{
            cell.streetFrom.text = origin.first
            var addr = origin.dropFirst().joined(separator: ", ")
            cell.detailAdrsFrom.text = String(addr.dropFirst())
        } else {
            cell.streetFrom.text = origin.first
            cell.detailAdrsFrom.text = ""
        }
        
        // -- set drop location --
        let destination = currentObj.dropAdress.components(separatedBy: ",")
        if destination.count > 1{
            cell.streetTo.text = destination.first
            var addr = destination.dropFirst().joined(separator: ", ")
            cell.detailAdrsTo.text = String(addr.dropFirst())
        } else {
            cell.streetTo.text = destination.first
            cell.detailAdrsTo.text = ""
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // -- push to detail view with required data --
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "AcceptDetailReqViewController") as! AcceptDetailReqViewController
        vc.requestPage = RequestView.accepted
        vc.rideDetail = rides[indexPath.row]
        self.navigationController?.pushViewController(vc, animated: true)
    }
}


