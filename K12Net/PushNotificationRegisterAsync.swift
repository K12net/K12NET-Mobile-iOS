//
//  PushNotificationRegisterAsync.swift
//  asisto
//
//  Created by Tarik Canturk on 20/08/15.
//  Copyright (c) 2015 Tarik Canturk. All rights reserved.
//

import Foundation

class PushNotificationRegisterAsync : AsyncTask {
    
    var tokenId = "";
    
    init(token : String) {
        self.tokenId = token;
    }
    
    override func doInBackground(){
        
     //   var requestQuery = (K12NetUserPreferences.getHomeAddress() as String) + "/SPSL.Web/ClientBin/Yuce-K12NET-SPServicesLibrary-SPDomainService.svc/json/SubmitChanges";

     let electronicIdJson = "{\"changeSet\": [{\"HasMemberChanges\": 0, \"Id\": 0, \"Operation\": 2, \"Entity\": {\"__type\": \"ElectronicId:#Yuce.K12NET.SPServicesLibrary\", \"ID\": \"00000000-0000-0000-0000-000000000000\", \"TypeID\": \""+AppStaticDefinition.K12NET_IOS_APPLICATION_ID+"\", \"Value\": \""+tokenId+"\"}, \"Associations\": [{\"Key\": \"PersonalInfo_ElectronicIds\", \"Value\": [1]}]}, {\"HasMemberChanges\": 0, \"Id\": 1, \"Operation\": 2, \"Entity\": {\"__type\": \"PersonalInfo_ElectronicId:#Yuce.K12NET.SPServicesLibrary\", \"PersonalInfoID\": \""+StudentListAsyncTask.providerId+"\", \"ElectronicIdID\": \"00000000-0000-0000-0000-000000000000\"}, \"Associations\": [{\"Key\": \"ElectronicId\", \"Value\": [0]}]}]}";
        
        let response: AutoreleasingUnsafeMutablePointer<URLResponse?>?=nil
        
        let serviceAddress = (K12NetUserPreferences.getHomeAddress() as String) + "/SPSL.Web/ClientBin/Yuce-K12NET-SPServicesLibrary-SPDomainService.svc/json/SubmitChanges?appID=" + AppStaticDefinition.K12NET_IOS_APP_NAME;
        
        //var err: NSErrorPointer = nil;
        let pnPost = K12NetWebRequest.retrievePostRequest(serviceAddress, params: electronicIdJson);
        let data =  K12NetWebRequest.sendSynchronousRequest(pnPost, returningResponse: response)
        
        let strData = NSString(data: data, encoding: String.Encoding.utf8.rawValue)! as String
        print("\n\nSendMsgWasRead : \(strData)");
        
    }
    
    override func postExecute(){
        
    }
    
    
}
