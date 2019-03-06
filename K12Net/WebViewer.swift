//
//  WebViewer.swift
//  K12Net Mobile
//
//  Created by Ilhami Sisnelioglu on 19.02.2019.
//  Copyright © 2019 K12Net. All rights reserved.
//
//

import Foundation
import UIKit

class WebViewer : NSObject, UIWebViewDelegate, IWebView {
    
    var web_viewer: UIWebView!
    var container: DocumentView!
    
    init(dv: DocumentView) {
        super.init()
        
        self.container = dv
    }
    
    func loadView() {
        let customFrame = CGRect(x: 0.0, y:0.0 , width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        
        web_viewer = UIWebView(frame: customFrame)
        web_viewer.contentMode = UIView.ContentMode.scaleToFill
        web_viewer.translatesAutoresizingMaskIntoConstraints=false
        web_viewer.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        container.view.addSubview(web_viewer)
        
        container.preloader.removeFromSuperview()
        container.view.addSubview(container.preloader)
    }
    
    func viewDidLoad() {        
        if(self.container.startUrl == nil) {
            let logonAddress = (K12NetUserPreferences.getHomeAddress() as String) + "/Logon.aspx";
            self.container.last_address = logonAddress;
            
            self.container.startUrl = URL(string: logonAddress as String);
        } else {
            self.container.last_address = self.container.startUrl?.absoluteString;
        }
        
        web_viewer.delegate = self;
        
        if(self.container.simple_page){
            self.web_viewer.loadRequest(URLRequest(url: self.container.startUrl!));
            self.container.preloader.stopAnimating();
        }
        else  {
            
            self.configureView();
            
            K12NetUserPreferences.resetBadgeCount();
            
            K12NetLogin.refreshAppBadge();
        }
        
    }
    
    func viewWillAppear(_ animated: Bool) {
        self.container.navigationController?.isToolbarHidden = false;
        self.container.navigationController?.isNavigationBarHidden = true;
        container.browseButton?.tintColor = .clear;
    }
    
    @IBAction func homeView(_ sender: AnyObject) {
        self.container.startUrl = URL(string: K12NetUserPreferences.getHomeAddress() as String);
        self.web_viewer.loadRequest(URLRequest(url: self.container.startUrl!));
        self.container.preloader.stopAnimating();
    }
    
    @IBAction func closeWindow(_ sender: AnyObject) {
        self.container.navigationController?.popViewController(animated: true);
    }
    
    @IBAction func browseView(_ sender: AnyObject) {
        if(self.container.startUrl == nil) {
            return
        }
        
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(self.container.startUrl!, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
        } else {
            UIApplication.shared.openURL(self.container.startUrl!)
        }
        
    }
    
    @IBAction func refreshView(_ sender: AnyObject) {
        
        web_viewer.reload();
    }
    
    @IBAction func backView(_ sender: AnyObject) {
        if web_viewer.canGoBack {
            web_viewer.goBack();
        }
        else if(self.container.simple_page) {
            self.container.navigationController?.popViewController(animated: true);
        }
    }
    
    @IBAction func nextView(_ sender: AnyObject) {
        if web_viewer.canGoForward {
            web_viewer.goForward();
        }
    }
    
    func configureView() {
        
        if let browser = self.web_viewer{
            
            if (self.container.startUrl == nil) {
                let logonAddress = (K12NetUserPreferences.getHomeAddress() as String) + "/Logon.aspx";
                self.container.last_address = logonAddress;
                
                self.container.startUrl = URL(string: logonAddress as String);
            } else {
                self.container.last_address = self.container.startUrl?.absoluteString;
            }
            
            if let urlAddress = self.container.startUrl {
                
                // let randomNumber = arc4random();
                let urlRequest : URLRequest = URLRequest(url: urlAddress);//, cachePolicy: NSURLRequest.CachePolicy.returnCacheDataElseLoad, timeoutInterval: 30.0 );
                
                browser.loadRequest(urlRequest);
            }
                
            else {
                let alertController = UIAlertController(title: "Web View", message:
                    "K12Net url address is wrong", preferredStyle: UIAlertController.Style.alert)
                alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertAction.Style.default,handler: nil))
                
                self.container.addActionSheetForiPad(actionSheet: alertController)
                self.container.present(alertController, animated: true, completion: nil)
                
                self.container.navigationItem.rightBarButtonItem = nil;
            }
        }
    }
    
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebView.NavigationType) -> Bool {
        let address = (request as NSURLRequest).url!.absoluteString.lowercased();
        
        print(address);
        
        if((address.contains("getfile.aspx") || address.contains("getimage.aspx")) && !address.contains(".google.com")) {
            
            if(container.preloader.isHidden == false) {
                return false;
            }
            
            self.container.preloader.startAnimating()
            self.container.preloader.isHidden = false
            
            let sessionConfig = URLSessionConfiguration.default
            let session = URLSession(configuration: sessionConfig)
            
            let task = session.downloadTask(with: request) { (tempLocalUrl, response, error) in
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
                                
                                let open = DocViewer(barButton: self.container.backButton, controller: self.container.navigationController!)
                                let activityVC = UIActivityViewController(activityItems: [destinationFileUrl],applicationActivities: [open])
                                
                                self.container.addActionSheetForiPad(actionSheet: activityVC)
                                self.container.present(activityVC, animated: true, completion: nil)
                                
                                DispatchQueue.main.async {
                                    self.container.preloader.stopAnimating()
                                    self.container.preloader.isHidden = true
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
            
            return false;
        }
        
        if (address.contains("login.aspx")){
            if(K12NetUserPreferences.getRememberMe()) {
                LoginAsyncTask.loginOperation();
                
                webView.loadRequest(URLRequest(url: URL(string: self.container.last_address!)!, cachePolicy: NSURLRequest.CachePolicy.returnCacheDataElseLoad, timeoutInterval: 30.0 ));
                return false;
            }
            else {
                self.container.navigationController?.popToRootViewController(animated: true);
            }
            return false;
        }
            
        else if(address.contains("logout.aspx")) {
            K12NetUserPreferences.saveRememberMe(false);
            K12NetLogin.isLogout = true;
            self.container.navigationController?.popToRootViewController(animated: true);
            
            return false;
        }
        
        DocumentView.setCookie()
        
        return true;
    }
    
    func webViewDidFinishLoad() {
        webViewDidFinishLoad(web_viewer)
    }
    
    func webViewDidStartLoad(_ webView : UIWebView) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        self.container.preloader.startAnimating();
        self.container.preloader.isHidden = false
    }
    
    func webViewDidFinishLoad(_ webView : UIWebView) {
        print(webView.request?.mainDocumentURL?.absoluteString ?? "");
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        self.container.preloader.stopAnimating();
        self.container.preloader.isHidden = true
        
        if web_viewer.canGoBack || self.container.simple_page {
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
        
        self.container.last_address = webView.request?.mainDocumentURL?.absoluteString;
        
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


// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
    return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}
