//
//  AsyncTask.swift
//  K12Net
//
//  Created by Tarik Canturk on 23/06/15.
//  Copyright (c) 2015 Tarik Canturk. All rights reserved.
//

import Foundation
import UIKit

public class AsyncTask {
    
    var listener : AsyncTaskCompleteListener?;
    
    var tag : Int32 = 0;
    
    public func setOnTaskComplete(listener : AsyncTaskCompleteListener){
        self.listener = listener;
    }
    
    public func Execute(){
        
        var queue : dispatch_queue_t = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        dispatch_async(queue) {
            
            UIApplication.sharedApplication().networkActivityIndicatorVisible = true
            
            self.doInBackground();
            
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            
            dispatch_async(dispatch_get_main_queue()) {
                
                self.postExecute();
                
                self.listener?.completed(self.tag);
                
            };
            
        }
        
    }
    
    func doInBackground(){
        
    }
    
    func postExecute(){
        
    }
    
}
