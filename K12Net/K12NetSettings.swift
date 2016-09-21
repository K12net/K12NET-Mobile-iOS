//
//  K12NetSettings.swift
//  K12Net
//
//  Created by Tarik Canturk on 08/07/15.
//  Copyright (c) 2015 Tarik Canturk. All rights reserved.
//

import Foundation
import UIKit
//import Parse

class K12NetSettings : UIViewController, UITextFieldDelegate {
    
    open static let ENGLISH = "en";
    open static let ARABIC = "ar";
    open static let TURKISH = "tr";
    
 //   static var languageCode = K12NetUserPreferences.getLanguage();
    
    @IBOutlet weak var connection_url: UITextField!
    @IBOutlet weak var ftp_address: UITextField!
    @IBOutlet weak var btnSave: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var languageSegmented: UISegmentedControl!
    @IBOutlet weak var lblPageTitle: UILabel!
    
    var keyboardFrame : CGRect = CGRect();
    
    static var languageMap : [String : [String : String]] = [:];
    
    static func setLanguageMap(){
        
        languageMap[ENGLISH] = [:];
        languageMap[ENGLISH]!["appTitle"] = "iSIS";
        languageMap[ENGLISH]!["settings"] = "Settings";
        languageMap[ENGLISH]!["username"] = "Username";
        languageMap[ENGLISH]!["password"] = "Password";
        languageMap[ENGLISH]!["login"] = "Login";
        languageMap[ENGLISH]!["rememberMe"] = "Remember Me";
        languageMap[ENGLISH]!["connectionUrl"] = "ConnectionURL";
        languageMap[ENGLISH]!["save"] = "Save";
        languageMap[ENGLISH]!["connectionUrlFailed"] = "Connection URL is not correct. Please check it and try again";
        languageMap[ENGLISH]!["noWifi"] = "Data connection can not be establised. Please check your data or WiFi connectivity";
        languageMap[ENGLISH]!["loginFailed"] = "Username or password is incorrect. Please check them and try again.";
        languageMap[ENGLISH]!["ok"] = "OK";
        languageMap[ENGLISH]!["english"] = "English";
        languageMap[ENGLISH]!["arabic"] = "العربية";
        languageMap[ENGLISH]!["turkish"] = "Türkçe";
        
        languageMap[ARABIC] = [:];
        languageMap[ARABIC]!["appTitle"] = "iSIS";
        languageMap[ARABIC]!["settings"] = "اعدادات";
        languageMap[ARABIC]!["username"] = "كلمة السر";
        languageMap[ARABIC]!["password"] = "كلمة السر";
        languageMap[ARABIC]!["login"] = "دخول";
        languageMap[ARABIC]!["rememberMe"] = "حفظ كلمة السر";
        languageMap[ARABIC]!["connectionUrl"] = "الرابط";
        languageMap[ARABIC]!["save"] = "حفظ";
        languageMap[ARABIC]!["connectionUrlFailed"] = "الرابط غير صحيح. يرجى التحقق منه والمحاولة مرة اخرى.";
        languageMap[ARABIC]!["noWifi"] = "لم تتم عملية الربط. يرجى التحقق من الاتصال بشبكة الانترنت او WIFI";
        languageMap[ARABIC]!["loginFailed"] = "اسم المستخدم او كلمة السر غير صحيحة. يرجى التحقق منهما والمحاولة مرة اخرى.";
        languageMap[ARABIC]!["ok"] = "موافق";
        languageMap[ARABIC]!["english"] = "English";
        languageMap[ARABIC]!["arabic"] = "العربية";
        languageMap[ARABIC]!["turkish"] = "Türkçe";
        
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.setNavigationBarHidden(false, animated: true);
        
        //self.view.addBackground("LoginBack");
        self.view.backgroundColor = UIColor(patternImage: UIImage(named:"Background")!);
        
        connection_url.text = K12NetUserPreferences.getHomeAddress() as String;
        ftp_address.text = K12NetUserPreferences.getFSAddress() as String;
        
        setupKeyboardNotifcationListenerForScrollView(scrollView, moveView: true);
        
        self.connection_url.delegate = self;
        self.ftp_address.delegate = self;
        
        /* let testObject = PFObject(className: "activity");
        testObject["Activity Name"] = "settings";
        testObject.saveInBackground();*/
        
        selLabelLanguage();
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated);
        
        selLabelLanguage();
    }
    
    func selLabelLanguage(){
        
      /*  self.navigationItem.title = K12NetSettings.languageMap[K12NetUserPreferences.getLanguage()]!["settings"];
        lblPageTitle.text = K12NetSettings.languageMap[K12NetUserPreferences.getLanguage()]!["settings"];
        connection_url.placeholder = K12NetSettings.languageMap[K12NetUserPreferences.getLanguage()]!["connectionUrl"];
        btnSave.setTitle(K12NetSettings.languageMap[K12NetUserPreferences.getLanguage()]!["save"], forState: .Normal);
        
        languageSegmented.setTitle(K12NetSettings.languageMap[K12NetUserPreferences.getLanguage()]!["english"], forSegmentAtIndex: 0);
        languageSegmented.setTitle(K12NetSettings.languageMap[K12NetUserPreferences.getLanguage()]!["arabic"], forSegmentAtIndex: 1);
        
        if(K12NetUserPreferences.getLanguage() == K12NetSettings.ENGLISH) {
            languageSegmented.selectedSegmentIndex = 0;
        }
        else {
            languageSegmented.selectedSegmentIndex = 1;
        }*/
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {   //delegate method
        textField.resignFirstResponder()
        return true
    }
    
    @IBAction func languageChanged(_ sender: AnyObject) {
     /*   if (languageSegmented.selectedSegmentIndex == 0) {
            K12NetSettings.languageCode = K12NetSettings.ENGLISH;
        }
        if (languageSegmented.selectedSegmentIndex == 1) {
            K12NetSettings.languageCode = K12NetSettings.ARABIC;
        }
        K12NetUserPreferences.saveLanguage(K12NetSettings.languageCode);*/
        selLabelLanguage();
    }
    
    @IBAction func save_address(_ sender: AnyObject) {
        
        K12NetUserPreferences.saveHomeAddress(connection_url.text!)
        K12NetUserPreferences.saveFSAddress(ftp_address.text!)
        
        self.navigationController!.popViewController(animated: true);
        
    }
}
