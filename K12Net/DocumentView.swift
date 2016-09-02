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
    
    var startUrl : NSURL?;
    
    var last_address: String?;
    
    var first_time = true;
    
    var windowDepth = 0;
    
    @IBOutlet weak var refreshButton: UIBarButtonItem!
    @IBOutlet weak var backButton: UIBarButtonItem!
    @IBOutlet weak var nextButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        self.navigationController?.navigationBarHidden = true;
        self.navigationController?.toolbarHidden = false;
        last_address = startUrl?.absoluteString;
        
        web_viewer.delegate = self;
        
        self.configureView();
        
    }
    
    @IBAction func closeWindow(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true);
    }
    
    @IBAction func refreshView(sender: AnyObject) {
        
        web_viewer.reload();
    }
    
    @IBAction func backView(sender: AnyObject) {
        if web_viewer.canGoBack {
            web_viewer.goBack();
        }
    }
    
    @IBAction func nextView(sender: AnyObject) {
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
                
                startUrl = NSURL(string: K12NetUserPreferences.getHomeAddress() as String);
                
            }
            
            if let urlAddress = startUrl {
                
                let urlRequest : NSURLRequest = NSURLRequest(URL: urlAddress, cachePolicy: NSURLRequestCachePolicy.ReturnCacheDataElseLoad, timeoutInterval: 30.0 );
                
                browser.loadRequest(urlRequest);
            }
                
            else {
                let alertController = UIAlertController(title: "Web View", message:
                    "K12Net url address is wrong", preferredStyle: UIAlertControllerStyle.Alert)
                alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default,handler: nil))
                
                self.presentViewController(alertController, animated: true, completion: nil)
                
                navigationItem.rightBarButtonItem = nil;
            }
        }
    }
    
    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        
        print(request.URL!);
        
        let address = request.URL!.absoluteString.lowercaseString;
        
      /*  var forNewTab = false;
        
        if(address.hasPrefix("newtab:")) {
            address = address.substringFromIndex(7);
            forNewTab = true;
        }*/
        
        if (address.containsString("login.aspx")){
            if(K12NetUserPreferences.getRememberMe()) {
                LoginAsyncTask.loginOperation();
                
                webView.loadRequest(NSURLRequest(URL: NSURL(string: last_address!)!, cachePolicy: NSURLRequestCachePolicy.ReturnCacheDataElseLoad, timeoutInterval: 30.0 ));
                return false;
            }
            else {
                self.navigationController?.popToRootViewControllerAnimated(true);
            }
            return false;
        }
            
       else if(address.containsString("logout.aspx")) {
            K12NetUserPreferences.saveRememberMe(false);
            K12NetLogin.isLogout = true;
            self.navigationController?.popToRootViewControllerAnimated(true);
            
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
        
        for cookie in NSHTTPCookieStorage.sharedHTTPCookieStorage().cookies! {
            print(cookie);
            print("------");
        }
        
        var cookie = NSHTTPCookieStorage.sharedHTTPCookieStorage().cookies![0];

        var cookieDict : [String : AnyObject] = [:];
        cookieDict[NSHTTPCookieName] = "UICulture";
        cookieDict[NSHTTPCookieValue] = K12NetUserPreferences.getLanguage();
        cookieDict[NSHTTPCookieVersion] = 0;
        cookieDict["sessionOnly"] = true;
        cookieDict[NSHTTPCookieDomain] = cookie.domain;
        cookieDict[NSHTTPCookieOriginURL] = cookie.domain;
        cookieDict[NSHTTPCookiePath] = cookie.path;
        cookieDict[NSHTTPCookieSecure] = cookie.secure;
        cookieDict[NSHTTPCookieExpires] = cookie.expiresDate;
        
         print("------");
        
         print(cookieDict);

        cookie = NSHTTPCookie(properties: cookieDict)!;
        NSHTTPCookieStorage.sharedHTTPCookieStorage().setCookie(cookie);
        
          cookieDict[NSHTTPCookieName] = "Culture";
        
        cookie = NSHTTPCookie(properties: cookieDict)!;
        NSHTTPCookieStorage.sharedHTTPCookieStorage().setCookie(cookie);
        
        print("------");

        for cookie in NSHTTPCookieStorage.sharedHTTPCookieStorage().cookies! {
            print(cookie);
            print("------");
        }
        
        return true;
    }
    
    func webViewDidStartLoad(webView : UIWebView) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        progressIndicator.startAnimating();
    }
    
    func webViewDidFinishLoad(webView : UIWebView) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        progressIndicator.stopAnimating();
        
        if web_viewer.canGoBack {
            backButton.enabled = true;
        }
        else {
            backButton.enabled = false;
        }
        
        if web_viewer.canGoForward {
            nextButton.enabled = true;
        }
        else {
            nextButton.enabled = false;
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
        
    }
}
