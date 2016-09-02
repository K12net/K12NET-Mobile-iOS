//
//  ViewController.swift
//  K12Net
//
//  Created by Tarik Canturk on 18/04/15.
//  Copyright (c) 2015 Tarik Canturk. All rights reserved.
//

import UIKit

class K12NetLogin: UIViewController, UITextFieldDelegate, AsyncTaskCompleteListener {
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        K12NetSettings.setLanguageMap();
        
        setupKeyboardNotifcationListenerForScrollView(scrollView, moveView: true);
        
       // self.view.addBackground("Background");
        self.view.backgroundColor = UIColor(patternImage: UIImage(named:"Background")!);
        
        chkRememberMe.setOn(K12NetUserPreferences.getRememberMe(), animated: true);
        txtUsername.text = K12NetUserPreferences.getUsername();
        
        if chkRememberMe.on {
            txtPassword.text = K12NetUserPreferences.getPassword();
            
            loginOperation();
        }
        
        self.txtUsername!.delegate = self;
        self.txtPassword!.delegate = self;
        
        selLabelLanguage();
        
    }
    
    deinit {
        removeKeyboardNotificationListeners();
    }
    
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {   //delegate method
        textField.resignFirstResponder()
        return true
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated);
        navigationController?.setNavigationBarHidden(true, animated: true);
        self.navigationController?.toolbarHidden = true;
        
        if (K12NetLogin.isLogout) {
            txtPassword.text = "";
            chkRememberMe.setOn(false, animated: true);
            K12NetLogin.isLogout = false;
        }
        
        selLabelLanguage();
        
    }
    
    func selLabelLanguage(){
       // lblAppTitle.text = K12NetSettings.languageMap[K12NetUserPreferences.getLanguage()]!["appTitle"];
        
       // txtUsername.placeholder = K12NetSettings.languageMap[K12NetUserPreferences.getLanguage()]!["username"];
        
       /* txtPassword.placeholder = K12NetSettings.languageMap[K12NetUserPreferences.getLanguage()]!["password"];
        lblRememberMe.text = K12NetSettings.languageMap[K12NetUserPreferences.getLanguage()]!["rememberMe"];
        btnSettings.setTitle(K12NetSettings.languageMap[K12NetUserPreferences.getLanguage()]!["settings"], forState: .Normal);
        btnLogiin.setTitle(K12NetSettings.languageMap[K12NetUserPreferences.getLanguage()]!["login"], forState: .Normal);
        
        self.navigationItem.title = K12NetSettings.languageMap[K12NetUserPreferences.getLanguage()]!["appTitle"];*/
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated);
        navigationController?.setNavigationBarHidden(false, animated: true);
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func loginK12Net(sender: AnyObject) {
        
        btnLogiin.enabled = false;
        
        K12NetUserPreferences.saveUsername(txtUsername.text!);
        K12NetUserPreferences.savePassword(txtPassword.text!);
        K12NetUserPreferences.saveRememberMe(chkRememberMe.on);
        
        loginOperation();
        
    }
    
    func completed(tag: Int32) {
        
        btnLogiin.enabled = true;
        
        if(LoginAsyncTask.urlError == true) {
            let alertController = UIAlertController(title: "appTitle".localized, message:
                "connectionUrlFailed".localized, preferredStyle: UIAlertControllerStyle.Alert);
            alertController.addAction(UIAlertAction(title: "ok".localized, style: .Default, handler: nil));
            
            self.presentViewController(alertController, animated: true, completion: nil)
        }
        else if(LoginAsyncTask.connectionError == true) {
            let alertController = UIAlertController(title: "appTitle".localized, message:
                "noWifi".localized, preferredStyle: UIAlertControllerStyle.Alert);
            alertController.addAction(UIAlertAction(title: "ok".localized, style: .Default, handler: nil));
            
            self.presentViewController(alertController, animated: true, completion: nil)
        }
        else if(LoginAsyncTask.lastOperationValue == 1) {
            
            let vc : DocumentView = self.storyboard!.instantiateViewControllerWithIdentifier("document_view") as! DocumentView;
            navigationController?.pushViewController(vc, animated: true)
            vc.first_time = true;
            vc.windowDepth = 1;
            
            let pnAsyncTask = StudentListAsyncTask();
            pnAsyncTask.Execute();
        }
        else {
            let alertController = UIAlertController(title: "appTitle".localized, message:"loginFailed".localized , preferredStyle: UIAlertControllerStyle.Alert)
            alertController.addAction(UIAlertAction(title: "ok".localized, style: UIAlertActionStyle.Default,handler: nil))
            
            self.presentViewController(alertController, animated: true, completion: nil)
        }
    }
    
    
    func loginOperation() {
        
        let task : LoginAsyncTask = LoginAsyncTask(username: txtUsername.text!, password: txtPassword.text!);
        task.setOnTaskComplete(self);
        task.Execute();
        
    }
    
}

