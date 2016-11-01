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
    
    @IBOutlet weak var connection_url: UITextField!
    @IBOutlet weak var ftp_address: UITextField!
    @IBOutlet weak var btnSave: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var languageSegmented: UISegmentedControl!
    @IBOutlet weak var lblPageTitle: UILabel!
    
    var keyboardFrame : CGRect = CGRect();
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.setNavigationBarHidden(false, animated: true);
        
        //self.view.backgroundColor = UIColor(patternImage: UIImage(named:"Background")!);
        let gradient: CAGradientLayer = CAGradientLayer()
        gradient.frame = view.bounds;
        let k12netBlue = UIColor(red: 0.5859375, green: 0.82421875, blue: 0.8984375, alpha: 1.0).cgColor;
        gradient.colors = [k12netBlue, UIColor.white.cgColor]
        view.layer.insertSublayer(gradient, at: 0)

        
        connection_url.text = K12NetUserPreferences.getHomeAddress() as String;
        ftp_address.text = K12NetUserPreferences.getFSAddress() as String;
        
        setupKeyboardNotifcationListenerForScrollView(scrollView, moveView: true);
        
        self.connection_url.delegate = self;
        self.ftp_address.delegate = self;
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {   //delegate method
        textField.resignFirstResponder()
        return true
    }
    
    @IBAction func save_address(_ sender: AnyObject) {
        
        K12NetUserPreferences.saveHomeAddress(connection_url.text!)
        K12NetUserPreferences.saveFSAddress(ftp_address.text!)
        
        self.navigationController!.popViewController(animated: true);
        
    }
}
