//
//  PushNotificationRegisterAsync.swift
//  asisto
//
//  Created by Tarik Canturk on 20/08/15.
//  Copyright (c) 2015 Tarik Canturk. All rights reserved.
//

import Foundation

class PushNotificationRegisterAsync : AsyncTask {
    
    let ASISTO_IOS_APPLICATION_ID = "99260947-ba8f-e511-bf62-3c15c2ddcd05";
    
    var tokenId = "";
    
    init(token : String) {
        self.tokenId = token;
    }
    
    override func doInBackground(){
        
        var requestQuery = (K12NetUserPreferences.getHomeAddress() as String) + "/SPSL.Web/ClientBin/Yuce-K12NET-SPServicesLibrary-SPDomainService.svc/json/SubmitChanges";

     let electronicIdJson = "{\"changeSet\": [{\"HasMemberChanges\": 0, \"Id\": 0, \"Operation\": 2, \"Entity\": {\"__type\": \"ElectronicId:#Yuce.K12NET.SPServicesLibrary\", \"ID\": \"00000000-0000-0000-0000-000000000000\", \"TypeID\": \""+ASISTO_IOS_APPLICATION_ID+"\", \"Value\": \""+tokenId+"\"}, \"Associations\": [{\"Key\": \"PersonalInfo_ElectronicIds\", \"Value\": [1]}]}, {\"HasMemberChanges\": 0, \"Id\": 1, \"Operation\": 2, \"Entity\": {\"__type\": \"PersonalInfo_ElectronicId:#Yuce.K12NET.SPServicesLibrary\", \"PersonalInfoID\": \""+StudentListAsyncTask.providerId+"\", \"ElectronicIdID\": \"00000000-0000-0000-0000-000000000000\"}, \"Associations\": [{\"Key\": \"ElectronicId\", \"Value\": [0]}]}]}";
        
        var response: AutoreleasingUnsafeMutablePointer<NSURLResponse?>=nil
        
        let serviceAddress = (K12NetUserPreferences.getHomeAddress() as String) + "/SPSL.Web/ClientBin/Yuce-K12NET-SPServicesLibrary-SPDomainService.svc/json/SubmitChanges?appID=k12net_ios";
        
        var err = NSErrorPointer();
        var pnPost = K12NetWebRequest.retrievePostRequest(serviceAddress, params: electronicIdJson);
        var data =  K12NetWebRequest.sendSynchronousRequest(pnPost, returningResponse: response)
        
        var strData = NSString(data: data, encoding: NSUTF8StringEncoding)! as String
        print("\n\nSendMsgWasRead : \(strData)");
        
    }
    
    override func postExecute(){
        
    }
    
    
}