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
        NotificationCenter.default.addObserver(self, selector: #selector(UIViewController.keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(UIViewController.keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        internalScrollView = scrollView
        internalMoveView = moveView;
    }
    
    public func removeKeyboardNotificationListeners() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
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
    
    @objc func keyboardWillShow(_ notification: Notification) {
        let userInfo = (notification as NSNotification).userInfo as! Dictionary<String, AnyObject>
        let animationDuration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as! TimeInterval
        let animationCurve = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey]!.int32Value
        let keyboardFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue; //userInfo[UIKeyboardFrameEndUserInfoKey]?.CGRectValue
        let keyboardFrameConvertedToViewFrame = view.convert(keyboardFrame, from: nil)
        let curveAnimationOption = UIView.AnimationOptions(rawValue: UInt(animationCurve!))
        let options: UIView.AnimationOptions = [.beginFromCurrentState, curveAnimationOption];
        if(self.view.frame.origin.y == 0) {
            UIView.animate(withDuration: animationDuration, delay: 0, options:options, animations: { () -> Void in
                let insetHeight = (self.internalScrollView.frame.height + self.internalScrollView.frame.origin.y) - keyboardFrameConvertedToViewFrame.origin.y
                self.internalScrollView.contentInset = UIEdgeInsets.init(top: 0, left: 0, bottom: insetHeight, right: 0)
                self.internalScrollView.scrollIndicatorInsets  = UIEdgeInsets.init(top: 0, left: 0, bottom: insetHeight, right: 0);
                if(self.internalMoveView) {
                    let bottomSize = self.view.frame.size.height - 400;
                    let shiftSize = max(0, keyboardFrameConvertedToViewFrame.size.height - bottomSize);
                    self.view.frame.origin.y -= shiftSize;
                }
                }) { (complete) -> Void in
            }
        }
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        let userInfo = (notification as NSNotification).userInfo as! Dictionary<String, AnyObject>
        let animationDuration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as! TimeInterval
        let animationCurve = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey]!.int32Value
        let curveAnimationOption = UIView.AnimationOptions(rawValue: UInt(animationCurve!))
        let options: UIView.AnimationOptions = [.beginFromCurrentState, curveAnimationOption];
        if(self.view.frame.origin.y < 0) {
            UIView.animate(withDuration: animationDuration, delay: 0,
                options: options,
                animations: { () -> Void in
                    self.internalScrollView.contentInset = UIEdgeInsets.init(top: 0, left: 0, bottom: 0, right: 0)
                    self.internalScrollView.scrollIndicatorInsets  = UIEdgeInsets.init(top: 0, left: 0, bottom: 0, right: 0)
                    self.view.frame.origin.y = 0
                }) { (complete) -> Void in
            }
        }
    }
}
