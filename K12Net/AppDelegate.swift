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
    public static var NotificationIsPermitted: Bool?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        if #available(iOS 10.0, *) {
            application.applicationIconBadgeNumber = 0;
            
            let center  = UNUserNotificationCenter.current()
            
            center.delegate = self
            
            center.requestAuthorization(options: [.badge, .alert, .sound]) { (granted, error) in
                if let error = error {
                    print("Error: \(error)");
                }
                
                AppDelegate.NotificationIsPermitted = granted;
                
                if granted {
                    DispatchQueue.main.async {
                        self.configureUserNotifications()
                        UIApplication.shared.registerForRemoteNotifications()
                    }
                } else {
                    print("Notification access denied.")
                }
            }
            
            if let remoteNotification = launchOptions?[UIApplication.LaunchOptionsKey.remoteNotification] as? NSDictionary {
                AppDelegate.handlerRemoteNotification((remoteNotification) as! [AnyHashable : Any] as! [String : AnyObject]);
            }
        }
        else {
            if #available(iOS 9.0, *) {
                
            } else {
                UIApplication.shared.statusBarStyle = UIStatusBarStyle.lightContent;
            }
        
            UIApplication.shared.registerUserNotificationSettings(UIUserNotificationSettings(types: [.sound, .alert, .badge], categories: nil))
            UIApplication.shared.registerForRemoteNotifications()
            
            AppDelegate.NotificationIsPermitted = UIApplication.shared.isRegisteredForRemoteNotifications
        }
        
        Localizer.DoTheSwizzling();
        
        return true
        
    }
           
    @available(iOS 10.0, *)
    func scheduleTestNotification() {
        let notificationCenter = UNUserNotificationCenter.current()
        
        let notification = UNMutableNotificationContent()
        notification.title = "Important Message"
        notification.body = "It's a snow day tomorrow. No school busses."
        notification.categoryIdentifier = "confirmas_aa"
        notification.userInfo = ["additionalData": "Additional data can also be provided"]
        notification.sound = UNNotificationSound.default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 10, repeats: false)
        
        let notificationRequest = UNNotificationRequest(identifier: UUID().uuidString, content: notification, trigger: trigger)
        notificationCenter.add(notificationRequest)
    }
    
    @available(iOS 10.0, *)
    func configureUserNotifications() {
        let acceptAction = UNNotificationAction(identifier:
                                                    "accept", title: "✅ "+"YES".localized, options:[])
        let rejectAction = UNNotificationAction(identifier:
            "reject", title: "❌ "+"NO".localized, options: [.destructive])
        
        if #available(iOS 11.0, *) {
            let category =
            UNNotificationCategory(identifier: "confirm",
                                   actions: [acceptAction,rejectAction],
                                   intentIdentifiers: [],
                                   hiddenPreviewsBodyPlaceholder: "",
                                   options: [.customDismissAction])//customDismissAction
            
            UNUserNotificationCenter.current()
                .setNotificationCategories([category])
        } else {
            
            let category =
                UNNotificationCategory(identifier: "confirm",
                                       actions: [acceptAction,rejectAction],
                                       intentIdentifiers: [],
                                       options: [])
            
            UNUserNotificationCenter.current()
                .setNotificationCategories([category])
        }
    }
    
    func application( _ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data ) {
        
        var token = ""
        for i in 0..<deviceToken.count {
            token = token + String(format: "%02.2hhx", arguments: [deviceToken[i]])
        }
        
        K12NetLogin.tokenId = token;
        K12NetUserPreferences.saveDeviceToken(token)
        
    }
    
    func application( _ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error ) {
        
        print( error.localizedDescription )
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
    
    private static func doSetNotificationResponse(isConfirmed:Bool, notificationID:String) {
        let urlAsString = (K12NetUserPreferences.getHomeAddress() as String) + "/GWCore.Web/api/Portals/NotificationResponse/"+(isConfirmed ? "1" : "0")+"/"+notificationID;
        
        let request = K12NetWebRequest.retrieveGetRequest(urlAsString);
        
        K12NetWebRequest.sendSynchronousRequest(request, complation: { (data, error) in
            if(error == nil) {
                let jsonStr = NSString(data: data!, encoding: String.Encoding.utf8.rawValue);
                
                print("NotificationResponse : \(String(describing: jsonStr))");
            }
            else {
                print("NotificationResponse lasterror");
                print(error ?? "");
            }
            
        })
        
    }
    
    public static func handlerRemoteNotification(_ userInfo: [AnyHashable: Any], actionIdentifier: String? = nil) {
        if userInfo.isEmpty {return}
        var message = "";
        var title = "";
        var intent = "";
        var portal = "";
        var query = "";
        
        if userInfo.keys.contains("body") {message = userInfo["body"] as! String;}
        if userInfo.keys.contains("title") {title = userInfo["title"] as! String;}
        if userInfo.keys.contains("intent") {intent = userInfo["intent"] as! String;}
        if userInfo.keys.contains("portal") {portal = userInfo["portal"] as! String;}
        if userInfo.keys.contains("query") {query = userInfo["query"] as! String;}
        
        if let info = userInfo["aps"] as? Dictionary<String, AnyObject>
        {
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
        }
        
        if !message.isEmpty
        {
            if (intent == "confirm" && actionIdentifier != nil)
            {
                let notificationID = query.components(separatedBy:";").last;
                
                switch actionIdentifier {
                   case "accept":
                    K12NetLogin.userInfo = [:];
                    AppDelegate.doSetNotificationResponse(isConfirmed: true,notificationID: notificationID ?? "0")
                      return
                   case "reject":
                    K12NetLogin.userInfo = [:];
                    AppDelegate.doSetNotificationResponse(isConfirmed: false,notificationID: notificationID ?? "0")
                      return
                   default:
                      break
               }
            }
            if !portal.isEmpty
            {
                K12NetLogin.userInfo = userInfo;
                
                var body = message + "\n\n" + "navToNotify".localized;
                
                if(intent == "confirm") {
                    body = message;
                }
                
                let dialogMessage = UIAlertController(title: title, message: body, preferredStyle: .alert)
                
                let ok = UIAlertAction(title: "OK".localized, style: .default, handler: { (action) -> Void in
                    K12NetLogin.userInfo = [:];
                    
                    if (intent == "confirm") {
                        let notificationID = query.components(separatedBy:";").last;
                        AppDelegate.doSetNotificationResponse(isConfirmed: true,notificationID: notificationID ?? "0")
                    } else {
                        let viewController = K12NetLogin.controller?.navigationController?.topViewController
                        
                        if(viewController != nil && viewController is DocumentView) {
                            let dv = (viewController as! DocumentView);
                            
                            if(dv.preloader != nil && !dv.preloader.isHidden) {
                                
                                K12NetLogin.notificationURL = URL(string:String(format: K12NetUserPreferences.getHomeAddress() + "/Default.aspx?intent=%@&portal=%@&query=%@",intent.urlEncode(),portal.urlEncode(),query.urlEncode()));
                                
                                return
                            }
                        }
                        let vc : DocumentView = K12NetLogin.controller!.storyboard!.instantiateViewController(withIdentifier: "document_view") as! DocumentView;
                        
                        vc.startUrl = URL(string:String(format: K12NetUserPreferences.getHomeAddress() + "/Default.aspx?intent=%@&portal=%@&query=%@",intent.urlEncode(),portal.urlEncode(),query.urlEncode()));
                        vc.simple_page = true;
                        vc.first_time = false;
                        vc.windowDepth = 1;
                        
                        K12NetLogin.controller?.navigationController?.pushViewController(vc, animated: true);
                        K12NetLogin.controller?.addActionSheetForiPad(actionSheet: dialogMessage)
// vc.navigationController?.pushViewController(vc, animated: true);
                    }
                })
                
                // Create Cancel button with action handlder
                let cancel = UIAlertAction(title: "Cancel".localized, style: .cancel) { (action) -> Void in
                    K12NetLogin.userInfo = [:];
                    
                    if (intent == "confirm") {
                        let notificationID = query.components(separatedBy:";").last;
                        AppDelegate.doSetNotificationResponse(isConfirmed: false,notificationID: notificationID ?? "0")
                    }
                }
                
                //Add OK and Cancel button to dialog message
                dialogMessage.addAction(ok)
                dialogMessage.addAction(cancel)
                K12NetLogin.controller?.addActionSheetForiPad(actionSheet: dialogMessage)
                
                // Present dialog message to user
                K12NetLogin.controller?.present(dialogMessage, animated: true, completion: nil)
            } else {
                let dialogMessage = UIAlertController(title: title, message: message, preferredStyle: .alert)
                
                let ok = UIAlertAction(title: "OK".localized, style: .default, handler: { (action) -> Void in
                    K12NetLogin.userInfo = [:];
                })
                
                dialogMessage.addAction(ok)
                K12NetLogin.controller?.addActionSheetForiPad(actionSheet: dialogMessage)
                K12NetLogin.controller?.present(dialogMessage, animated: true, completion: nil)
            }
        }
    }
    
        
    @available(iOS 10.0, *)
    func userNotificationCenter(center: UNUserNotificationCenter, willPresentNotification notification: UNNotification, withCompletionHandler completionHandler: (UNNotificationPresentationOptions) -> Void) {
        print("User Info = ",notification.request.content.userInfo)
        AppDelegate.handlerRemoteNotification(notification.request.content.userInfo)
        completionHandler([.alert, .badge, .sound])
    }
    
    @available(iOS 10.0, *)
    func userNotificationCenter(center: UNUserNotificationCenter, didReceiveNotificationResponse response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping() -> Void) {
        print("User Info 1 = ",response.notification.request.content.userInfo)
        AppDelegate.handlerRemoteNotification(response.notification.request.content.userInfo, actionIdentifier:response.actionIdentifier)
        completionHandler()
    }
    
    //Called when a notification is delivered to a foreground app.
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        print("User Info = ",notification.request.content.userInfo)
        AppDelegate.handlerRemoteNotification(notification.request.content.userInfo)
        completionHandler([.alert, .badge, .sound])
    }
    
    //Called to let your app know which action was selected by the user for a given notification.
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        print("User Info 1 = ",response.notification.request.content.userInfo)
        AppDelegate.handlerRemoteNotification(response.notification.request.content.userInfo, actionIdentifier:response.actionIdentifier)
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
            AppDelegate.handlerRemoteNotification(userInfo)
        }
        
        print("application = ",userInfo)
        
    }
    
    func application(_ application: UIApplication, didReceive notification: UILocalNotification) {
        
        
        NotificationCenter.default.post(name: Notification.Name(rawValue: "TodoListShouldRefresh"), object: self)
    
    }


}

