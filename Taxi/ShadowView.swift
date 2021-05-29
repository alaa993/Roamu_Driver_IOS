//
//  ShadowView.swift
//  Taxi
//
//  Created by Bhavin
//  skype : bhavin.bhadani
//

import UIKit
import MBProgressHUD

class ShadowView: UIView {
    override var bounds: CGRect {
        didSet {
            setupShadow()
        }
    }
    
    private func setupShadow() {
        self.layer.cornerRadius = 8
        self.layer.shadowOffset = CGSize(width: 1, height: 1)
        self.layer.shadowRadius = 2
        self.layer.shadowOpacity = 0.3
        self.layer.shadowPath = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: .allCorners, cornerRadii: CGSize(width: 8, height: 8)).cgPath
        self.layer.shouldRasterize = true
        self.layer.rasterizationScale = UIScreen.main.scale
    }
}


class CornerView:UIView{
    override var bounds: CGRect {
        didSet {
            setupCorners()
        }
    }
    
    private func setupCorners() {
        self.layer.cornerRadius = 8
        self.layer.masksToBounds = true
    }
    
}

//set HUD........
class HUD: MBProgressHUD {
    
    class func hide(to view: UIView){
        DispatchQueue.main.async {
            MBProgressHUD.hide(for: view, animated: true)
        }
    }
    
    class func show(to view:UIView) {
        DispatchQueue.main.async {
            MBProgressHUD.showAdded(to: view, animated: true)
        }
    }
}
