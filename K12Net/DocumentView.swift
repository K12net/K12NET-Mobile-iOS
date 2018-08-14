//
//  DocumentView.swift
//  K12Net
//
//  Created by Tarik Canturk on 09/07/15.
//  Copyright (c) 2015 Tarik Canturk. All rights reserved.
//

import Foundation
import UIKit

class DocumentView : UIViewController, UIWebViewDelegate {
    
    @IBOutlet weak var web_viewer: UIWebView!
    
    @IBOutlet weak var progressIndicator: UIActivityIndicatorView!
    
    var startUrl : URL?;
    
    var last_address: String?;
    
    var first_time = true;
    
    var simple_page = false;
    
    var windowDepth = 0;
    
    @IBOutlet weak var refreshButton: UIBarButtonItem!
    @IBOutlet weak var backButton: UIBarButtonItem!
    @IBOutlet weak var nextButton: UIBarButtonItem!
    @IBOutlet weak var homeButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        self.navigationController?.isNavigationBarHidden = true;
        self.navigationController?.isToolbarHidden = false;
        
        if(startUrl == nil) {
            startUrl = URL(string: K12NetUserPreferences.getHomeAddress() as String);
        }
        
        last_address = startUrl?.absoluteString;
        
        web_viewer.delegate = self;
        
        if(simple_page){
            self.web_viewer.loadRequest(URLRequest(url: startUrl!));
            progressIndicator.stopAnimating();
        }
        else  {
            
            self.configureView();
            
            K12NetUserPreferences.resetBadgeCount();
            
            K12NetLogin.refreshAppBadge();
        }
        
    }
    
    @IBAction func homeView(_ sender: AnyObject) {
        startUrl = URL(string: K12NetUserPreferences.getHomeAddress() as String);
        self.web_viewer.loadRequest(URLRequest(url: startUrl!));
        progressIndicator.stopAnimating();
    }
    
    @IBAction func closeWindow(_ sender: AnyObject) {
        self.navigationController?.popViewController(animated: true);
    }
    
    @IBAction func refreshView(_ sender: AnyObject) {
        
        web_viewer.reload();
    }
    
    @IBAction func backView(_ sender: AnyObject) {
        if web_viewer.canGoBack {
            web_viewer.goBack();
        }
        else if(simple_page) {
            self.navigationController?.popViewController(animated: true);
        }
    }
    
    @IBAction func nextView(_ sender: AnyObject) {
        if web_viewer.canGoForward {
            web_viewer.goForward();
        }
        
        /*    NSURLCache.sharedURLCache().removeAllCachedResponses()
         NSURLCache.sharedURLCache().diskCapacity = 0
         NSURLCache.sharedURLCache().memoryCapacity = 0
         
         let storage = NSHTTPCookieStorage.sharedHTTPCookieStorage();
         for cookie in storage.cookies! {
         storage.deleteCookie(cookie);
         }
         NSUserDefaults.standardUserDefaults().synchronize();*/
    }
    
    func configureView() {
        
        if let browser = self.web_viewer{
            
            if startUrl == nil {
                
                startUrl = URL(string: K12NetUserPreferences.getHomeAddress() as String);
                
            }
            
            if let urlAddress = startUrl {
                
                // let randomNumber = arc4random();
                let urlRequest : URLRequest = URLRequest(url: urlAddress);//, cachePolicy: NSURLRequest.CachePolicy.returnCacheDataElseLoad, timeoutInterval: 30.0 );
                
                browser.loadRequest(urlRequest);
            }
                
            else {
                let alertController = UIAlertController(title: "Web View", message:
                    "K12Net url address is wrong", preferredStyle: UIAlertControllerStyle.alert)
                alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default,handler: nil))
                
                self.present(alertController, animated: true, completion: nil)
                
                navigationItem.rightBarButtonItem = nil;
            }
        }
    }
    
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        
        print(request.url!);
        
        let address = (request as NSURLRequest).url!.absoluteString.lowercased();
        
        /*  var forNewTab = false;
         
         if(address.hasPrefix("newtab:")) {
         address = address.substringFromIndex(7);
         forNewTab = true;
         }*/
        
        if (address.contains("login.aspx")){
            if(K12NetUserPreferences.getRememberMe()) {
                LoginAsyncTask.loginOperation();
                
                webView.loadRequest(URLRequest(url: URL(string: last_address!)!, cachePolicy: NSURLRequest.CachePolicy.returnCacheDataElseLoad, timeoutInterval: 30.0 ));
                return false;
            }
            else {
                self.navigationController?.popToRootViewController(animated: true);
            }
            return false;
        }
            
        else if(address.contains("logout.aspx")) {
            K12NetUserPreferences.saveRememberMe(false);
            K12NetLogin.isLogout = true;
            self.navigationController?.popToRootViewController(animated: true);
            
            return false;
        }
        
        /*   if(navigationType == UIWebViewNavigationType.LinkClicked && forNewTab) {
         // UIApplication.sharedApplication().openURL(request.URL!);
         
         let vc : DocumentView = self.storyboard!.instantiateViewControllerWithIdentifier("document_view") as! DocumentView;
         vc.first_time = true;
         vc.windowDepth = windowDepth+1;
         vc.startUrl = NSURL(string: address);
         navigationController?.pushViewController(vc, animated: true)
         
         progressIndicator.stopAnimating();
         return false;
         }*/
        
        // let cookie : NSHTTPCookie = NSHTTPCookie(properties: cookieDict)!;
        // NSHTTPCookieStorage.sharedHTTPCookieStorage().setCookie(cookie);
        
        var cookieDict : [HTTPCookiePropertyKey : Any] = [:];
        cookieDict[HTTPCookiePropertyKey.name] = "UICulture";
        cookieDict[HTTPCookiePropertyKey.value] = K12NetUserPreferences.getLanguage();
        cookieDict[HTTPCookiePropertyKey.version] = 0;
        
        if(HTTPCookieStorage.shared.cookies != nil && (HTTPCookieStorage.shared.cookies?.count)! > 0) {
            let cookie = HTTPCookieStorage.shared.cookies![0];
            cookieDict[HTTPCookiePropertyKey.domain] = cookie.domain;
            cookieDict[HTTPCookiePropertyKey.originURL] = cookie.domain;
            cookieDict[HTTPCookiePropertyKey.path] = cookie.path;
            cookieDict[HTTPCookiePropertyKey.secure] = cookie.isSecure;
            cookieDict[HTTPCookiePropertyKey.expires] = cookie.expiresDate;
        }
        
        if let cookieNew = HTTPCookie(properties: cookieDict ) {
            HTTPCookieStorage.shared.setCookie(cookieNew);
        }
        
        if(HTTPCookieStorage.shared.cookies != nil && (HTTPCookieStorage.shared.cookies?.count)! > 0) {
            let cookie = HTTPCookieStorage.shared.cookies![0];
            cookieDict[HTTPCookiePropertyKey.domain] = cookie.domain;
            cookieDict[HTTPCookiePropertyKey.originURL] = cookie.domain;
            cookieDict[HTTPCookiePropertyKey.path] = cookie.path;
            cookieDict[HTTPCookiePropertyKey.secure] = cookie.isSecure;
            cookieDict[HTTPCookiePropertyKey.expires] = cookie.expiresDate;
        }
        
        cookieDict[HTTPCookiePropertyKey.name] = "Culture";
        cookieDict[HTTPCookiePropertyKey.value] = K12NetUserPreferences.getLanguage();
        
        if let cookieNew = HTTPCookie(properties: cookieDict ) {
            HTTPCookieStorage.shared.setCookie(cookieNew);
        }
        
        cookieDict[HTTPCookiePropertyKey.name] = "AppID";
        cookieDict[HTTPCookiePropertyKey.value] = AppStaticDefinition.K12NET_IOS_APPLICATION_ID;
        
        if let cookieNew = HTTPCookie(properties: cookieDict ) {
            HTTPCookieStorage.shared.setCookie(cookieNew);
        }
        
        return true;
    }
    
    func webViewDidStartLoad(_ webView : UIWebView) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        progressIndicator.startAnimating();
    }
    
    func webViewDidFinishLoad(_ webView : UIWebView) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        progressIndicator.stopAnimating();
        
        if web_viewer.canGoBack || simple_page {
            backButton.isEnabled = true;
        }
        else {
            backButton.isEnabled = false;
        }
        
        if web_viewer.canGoForward {
            nextButton.isEnabled = true;
        }
        else {
            nextButton.isEnabled = false;
        }
        
        //   let htmlString = webView.stringByEvaluatingJavaScriptFromString("document.documentElement.outerHTML");
        
        //  print (htmlString);
        
        //  let jsonStrng = webView.stringByEvaluatingJavaScriptFromString("(function(fields) { var O=[]; for(var i=0; i<fields.length;i++) {O.push(fields[i].value);} return JSON.stringify(O); })(document.querySelectorAll('input[type=\"text\"]'))");
        
        /*   let jsInjection = "javascript: var allLinks = document.getElementsByTagName('a'); if (allLinks) {var i;for (i=0; i<allLinks.length; i++) {var link = allLinks[i];var target = link.getAttribute('target'); if (target && target == '_blank') {link.setAttribute('target','_self');link.href = 'newtab:'+link.href;}}}";
         
         webView.stringByEvaluatingJavaScriptFromString(jsInjection);*/
        
        last_address = webView.request?.mainDocumentURL?.absoluteString;
        
        /*   if(last_address != nil && last_address!.hasPrefix("newtab:")) {
         last_address = last_address!.substringFromIndex(7);
         }*/
        
        let htmlCode = webView.stringByEvaluatingJavaScript(from: "document.head.innerHTML");
        if(htmlCode?.contains("atlas-mobile-web-app-no-sleep"))! {
            UIApplication.shared.isIdleTimerDisabled = true;
        }
        else {
            UIApplication.shared.isIdleTimerDisabled = false;
        }
        
        K12NetUserPreferences.resetBadgeCount();
        
        K12NetLogin.refreshAppBadge();
        
    }
}
