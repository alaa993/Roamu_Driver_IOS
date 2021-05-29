//
//  PassengersViewController.swift
//  Taxi
//
//  Created by Syria.Apple on 4/25/20.
//  Copyright © 2020 icanStudioz. All rights reserved.
//

import UIKit

class PassengersViewController: UIViewController {
    
    var delegate: NoOfPassengers?
    var PassengersCount = -1
    @IBOutlet var NoOfPassengersLabel: UILabel!
    @IBOutlet var SeatsLabel: UILabel!
    
    @IBOutlet var AddPassengerButton: UIButton!
    @IBOutlet var SubsPassengerButton: UIButton!
    @IBOutlet var ConfirmButton: UIButton!
    @IBOutlet var CancelButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NoOfPassengersLabel.text = String(PassengersCount)
        SeatsLabel.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "PassengersVCSeatsLabel", comment: "")
        
        AddPassengerButton.setTitle(LocalizationSystem.sharedInstance.localizedStringForKey(key: "PassengersVCAddPassengerButton", comment: ""), for: .normal)
        
        SubsPassengerButton.setTitle(LocalizationSystem.sharedInstance.localizedStringForKey(key: "PassengersVCSubsPassengerButton", comment: ""), for: .normal)
        
        ConfirmButton.setTitle(LocalizationSystem.sharedInstance.localizedStringForKey(key: "PassengersVCConfirmButton", comment: ""), for: .normal)
        
        CancelButton.corner(radius: 5.0, color: UIColor.white, width: 1.0)
        CancelButton.setTitle(LocalizationSystem.sharedInstance.localizedStringForKey(key: "PassengersVCCancelButton", comment: ""), for: .normal)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        delegate!.NoOfPassengersPass(NoOfPassengersVar: PassengersCount)
    }
    
    @IBAction func backWasPressed(_ sender: Any) {
        //_ = self.navigationController?.popViewController(animated: true)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func AddButton(_ sender: Any) {
        if PassengersCount < 8 {
            PassengersCount = PassengersCount + 1
            NoOfPassengersLabel.text = String(PassengersCount)
            if PassengersCount == 8
            {
                AddPassengerButton.isEnabled = false
            }
            if SubsPassengerButton.isEnabled == false
            {
                SubsPassengerButton.isEnabled = true
            }
        }
    }
    
    @IBAction func SubsButton(_ sender: Any) {
        if PassengersCount > 1 {
            PassengersCount = PassengersCount - 1
            NoOfPassengersLabel.text = String(PassengersCount)
            if PassengersCount == 1
            {
                SubsPassengerButton.isEnabled = false
            }
            if AddPassengerButton.isEnabled == false
            {
                AddPassengerButton.isEnabled = true
            }
        }
    }
    
    @IBAction func ConfirmButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
