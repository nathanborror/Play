//
//  VolumeHeader.swift
//  Play
//
//  Created by Nathan Borror on 6/14/14.
//  Copyright (c) 2014 Nathan Borror. All rights reserved.
//

import UIKit

class VolumeHeader: UIButton {

    let kMargin:CGFloat = 16.0
    let kAccessorySize:CGFloat = 44.0

    let title = UILabel()
    let accessoryView = UIImageView()
    let seperator = UIView()

    override init(frame: CGRect) {
        super.init(frame: frame)

        self.backgroundColor = UIColor.whiteColor()

        title.frame = CGRect(x: kMargin, y: 0, width: CGRectGetWidth(self.bounds), height: CGRectGetHeight(self.bounds))
        title.autoresizingMask = .FlexibleWidth | .FlexibleHeight | .FlexibleTopMargin
        title.font = UIFont.header()
        title.textColor = UIColor.textColor()
        title.text = "Undefined"
        self.addSubview(title)

        accessoryView.frame = CGRect(x: CGRectGetWidth(self.bounds)-kAccessorySize, y: (CGRectGetHeight(self.bounds)/2)-(kAccessorySize/2), width: kAccessorySize, height: kAccessorySize)
        accessoryView.image = UIImage(named: "Chevron")
        self.addSubview(accessoryView)

        seperator.frame = CGRect(x: kMargin, y: CGRectGetHeight(self.bounds)-0.5, width: CGRectGetWidth(self.bounds)-kMargin, height: 0.5)
        seperator.backgroundColor = UIColor.borderColor()
        self.addSubview(seperator)
    }

    required init(coder aDecoder: NSCoder!) {
        super.init(coder: aDecoder)
    }

}
