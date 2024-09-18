//
//  K12NetWebRequest.swift
//  K12Net
//
//  Created by Tarik Canturk on 27/06/15.
//  Copyright (c) 2015 Tarik Canturk. All rights reserved.
//

import Foundation
import UIKit;

open class K12NetWebRequest {
    
    public static func retrieveGetRequest(_ urlAsString : String) -> NSMutableURLRequest {
        let httpMethod = "GET"
        
        let request = NSMutableURLRequest(url: URL(string: urlAsString)!);
        request.httpMethod = httpMethod
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        return request;
    }
    
    public static func retrievePostRequest(_ urlAsString : String, params : Any) -> NSMutableURLRequest {
        let httpMethod = "POST"
        
        let request = NSMutableURLRequest(url: URL(string: urlAsString.trimmingCharacters(in: .whitespacesAndNewlines))!);
        request.httpMethod = httpMethod
        
        var data : Data;
        if let new_data = params as? String {
            data = new_data.data(using: String.Encoding.utf8)!;
        }
        else {
            do {
                data = try JSONSerialization.data(withJSONObject: params, options: JSONSerialization.WritingOptions.init(rawValue: 2))
            } catch _ {
                data = "".data(using: String.Encoding.utf8)!;
            }
        }
        
        request.httpBody = data;
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue(K12NetUserPreferences.getDeviceToken() as String, forHTTPHeaderField: "Atlas-DeviceID");
        request.addValue(AppStaticDefinition.K12NET_IOS_APPLICATION_ID, forHTTPHeaderField: "Atlas-DeviceTypeID");
        request.addValue(UIDevice.current.name + " [" + UIDevice.current.modelName + "] [" + UIDevice.current.systemName + " " + UIDevice.current.systemVersion + "]", forHTTPHeaderField: "Atlas-DeviceModel");
        
        return request;
    }
    
    public static func retrievePostRequest(_ urlAsString : String) -> NSMutableURLRequest {
        let httpMethod = "POST"
        let url = URL(string: urlAsString)
        
        let request = NSMutableURLRequest(url: url!);
        request.httpMethod = httpMethod
        
        request.addValue("application/json;charset=UTF-8", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json, text/plain, */*", forHTTPHeaderField: "Accept")
        return request;
    }
    
    public static func sendSynchronousRequest( _ getReq : NSMutableURLRequest , complation : @escaping (Data?,NSError?)->Void, retry:Bool = true, isLogin:Bool = false){
        
        
        /* var data : Data?;
         
         do {
         data = try  NSURLConnection.sendSynchronousRequest(getReq as URLRequest, returning: nil);
         if let jsonStr = NSString(data: data!, encoding: String.Encoding.utf8.rawValue) {
         if jsonStr.length > 100 {
         let splitString = jsonStr.substring(to: 100) as String;
         if (splitString.lowercased().contains("Authentication Failed".lowercased())) {
         LoginAsyncTask.loginOperation();
         data = try  NSURLConnection.sendSynchronousRequest(getReq as URLRequest, returning: nil);
         }
         }
         }
         complation(data,nil)
         } catch let error as NSError {
         data = Data();
         complation(data,error)
         }*/
        var data : Data?;
        var err = nil as NSError?
        let group = DispatchGroup()
        group.enter()
        
        let session = URLSession.shared
        let task = session.dataTask(with: getReq as URLRequest, completionHandler: { d, response, error in
            data = d
            err = error as NSError?
            
         /*   if let response = response {
                print(response)
                if let httpResponse = response as? HTTPURLResponse {
                    print("statusCode: \(httpResponse.statusCode)")
                }
            }*/
            
            if(err != nil){
                group.leave()
                return
            }
            
            if let jsonStr = NSString(data: data!, encoding: String.Encoding.utf8.rawValue) {
                if jsonStr.length > 100 {
                    let splitString = jsonStr.substring(to: 100) as String;
                    if (splitString.lowercased().contains("Authentication Failed".lowercased())) {
                        if(retry && isLogin == false) {
                            LoginAsyncTask.loginOperation();
                            K12NetWebRequest.sendSynchronousRequest(getReq,complation: { (d, error) in
                                data = d
                                err = error as NSError?
                                group.leave()
                            }, retry:false);
                            return
                        }
                    }
                }
            }
            
            group.leave()
        })
        
        task.resume()
        group.wait()
        
        complation(data,err)
    }
}
