//
//  WebView.swift
//  K12Net Mobile
//
//  Created by Ilhami Sisnelioglu on 15.02.2019.
//  Copyright © 2019 K12Net. All rights reserved.
//

import Foundation
import UIKit
import WebKit

class DocumentView: UIViewController, UIScrollViewDelegate {
    
    @IBOutlet weak var preloader: UIActivityIndicatorView!
    
    @IBOutlet weak var browseButton: UIBarButtonItem!
    @IBOutlet weak var refreshButton: UIBarButtonItem!
    @IBOutlet weak var backButton: UIBarButtonItem!
    @IBOutlet weak var nextButton: UIBarButtonItem!
    @IBOutlet weak var homeButton: UIBarButtonItem!
    
    var lastOffsetY :CGFloat = 0
    
    var startUrl : URL?;
    var last_address: String?;
    var first_time = true;
    var simple_page = false;    
    var windowDepth = 0;
    
    var web_viewer : IWebView!
    
    override func loadView() {
        super.loadView()
        
        if #available(iOS 11.0, *) {
            web_viewer = WKWebViewer(dv:self)
        } else {
            web_viewer = WebViewer(dv:self)
        }
        
        web_viewer.loadView()
    }
    
    //Delegate Methods
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView){
        lastOffsetY = scrollView.contentOffset.y
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView){
        let hide = scrollView.contentOffset.y > self.lastOffsetY
        self.navigationController?.setToolbarHidden(hide, animated: true)
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        web_viewer.viewDidLoad()
        
        self.preloader.transform = CGAffineTransform(scaleX: 2, y: 2)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isToolbarHidden = false;
        self.navigationController?.isNavigationBarHidden = true;
        browseButton?.tintColor = .clear;
    }
    
    override func viewDidDisappear(_ animated: Bool) {
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
        
    }
    
    func configureView() {
        
        web_viewer.configureView()
        
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        
        return .default
        
    }
    
    @IBAction func homeView(_ sender: AnyObject) {
        web_viewer.homeView(sender)
    }
    
    @IBAction func closeWindow(_ sender: AnyObject) {
        self.navigationController?.popViewController(animated: true);
    }
    
    @IBAction func browseView(_ sender: AnyObject) {
        if(startUrl == nil) {
            return
        }
        
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(startUrl!, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
        } else {
            UIApplication.shared.openURL(startUrl!)
        }
        
    }
    
    @IBAction func refreshView(_ sender: AnyObject) {
        web_viewer.refreshView(sender)
    }
    
    @IBAction func backView(_ sender: AnyObject) {
        web_viewer.backView(sender)
    }
    
    @IBAction func nextView(_ sender: AnyObject) {
        web_viewer.nextView(sender)
    }
    
    static func setCookie() {
        var cookieDict : [HTTPCookiePropertyKey : Any] = [:];
        cookieDict[HTTPCookiePropertyKey.name] = "UICulture";
        cookieDict[HTTPCookiePropertyKey.value] = K12NetUserPreferences.getLanguage();
        cookieDict[HTTPCookiePropertyKey.version] = 0;
        
        if(HTTPCookieStorage.shared.cookies != nil && (HTTPCookieStorage.shared.cookies?.count)! > 0) {
            let cookie = HTTPCookieStorage.shared.cookies![(HTTPCookieStorage.shared.cookies?.count)!-1];
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
            let cookie = HTTPCookieStorage.shared.cookies![(HTTPCookieStorage.shared.cookies?.count)!-1];
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
        
        UserDefaults.standard.synchronize()
    }
    
    func webViewDidStartLoad() {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        self.preloader.startAnimating()
        self.preloader.isHidden = false
    }
    
    func webViewDidFinishLoad() {
        web_viewer.webViewDidFinishLoad()
    }
    
    override var prefersStatusBarHidden: Bool {
        
        return false
        
    }
    
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
    return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}
