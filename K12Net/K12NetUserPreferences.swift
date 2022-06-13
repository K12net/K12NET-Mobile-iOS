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
    static var LANG_UPDATED = true
    
    static let USERNAME = "USERNAME"
    static let PASSWORD = "PASSWORD"
    static let REMEMBER_ME = "REMEMBER_ME"
    static let BADGE_COUNT = "BADGE_COUNT"
    static let LANGUAGE = "LANGUAGE"
    static let DEVICE_TOKEN = "DEVICE_TOKEN"
    
    
    static let defaults = UserDefaults.standard;
    
    
    static func getStringValue(_ keyValue:String) -> String? {
        return defaults.string(forKey: keyValue)
    }
    
    static func setStringValue(_ key:String, value:String) {
        defaults.set(value, forKey: key)
    }
    
    static func getNumberValue(_ keyValue:String) -> Int? {
        return defaults.integer(forKey: keyValue)
    }
    
    static func setNumberValue(_ key:String, value:Int) {
        defaults.set(value, forKey: key)
    }
    
    static func getBooleanValue(_ keyValue:String) -> Bool? {
        if(defaults.object(forKey: keyValue) == nil) {return nil}
        return defaults.bool(forKey: keyValue)
    }
    
    static func setBooleanValue(_ key:String, value:Bool) {
        defaults.set(value, forKey: key)
    }
    
    private static func initiateDomain() -> Void {
        
        let locale = NSLocale.current
        
        var languageCode = locale.languageCode ?? "tr";
        
        languageCode = languageCode.split(separator: "-")[0].split(separator: "_")[0].lowercased();
        
        if languageCode == "tr" {
            
            saveHomeAddress(AppStaticDefinition.K12NET_LOGIN_DEFAULT_URL);
            saveFSAddress(AppStaticDefinition.K12NET_FS_DEFAULT_URL);
            saveLanguage(lang: AppStaticDefinition.K12NET_DEFAULT_LANGUAGE);
            
        } else {
            
            saveHomeAddress("https://azure.k12net.com");
            saveFSAddress("http://fs.azure.k12net.com/FS/");
            saveLanguage(lang: languageCode);
            
        }
    }
    
    public static func getLanguage() -> String {
        var language : String? = getStringValue(LANGUAGE);
        if language == nil {
            initiateDomain();
            language = getStringValue(LANGUAGE);
            
            if ( language == nil ) {
                language = "tr";
                saveLanguage(lang: language!)
            }
        }
        return language!;
    }
    
    public static func getHomeAddress() -> String {
        var url : NSString;
        if let url_address = getStringValue(HOME_ADDRESS) {
            url = url_address as NSString;
        }
        else {
            initiateDomain();
            url = getStringValue(HOME_ADDRESS)! as NSString;
        }
        
        return url as String
    }
    
    public static func getFSAddress() -> NSString {
        var url : NSString;
        if let url_address = getStringValue(FILE_SERVER_ADDRESS) {
            url = url_address as NSString;
        }
        else {
            initiateDomain();
            url = getStringValue(FILE_SERVER_ADDRESS)! as NSString;
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
    
    public static func getBadgeCount() -> Int {
        var badgeCount = 0;
        if let safeBadgeCount = getNumberValue(BADGE_COUNT) {
            badgeCount = safeBadgeCount;
        }
        return badgeCount;
    }
    
    public static func getDeviceToken() -> String {
        var devId = "";
        if let dev_Id = getStringValue(DEVICE_TOKEN) {
            devId = dev_Id;
        }
        return devId
    }
    
    public static func saveRememberMe(_ state: Bool) {
        setBooleanValue(REMEMBER_ME, value: state)
    }
    
    public static func saveHomeAddress(_ address: String) {
        setStringValue(HOME_ADDRESS, value: address)
    }

    public static func saveFSAddress(_ address: String) {
        setStringValue(FILE_SERVER_ADDRESS, value: address)
    }
    
    public static func saveLanguage(lang: String) {
        var mlang = lang;
        if(mlang == "ar") {
            mlang = "ar-AE";
        }
        LANG_UPDATED = LANG_UPDATED || (mlang != getStringValue(LANGUAGE))
        
        setStringValue(LANGUAGE, value: mlang)
    }
    
    public static func saveUsername(_ username: String) {
        setStringValue(USERNAME, value: username)
    }
    
    
    public static func savePassword(_ password: String) {
        setStringValue(PASSWORD, value: password)
    }
    
    public static func increaseBadgeCount() {
        var badgeCount = getBadgeCount();
        badgeCount += 1;
        setNumberValue(BADGE_COUNT, value: badgeCount);
    }
    
    public static func resetBadgeCount() {
        setNumberValue(BADGE_COUNT, value: 0);
    }
    
    public static func saveDeviceToken(_ deviceToken: String) {
        setStringValue(DEVICE_TOKEN, value: deviceToken)
    }
}
