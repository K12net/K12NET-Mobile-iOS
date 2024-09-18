//
//  LoginAsyncTask.swift
//  K12Net
//
//  Created by Tarik Canturk on 23/06/15.
//  Copyright (c) 2015 Tarik Canturk. All rights reserved.
//

import Foundation;
import UIKit;
//import WebKit;
//import SplunkMint;

open class LoginAsyncTask : AsyncTask  {
    
    var strData : NSString = "";
    
    var username : String;
    var password : String;
    
    static var lastOperationValue = false;
    static var urlError = false;
    static var connectionError = false;
    static var loginStarted = false;
    
    init(username : String, password : String) {
        self.username = username;
        self.password = password;
    }
    
    override func doInBackground(){
        LoginAsyncTask.loginOperation();
    }
    
    override func postExecute(){
        
    }
    
    static func loginOperation() {
        loginStarted = true;
        
       let storage = HTTPCookieStorage.shared
        for cookie in storage.cookies! {
            storage.deleteCookie(cookie)
        }
        
        let deviceToken = K12NetUserPreferences.getDeviceToken();
        
        if(deviceToken.isEmpty && AppDelegate.NotificationIsPermitted != nil && AppDelegate.NotificationIsPermitted == true  ){
            if let wd = UIApplication.shared.delegate?.window {
                let vc = wd!.rootViewController

                if(vc != nil){
                    let alertController = UIAlertController(title: "appTitle".localized, message:"deviceIDFailed".localized , preferredStyle: UIAlertController.Style.alert)
                    alertController.addAction(UIAlertAction(title: "ok".localized, style: UIAlertAction.Style.default,handler: nil))
                    
                    vc?.addActionSheetForiPad(actionSheet: alertController)
                    vc?.present(alertController, animated: true, completion: nil)
                    
                    return;
                }
            }
        }
        
        let urlAsString = (K12NetUserPreferences.getHomeAddress() as String) + "/GWCore.Web/api/Login/Validate"
        var params : [String:String] = [:];
        params["UserName"] = K12NetUserPreferences.getUsername();
        params["Password"] = K12NetUserPreferences.getPassword();
        
        params["createPersistentCookie"] = "false";
        
        let request = K12NetWebRequest.retrievePostRequest(urlAsString, params: params);
        
        LoginAsyncTask.urlError = false;
        LoginAsyncTask.connectionError = false;
        
        let appVersion = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as? String ?? "";
            
        var userAgent = "K12net " + appVersion + UIDevice.current.name + " ; " ;
        userAgent = userAgent + UIDevice.current.modelName + " ; " + UIDevice.current.systemName + " - " + UIDevice.current.systemVersion + "";
            
        request.setValue(userAgent, forHTTPHeaderField: "User-Agent")
        K12NetWebRequest.sendSynchronousRequest(request, complation: { (data, error) in
            if error != nil {
                print("lasterror");
                print(error ?? "");
                if(error?.code == -1003) { //NSURLErrorDomain
                    LoginAsyncTask.urlError = true;
                }
                else if(error?.code == NSURLErrorTimedOut ||
                            error?.code == NSURLErrorCannotConnectToHost ||
                            error?.code == NSURLErrorNetworkConnectionLost ||
                            error?.code == NSURLErrorNotConnectedToInternet) {
                    LoginAsyncTask.connectionError = true;
                }
            } else {
                
                let jsonStr = NSString(data: data!, encoding: String.Encoding.utf8.rawValue);
                
                print("logintex : \(String(describing: jsonStr))");
                
                var json : NSDictionary?;
                
                do {
                    json = try JSONSerialization.jsonObject(with: data!, options: .mutableLeaves) as? NSDictionary
                } catch _ {
                    json = NSDictionary();
                }
                
                if let parseJSON = json {
                    if let success = parseJSON["Success"] as? Bool {
                        LoginAsyncTask.lastOperationValue = success;
                        
                        if success {
                            
                            if let loginSite = parseJSON["LoginSite"] as? String {
                                let connectionString = K12NetUserPreferences.getHomeAddress() as String;
                                
                                if(loginSite.starts(with: "http") && connectionString != loginSite) {
                                    K12NetUserPreferences.saveHomeAddress(loginSite);
                                }
                            }
                            
                            AttendanceManager.Instance.Initialize(controller: K12NetLogin.controller!)
                            
                        } else {
                            LoginAsyncTask.lastOperationValue = false;
                        }
                    }
                    else {
                        LoginAsyncTask.lastOperationValue = false;
                    }
                    
                }
            }
            
            loginStarted = false;
        },retry: false,isLogin: true)
        
    }
    
}
