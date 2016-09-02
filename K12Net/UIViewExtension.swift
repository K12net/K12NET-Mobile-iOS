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
    func addBackground(imageName : String) {
        // screen width and height:
        let width = UIScreen.mainScreen().bounds.size.width
        let height = UIScreen.mainScreen().bounds.size.height
        
        let imageViewBackground = UIImageView(frame: CGRectMake(0, 0, width, height))
        imageViewBackground.image = UIImage(named: imageName)
        
        // you can change the content mode:
        imageViewBackground.contentMode = UIViewContentMode.ScaleAspectFill
        
        self.addSubview(imageViewBackground)
        self.sendSubviewToBack(imageViewBackground)
    }
}