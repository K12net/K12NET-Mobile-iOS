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
    
    public static let ENGLISH = "en";
    public static let ARABIC = "ar";
    public static let TURKISH = "tr";
    
    @IBOutlet weak var connection_url: UITextField!
    @IBOutlet weak var ftp_address: UITextField!
    @IBOutlet weak var btnSave: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var languageSegmented: UISegmentedControl!
    @IBOutlet weak var lblPageTitle: UILabel!
    
    var keyboardFrame : CGRect = CGRect();
    
    let languageMap = [TURKISH,ENGLISH,ARABIC];
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.setNavigationBarHidden(false, animated: true);
        
        if(AppStaticDefinition.K12NET_UPDATE_VIEW_COLOR) {
            //self.view.backgroundColor = UIColor(patternImage: UIImage(named:"Background")!);
            let gradient: CAGradientLayer = CAGradientLayer()
            gradient.frame = view.bounds;
            gradient.colors = [AppStaticDefinition.K12NET_LOGIN_SCREEN_START_COLOR, AppStaticDefinition.K12NET_LOGIN_SCREEN_END_COLOR];
            view.layer.insertSublayer(gradient, at: 0)
        }
        
        connection_url.text = K12NetUserPreferences.getHomeAddress() as String;
        ftp_address.text = K12NetUserPreferences.getFSAddress() as String;
        
        setupKeyboardNotifcationListenerForScrollView(scrollView, moveView: true);
        
        var languageIndex = 0;
        switch K12NetUserPreferences.getLanguage() {
        case "tr":
            languageIndex = 0;
        case "en":
            languageIndex = 1;
        case "ar":
            languageIndex = 2;
        default:
            languageIndex = 0;
        };
        
        languageSegmented.selectedSegmentIndex = languageIndex;
        
        self.connection_url.delegate = self;
        self.ftp_address.delegate = self;
        
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
    	
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {   //delegate method
        textField.resignFirstResponder()
        return true
    }
    
    @IBAction func save_address(_ sender: AnyObject) {
        
        K12NetUserPreferences.saveHomeAddress(connection_url.text!)
        K12NetUserPreferences.saveFSAddress(ftp_address.text!)
        
        Localizer.RefreshUI(self);
    }
    
    @IBAction func segmentedValueChanged(_ sender: Any) {
        K12NetUserPreferences.saveLanguage(lang: languageMap[languageSegmented.selectedSegmentIndex]);
    }
    
}
