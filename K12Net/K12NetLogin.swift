//
//  ViewController.swift
//  K12Net
//
//  Created by Tarik Canturk on 18/04/15.
//  Copyright (c) 2015 Tarik Canturk. All rights reserved.
//

import UIKit

class K12NetLogin: UIViewController, UITextFieldDelegate, AsyncTaskCompleteListener , XMLParserDelegate{
    var latestVersion = "";
    
    @IBOutlet weak var txtUsername: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    @IBOutlet weak var btnLogiin: UIButton!
    @IBOutlet weak var chkRememberMe: UISwitch!
    @IBOutlet weak var lblRememberMe: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var btnSettings: UIButton!
    @IBOutlet weak var lblAppTitle: UILabel!;
    
    static var tokenId = "";
    static var isLogout = false;
    
    static var controller :K12NetLogin? = nil;
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
        if elementName == "ios" {
            if let version = attributeDict["version"] {
                self.latestVersion = version;
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
       // K12NetSettings.setLanguageMap();
        
        K12NetLogin.controller = self;
        setupKeyboardNotifcationListenerForScrollView(scrollView, moveView: true);
        
       // self.view.addBackground("Background");
        //self.view.backgroundColor = UIColor(patternImage: UIImage(named:"Background")!);
        if(AppStaticDefinition.K12NET_UPDATE_VIEW_COLOR) {
            let gradient: CAGradientLayer = CAGradientLayer()
            gradient.frame = view.bounds;
            gradient.colors = [AppStaticDefinition.K12NET_LOGIN_SCREEN_START_COLOR, AppStaticDefinition.K12NET_LOGIN_SCREEN_END_COLOR];
            view.layer.insertSublayer(gradient, at: 0)
        }
        
       // lblAppTitle.text = AppStaticDefinition.K12NET_IOS_APP_TITLE;
       // lblAppTitle.font = UIFont(name: "Helvetica", size: AppStaticDefinition.K12NET_IOS_APP_TITLE_SIZE);
       // lblAppTitle.textColor = UIColor.white;
        
        chkRememberMe.setOn(K12NetUserPreferences.getRememberMe(), animated: true);
        txtUsername.text = K12NetUserPreferences.getUsername();
        txtPassword.text = K12NetUserPreferences.getPassword();
        
        //todo: App provider must include their own PrivacyPolicy by changing below url
        var xmlString = ""
        if let url = URL(string: "http://fs.k12net.com/mobile/files/versions.k12net.txt") {
            do {
                xmlString = try String(contentsOf: url)
                
                let xmlData = xmlString.data(using: String.Encoding.utf8)!
                let parser = XMLParser(data: xmlData)
                
                parser.delegate = self;
                
                parser.parse()
            } catch {
                print("Error download url \(url) : \(error)")
            }
        } else {
            // the URL was bad!
        }
        
        if(self.latestVersion != "") {
            let appVersion = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as? String;
            
            if(appVersion != nil) {
                let latestVersionList = self.latestVersion.split(separator: ".").map{ Int($0)!};
                let appVersionList = appVersion?.split(separator: ".").map{ Int($0)!};
                var index = 0;
                var hasNewUpdate = false;
                
                for version in latestVersionList {
                    if((appVersionList?.count)! > index && version > (appVersionList?[index])!) {
                        hasNewUpdate = true;
                        break;
                    }
                    
                    index = index + 1;
                }
                
                if(hasNewUpdate) {
                    let alert = UIAlertController(title: "alert".localized, message: "newUpdateAvailableWarning".localized, preferredStyle: UIAlertController.Style.alert)
                    
                    let cancel = UIAlertAction(title: "Cancel".localized, style: .cancel) { (action) -> Void in
                        
                    }
                    
                    alert.addAction(UIAlertAction(title: "update".localized, style: UIAlertAction.Style.default, handler: { action in
                        let appUrl = URL(string: "https://itunes.apple.com/tr/app/k12net-mobil/id1155767502?l=tr&mt=8")
                        
                        if #available(iOS 10.0, *) {
                            UIApplication.shared.open(appUrl!, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
                        } else {
                            UIApplication.shared.openURL(appUrl!)
                        }
                        
                    }));
                    alert.addAction(cancel)
                    
                    self.present(alert, animated: true, completion: nil)
                }
            }
            
        }
        
        if chkRememberMe.isOn {
            loginOperation();
        }
        
        self.txtUsername!.delegate = self;
        self.txtPassword!.delegate = self;
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
    
    deinit {
        removeKeyboardNotificationListeners();
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        
        if(AppStaticDefinition.K12NET_UPDATE_VIEW_COLOR) {
            view.layer.sublayers?.remove(at: 0);
            let gradient: CAGradientLayer = CAGradientLayer();
            gradient.frame = CGRect(x:0, y:0, width:view.bounds.height, height:view.bounds.width);
            gradient.colors = [AppStaticDefinition.K12NET_LOGIN_SCREEN_START_COLOR, AppStaticDefinition.K12NET_LOGIN_SCREEN_END_COLOR];
            view.layer.insertSublayer(gradient, at: 0)
        }

        
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {   //delegate method
        textField.resignFirstResponder()
        return true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated);
        navigationController?.setNavigationBarHidden(true, animated: true);
        self.navigationController?.isToolbarHidden = true;
        
        if (K12NetLogin.isLogout) {
            K12NetLogin.isLogout = false;
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated);
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    static func refreshAppBadge() {
        
        UIApplication.shared.applicationIconBadgeNumber = K12NetUserPreferences.getBadgeCount();
    }
    
    @IBAction func loginK12Net(_ sender: AnyObject) {
        
        btnLogiin.isEnabled = false;
        
        K12NetUserPreferences.saveUsername(txtUsername.text!);
        K12NetUserPreferences.savePassword(txtPassword.text!);
        K12NetUserPreferences.saveRememberMe(chkRememberMe.isOn);
        
        loginOperation();
        
    }
    
    func completed(_ tag: Int32) {
        
        btnLogiin.isEnabled = true;
        
        if(LoginAsyncTask.urlError) {
            let alertController = UIAlertController(title: "appTitle".localized, message:
                "connectionUrlFailed".localized, preferredStyle: UIAlertController.Style.alert);
            alertController.addAction(UIAlertAction(title: "ok".localized, style: .default, handler: nil));
            
            self.present(alertController, animated: true, completion: nil)
        }
        else if(LoginAsyncTask.connectionError) {
            let alertController = UIAlertController(title: "appTitle".localized, message:
                "noWifi".localized, preferredStyle: UIAlertController.Style.alert);
            alertController.addAction(UIAlertAction(title: "ok".localized, style: .default, handler: nil));
            
            self.present(alertController, animated: true, completion: nil)
        }
        else if(LoginAsyncTask.lastOperationValue) {
            
            let vc : DocumentView = self.storyboard!.instantiateViewController(withIdentifier: "document_view") as! DocumentView;
            navigationController?.pushViewController(vc, animated: true)
            vc.first_time = true;
            vc.simple_page = false;
            vc.startUrl = nil;
            vc.windowDepth = 1;
        }
        else {
            let alertController = UIAlertController(title: "appTitle".localized, message:"loginFailed".localized , preferredStyle: UIAlertController.Style.alert)
            alertController.addAction(UIAlertAction(title: "ok".localized, style: UIAlertAction.Style.default,handler: nil))
            
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    
    func loginOperation() {
        
        let task : LoginAsyncTask = LoginAsyncTask(username: txtUsername.text!, password: txtPassword.text!);
        task.setOnTaskComplete(self);
        task.Execute();
        
    }
    
    @IBAction func clickForgotPassword(_ sender: Any) {
        let vc : DocumentView = self.storyboard!.instantiateViewController(withIdentifier: "document_view") as! DocumentView;
        vc.startUrl = URL(string:AppStaticDefinition.K12NET_LOGIN_DEFAULT_URL + "/ResetPassword.aspx");
        vc.simple_page = true;
        vc.first_time = false;
        vc.windowDepth = 1;
        navigationController?.pushViewController(vc, animated: true);
        
    }
}


// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}
