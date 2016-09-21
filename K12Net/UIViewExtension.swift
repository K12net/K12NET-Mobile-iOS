//
//  UIViewExtension.swift
//  K12Net
//
//  Created by Tarik Canturk on 30/11/15.
//  Copyright © 2015 K12Net. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    func addBackground(_ imageName : String) {
        // screen width and height:
        let width = UIScreen.main.bounds.size.width
        let height = UIScreen.main.bounds.size.height
        
        let imageViewBackground = UIImageView(frame: CGRect(x: 0, y: 0, width: width, height: height))
        imageViewBackground.image = UIImage(named: imageName)
        
        // you can change the content mode:
        imageViewBackground.contentMode = UIViewContentMode.scaleAspectFill
        
        self.addSubview(imageViewBackground)
        self.sendSubview(toBack: imageViewBackground)
    }
}
