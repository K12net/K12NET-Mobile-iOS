//
//  K12NetWebRequest.swift
//  K12Net
//
//  Created by Tarik Canturk on 27/06/15.
//  Copyright (c) 2015 Tarik Canturk. All rights reserved.
//

import Foundation

open class K12NetWebRequest {
    
    fileprivate static var lastError : NSError?;
    
    open static func getLastError() -> NSError? {
        return K12NetWebRequest.lastError;
    }
    
    open static func retrieveGetRequest(_ urlAsString : String) -> NSMutableURLRequest {
        let httpMethod = "GET"
        
        let request = NSMutableURLRequest(url: URL(string: urlAsString)!);
        request.httpMethod = httpMethod
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        return request;
    }
    
    open static func retrievePostRequest(_ urlAsString : String, params : Any) -> NSMutableURLRequest {
        let httpMethod = "POST"
        
        let request = NSMutableURLRequest(url: URL(string: urlAsString)!);
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
        
        return request;
    }
    
    open static func retrievePostRequest(_ urlAsString : String) -> NSMutableURLRequest {
        let httpMethod = "POST"
        
        let request = NSMutableURLRequest(url: URL(string: urlAsString)!);
        request.httpMethod = httpMethod
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        return request;
    }
    
    open static func sendSynchronousRequest( _ getReq : NSMutableURLRequest ,returningResponse : AutoreleasingUnsafeMutablePointer<URLResponse?>?) -> Data {
        
        var data : Data?;
        K12NetWebRequest.lastError = nil;
        
        do {
            data = try  NSURLConnection.sendSynchronousRequest(getReq as URLRequest, returning: returningResponse);
            if let jsonStr = NSString(data: data!, encoding: String.Encoding.utf8.rawValue) {
                if jsonStr.length > 100 {
                    let splitString = jsonStr.substring(to: 100) as String;
                    if (splitString.lowercased().contains("Authentication Failed".lowercased())) {
                        LoginAsyncTask.loginOperation();
                        data = try  NSURLConnection.sendSynchronousRequest(getReq as URLRequest, returning: returningResponse);
                    }
                }
            }
        } catch let error as NSError {
            data = Data();
            K12NetWebRequest.lastError = error;
        }
    
    
        
        return data!;
    }
}
