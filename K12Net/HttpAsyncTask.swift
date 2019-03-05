//
//  HttpAsyncTask.swift
//  K12Net Mobile
//
//  Created by Ilhami Sisnelioglu on 12.01.2019.
//  Copyright © 2019 K12Net. All rights reserved.
//

import Foundation;
import UIKit;

open class HttpAsyncTask : AsyncTask  {
    
    private var operation : String = "";
    
    var lastOperationValue : String = "";
    
    init(operation:String) {
        self.operation = operation;
    }
    
    override func doInBackground(){
        if (self.operation == "SetLanguage") {
            self.doSetLanguage();
        }
    }
    
    override func postExecute(){
        
    }
    
    private func doSetLanguage() {
        if(!K12NetUserPreferences.LANG_UPDATED) {
            return;
        }
        
        K12NetUserPreferences.LANG_UPDATED = false;
        
        let urlAsString = (K12NetUserPreferences.getHomeAddress() as String) + "/Authentication_JSON_AppService.axd/SetLanguage"
        let endpointUrl = URL(string: urlAsString)!
        
        var request = URLRequest(url: endpointUrl)
        
        request.httpMethod = "POST"
        
        /*var json = [String:Any]()
         json["LanguageCode"] = K12NetUserPreferences.getLanguage()
         let data = try JSONSerialization.data(withJSONObject: json, options: [])
         request.httpBody = data*/
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        request.setValue(K12NetUserPreferences.getLanguage(), forHTTPHeaderField: "LanguageCode")
        
        let task = URLSession.shared.dataTask(with: request)
        
        task.resume()
        
        /*let urlAsString = (K12NetUserPreferences.getHomeAddress() as String) + "/Authentication_JSON_AppService.axd/SetLanguage"
        
        let response: AutoreleasingUnsafeMutablePointer<URLResponse?>?=nil
        var request = URLRequest(url: URL(string: urlAsString)!);
        
        /*request.httpMethod = "POST";
        request.httpBody =  "".data(using: String.Encoding.utf8)!;*/
        request.setValue(K12NetUserPreferences.getLanguage(), forHTTPHeaderField: "LanguageCode");
        let task = URLSession.shared.dataTask(with: request,
                                    completionHandler: { data2, response, error -> Void in
                                        let data1 = data2 ?? "".data(using: String.Encoding.utf8)!;
                                        print(String(data: data1, encoding: .utf8)!)
        })
        task.resume()*/
     /*   let task = URLSession.shared.dataTask(request) {
            data, response, error in
            
            // Check for error
            if error != nil
            {
                print("error=\(error)")
                return
            }
            
            // Print out response string
            let responseString = NSString(data: data!, encoding: NSUTF8StringEncoding)
            print("responseString = \(responseString)")
            
            
            // Convert server json response to NSDictionary
            do {
                if let convertedJsonIntoDict = try NSJSONSerialization.JSONObjectWithData(data!, options: []) as? NSDictionary {
                    
                    // Print out dictionary
                    print(convertedJsonIntoDict)
                    
                    // Get value by key
                    let firstNameValue = convertedJsonIntoDict["userName"] as? String
                    print(firstNameValue!)
                    
                }
            } catch let error as NSError {
                print(error.localizedDescription)
            }
            
        }*/
        /*NSURLConnection.sendAsynchronousRequest(request as URLRequest, queue: OperationQueue.main) {(response, data2, error) in
            let data1 = data2 ?? "".data(using: String.Encoding.utf8)!;
            print(String(data: data1, encoding: .utf8)!)
        }*/
        
        
        /*let data: Data = K12NetWebRequest.sendSynchronousRequest(request, returningResponse: response)
        
        if(K12NetWebRequest.getLastError() == nil) {
            
            let jsonStr = NSString(data: data, encoding: String.Encoding.utf8.rawValue);
            
            print("logintex : \(String(describing: jsonStr))");
            
        }
        else {
            print("lasterror");
            print(K12NetWebRequest.getLastError() ?? "");
            if(K12NetWebRequest.getLastError()?.code == -1003) { //NSURLErrorDomain
                LoginAsyncTask.urlError = true;
            }
            else if(K12NetWebRequest.getLastError()?.code == NSURLErrorTimedOut ||
                K12NetWebRequest.getLastError()?.code == NSURLErrorCannotConnectToHost ||
                K12NetWebRequest.getLastError()?.code == NSURLErrorNetworkConnectionLost ||
                K12NetWebRequest.getLastError()?.code == NSURLErrorNotConnectedToInternet) {
                LoginAsyncTask.connectionError = true;
            }
        }*/
    }
}
