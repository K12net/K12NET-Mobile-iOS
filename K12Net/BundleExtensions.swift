
//
//  BundleExtensions.swift
//  K12Net Mobile
//
//  Created by Ilhami Sisnelioglu on 7.03.2019.
//  Copyright © 2019 K12Net. All rights reserved.
//

import Foundation

extension Bundle {
    
    @objc func specialLocalizedStringForKey(_ key: String, value: String?, table tableName: String?) -> String {
        let currentLanguage = K12NetUserPreferences.getLanguage()
        var bundle = Bundle.main
        if let path = Bundle.main.path(forResource: currentLanguage, ofType: "lproj") {
            bundle = Bundle.init(path: path)!
        } else {
            let basePath = Bundle.main.path(forResource: "Base", ofType: "lproj")
            bundle = Bundle.init(path: basePath!)!
        }
        if let name = tableName, name == "CameraUI" {
            let values = NSLocalizedString(key, comment: name)
            return bundle.specialLocalizedStringForKey(key, value: values, table: tableName)
        }
        return bundle.specialLocalizedStringForKey(key, value: value, table: tableName)
    }
}
