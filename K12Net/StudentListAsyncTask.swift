//
//  StudentListAsyncTask.swift
//  K12Net
//
//  Created by Tarik Canturk on 23/06/15.
//  Copyright (c) 2015 Tarik Canturk. All rights reserved.
//

import Foundation
import UIKit

public class StudentListAsyncTask : AsyncTask {
    
    var studentIdList = [String]()
    
    var strData : String = "";
    
    public static var providerId : String = "";
    
    override func doInBackground(){
        
        var response: AutoreleasingUnsafeMutablePointer<NSURLResponse?>=nil
        
        var error: NSErrorPointer = nil
        var getUserUrl = (K12NetUserPreferences.getHomeAddress() as String) + "/SPSL.Web/ClientBin/Yuce-K12NET-SPSL-Web-AuthenticationService.svc/json/GetUser"
        
        var request = K12NetWebRequest.retrieveGetRequest(getUserUrl);
        
        var data =  K12NetWebRequest.sendSynchronousRequest(request, returningResponse: response)
        
        if data.length > 0 && error == nil {
            do {
                var json = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers) as? NSDictionary;
                let html = NSString(data: data, encoding: NSUTF8StringEncoding);
                if let topJson  = json as NSDictionary?  {
                    
                    if let userResult = topJson["GetUserResult"] as? NSDictionary  {
                        if let rootResult = userResult["RootResults"] as? NSArray  {
                            if let rootResultItem = rootResult[0] as? NSDictionary {
                                if let providerId = rootResultItem["ProviderUserKey"] as? String {
                                    studentIdList.append(providerId)
                                    strData = providerId as String;
                                    StudentListAsyncTask.providerId = providerId;
                                }
                            }
                        }
                    }
                }
            } catch _ {
                
            }
            
            //------------------------------------
            
        }
    }
    
    override func postExecute(){
        
        let pnAsyncTask = PushNotificationRegisterAsync(token: K12NetLogin.tokenId);
        pnAsyncTask.Execute();
        
    }
    
    
}