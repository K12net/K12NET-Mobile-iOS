//
//  UIViewControllerExtension.swift
//  K12Net
//
//  Created by tarikcanturk on 03/10/15.
//  Copyright (c) 2015 Tarik Canturk. All rights reserved.
//

import UIKit

private var scrollViewKey : UInt8 = 0
private var moveViewKey : UInt8 = 1

extension UIViewController {
    
    public func setupKeyboardNotifcationListenerForScrollView(scrollView: UIScrollView, moveView : Bool) {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow:"), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHide:"), name: UIKeyboardWillHideNotification, object: nil)
        internalScrollView = scrollView
        internalMoveView = moveView;
    }
    
    public func removeKeyboardNotificationListeners() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
    
    private var internalScrollView: UIScrollView! {
        get {
            return objc_getAssociatedObject(self, &scrollViewKey) as? UIScrollView
        }
        set(newValue) {
            objc_setAssociatedObject(self, &scrollViewKey, newValue, .OBJC_ASSOCIATION_ASSIGN)
        }
    }
    
    private var internalMoveView: Bool {
        get {
            return (objc_getAssociatedObject(self, &moveViewKey) as? Bool)!
        }
        set(newValue) {
            objc_setAssociatedObject(self, &moveViewKey, newValue, .OBJC_ASSOCIATION_ASSIGN)
        }
    }
    
    func keyboardWillShow(notification: NSNotification) {
        let userInfo = notification.userInfo as! Dictionary<String, AnyObject>
        let animationDuration = userInfo[UIKeyboardAnimationDurationUserInfoKey] as! NSTimeInterval
        let animationCurve = userInfo[UIKeyboardAnimationCurveUserInfoKey]!.intValue
        let keyboardFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue(); //userInfo[UIKeyboardFrameEndUserInfoKey]?.CGRectValue
        let keyboardFrameConvertedToViewFrame = view.convertRect(keyboardFrame, fromView: nil)
        let curveAnimationOption = UIViewAnimationOptions(rawValue: UInt(animationCurve))
        let options: UIViewAnimationOptions = [.BeginFromCurrentState, curveAnimationOption];
        if(self.view.frame.origin.y == 0) {
            UIView.animateWithDuration(animationDuration, delay: 0, options:options, animations: { () -> Void in
                let insetHeight = (self.internalScrollView.frame.height + self.internalScrollView.frame.origin.y) - keyboardFrameConvertedToViewFrame.origin.y
                self.internalScrollView.contentInset = UIEdgeInsetsMake(0, 0, insetHeight, 0)
                self.internalScrollView.scrollIndicatorInsets  = UIEdgeInsetsMake(0, 0, insetHeight, 0);
                if(self.internalMoveView) {
                    let bottomSize = self.view.frame.size.height - 400;
                    let shiftSize = max(0, keyboardFrameConvertedToViewFrame.size.height - bottomSize);
                    self.view.frame.origin.y -= shiftSize;
                }
                }) { (complete) -> Void in
            }
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        let userInfo = notification.userInfo as! Dictionary<String, AnyObject>
        let animationDuration = userInfo[UIKeyboardAnimationDurationUserInfoKey] as! NSTimeInterval
        let animationCurve = userInfo[UIKeyboardAnimationCurveUserInfoKey]!.intValue
        let curveAnimationOption = UIViewAnimationOptions(rawValue: UInt(animationCurve))
        let options: UIViewAnimationOptions = [.BeginFromCurrentState, curveAnimationOption];
        if(self.view.frame.origin.y < 0) {
            UIView.animateWithDuration(animationDuration, delay: 0,
                options: options,
                animations: { () -> Void in
                    self.internalScrollView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0)
                    self.internalScrollView.scrollIndicatorInsets  = UIEdgeInsetsMake(0, 0, 0, 0)
                    self.view.frame.origin.y = 0
                }) { (complete) -> Void in
            }
        }
    }
}