//
//  AttendanceManager.swift
//  K12Net Mobile
//
//  Created by Ilhami Sisnelioglu on 24.05.2022.
//  Copyright © 2022 K12Net. All rights reserved.
//

import UIKit
import CoreLocation

class AttendanceManager: NSObject {
    var GeoFenceList = [GeoFenceData]()
    var LocationManager :CLLocationManager?
    static let Instance = AttendanceManager()
    
    func Initialize(controller : UIViewController){
        let hasUserPermit = K12NetUserPreferences.getBooleanValue("PERMIT_LOCATION_ATTENDANCE");
        if hasUserPermit != nil && hasUserPermit == false {
            return
        }
        
        let isReady = BindGeoFences();
        
        if(!isReady) {
            return;
        }
        
        if self.GeoFenceList.isEmpty {
            K12NetUserPreferences.setBooleanValue("PERMIT_LOCATION_ATTENDANCE", value: false)
            if hasUserPermit != nil {
                stopMonitorServices()
            }
            
            let alertController = UIAlertController(title: "attendanceService".localized, message:"noGeoFence".localized , preferredStyle: UIAlertController.Style.alert)
            alertController.addAction(UIAlertAction(title: "ok".localized, style: UIAlertAction.Style.default,handler: nil))
            
            controller.addActionSheetForiPad(actionSheet: alertController)
            controller.present(alertController, animated: true, completion: nil)
            
            return
        }
        
        if !CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self) {
            let alertController = UIAlertController(title: "attendanceService".localized, message:"locationMonitorNotSupport".localized , preferredStyle: UIAlertController.Style.alert)
            alertController.addAction(UIAlertAction(title: "ok".localized, style: UIAlertAction.Style.default,handler: nil))
            
            controller.addActionSheetForiPad(actionSheet: alertController)
            controller.present(alertController, animated: true, completion: nil)
        }
        
        LocationManager = CLLocationManager()
        LocationManager!.delegate = self
        
        if CLLocationManager.locationServicesEnabled() {
            locationManagerDidChangeAuthorization(LocationManager!)
        }
    }
    
    func takeAttendance(region:CLCircularRegion, way:String){
        let fence = GeoFenceData.parse(region.identifier)
        let deviceID = K12NetUserPreferences.getDeviceToken()
        let urlAsString = (K12NetUserPreferences.getHomeAddress() as String) + "/SISCore.Web/api/MyAttendances/Edit/TakeAttendance"
        
        if (deviceID == "")  {
            //deviceID = "cnt47szSQN6Wr-vaSUVwTc:APA91bGY6ibYOuFJtyVah8zhk8PswkT5x5_5VCucFGdzg5IsccJg0Hw5Lm7ua4KsL4SQqRDsXPV3rk4gGmoT21ITiZKO1JLHJrueFn-HBwZljwMdXTwtqjMqahmSW4yytziBUHVEttvm"
            //return false;
        }
        
        var params : [String:AnyObject] = [:];
        params["UserName"] = K12NetUserPreferences.getUsername().trimmingCharacters(in: .whitespacesAndNewlines) as AnyObject;
        params["DeviceID"] = deviceID as AnyObject;
        params["LocationIX"] = fence.LocationIX as AnyObject;
        params["Way"] = way as AnyObject;
        
        let request = K12NetWebRequest.retrievePostRequest(urlAsString, params: params);
        
        K12NetWebRequest.sendSynchronousRequest(request, complation: { (data, error) in
            if(error == nil) {
                let responseStr = String(data: data!, encoding: String.Encoding.utf8) ?? "x";
                
                //print("takeAttendance Response : \(responseStr)");
                
                if responseStr == "\"ok\"" {
                    let title = way.localized
                    let message = fence.LocationSummary
                    self.sendNotification(title,message,fence.Portal)
                }
            }
            else {
                print("takeAttendance lasterror");
                print(error ?? "");
            }
            
        })
    }
    
    func sendNotification(_ title :String,_ message :String,_ portal :String ) {
        let isAppActive = false;//UIApplication.shared.applicationState == .active
        
        if isAppActive {
            let rootviewcontroller: UIWindow = ((UIApplication.shared.delegate?.window)!)!
            rootviewcontroller.rootViewController!.showAlert(withTitle: title, message: message)
        } else if #available(iOS 10.0, *) {
            // Otherwise present a local notification
            
            let notificationContent = UNMutableNotificationContent()
            var intent = "MyAttendances"
            var query = "/#/check"
            
            if portal == "TP" {
                intent = "StaffAttendances"
                query = "/#/Request/check"
            }
            
            //notificationContent.setValue("YES", forKeyPath: "shouldAlwaysAlertWhileAppIsForeground")
            notificationContent.title = title
            notificationContent.body = message
            notificationContent.sound = .default
            notificationContent.badge = UIApplication.shared.applicationIconBadgeNumber + 1 as NSNumber
            notificationContent.userInfo = ["body": message,"title" : title,"intent":intent,"portal":portal,"query":query]
            
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
            let request = UNNotificationRequest(
                identifier: UUID().uuidString,
                content: notificationContent,
                trigger: trigger)
            
            UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    print("Error: \(error)")
                }
            }
        }
    }
    
    func BindGeoFences() -> Bool {
        self.GeoFenceList = []
        let deviceID = K12NetUserPreferences.getDeviceToken()
        
        if (deviceID == "")  {
            //deviceID = "cnt47szSQN6Wr-vaSUVwTc:APA91bGY6ibYOuFJtyVah8zhk8PswkT5x5_5VCucFGdzg5IsccJg0Hw5Lm7ua4KsL4SQqRDsXPV3rk4gGmoT21ITiZKO1JLHJrueFn-HBwZljwMdXTwtqjMqahmSW4yytziBUHVEttvm"
            return false;
        }
        
        let urlAsString = (K12NetUserPreferences.getHomeAddress() as String) + "/SISCore.Web/api/MyAttendances/GeoFences"
                
        if (urlAsString == "" || URL(string: urlAsString) == nil)  {
            self.sendNotification("Url not correct!","","*")
            return false;
        }
        
        var params : [String:String] = [:];
        params["UserName"] = K12NetUserPreferences.getUsername().trimmingCharacters(in: .whitespacesAndNewlines);
        params["DeviceID"] = deviceID;
        
        let request = K12NetWebRequest.retrievePostRequest(urlAsString, params: params);
        var isReady = true;
        
        K12NetWebRequest.sendSynchronousRequest(request, complation: { (data, error) in
            if(error == nil) {
                let jsonStr = NSString(data: data!, encoding: String.Encoding.utf8.rawValue);
                
                print("GeoFences Response : \(String(describing: jsonStr))");
                do {
                    self.GeoFenceList = try JSONDecoder().decode([GeoFenceData].self, from: data!)
                    
                    if (!self.GeoFenceList.isEmpty) {
                        self.sendNotification("geofences_added".localized,"","*")
                    }
                }
                catch {
                    isReady = false;
                    if (error as? URLError)?.code == .cancelled {
                        print("cancelled")
                    }
                }
            }
            else {
                isReady = false;
                print("GeoFences lasterror");
                print(error ?? "");
            }
            
        })
        
        return isReady;
    }
    
    func stopMonitorServices() {
        if LocationManager == nil {
            LocationManager = CLLocationManager()
            //LocationManager!.delegate = self do not delege for register events
        }
        
        var portal = "EP";
        
        let monitoredRegions = self.LocationManager!.monitoredRegions
        if !monitoredRegions.isEmpty
        {
            portal = GeoFenceData.parse(monitoredRegions.first!.identifier).Portal
        }
        
        for region in monitoredRegions {
            LocationManager!.stopMonitoring(for: region)
        }
        
        self.sendNotification("geofences_removed".localized,"",portal)
    }
    
    public struct GeoFenceData:Decodable{
        public var Latitude : Double
        public var Longitude : Double
        public var RadiusInMeter : Float
        public var LocationIX : Int
        public var LocationSummary : String
        public var Portal : String
        
        init() {
            self.Latitude = 0
            self.Longitude = 0
            self.RadiusInMeter = 100
            self.LocationIX = 0
            self.LocationSummary = ""
            self.Portal = ""
        }
        
        func identifier() -> String {
            //return String(format: "%f$$$%f$$$%d$$$%@$$$%@",self.Latitude,self.Longitude,self.LocationIX,self.LocationSummary,self.Portal)
            return String(format: "%d$$$%@$$$%@",self.LocationIX,self.LocationSummary,self.Portal)
        }
        
        static func parse(_ identifier:String) -> GeoFenceData {
            let parts = identifier.components(separatedBy: "$$$")
            
            var fence = GeoFenceData()
            
            fence.LocationIX = Int(parts[0] as String)!
            fence.LocationSummary = (parts[1] as String)
            fence.Portal = (parts[2] as String)
            
            /*fence.Latitude = Double(parts[0] as String)!
            fence.Longitude = Double(parts[1] as String)!
            fence.LocationIX = Int(parts[2] as String)!
            fence.LocationSummary = (parts[3] as String)
            fence.Portal = (parts[4] as String)*/
            
            return fence
        }
    }
}


extension AttendanceManager: CLLocationManagerDelegate {
    
    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("LocationManager failed: \(error.localizedDescription)")
    }
    
    func locationManager(_ manager: CLLocationManager,
                         monitoringDidFailFor region: CLRegion?,
                         withError error: Error) {
        print("Region \(region?.identifier ?? "?")  failed: \(error.localizedDescription)")
        self.sendNotification("failed : "+error.localizedDescription,region?.identifier ?? "","")
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
         if let region = region as? CLCircularRegion {
             self.takeAttendance(region: region,way: "enter")
         }
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        if let region = region as? CLCircularRegion {
             self.takeAttendance(region: region,way: "exit")
         }
    }
    
    func locationManager(_ manager:CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        _ = calculateDistance(manager,center, "")
    }
    
    func calculateDistance(_ manager:CLLocationManager,_ currentLocation:CLLocationCoordinate2D, _ identifier:String) -> Double {
        if(manager.monitoredRegions.isEmpty) {
            return 10000000
        }
        
        let l = CLLocation(latitude: currentLocation.latitude, longitude: currentLocation.longitude)
        
        var fenceList = manager.monitoredRegions
        
        if identifier != "" {
            fenceList = fenceList.filter { fence in
                return fence.identifier ==  identifier
            }
        }
        
        if(fenceList.isEmpty) {
            return 10000000
        }
        
        var closestLocation = CLLocation(latitude: 0, longitude: 0)
        if let closestFence = fenceList.first! as? CLCircularRegion {
            closestLocation = CLLocation(latitude: closestFence.center.latitude, longitude: closestFence.center.longitude)
        }
        
        var closestDistance = abs(l.distance(from: closestLocation) as Double)
        
        if identifier != "" {
            return closestDistance
        }
        
        for fence in fenceList {
            if let fence = fence as? CLCircularRegion {
                let fenceLocation = CLLocation(latitude: fence.center.latitude, longitude: fence.center.longitude)
                let locationDistance = abs(l.distance(from: fenceLocation) as Double)
                
                if closestDistance > locationDistance {
                    closestLocation = fenceLocation
                    closestDistance = locationDistance
                }
            }
        }
        
        print("******************************")
        print(currentLocation)
        
        print(String(format: "distance:%f", closestDistance))
        self.sendNotification("Location updated",String(format: "distance:%f", closestDistance),"")
        return closestDistance
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        locationManagerDidChangeAuthorization(manager)
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        var status = CLAuthorizationStatus.authorizedAlways
        
        if #available(iOS 14.0, *) {
            status = manager.authorizationStatus
        }
        
        if status != .authorizedAlways {
            let alertController = UIAlertController(title: "location_permission".localized, message:"locationAccessAppSettings".localized , preferredStyle: UIAlertController.Style.alert)
            alertController.addAction(UIAlertAction(title: "ok".localized, style: UIAlertAction.Style.default,handler: nil))
            
            K12NetLogin.controller?.addActionSheetForiPad(actionSheet: alertController)
            K12NetLogin.controller?.present(alertController, animated: true, completion: nil)
        }
        
        switch status {
        case .notDetermined:
            print("notDetermined")
            manager.requestAlwaysAuthorization()
            
        case .restricted, .denied: print("restricted")
            manager.requestAlwaysAuthorization()
        case .authorizedAlways:
            print("authorizedAlways")
            
            //manager.activityType = .automotiveNavigation
            if #available(iOS 14.0, *) {
                manager.desiredAccuracy = kCLLocationAccuracyBest
            } else {
                //  manager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
            }
            manager.desiredAccuracy = 10//the DesiredAccuracy to update whenever the location changes by a meter.
            
            manager.distanceFilter = kCLDistanceFilterNone
            manager.pausesLocationUpdatesAutomatically = false
            manager.allowsBackgroundLocationUpdates = true
            if #available(iOS 11.0, *) {
                manager.showsBackgroundLocationIndicator = true
            }
            //manager.locationServicesEnabled
            
            let monitoringAvailable = CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self)
            let monitoredRegions = manager.monitoredRegions;
            
            for fence in self.GeoFenceList {
                let center:CLLocationCoordinate2D = CLLocationCoordinate2DMake(fence.Latitude, fence.Longitude)
                let identifier = fence.identifier()
                
                let region = CLCircularRegion(center: center,
                                              radius: CLLocationDistance(fence.RadiusInMeter),
                                              //radius: CLLocationDistance(30),
                                              identifier: identifier)
                
                region.notifyOnEntry = true
                region.notifyOnExit = true
                
                let monitored = monitoredRegions.contains(region)
                
                if  monitoringAvailable && !monitored {
                    manager.startMonitoring(for: region)
                } else if monitoringAvailable {
                   // manager.requestState(for: region)
                }
                
                /*CLLocation* location = [self.locationManager location];
                NSDate* eventDate = location.timestamp;
                float accuracy = location.horizontalAccuracy;
                NSTimeInterval howRecent = [eventDate timeIntervalSinceNow];
                CLLocation* regionLocation = [[CLLocation alloc] initWithLatitude:region.center.latitude longitude:region.center.longitude];
                CLLocationDistance distance = [location distanceFromLocation:regionLocation];

                if (state == CLRegionStateInside && abs(howRecent) < 10 && accuracy <= 100 && distance < region.radius)
                {
                    //Do Something
                }*/
                
                if manager.location != nil {
                    if region.contains(manager.location!.coordinate) {
                        print("===>   inside : " + region.identifier)
                        self.takeAttendance(region: region,way: "enter")
                    } else {
                        print("===>   outside : " + region.identifier)
                        self.takeAttendance(region: region,way: "exit")
                    }
                }
                
                /*let distance = calculateDistance(manager, manager.location!.coordinate,region.identifier)
                
                if distance <= region.radius {
                    print("===>   inside : " + region.identifier + " distance:" + distance.description)
                    self.takeAttendance(region: region,way: "enter")
                } else {
                    print("===>   outside : " + region.identifier + " distance:" + distance.description)
                    self.takeAttendance(region: region,way: "exit")
                }*/
                
                //print(identifier + " monitored:"+monitored.description+" available: "+monitoringAvailable.description)
            }
            
            for region in monitoredRegions {
                let monitored = self.GeoFenceList.filter { fence in
                    return fence.identifier() == region.identifier
                }.count > 0
                
                if !monitored {
                    manager.stopMonitoring(for: region)
                }
            }
            
            /*if CLLocationManager.locationServicesEnabled() {
                manager.startUpdatingLocation()
            }
            manager.startMonitoringSignificantLocationChanges()*/
            
        case .authorizedWhenInUse:
            print("authorizedWhenInUse")
            manager.requestAlwaysAuthorization()
            
        @unknown default:
            print("unknown default")
        }
        
    }
    
    func locationManager_Depraceted(_ manager: CLLocationManager,
                         didDetermineState state: CLRegionState,
                         for region: CLRegion) {
        switch(state) {
        case .inside:
            
            if let region = region as? CLCircularRegion {
                let distance = calculateDistance(manager, manager.location!.coordinate,region.identifier)
                
                if distance <= region.radius {
                    print("===>   inside.ok : " + region.identifier + " distance:" + distance.description)
                    self.takeAttendance(region: region,way: "enter")
                } else {
                    print("===>   inside.error : " + region.identifier + " distance:" + distance.description)
                }
            }
            
        case .outside:
            if let region = region as? CLCircularRegion {
                let distance = calculateDistance(manager, manager.location!.coordinate,region.identifier)
                
                if distance >= region.radius {
                    print("===>   outside.ok : " + region.identifier + " distance:" + distance.description)
                    self.takeAttendance(region: region,way: "exit")
                } else {
                    print("===>   outside.error : " + region.identifier + " distance:" + distance.description)
                }
            }
        case .unknown:
            print("Region \(region.identifier )  state: unknown")
            self.sendNotification("Region unknown",region.identifier,"")
        }
    }
    
    func locationManagerDidPauseLocationUpdates(_ manager: CLLocationManager) {
        print("locationManagerDidPauseLocationUpdates")
        locationManagerDidChangeAuthorization(manager)
    }
    
    func locationManagerDidResumeLocationUpdates(_ manager: CLLocationManager) {
        print("locationManagerDidResumeLocationUpdates")
    }
}
