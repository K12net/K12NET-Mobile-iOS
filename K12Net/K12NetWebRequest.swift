//
//  K12NetWebRequest.swift
//  K12Net
//
//  Created by Tarik Canturk on 27/06/15.
//  Copyright (c) 2015 Tarik Canturk. All rights reserved.
//

import Foundation

public class K12NetWebRequest {
    
    private static var lastError : NSError?;
    
    public static func getLastError() -> NSError? {
        return K12NetWebRequest.lastError;
    }
    
    public static func retrieveGetRequest(urlAsString : String) -> NSMutableURLRequest {
        let httpMethod = "GET"
        
        let request = NSMutableURLRequest(URL: NSURL(string: urlAsString)!);
        request.HTTPMethod = httpMethod
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        return request;
    }
    
    public static func retrievePostRequest(urlAsString : String, params : AnyObject) -> NSMutableURLRequest {
        let httpMethod = "POST"
        
        var request = NSMutableURLRequest(URL: NSURL(string: urlAsString)!);
        request.HTTPMethod = httpMethod
        
        var data : NSData;
        if let new_data = params as? String {
            data = new_data.dataUsingEncoding(NSUTF8StringEncoding)!;
        }
        else {
            do {
                data = try NSJSONSerialization.dataWithJSONObject(params, options: NSJSONWritingOptions.init(rawValue: 2))
            } catch _ {
                data = "".dataUsingEncoding(NSUTF8StringEncoding)!;
            }
        }
        
        request.HTTPBody = data;
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        return request;
    }
    
    public static func retrievePostRequest(urlAsString : String) -> NSMutableURLRequest {
        let httpMethod = "POST"
        
        let request = NSMutableURLRequest(URL: NSURL(string: urlAsString)!);
        request.HTTPMethod = httpMethod
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        return request;
    }
    
    public static func sendSynchronousRequest( getReq : NSMutableURLRequest ,returningResponse : AutoreleasingUnsafeMutablePointer<NSURLResponse?>) -> NSData {
        
        var data : NSData?;
        K12NetWebRequest.lastError = nil;
        
        do {
            data = try  NSURLConnection.sendSynchronousRequest(getReq, returningResponse: returningResponse);
            if let jsonStr = NSString(data: data!, encoding: NSUTF8StringEncoding) {
                if jsonStr.length > 100 {
                    let splitString = jsonStr.substringToIndex(100) as String;
                    if (splitString.lowercaseString.containsString("Authentication Failed".lowercaseString)) {
                        LoginAsyncTask.loginOperation();
                        data = try  NSURLConnection.sendSynchronousRequest(getReq, returningResponse: returningResponse);
                    }
                }
            }
        } catch let error as NSError {
            data = NSData();
            K12NetWebRequest.lastError = error;
        }
    
    
        
        return data!;
    }
}
