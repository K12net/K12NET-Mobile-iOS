//
//  StringExtension.swift
//  K12Net
//
//  Created by Tarik Canturk on 10/07/15.
//  Copyright (c) 2015 Tarik Canturk. All rights reserved.
//

import Foundation
import UIKit


extension String {
    
    var localized: String {
        return NSLocalizedString(self, comment: "")
    }
    
    func substringFromIndex(_ index: Int) -> String
    {
        if (index < 0 || index > self.characters.count)
        {
            print("index \(index) out of bounds")
            return ""
        }
        return self.substring(from: self.characters.index(self.startIndex, offsetBy: index))
    }
}

