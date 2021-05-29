//
//  AnimationUtils.swift
//  MaterialUI
//
//  Created by Bhavin
//  skype : bhavin.bhadani
//

import Foundation
import UIKit

extension UIView {
    /**
     fade In (alpha = 1) to one or more views using the specified duration, delay.
     
     - parameter duration:     The total duration of the animations, measured in seconds. If you specify a negative value or 0, the changes are made without animating them.
     - parameter delay:        The amount of time (measured in seconds) to wait before beginning the animations. Specify a value of 0 to begin the animations immediately.
     */
    func fadeIn(withDuration duration: TimeInterval, andDelay delay:TimeInterval){
        alpha = 0
        UIView.animate(withDuration:duration , delay: delay,
                       options: [],
                       animations: {
                        self.alpha = 1
            }, completion: nil)
    }
    
    /**
     fade out (alpha = 0) to one or more views using the specified duration, delay.
     
     - parameter duration:     The total duration of the animations, measured in seconds. If you specify a negative value or 0, the changes are made without animating them.
     - parameter delay:        The amount of time (measured in seconds) to wait before beginning the animations. Specify a value of 0 to begin the animations immediately.
     */
    func fadeOut(withDuration duration: TimeInterval, andDelay delay:TimeInterval){
        alpha = 1
        UIView.animate(withDuration:duration , delay: delay,
                       options: [],
                       animations: {
                        self.alpha = 0
            }, completion: nil)
    }
    
    /**
     scale In (from 1 to 0) to one or more views using the specified duration, delay.
     
     - parameter duration:     The total duration of the animations, measured in seconds. If you specify a negative value or 0, the changes are made without animating them.
     - parameter delay:        The amount of time (measured in seconds) to wait before beginning the animations. Specify a value of 0 to begin the animations immediately.
     */
    func scaleIn(withDuration duration: TimeInterval, andDelay delay:TimeInterval) {
        self.transform = CGAffineTransform.identity
        UIView.animate(withDuration: duration, delay: delay,
                       options: [.curveLinear],
                       animations: {
                        self.transform = CGAffineTransform(scaleX: 0.001, y: 0.001)
            }, completion: nil)
    }
    
    /**
     scale Out (from 0 to 1) to one or more views using the specified duration, delay.
     
     - parameter duration:     The total duration of the animations, measured in seconds. If you specify a negative value or 0, the changes are made without animating them.
     - parameter delay:        The amount of time (measured in seconds) to wait before beginning the animations. Specify a value of 0 to begin the animations immediately.
     */
    func scaleOut(withDuration duration: TimeInterval, andDelay delay:TimeInterval) {
        self.transform = CGAffineTransform(scaleX: 0.0, y: 0.0)
        UIView.animate(withDuration: duration, delay: delay,
                       options: [.curveLinear],
                       animations: {
                        self.transform = CGAffineTransform.identity
            }, completion: nil)
    }
    
    /**
     slide Right: animate from left to right to one or more views using the specified duration, delay and UIViewAnimationOptions.
     
     - parameter position:     X position of a view. (layer.position.x += position)
     - parameter duration:     The total duration of the animations, measured in seconds. If you specify a negative value or 0, the changes are made without animating them.
     - parameter delay:        The amount of time (measured in seconds) to wait before beginning the animations. Specify a value of 0 to begin the animations immediately.
     */
    func slideRight(toPosition position:CGFloat, withDuration duration: TimeInterval, delay delayTime:TimeInterval, andOptions options:UIView.AnimationOptions){
        UIView.animate(withDuration: duration, delay: delayTime,
                       options: options,
                       animations: {
                        self.layer.position.x += position
            }, completion: nil)
    }
    
    /**
     slide Right Spring: Spring animation from left to right to one or more views using the specified duration, delay and UIViewAnimationOptions.
     
     - parameter position:     X position of a view. (layer.position.x += position)
     - parameter duration:     The total duration of the animations, measured in seconds. If you specify a negative value or 0, the changes are made without animating them.
     - parameter delay:        The amount of time (measured in seconds) to wait before beginning the animations. Specify a value of 0 to begin the animations immediately.
     */
    func slideRightSpring(toPosition position:CGFloat, withDuration duration: TimeInterval, delay delayTime:TimeInterval, andOptions options:UIView.AnimationOptions){
        UIView.animate(withDuration: duration, delay: delayTime,
                       usingSpringWithDamping: 0.7,
                       initialSpringVelocity: 0.7,
                       options: options,
                       animations: {
                        self.layer.position.x += position
            }, completion: nil)
    }
    
    /**
     slide left: animate from right to left to one or more views using the specified duration, delay and UIViewAnimationOptions.
     
     - parameter position:     X position of a view. (layer.position.x -= position)
     - parameter duration:     The total duration of the animations, measured in seconds. If you specify a negative value or 0, the changes are made without animating them.
     - parameter delay:        The amount of time (measured in seconds) to wait before beginning the animations. Specify a value of 0 to begin the animations immediately.
     */
    func slideLeft(toPosition position:CGFloat, withDuration duration: TimeInterval, delay delayTime:TimeInterval, andOptions options:UIView.AnimationOptions){
        UIView.animate(withDuration: duration, delay: delayTime,
                       options: options,
                       animations: {
                        self.layer.position.x -= position
            }, completion: nil)
    }
    
    /**
     slide Left Spring: Spring animation from right to left to one or more views using the specified duration, delay and UIViewAnimationOptions.
     
     - parameter position:     X position of a view. (layer.position.x -= position)
     - parameter duration:     The total duration of the animations, measured in seconds. If you specify a negative value or 0, the changes are made without animating them.
     - parameter delay:        The amount of time (measured in seconds) to wait before beginning the animations. Specify a value of 0 to begin the animations immediately.
     */
    func slideLeftSpring(toPosition position:CGFloat, withDuration duration: TimeInterval, delay delayTime:TimeInterval, andOptions options:UIView.AnimationOptions){
        UIView.animate(withDuration: duration, delay: delayTime,
                       usingSpringWithDamping: 0.7,
                       initialSpringVelocity: 0.7,
                       options: options,
                       animations: {
                        self.layer.position.x -= position
            }, completion: nil)
    }
    
    /**
     slide Up: animate from bottom to top to one or more views using the specified duration, delay and UIViewAnimationOptions.
     
     - parameter position:     y position of a view. (layer.position.y -= position)
     - parameter duration:     The total duration of the animations, measured in seconds. If you specify a negative value or 0, the changes are made without animating them.
     - parameter delay:        The amount of time (measured in seconds) to wait before beginning the animations. Specify a value of 0 to begin the animations immediately.
     */
    func slideUp(toPosition position:CGFloat, withDuration duration: TimeInterval, delay delayTime:TimeInterval, andOptions options:UIView.AnimationOptions){
        UIView.animate(withDuration: duration, delay: delayTime,
                       options: options,
                       animations: {
                        self.layer.position.y -= position
        }, completion: nil)
    }
    
    /**
     slide Up Spring: Spring animation from bottom to top to one or more views using the specified duration, delay and UIViewAnimationOptions.
     
     - parameter position:     y position of a view. (layer.position.y -= position)
     - parameter duration:     The total duration of the animations, measured in seconds. If you specify a negative value or 0, the changes are made without animating them.
     - parameter delay:        The amount of time (measured in seconds) to wait before beginning the animations. Specify a value of 0 to begin the animations immediately.
     */
    func slideUpSpring(toPosition position:CGFloat, withDuration duration: TimeInterval, delay delayTime:TimeInterval, andOptions options:UIView.AnimationOptions){
        UIView.animate(withDuration: duration, delay: delayTime,
                       usingSpringWithDamping: 0.7,
                       initialSpringVelocity: 0.7,
                       options: options,
                       animations: {
                        self.layer.position.y -= position
            }, completion: nil)
    }
    
    /**
     slide Down: animate from top to bottom to one or more views using the specified duration, delay and UIViewAnimationOptions.
     
     - parameter position:     y position of a view. (layer.position.y += position)
     - parameter duration:     The total duration of the animations, measured in seconds. If you specify a negative value or 0, the changes are made without animating them.
     - parameter delay:        The amount of time (measured in seconds) to wait before beginning the animations. Specify a value of 0 to begin the animations immediately.
     */
    func slideDown(element view:UIView, toPosition position:CGFloat, withDuration duration: TimeInterval, delay delayTime:TimeInterval, andOptions options:UIView.AnimationOptions){
        UIView.animate(withDuration: duration, delay: delayTime,
                       options: options,
                       animations: {
                        view.layer.position.y += position
            }, completion: nil)
    }
    
    /**
     slide Down Spring: animate from top to bottom to one or more views using the specified duration, delay and UIViewAnimationOptions.
     
     - parameter position:     y position of a view. (layer.position.y += position)
     - parameter duration:     The total duration of the animations, measured in seconds. If you specify a negative value or 0, the changes are made without animating them.
     - parameter delay:        The amount of time (measured in seconds) to wait before beginning the animations. Specify a value of 0 to begin the animations immediately.
     */
    func slideDownSpring(toPosition position:CGFloat, withDuration duration: TimeInterval, delay delayTime:TimeInterval, andOptions options:UIView.AnimationOptions){
        UIView.animate(withDuration: duration, delay: delayTime,
                       usingSpringWithDamping: 0.7,
                       initialSpringVelocity: 0.7,
                       options: options,
                       animations: {
                        self.layer.position.y += position
            }, completion: nil)
    }
    
    
    func animateConstraints(withDuration duration: TimeInterval, delay delayTime:TimeInterval, _options options:UIView.AnimationOptions , constraintsWithValue:[[NSLayoutConstraint:CGFloat]], completion:((Bool) -> Swift.Void)? = nil){
        
        // perform any required changes
        self.layoutIfNeeded()
        
        // change constraints
        for con in constraintsWithValue{
            for (key,value) in con {
                key.constant = value
            }
        }
        
        // animate constraints
        UIView.animate(withDuration: duration, delay: delayTime,
                       options: options,
                       animations: {
                        self.layoutIfNeeded()
        }) { (finished) in
            if (completion != nil){
                completion!(finished)
            }
        }
    }
    
    func animateConstraintsSpring(withDuration duration: TimeInterval, delay delayTime:TimeInterval, usingSpringWithDamping dampingRatio: CGFloat, initialSpringVelocity velocity: CGFloat, _options options:UIView.AnimationOptions , constraintsWithValue:[[NSLayoutConstraint:CGFloat]], completion:((Bool) -> Swift.Void)? = nil){
        
        // perform any required changes
        self.layoutIfNeeded()
        
        // change constraints
        for con in constraintsWithValue{
            for (key,value) in con {
                key.constant = value
            }
        }
        
        // animate constraints
        UIView.animate(withDuration: duration,
                              delay: delayTime,
             usingSpringWithDamping: dampingRatio,
              initialSpringVelocity: velocity,
                            options: options,
                         animations: {
                            self.layoutIfNeeded()
            }) { (finished) in
                if (completion != nil){
                    completion!(finished)
                }
        }
    }
    
    func animateCornerRadius(from: CGFloat, to: CGFloat, duration: CFTimeInterval) {
        let animation = CABasicAnimation(keyPath:"cornerRadius")
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
        animation.fromValue = from
        animation.toValue = to
        animation.duration = duration
        self.layer.add(animation, forKey: "cornerRadius")
        self.layer.cornerRadius = to
    }
    
    func getTimingFunction(curve: UIView.AnimationCurve) -> CAMediaTimingFunction {
        switch curve {
        case .easeIn:
            return CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeIn)
        case .easeOut:
            return CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
        case .easeInOut:
            return CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        case .linear:
            return CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
        }
    }
    
    
    //----------------------------------------------------------------------------------------------------------------
    /**
     cornerRadius: to give a corner radius.
     
     - parameter radius:  When positive, the background of the layer will be drawn with
     rounded corners. Also effects the mask generated by the
     `masksToBounds' property. Defaults to zero. Animatable.
     
     */
    func corner(radius:CGFloat, color:UIColor, width:CGFloat ){
        layer.cornerRadius = radius
        layer.masksToBounds = true
        layer.borderColor = color.cgColor
        layer.borderWidth = width
    }
}


