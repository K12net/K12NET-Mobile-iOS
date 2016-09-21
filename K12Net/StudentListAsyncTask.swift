//
//  StudentListAsyncTask.swift
//  K12Net
//
//  Created by Tarik Canturk on 23/06/15.
//  Copyright (c) 2015 Tarik Canturk. All rights reserved.
//

import Foundation
import UIKit

open class StudentListAsyncTask : AsyncTask {
    
    var studentIdList = [String]()
    
    var strData : String = "";
    
    open static var providerId : String = "";
    
    override func doInBackground(){
        
        var response: AutoreleasingUnsafeMutablePointer<URLResponse?>?=nil
        
        var error: NSErrorPointer? = nil
        var getUserUrl = (K12NetUserPreferences.getHomeAddress() as String) + "/SPSL.Web/ClientBin/Yuce-K12NET-SPSL-Web-AuthenticationService.svc/json/GetUser"
        
        var request = K12NetWebRequest.retrieveGetRequest(getUserUrl);
        
        var data =  K12NetWebRequest.sendSynchronousRequest(request, returningResponse: response)
        
        if data.count > 0 && error == nil {
            do {
                var json = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers) as? NSDictionary;
                let html = NSString(data: data, encoding: String.Encoding.utf8.rawValue);
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
