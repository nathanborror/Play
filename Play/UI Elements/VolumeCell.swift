//
//  VolumeCell.swift
//  Play
//
//  Created by Nathan Borror on 6/14/14.
//  Copyright (c) 2014 Nathan Borror. All rights reserved.
//

import UIKit

class VolumeCell: UITableViewCell {

    let kDialHeight = 48.0
    let kNameMargin = 16.0

    let name = UILabel()
    let dial = NBDial(frame: CGRectZero)

    init(style: UITableViewCellStyle, reuseIdentifier: String) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        self.selectionStyle = .None

        name.frame = CGRect(x: kNameMargin, y: 0, width: CGRectGetWidth(self.bounds)-(kNameMargin*2), height: CGRectGetHeight(self.bounds)-kDialHeight)
        name.textColor = UIColor.textColor()
        name.font = UIFont.subHeader()
        name.backgroundColor = UIColor.clearColor()
        name.autoresizingMask = .FlexibleWidth | .FlexibleHeight
        name.text = "Undefined"
        self.addSubview(name)

        dial.frame = CGRect(x: 0.0, y: CGRectGetHeight(self.bounds)-kDialHeight, width: CGRectGetWidth(self.bounds), height: kDialHeight)
        dial.autoresizingMask = .FlexibleTopMargin
        dial.maxValue = 100.0
        dial.minValue = 0.0
        dial.value = 10.0
        self.addSubview(dial)

    }

}
