//
//  K12NetUserPreferences.swift
//  K12Net
//
//  Created by Tarik Canturk on 13/05/15.
//  Copyright (c) 2015 Tarik Canturk. All rights reserved.
//

import Foundation

public class K12NetUserPreferences {
    
    static let FILE_SERVER_ADDRESS = "FILE_SERVER_ADDRESS"
    static let HOME_ADDRESS = "HOME_ADDRESS"
    
    static let USERNAME = "USERNAME"
    static let PASSWORD = "PASSWORD"
    static let REMEMBER_ME = "REMEMBER_ME"
        static let LANGUAGE = "LANGUAGE"
    
    
    static let defaults = NSUserDefaults.standardUserDefaults();
    
    
    static func getStringValue(keyValue:String) -> String? {
        return defaults.stringForKey(keyValue)
    }
    
    static func setStringValue(key:String, value:String) {
        defaults.setObject(value, forKey: key)
    }
    
    static func getBooleanValue(keyValue:String) -> Bool? {
        return defaults.boolForKey(keyValue)
    }
    
    static func setBooleanValue(key:String, value:Bool) {
        defaults.setObject(value, forKey: key)
    }
    
    public static func getLanguage() -> String {
        var language : String;
        if getStringValue(LANGUAGE) != nil {
            language = getStringValue(LANGUAGE)!;
        }
        else {
            language = "en"
        }
        return language;
    }
    
    public static func getHomeAddress() -> NSString {
        var url : NSString;
        if let url_address = getStringValue(HOME_ADDRESS) {
            url = url_address;
        }
        else {
            url = "https://okul.k12net.com"
        }
        return url
    }
    
    public static func getFSAddress() -> NSString {
        var url : NSString;
        if let url_address = getStringValue(FILE_SERVER_ADDRESS) {
            url = url_address;
        }
        else {
            url = "http://fs.k12net.com/FS/"
        }
        return url
    }
    
    public static func getUsername() -> String {
        var name = "";
        if let temp_name  = getStringValue(USERNAME) {
            name = temp_name;
        }
        return name
    }
    
    public static func getPassword() -> String {
        var pass = "";
        if let temp_pass  = getStringValue(PASSWORD) {
            pass = temp_pass;
        }
        return pass
    }
    
    public static func getRememberMe() -> Bool {
        var rememberMe = false;
        if let rememberMeValue = getBooleanValue(REMEMBER_ME) {
            rememberMe = rememberMeValue;
        }
        return rememberMe;
    }
    
    public static func saveRememberMe(state: Bool) {
        setBooleanValue(REMEMBER_ME, value: state)
    }
    
    public static func saveHomeAddress(address: String) {
        setStringValue(HOME_ADDRESS, value: address)
    }

    public static func saveFSAddress(address: String) {
        setStringValue(FILE_SERVER_ADDRESS, value: address)
    }
    
    public static func saveLanguage(lang: String) {
        setStringValue(LANGUAGE, value: lang)
    }
    
    public static func saveUsername(username: String) {
        setStringValue(USERNAME, value: username)
    }
    
    
    public static func savePassword(password: String) {
        setStringValue(PASSWORD, value: password)
    }
    
    
}
