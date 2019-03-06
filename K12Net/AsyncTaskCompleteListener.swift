//
//  AsyncTaskCompleteListener.swift
//  K12Net
//
//  Created by Tarik Canturk on 23/06/15.
//  Copyright (c) 2015 Tarik Canturk. All rights reserved.
//

import Foundation

public protocol AsyncTaskCompleteListener {
    
    func completed(_ tag: Int32);
}
