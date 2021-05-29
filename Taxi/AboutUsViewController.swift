import UIKit

class AboutUsViewController: UIViewController {
    
    @IBOutlet var AboutUSTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = LocalizationSystem.sharedInstance.localizedStringForKey(key: "MenuItem10", comment: "")
        
        // -- setup revealview (side menu) --
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
        
        let postAttributedText = NSMutableAttributedString(string: LocalizationSystem.sharedInstance.localizedStringForKey(key: "AboutUSVC_text1", comment: ""), attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 17) , NSAttributedString.Key.foregroundColor : UIColor(red: 0.26, green: 0.52, blue: 0.96, alpha: 1.00)])
        postAttributedText.append(NSMutableAttributedString(string: "\n", attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 15)]))
        postAttributedText.append(NSAttributedString(string: LocalizationSystem.sharedInstance.localizedStringForKey(key: "AboutUSVC_text2", comment: "") , attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 15), NSAttributedString.Key.foregroundColor : UIColor(red: 0.00, green: 0.00, blue: 0.00, alpha: 1.00)]))
        postAttributedText.append(NSMutableAttributedString(string: "\n", attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 15)]))
        postAttributedText.append(NSAttributedString(string: LocalizationSystem.sharedInstance.localizedStringForKey(key: "AboutUSVC_text3", comment: "") , attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 15), NSAttributedString.Key.foregroundColor : UIColor(red: 0.00, green: 0.00, blue: 0.00, alpha: 1.00)]))
        postAttributedText.append(NSMutableAttributedString(string: "\n", attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 15)]))
        postAttributedText.append(NSAttributedString(string: LocalizationSystem.sharedInstance.localizedStringForKey(key: "AboutUSVC_text4", comment: "") , attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 15), NSAttributedString.Key.foregroundColor : UIColor(red: 0.00, green: 0.00, blue: 0.00, alpha: 1.00)]))
        postAttributedText.append(NSMutableAttributedString(string: "\n", attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 15)]))
        postAttributedText.append(NSAttributedString(string: LocalizationSystem.sharedInstance.localizedStringForKey(key: "AboutUSVC_text5", comment: "") , attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 15), NSAttributedString.Key.foregroundColor : UIColor(red: 0.00, green: 0.00, blue: 0.00, alpha: 1.00)]))
        
        AboutUSTextView.textAlignment = .center
        AboutUSTextView.isEditable = false
        AboutUSTextView.isUserInteractionEnabled = false
        AboutUSTextView.attributedText = postAttributedText
        
        
        
        
        
    }
}
