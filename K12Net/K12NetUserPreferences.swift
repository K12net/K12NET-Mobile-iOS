//
//  K12NetUserPreferences.swift
//  K12Net
//
//  Created by Tarik Canturk on 13/05/15.
//  Copyright (c) 2015 Tarik Canturk. All rights reserved.
//

import Foundation

open class K12NetUserPreferences {
    
    static let FILE_SERVER_ADDRESS = "FILE_SERVER_ADDRESS"
    static let HOME_ADDRESS = "HOME_ADDRESS"
    
    static let USERNAME = "USERNAME"
    static let PASSWORD = "PASSWORD"
    static let REMEMBER_ME = "REMEMBER_ME"
    //    static let LANGUAGE = "LANGUAGE"
    
    
    static let defaults = UserDefaults.standard;
    
    
    static func getStringValue(_ keyValue:String) -> String? {
        return defaults.string(forKey: keyValue)
    }
    
    static func setStringValue(_ key:String, value:String) {
        defaults.set(value, forKey: key)
    }
    
    static func getBooleanValue(_ keyValue:String) -> Bool? {
        return defaults.bool(forKey: keyValue)
    }
    
    static func setBooleanValue(_ key:String, value:Bool) {
        defaults.set(value, forKey: key)
    }
    
   /* public static func getLanguage() -> String {
        var language : String;
        if getStringValue(LANGUAGE) != nil {
            language = getStringValue(LANGUAGE)!;
        }
        else {
            language = "en"
        }
        return language;
    }*/
    
    open static func getHomeAddress() -> NSString {
        var url : NSString;
        if let url_address = getStringValue(HOME_ADDRESS) {
            url = url_address as NSString;
        }
        else {
            url = "https://okul.k12net.com"
        }
        return url
    }
    
    open static func getFSAddress() -> NSString {
        var url : NSString;
        if let url_address = getStringValue(FILE_SERVER_ADDRESS) {
            url = url_address as NSString;
        }
        else {
            url = "http://fs.k12net.com/FS/"
        }
        return url
    }
    
    open static func getUsername() -> String {
        var name = "";
        if let temp_name  = getStringValue(USERNAME) {
            name = temp_name;
        }
        return name
    }
    
    open static func getPassword() -> String {
        var pass = "";
        if let temp_pass  = getStringValue(PASSWORD) {
            pass = temp_pass;
        }
        return pass
    }
    
    open static func getRememberMe() -> Bool {
        var rememberMe = false;
        if let rememberMeValue = getBooleanValue(REMEMBER_ME) {
            rememberMe = rememberMeValue;
        }
        return rememberMe;
    }
    
    open static func saveRememberMe(_ state: Bool) {
        setBooleanValue(REMEMBER_ME, value: state)
    }
    
    open static func saveHomeAddress(_ address: String) {
        setStringValue(HOME_ADDRESS, value: address)
    }

    open static func saveFSAddress(_ address: String) {
        setStringValue(FILE_SERVER_ADDRESS, value: address)
    }
    
  /*  public static func saveLanguage(lang: String) {
        setStringValue(LANGUAGE, value: lang)
    }*/
    
    open static func saveUsername(_ username: String) {
        setStringValue(USERNAME, value: username)
    }
    
    
    open static func savePassword(_ password: String) {
        setStringValue(PASSWORD, value: password)
    }
    
    
}
