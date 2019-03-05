//
//  DocViewer.swift
//  K12Net Mobile
//
//  Created by Ilhami Sisnelioglu on 15.02.2019.
//  Copyright © 2019 K12Net. All rights reserved.
//

import Foundation
import UIKit

class DocViewer: UIActivity,UIDocumentInteractionControllerDelegate {
    var docController: UIDocumentInteractionController!
    var controller:UIViewController
    weak var barButton: UIBarButtonItem!
    
    // it's necessary to know which button the UIActivityViewController originated from
    init(barButton barB: UIBarButtonItem, controller cnt: UIViewController) {
        self.barButton = barB
        self.controller = cnt
    }
    
    override open class var activityCategory : UIActivity.Category {
        return .action
    }
    
    override open var activityType: UIActivity.ActivityType? {
        return UIActivity.ActivityType(rawValue: "com.atlas.k12netframe.OpenIn")
    }
    
    override open  var activityTitle : String? {
        return "Open".localized
    }
    
    override open var activityImage : UIImage? {
        return UIImage(named: "view")
    }
    
    override open func canPerform(withActivityItems activityItems: [Any]) -> Bool {
        for a in activityItems {
            if let url = a as? URL  {
                docController = UIDocumentInteractionController(url: url)
                return true
            }
        }
        return false
    }
    
    override open func perform() {
        docController.delegate = self
        docController.presentPreview(animated: true)
        
        activityDidFinish(true)
    }
    
    public func documentInteractionControllerViewControllerForPreview(_ controller: UIDocumentInteractionController) -> UIViewController {
        return self.controller
    }
    
    public func documentInteractionControllerDidEndPreview(_ controller: UIDocumentInteractionController) {
        docController = nil
    }
}

