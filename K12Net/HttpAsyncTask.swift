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
        var params : [String:String] = [:];
        params["createPersistentCookie"] = "false";
        
        let request = K12NetWebRequest.retrievePostRequest(urlAsString, params: params);
        
        request.setValue(K12NetUserPreferences.getLanguage(), forHTTPHeaderField: "LanguageCode")
        
        K12NetWebRequest.sendSynchronousRequest(request, complation: { (data, error) in
            if(error == nil) {
                let jsonStr = NSString(data: data!, encoding: String.Encoding.utf8.rawValue);
                
                print("LanguageCode : \(String(describing: jsonStr))");
                
                DocumentView.setCookie()
            }
            else {
                print("LanguageCode lasterror");
                print(error ?? "");
            }
            
        })
        
    }
}
