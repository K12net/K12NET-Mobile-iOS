//
//  UIAlertControllerExtension.swift
//  K12Net Mobile
//
//  Created by Ilhami Sisnelioglu on 12.06.2018.
//  Copyright © 2018 K12Net. All rights reserved.
//

import Foundation
import UIKit

public extension UIAlertController {
    func show() {
        let win = UIWindow(frame: UIScreen.main.bounds)
        let vc = UIViewController()
        vc.view.backgroundColor = .clear
        win.rootViewController = vc
        win.windowLevel = UIWindowLevelAlert + 1
        win.makeKeyAndVisible()
        vc.present(self, animated: true, completion: nil)
    }
}
