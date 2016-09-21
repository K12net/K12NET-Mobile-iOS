//
//  AsyncTask.swift
//  K12Net
//
//  Created by Tarik Canturk on 23/06/15.
//  Copyright (c) 2015 Tarik Canturk. All rights reserved.
//

import Foundation
import UIKit

open class AsyncTask {
    
    var listener : AsyncTaskCompleteListener?;
    
    var tag : Int32 = 0;
    
    open func setOnTaskComplete(_ listener : AsyncTaskCompleteListener){
        self.listener = listener;
    }
    
    open func Execute(){
        
        var queue : DispatchQueue = DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default);
        queue.async {
            
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
            
            self.doInBackground();
            
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            
            DispatchQueue.main.async {
                
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
