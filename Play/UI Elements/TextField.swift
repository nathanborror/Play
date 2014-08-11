//
//  TextField.swift
//  Play
//
//  Created by Nathan Borror on 7/26/14.
//  Copyright (c) 2014 Nathan Borror. All rights reserved.
//

import UIKit

class TextField: UITextField {

    let underline = UIView()

    override init(frame: CGRect) {
        super.init(frame: frame)

        underline.backgroundColor = UIColor(white: 0.9, alpha: 1)
        self.addSubview(underline)
    }

    required init(coder aDecoder: NSCoder!) {
        super.init(coder: aDecoder)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        underline.frame = CGRect(x: 0.0, y: CGRectGetHeight(self.bounds)-0.5, width: CGRectGetWidth(self.bounds), height: 0.5)
    }

}
