//
//  AppDelegate.swift
//  K12Net
//
//  Created by Tarik Canturk on 18/04/15.
//  Copyright (c) 2015 Tarik Canturk. All rights reserved.
//

import UIKit
//import SplunkMint;
//import Parse;

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        UIApplication.shared.setStatusBarStyle(UIStatusBarStyle.lightContent, animated: true);
        
        let type : UIUserNotificationType = [.badge, .alert, .sound];
        let setting = UIUserNotificationSettings(types: type, categories: nil);
        UIApplication.shared.registerUserNotificationSettings(setting);
        UIApplication.shared.registerForRemoteNotifications();
        return true
        
    }
    
    func application( _ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data ) {
        
        let characterSet: CharacterSet = CharacterSet( charactersIn: "<>" )
        
        let deviceTokenString: String = ( deviceToken.description as NSString )
            .trimmingCharacters( in: characterSet )
            .replacingOccurrences( of: " ", with: "" ) as String
        
        K12NetLogin.tokenId = deviceTokenString;
        
    }
    
    func application( _ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error ) {
        
        //print( error.localizedDescription )
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
       // NSNotificationCenter.defaultCenter().postNotificationName("TodoListShouldRefresh", object: self);
        
        HTTPCookieStorage.shared.cookieAcceptPolicy = HTTPCookie.AcceptPolicy.always;
        
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        
        NotificationCenter.default.post(name: Notification.Name(rawValue: "TodoListShouldRefresh"), object: self)
        
        var temp : NSDictionary = userInfo as NSDictionary
        if let info = userInfo["aps"] as? Dictionary<String, AnyObject>
        {
            let alertMsg = info["alert"] as! String
            var alert: UIAlertView!
            alert = UIAlertView(title: "", message: alertMsg, delegate: nil, cancelButtonTitle: "OK")
            alert.show()
        }
    }
    
    func application(_ application: UIApplication, didReceive notification: UILocalNotification) {
        
        
        NotificationCenter.default.post(name: Notification.Name(rawValue: "TodoListShouldRefresh"), object: self)
    
    }


}

