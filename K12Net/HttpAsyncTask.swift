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
       // if (self.operation == "SetLanguage") {
        //     self.doSetLanguage();
        //}
    }
    
    override func postExecute(){
        
    }
    
}
