//
//  VolumeCell.swift
//  Play
//
//  Created by Nathan Borror on 6/14/14.
//  Copyright (c) 2014 Nathan Borror. All rights reserved.
//

import UIKit

class VolumeCell: UITableViewCell {

    let kDialHeight:CGFloat = 48.0
    let kNameMargin:CGFloat = 16.0

    let name = UILabel()
    let dial = NBDial(frame: CGRectZero)

    var controller: SonosController? {
        didSet{
            self.controller!.volume { (response) in
                // TODO: This sucks and will eventually be replaced with sanity
                let envelope = response["Envelope"] as! NSDictionary
                let body = envelope["Body"] as! NSDictionary
                let volumeResponse = body["GetVolumeResponse"] as! NSDictionary
                let currentVolume = volumeResponse["CurrentVolume"] as! NSDictionary
                let volume = currentVolume["text"] as! NSString

                self.dial.value =  CGFloat(volume.floatValue)
            }

            self.controller!.description { (response) in
                // TODO: Ditto
                let root = response["root"] as! NSDictionary
                let device = root["device"] as! NSDictionary
                let deviceName = device["roomName"] as! NSDictionary

                self.name.text = deviceName["text"] as? String
            }
        }
    }

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        self.selectionStyle = .None

        name.frame = CGRect(x: kNameMargin, y: 0, width: CGRectGetWidth(self.bounds)-(kNameMargin*2), height: CGRectGetHeight(self.bounds)-kDialHeight)
        name.textColor = UIColor.textColor()
        name.font = UIFont.subHeader()
        name.backgroundColor = UIColor.clearColor()
        name.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        self.addSubview(name)

        dial.addTarget(self, action: "changeVolume:", forControlEvents: .ValueChanged)
        dial.frame = CGRect(x: 0.0, y: CGRectGetHeight(self.bounds)-kDialHeight, width: CGRectGetWidth(self.bounds), height: kDialHeight)
        dial.autoresizingMask = .FlexibleTopMargin
        dial.maxValue = 100.0
        dial.minValue = 0.0
        dial.value = 10.0
        self.addSubview(dial)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    func changeVolume(dial: NBDial) {
        self.controller?.setVolume(Int(dial.value))
    }

}