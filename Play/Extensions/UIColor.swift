//
//  UIColor.swift
//  Play
//
//  Created by Nathan Borror on 6/14/14.
//  Copyright (c) 2014 Nathan Borror. All rights reserved.
//

import UIKit

extension UIColor {

    class func tintColor() -> UIColor {
        return UIColor(red: 1.0, green: 0.16, blue: 0.41, alpha: 1.0)
    }

    class func textColor() -> UIColor {
        return UIColor.blackColor()
    }

    class func borderColor() -> UIColor {
        return UIColor(white: 0.9, alpha: 1)
    }

}