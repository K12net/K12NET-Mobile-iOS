//
//  AppDelegate.swift
//  K12Net
//
//  Created by Tarik Canturk on 18/04/15.
//  Copyright (c) 2015 Tarik Canturk. All rights reserved.
//

import UIKit
import UserNotifications;

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        UIApplication.shared.statusBarStyle = UIStatusBarStyle.lightContent;
        
        if #available(iOS 10.0, *) {
            let center  = UNUserNotificationCenter.current()
            center.delegate = self
            
            center.requestAuthorization(options: [.badge, .alert, .sound]) { (granted, error) in
                if let error = error {
                    print("Error: \(error)");
                }
                if granted {
                    DispatchQueue.main.async {
                        UIApplication.shared.registerForRemoteNotifications()
                    }
                } else {
                    print("Notification access denied.")
                }
            }
            
            if let remoteNotification = launchOptions?[UIApplicationLaunchOptionsKey.remoteNotification] as? NSDictionary {
                self.handlerRemoteNotification((remoteNotification) as! [AnyHashable : Any] as! [String : AnyObject]);
            }
        }
        else {
            UIApplication.shared.registerUserNotificationSettings(UIUserNotificationSettings(types: [.sound, .alert, .badge], categories: nil))
            UIApplication.shared.registerForRemoteNotifications()
        }
        
        Localizer.DoTheSwizzling();
        
        return true
        
    }
    
    /*func application(_ application: UIApplication,
                     handleActionWithIdentifier identifier: String?,
                     forRemoteNotification userInfo: [AnyHashable : Any],
                     completionHandler: @escaping () -> Swift.Void) {
        
        self.handlerRemoteNotification(userInfo);
        completionHandler()
    }*/
    
    func application( _ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data ) {
        
        var token = ""
        for i in 0..<deviceToken.count {
            token = token + String(format: "%02.2hhx", arguments: [deviceToken[i]])
        }
        
        K12NetLogin.tokenId = token;
        K12NetUserPreferences.saveDeviceToken(token)
        
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
    
    func handlerRemoteNotification(_ userInfo: [AnyHashable: Any]) {
        if #available(iOS 10.0, *) {
        } else {
            if UIApplication.shared.applicationState != .active { return }
        }
        
        if let info = userInfo["aps"] as? Dictionary<String, AnyObject>
        {
            var message = "";
            var title = "";
            var intent = "";
            var portal = "";
            var query = "";
            
            if let alert = info["alert"] as? Dictionary<String, AnyObject>
            {
                if alert.keys.contains("body") {message = alert["body"] as! String;}
                if alert.keys.contains("title") {title = alert["title"] as! String;}
                if alert.keys.contains("intent") {intent = alert["intent"] as! String;}
                if alert.keys.contains("portal") {portal = alert["portal"] as! String;}
                if alert.keys.contains("query") {query = alert["query"] as! String;}
            } else {
                message = info["alert"] as! String;
            }
            
            if !message.isEmpty
            {
                if !portal.isEmpty
                {
                    let dialogMessage = UIAlertController(title: title, message: message + "\n\n" + "navToNotify".localized, preferredStyle: .alert)
                    
                    let ok = UIAlertAction(title: "OK".localized, style: .default, handler: { (action) -> Void in
                        let vc : DocumentView = K12NetLogin.controller!.storyboard!.instantiateViewController(withIdentifier: "document_view") as! DocumentView;
                        
                        vc.startUrl = URL(string:String(format: AppStaticDefinition.K12NET_LOGIN_DEFAULT_URL + "/Default.aspx?intent=%@&portal=%@&query=%@",intent.urlEncode(),portal.urlEncode(),query.urlEncode()));
                        vc.simple_page = true;
                        vc.first_time = false;
                        vc.windowDepth = 1;
                        
                        K12NetLogin.controller?.navigationController?.pushViewController(vc, animated: true);
                    })
                    
                    // Create Cancel button with action handlder
                    let cancel = UIAlertAction(title: "Cancel".localized, style: .cancel) { (action) -> Void in
                        
                    }
                    
                    //Add OK and Cancel button to dialog message
                    dialogMessage.addAction(ok)
                    dialogMessage.addAction(cancel)
                    
                    // Present dialog message to user
                    K12NetLogin.controller?.present(dialogMessage, animated: true, completion: nil)
                } else {
                    let dialogMessage = UIAlertController(title: title, message: message, preferredStyle: .alert)
                    
                    let ok = UIAlertAction(title: "OK".localized, style: .default, handler: { (action) -> Void in
                    })
                    
                    dialogMessage.addAction(ok)
                    K12NetLogin.controller?.present(dialogMessage, animated: true, completion: nil)
                }
            }
        }
    }
    
    //Called when a notification is delivered to a foreground app.
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        print("User Info = ",notification.request.content.userInfo)
        handlerRemoteNotification(notification.request.content.userInfo)
        completionHandler([.alert, .badge, .sound])
    }
    
    //Called to let your app know which action was selected by the user for a given notification.
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        print("User Info 1 = ",response.notification.request.content.userInfo)
        handlerRemoteNotification(response.notification.request.content.userInfo)
        completionHandler()
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        
        NotificationCenter.default.post(name: Notification.Name(rawValue: "TodoListShouldRefresh"), object: self);
        
        K12NetUserPreferences.increaseBadgeCount();
        
        K12NetLogin.refreshAppBadge();
        
        if #available(iOS 10.0, *) {
            if UIApplication.shared.applicationState != .active {
                
            } else {
            }
        } else {
            handlerRemoteNotification(userInfo)
        }
        
        print("application = ",userInfo)
        
    }
    
    func application(_ application: UIApplication, didReceive notification: UILocalNotification) {
        
        
        NotificationCenter.default.post(name: Notification.Name(rawValue: "TodoListShouldRefresh"), object: self)
    
    }


}

