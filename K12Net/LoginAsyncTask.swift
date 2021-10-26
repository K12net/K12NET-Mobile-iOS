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
    static var isLoginRetry = false;
    
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
        
        let urlAsString = (K12NetUserPreferences.getHomeAddress() as String) + "/Authentication_JSON_AppService.axd/Login"
        var params : [String:String] = [:];
        params["userName"] = K12NetUserPreferences.getUsername();
        params["password"] = K12NetUserPreferences.getPassword();
        params["createPersistentCookie"] = "false";
        
        let request = K12NetWebRequest.retrievePostRequest(urlAsString, params: params);
        
        LoginAsyncTask.urlError = false;
        LoginAsyncTask.connectionError = false;
        
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
                    if let success = parseJSON["d"] as? Bool {
                        LoginAsyncTask.lastOperationValue = success;
                        
                        if success {
                            
                            if isLoginRetry {
                                let connectionString = K12NetUserPreferences.getHomeAddress() as String;
                                
                                if connectionString == AppStaticDefinition.K12NET_LOGIN_DEFAULT_URL {
                                    K12NetUserPreferences.saveLanguage(lang:"tr");
                                } else {
                                    if (K12NetUserPreferences.getLanguage() == "tr") {
                                        K12NetUserPreferences.saveLanguage(lang:"en");
                                    }
                                }
                            }
                            
                            if(K12NetUserPreferences.LANG_UPDATED) {
                                let task = HttpAsyncTask(operation: "SetLanguage");
                                
                                task.Execute();
                            }
                            
                        } else {
                            if !isLoginRetry {
                                isLoginRetry = true;
                                
                                let connectionString = K12NetUserPreferences.getHomeAddress() as String;
                                
                                if connectionString == AppStaticDefinition.K12NET_LOGIN_DEFAULT_URL {
                                    K12NetUserPreferences.saveHomeAddress("https://azure.k12net.com");
                                    K12NetUserPreferences.saveFSAddress("http://fs.azure.k12net.com/FS/");
                                } else {
                                    K12NetUserPreferences.saveHomeAddress(AppStaticDefinition.K12NET_LOGIN_DEFAULT_URL);
                                    K12NetUserPreferences.saveFSAddress(AppStaticDefinition.K12NET_FS_DEFAULT_URL);
                                }
                                
                                loginOperation();
                                
                                return;
                                
                            } else {
                                LoginAsyncTask.lastOperationValue = false;
                            }
                        }
                    }
                    else {
                        if !isLoginRetry {
                            isLoginRetry = true;
                            
                            let connectionString = K12NetUserPreferences.getHomeAddress() as String;
                            
                            if connectionString == AppStaticDefinition.K12NET_LOGIN_DEFAULT_URL {
                                K12NetUserPreferences.saveHomeAddress("https://azure.k12net.com");
                                K12NetUserPreferences.saveFSAddress("http://fs.azure.k12net.com/FS/");
                            } else {
                                K12NetUserPreferences.saveHomeAddress(AppStaticDefinition.K12NET_LOGIN_DEFAULT_URL);
                                K12NetUserPreferences.saveFSAddress(AppStaticDefinition.K12NET_FS_DEFAULT_URL);
                            }
                            
                            loginOperation();
                            
                            return;
                            
                        } else {
                            LoginAsyncTask.lastOperationValue = false;
                        }
                    }
                    
                }
            }
            
            loginStarted = false;
        })
        
    }
    
}
