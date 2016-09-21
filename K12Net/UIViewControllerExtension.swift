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
    
    public func setupKeyboardNotifcationListenerForScrollView(_ scrollView: UIScrollView, moveView : Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(UIViewController.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(UIViewController.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        internalScrollView = scrollView
        internalMoveView = moveView;
    }
    
    public func removeKeyboardNotificationListeners() {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    fileprivate var internalScrollView: UIScrollView! {
        get {
            return objc_getAssociatedObject(self, &scrollViewKey) as? UIScrollView
        }
        set(newValue) {
            objc_setAssociatedObject(self, &scrollViewKey, newValue, .OBJC_ASSOCIATION_ASSIGN)
        }
    }
    
    fileprivate var internalMoveView: Bool {
        get {
            return (objc_getAssociatedObject(self, &moveViewKey) as? Bool)!
        }
        set(newValue) {
            objc_setAssociatedObject(self, &moveViewKey, newValue, .OBJC_ASSOCIATION_ASSIGN)
        }
    }
    
    func keyboardWillShow(_ notification: Notification) {
        let userInfo = (notification as NSNotification).userInfo as! Dictionary<String, AnyObject>
        let animationDuration = userInfo[UIKeyboardAnimationDurationUserInfoKey] as! TimeInterval
        let animationCurve = userInfo[UIKeyboardAnimationCurveUserInfoKey]!.int32Value
        let keyboardFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue; //userInfo[UIKeyboardFrameEndUserInfoKey]?.CGRectValue
        let keyboardFrameConvertedToViewFrame = view.convert(keyboardFrame, from: nil)
        let curveAnimationOption = UIViewAnimationOptions(rawValue: UInt(animationCurve!))
        let options: UIViewAnimationOptions = [.beginFromCurrentState, curveAnimationOption];
        if(self.view.frame.origin.y == 0) {
            UIView.animate(withDuration: animationDuration, delay: 0, options:options, animations: { () -> Void in
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
    
    func keyboardWillHide(_ notification: Notification) {
        let userInfo = (notification as NSNotification).userInfo as! Dictionary<String, AnyObject>
        let animationDuration = userInfo[UIKeyboardAnimationDurationUserInfoKey] as! TimeInterval
        let animationCurve = userInfo[UIKeyboardAnimationCurveUserInfoKey]!.int32Value
        let curveAnimationOption = UIViewAnimationOptions(rawValue: UInt(animationCurve!))
        let options: UIViewAnimationOptions = [.beginFromCurrentState, curveAnimationOption];
        if(self.view.frame.origin.y < 0) {
            UIView.animate(withDuration: animationDuration, delay: 0,
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
