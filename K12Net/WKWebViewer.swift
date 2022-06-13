//
//  WKWebViewer.swift
//  K12Net Mobile
//
//  Created by Ilhami Sisnelioglu on 19.02.2019.
//  Copyright © 2019 K12Net. All rights reserved.
//

import Foundation
import UIKit
import WebKit

class WKWebViewer: NSObject, WKNavigationDelegate, WKUIDelegate, IWebView {
    
    static var commonProcessPool : WKProcessPool = WKProcessPool()
    
    var popupWebViews: [WKWebView]?
    var popupWebView: WKWebView?
    var web_viewer: WKWebView!
    var container: DocumentView!
    var downloadInProgress: Bool!
    
    init(dv: DocumentView) {
        super.init()
        
        self.container = dv
    }
    
    func loadView() {
        let preferences = WKPreferences()
        preferences.javaScriptEnabled = true
        preferences.javaScriptCanOpenWindowsAutomatically = true
        preferences.setValue(true, forKey: "allowFileAccessFromFileURLs")
        
        let webConfiguration = WKWebViewConfiguration()
        webConfiguration.preferences = preferences
        
        var Ycord : CGFloat = 0.0 // for top space
        if UIScreen.main.bounds.height == 812 { //Check for iPhone-x
            Ycord = 44.0
        }
        else {
            Ycord = 20.0
        }
        
        let customFrame = CGRect(x: 0.0, y: Ycord, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height-Ycord)
        
        if #available(iOS 11.0, *) {
            
        } else {
            let userContentController = WKUserContentController()
            
            if let cookies = HTTPCookieStorage.shared.cookies {
                let script = getJSCookiesString(for: cookies)
                let cookieScript = WKUserScript(source: script, injectionTime: .atDocumentStart, forMainFrameOnly: false)
                userContentController.addUserScript(cookieScript)
            }
            
            webConfiguration.userContentController = userContentController
        }
        
        webConfiguration.allowsInlineMediaPlayback = true
        
        if #available(iOS 9.0, *) {
            webConfiguration.applicationNameForUserAgent = "K12Net_IOS"
        } else {
            // Fallback on earlier versions
        }
        webConfiguration.processPool = WKWebViewer.commonProcessPool
        
        if #available(iOS 10.0, *) {
            webConfiguration.mediaTypesRequiringUserActionForPlayback = WKAudiovisualMediaTypes.all
        }
        
        web_viewer = WKWebView(frame: customFrame, configuration: webConfiguration)
        web_viewer.uiDelegate = self
        web_viewer.contentMode = UIView.ContentMode.scaleToFill
        web_viewer.allowsBackForwardNavigationGestures=true
        web_viewer.translatesAutoresizingMaskIntoConstraints=false
        web_viewer.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        web_viewer.scrollView.delegate = container
        
        DocumentView.setCookie()
        
        container.preloader.removeFromSuperview()
        container.view.addSubview(web_viewer)
        container.view.addSubview(container.preloader)
    }
    
    open func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        decisionHandler(.allow)
    }
    
    public func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        
        let address = navigationAction.request.url!.absoluteString.lowercased();
        
        print(address);
        
        if(address.contains("browse=newtab") || address.contains("razplus")) {
            UIApplication.shared.openURL(navigationAction.request.url!)
            return nil;
        }
        
        var Ycord : CGFloat = 0.0 // for top space
        if UIScreen.main.bounds.height == 812 { //Check for iPhone-x
            Ycord = 44.0
        }
        else {
            Ycord = 20.0
        }
        
        let customFrame = CGRect(x: 0.0, y: Ycord, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height-Ycord-80)
        
        if (popupWebView != nil) {
            
            if (popupWebViews == nil) {
                popupWebViews = []
            }
            
            popupWebViews?.append(popupWebView!)
        }
        
        popupWebView = WKWebView(frame: customFrame, configuration: configuration)
        popupWebView?.uiDelegate = self
        popupWebView?.contentMode = UIView.ContentMode.scaleToFill
        popupWebView?.allowsBackForwardNavigationGestures=true
        popupWebView?.translatesAutoresizingMaskIntoConstraints=false
        popupWebView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        popupWebView?.scrollView.delegate = container
        
        web_viewer.removeFromSuperview()
        container.view.addSubview(popupWebView!)
        
        return popupWebView!
    }
    
    func webViewDidClose(_ webView: WKWebView) {
        if webView == popupWebView {
            popupWebView?.removeFromSuperview()
            popupWebViews?.removeAll()
            popupWebView = nil
        }
    }
    
    func viewDidLoad() {
        web_viewer.navigationDelegate = self
        
        web_viewer.uiDelegate = self
        
        web_viewer.scrollView.bounces = false
        
        self.web_viewer.addObserver(self, forKeyPath: #keyPath(WKWebView.isLoading), options: .new, context: nil)
        
        if(container.startUrl == nil) {
            let logonAddress = (K12NetUserPreferences.getHomeAddress() as String) + "/Logon.aspx";
            container.last_address = logonAddress;
            
            container.startUrl = URL(string: logonAddress as String);
        } else {
            container.last_address = container.startUrl?.absoluteString;
        }
        
        if(container.simple_page){
            self.loadURL(url: container.startUrl!);
        }
        else  {
            
            self.configureView();
            
            K12NetUserPreferences.resetBadgeCount();
            
            K12NetLogin.refreshAppBadge();
        }
    }
    
    func viewWillAppear(_ animated: Bool) {
        container.navigationController?.isToolbarHidden = false;
        container.navigationController?.isNavigationBarHidden = true;
        container.browseButton?.tintColor = .clear;
    }
    
    func configureView() {
        if (container.startUrl == nil) {
            let logonAddress = (K12NetUserPreferences.getHomeAddress() as String) + "/Logon.aspx";
            container.last_address = logonAddress;
            
            container.startUrl = URL(string: logonAddress as String);
        } else {
            container.last_address = container.startUrl?.absoluteString;
        }
        
        if let urlAddress = container.startUrl {
            self.loadURL(url: urlAddress);
        } else {
            let alertController = UIAlertController(title: "Web View", message:
                                                        "K12Net url address is wrong", preferredStyle: UIAlertController.Style.alert)
            alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertAction.Style.default,handler: nil))
            
            DispatchQueue.main.async {
                self.container.addActionSheetForiPad(actionSheet: alertController)
                self.container.present(alertController, animated: true, completion: nil)
            }
            
            container.navigationItem.rightBarButtonItem = nil;
        }
    }
    
    func homeView(_ sender: AnyObject) {
        if popupWebView != nil {
            self.backView(sender)
            return
        }
        container.startUrl = URL(string: K12NetUserPreferences.getHomeAddress() as String);
        self.loadURL(url: container.startUrl!);
        //progressIndicator.stopAnimating();
    }
    
    func browseView(_ sender: AnyObject) {
        if(container.startUrl == nil) {
            return
        }
        
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(container.startUrl!, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
        } else {
            UIApplication.shared.openURL(container.startUrl!)
        }
        
    }
    
    func refreshView(_ sender: AnyObject) {
        
        self.loadURL(url: (container.last_address != nil) ? URL(string: container.last_address!)! : container.startUrl!);
        
        //web_viewer.reload();
    }
    
    func backView(_ sender: AnyObject) {
        if popupWebView != nil {
            if popupWebView!.canGoBack {
                popupWebView?.goBack();
            }
            else if(container.simple_page) {
                container.navigationController?.popViewController(animated: true);
            } else {
                popupWebView?.removeFromSuperview()
                popupWebView = nil
                
                if(popupWebViews != nil && popupWebViews!.count > 0) {
                    popupWebView = popupWebViews?.removeLast()
                    
                    container.view.addSubview(popupWebView!)
                    popupWebView!.scrollView.delegate = container
                } else {
                    container.view.addSubview(web_viewer)
                    web_viewer.scrollView.delegate = container
                }
            }
            return
        }
        
        if web_viewer.canGoBack {
            web_viewer.goBack();
        }
        else if(container.simple_page) {
            container.navigationController?.popViewController(animated: true);
        }
    }
    
    func nextView(_ sender: AnyObject) {
        if web_viewer.canGoForward {
            web_viewer.goForward();
        }
    }
    
    func loadURL(url: URL) {
        let request = URLRequest(url: url)
        
        DocumentView.setCookie()
        
        if #available(iOS 11.0, *) {
            
            let cookies = HTTPCookieStorage.shared.cookies ?? [HTTPCookie]()
            
            cookies.forEach({
                (popupWebView ?? web_viewer).configuration.websiteDataStore.httpCookieStore.setCookie($0, completionHandler: nil)
            })
        }
        
        (popupWebView ?? web_viewer).load(request);
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        
        let hostAddress = navigationAction.request.url?.host
        
        let address = navigationAction.request.url!.absoluteString.lowercased();
        
        print(address);
        
        if(address.contains("browse=newtab")) {
            UIApplication.shared.openURL(navigationAction.request.url!)
            decisionHandler(.cancel)
            return
        }
        
        if #available(iOS 11.0, *) {
            /*let cookies = HTTPCookieStorage.shared.cookies ?? [HTTPCookie]()
             
             cookies.forEach({
             let wkHttpCookieStorage = WKWebsiteDataStore.default().httpCookieStore;
             let cookie = $0
             
             if(cookie.name.contains("AUTH")) {
             var authCookie:HTTPCookie? = nil
             
             wkHttpCookieStorage.getAllCookies { (wkCookies) in
             // Nothing comes here sometimes !
             for wkCookie in wkCookies {
             if(wkCookie.name == cookie.name && wkCookie.value != cookie.value ) {
             authCookie = wkCookie
             print(wkCookie.name + "- wkCookie -" + wkCookie.value)
             
             //break
             }
             }
             }
             
             if(authCookie != nil) {
             print(cookie.name + "- cookie -" + cookie.value)
             var cookieDict : [HTTPCookiePropertyKey : Any] = [:];
             cookieDict[HTTPCookiePropertyKey.name] = authCookie?.name;
             cookieDict[HTTPCookiePropertyKey.value] = authCookie?.value;
             cookieDict[HTTPCookiePropertyKey.version] = authCookie?.version;
             cookieDict[HTTPCookiePropertyKey.domain] = authCookie?.domain;
             cookieDict[HTTPCookiePropertyKey.originURL] = authCookie?.domain;
             cookieDict[HTTPCookiePropertyKey.path] = authCookie?.path;
             cookieDict[HTTPCookiePropertyKey.secure] = authCookie?.isSecure;
             cookieDict[HTTPCookiePropertyKey.expires] = authCookie?.expiresDate;
             
             if let cookieNew = HTTPCookie(properties: cookieDict ) {
             HTTPCookieStorage.shared.setCookie(cookieNew);
             }
             
             UserDefaults.standard.synchronize()
             // web_viewer.configuration.websiteDataStore.httpCookieStore.setCookie(cookie, completionHandler: nil)
             }
             }
             })*/
        } else {
            DocumentView.setCookie()
            
            let cookies = HTTPCookie.requestHeaderFields(with: HTTPCookieStorage.shared.cookies ?? [])
            
            var headers = navigationAction.request.allHTTPHeaderFields ?? [:]
            cookies.forEach { c in
                headers[c.key] = c.value
            }
            
            var req = navigationAction.request
            req.allHTTPHeaderFields = headers
            req.httpShouldHandleCookies = true
        }
        
        // To connnect app store
        if hostAddress == "itunes.apple.com" {
            if UIApplication.shared.canOpenURL(navigationAction.request.url!) {
                UIApplication.shared.openURL(navigationAction.request.url!)
                decisionHandler(.cancel)
                return
            }
        }
        
        if navigationAction.targetFrame == nil {
            webView.load(navigationAction.request);
        } else if (!(navigationAction.targetFrame?.isMainFrame)! && address == "about:blank") {
            /*decisionHandler(.cancel)
             return*/
        }
        
        if((address.contains("FSCore.Web/api/File") || address.contains("getfile.aspx") || address.contains("getimage.aspx")) && !address.contains(".google.com") && !address.contains("pdfviewer/viewer.html")) {
            
            if(self.downloadInProgress) {
                decisionHandler(.cancel)
                return
            }
            
            self.downloadInProgress = true
            container.preloader.startAnimating()
            container.preloader.isHidden = false
            
            let sessionConfig = URLSessionConfiguration.default
            let session = URLSession(configuration: sessionConfig)
            
            let task = session.downloadTask(with: navigationAction.request) { (tempLocalUrl, response, error) in
                if let tempLocalUrl = tempLocalUrl, error == nil {
                    var fileName = "downloaded_file.pdf"
                    
                    if(address.contains("filename=")) {
                        fileName = address.components(separatedBy: "filename=").last!.components(separatedBy: "&").first!
                    } else if(address.contains("path=")) {
                        fileName = address.components(separatedBy: "path=").last!.components(separatedBy: "/").last!.components(separatedBy: "&").first!
                    }
                    
                    let documentsUrl =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
                    let destinationFileUrl = documentsUrl!.appendingPathComponent(fileName.removingPercentEncoding!)
                    
                    // Success
                    if let statusCode = (response as? HTTPURLResponse)?.statusCode {
                        print("destinationFileUrl: \(destinationFileUrl.absoluteString)")
                        
                        if statusCode == 200 {
                            
                            do {
                                
                                if(FileManager.default.fileExists(atPath: destinationFileUrl.path)) {
                                    _ = try FileManager.default.replaceItemAt(destinationFileUrl, withItemAt: tempLocalUrl)
                                } else {
                                    try FileManager.default.copyItem(at: tempLocalUrl, to: destinationFileUrl)
                                }
                                
                                DispatchQueue.main.async {
                                    let open = DocViewer(barButton: self.container.backButton, controller: self.container.navigationController!)
                                    let activityVC = UIActivityViewController(activityItems: [destinationFileUrl],applicationActivities: [open])
                                    
                                    self.container.addActionSheetForiPad(actionSheet: activityVC)
                                    self.container.present(activityVC, animated: true, completion: nil)
                                    
                                    self.stopAnimating()
                                }
                                
                            } catch (let writeError) {
                                print("Error creating a file \(destinationFileUrl) : \(writeError)")
                            }
                            
                        }
                    }
                    
                } else {
                    print("Error took place while downloading a file. Error description: %@", error?.localizedDescription ?? "");
                }
            }
            
            task.resume()
            
            decisionHandler(.cancel)
            return;
        }
        
        if (address.contains("login.aspx")){
            if(K12NetUserPreferences.getRememberMe()) {
                
                container.preloader.startAnimating()
                container.preloader.isHidden = false
                
                LoginAsyncTask.loginOperation();
                
                self.loadURL(url: URL(string: container.last_address!)!);
                
                self.stopAnimating()
            }
            else {
                self.container.navigationController?.popToRootViewController(animated: true);
            }
            
            decisionHandler(.cancel)
            return;
        }
        else if(address.contains("logout.aspx")) {
            K12NetUserPreferences.saveRememberMe(false);
            K12NetLogin.isLogout = true;
            self.container.navigationController?.popToRootViewController(animated: true);
            
            decisionHandler(.cancel)
            return;
        }
        
        if navigationAction.request.url?.scheme == "tel" {
            
            UIApplication.shared.openURL(navigationAction.request.url!)
            
            decisionHandler(.cancel)
            
        }
        else if navigationAction.request.url?.scheme == "mailto" {
            
            UIApplication.shared.openURL(navigationAction.request.url!)
            
            decisionHandler(.cancel)
            
        }
        else if #available(iOS 11.0, *)  {
            decisionHandler(.allow)
        }
        else {
            let headerKeys = navigationAction.request.allHTTPHeaderFields?.keys
            let hasCookies = headerKeys?.contains("Cookie") ?? false
            
            if hasCookies {
                decisionHandler(.allow)
            } else {
                let cookies = HTTPCookie.requestHeaderFields(with: HTTPCookieStorage.shared.cookies ?? [])
                
                var headers = navigationAction.request.allHTTPHeaderFields ?? [:]
                cookies.forEach { c in
                    headers[c.key] = c.value
                }
                
                var req = navigationAction.request
                req.allHTTPHeaderFields = headers
                req.httpShouldHandleCookies = true
                webView.load(req)
                
                decisionHandler(.cancel)
            }
        }
        
    }
    
    func stopAnimating() {
        self.downloadInProgress = false
        self.container.preloader.stopAnimating()
        self.container.preloader.isHidden = true
    }
    
    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo,
                 completionHandler: @escaping () -> Void) {
        
        if self.container.presentedViewController != nil {
            // either the Alert is already presented, or any other view controller
            // is active (e.g. a PopOver)
            // ...
            completionHandler()
            return
        }
        
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: "OK".localized, style: .default, handler: { (action) in
            completionHandler()
        }))
        
        DispatchQueue.main.async {
            self.container.addActionSheetForiPad(actionSheet: alertController)
            self.container.present(alertController, animated: true, completion: nil)
        }
    }
    
    func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo,
                 completionHandler: @escaping (Bool) -> Void) {
        
        if self.container.presentedViewController != nil {
            // either the Alert is already presented, or any other view controller
            // is active (e.g. a PopOver)
            // ...
            
            let thePresentedVC : UIViewController? = self.container.presentedViewController as UIViewController?
            
            if thePresentedVC != nil {
                /*if let thePresentedVCAsAlertController : UIAlertController = thePresentedVC as? UIAlertController {
                 // nothing to do , AlertController already active
                 // ...
                 print("Alert not necessary, already on the screen !")
                 
                 } else {
                 // there is another ViewController presented
                 // but it is not an UIAlertController, so do
                 // your UIAlertController-Presentation with
                 // this (presented) ViewController
                 // ...
                 
                 print("Alert comes up via another presented VC, e.g. a PopOver")
                 }*/
                
                completionHandler(false)
                return
            }
        }
        
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .actionSheet)
        
        alertController.addAction(UIAlertAction(title: "OK".localized, style: .default, handler: { (action) in
            completionHandler(true)
        }))
        
        alertController.addAction(UIAlertAction(title: "Cancel".localized, style: .default, handler: { (action) in
            completionHandler(false)
        }))
        
        DispatchQueue.main.async {
            self.container.addActionSheetForiPad(actionSheet: alertController)
            self.container.present(alertController, animated: true, completion: nil)
        }
    }
    
    func webView(_ webView: WKWebView, runJavaScriptTextInputPanelWithPrompt prompt: String, defaultText: String?, initiatedByFrame frame: WKFrameInfo,
                 completionHandler: @escaping (String?) -> Void) {
        
        let alertController = UIAlertController(title: nil, message: prompt, preferredStyle: .alert)
        
        alertController.addTextField { (textField) in
            textField.text = defaultText
        }
        
        alertController.addAction(UIAlertAction(title: "OK".localized, style: .default, handler: { (action) in
            if let text = alertController.textFields?.first?.text {
                completionHandler(text)
            } else {
                completionHandler(defaultText)
            }
        }))
        
        alertController.addAction(UIAlertAction(title: "Cancel".localized, style: .default, handler: { (action) in
            completionHandler(nil)
        }))
        
        DispatchQueue.main.async {
            self.container.addActionSheetForiPad(actionSheet: alertController)
            self.container.present(alertController, animated: true, completion: nil)
        }
    }
    
    public func getJSCookiesString(for cookies: [HTTPCookie]) -> String {
        var result = ""
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        dateFormatter.dateFormat = "EEE, d MMM yyyy HH:mm:ss zzz"
        
        for cookie in cookies {
            result += "document.cookie='\(cookie.name)=\(cookie.value); domain=\(cookie.domain); path=\(cookie.path); "
            if let date = cookie.expiresDate {
                result += "expires=\(dateFormatter.string(from: date)); "
            }
            if (cookie.isSecure) {
                result += "secure; "
            }
            result += "'; "
        }
        return result
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        if keyPath == "loading" {
            
            if self.web_viewer.isLoading {
                webViewDidStartLoad()
            } else {
                webViewDidFinishLoad()
            }
            
        }
        
    }
    
    func webViewDidStartLoad() {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        container.preloader.startAnimating()
        container.preloader.isHidden = false
    }
    
    func webViewDidFinishLoad() {
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        
        self.stopAnimating()
        
        if web_viewer.canGoBack || container.simple_page {
            container.backButton.isEnabled = true;
        }
        else {
            container.backButton.isEnabled = false;
        }
        
        if web_viewer.canGoForward {
            container.nextButton.isEnabled = true;
        }
        else {
            container.nextButton.isEnabled = false;
        }
        
        container.last_address = web_viewer.url?.absoluteString;
        
        web_viewer.evaluateJavaScript("document.head.innerHTML") { (htmlCode, error) in
            if error != nil && htmlCode != nil {
                if((htmlCode as! String).contains("atlas-mobile-web-app-no-sleep")) {
                    UIApplication.shared.isIdleTimerDisabled = true;
                }
                else {
                    UIApplication.shared.isIdleTimerDisabled = false;
                }
            }
        }
        
        K12NetUserPreferences.resetBadgeCount();
        
        K12NetLogin.refreshAppBadge();
        
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
    return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}
