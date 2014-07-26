//
//  NBDial.swift
//  Play
//
//  Created by Nathan Borror on 6/14/14.
//  Copyright (c) 2014 Nathan Borror. All rights reserved.
//

import UIKit

class NBDial: UIControl {

    var panCoordBegan = CGPoint(x: 0.0, y: 0.0)
    var maxOrigin:CGFloat = 0.0
    var minOrigin:CGFloat = 0.0

    var maxValue:CGFloat = 0.0
    var minValue:CGFloat = 0.0
    var value: CGFloat = 0.0 {
        didSet {
            let newPoint = CGPoint(x: self.findPosition(value), y: thumb.center.y)
            if newPoint.x < maxOrigin && newPoint.x > minOrigin {
                thumb.center = newPoint;
            } else {
                if newPoint.x > maxOrigin {
                    thumb.center = CGPoint(x: maxOrigin, y: thumb.center.y);
                }
                if (newPoint.x < minOrigin) {
                    thumb.center = CGPoint(x: minOrigin, y: thumb.center.y);
                }
            }
            min.frame = CGRect(x: 0, y: 0, width: CGRectGetMaxX(thumb.frame), height: CGRectGetHeight(self.bounds))
        }
    }

    let max = UIView()
    let min = UIView()
    let thumb = UIView()

    init(frame: CGRect) {
        super.init(frame: frame)
        self.clipsToBounds = false

        max.frame = CGRect(x: 0.0, y: 0.0, width: CGRectGetWidth(self.frame), height: CGRectGetHeight(self.frame))
        max.backgroundColor = UIColor(patternImage: UIImage(named: "DialBackground"))
        max.autoresizingMask = .FlexibleWidth | .FlexibleHeight
        self.addSubview(max)

        min.frame = CGRect(x: 0.0, y: 0.0, width: 8.0, height: CGRectGetHeight(self.frame))
        min.backgroundColor = UIColor.tintColor()
        min.autoresizingMask = .FlexibleHeight
        self.addSubview(min)

        thumb.frame = CGRect(x: 0.0, y: 0.0, width: 4.0, height: CGRectGetHeight(self.frame))
        thumb.autoresizingMask = .FlexibleHeight
        self.addSubview(thumb)

        let panGesture = UIPanGestureRecognizer(target: self, action: "handlePanGesture:")
        self.addGestureRecognizer(panGesture)

        maxOrigin = CGRectGetWidth(self.bounds) - 15.0
        minOrigin = 15.0
    }

    override func layoutSubviews() {
        maxOrigin = CGRectGetWidth(self.bounds) - 15.0
    }

    func handlePanGesture(recognizer: UIPanGestureRecognizer) {
        if recognizer.state == UIGestureRecognizerState.Began {
            panCoordBegan = recognizer.locationInView(thumb)
        }

        if recognizer.state == UIGestureRecognizerState.Changed {
            let panCoordChange = recognizer.locationInView(thumb)
            let xDelta = panCoordChange.x - panCoordBegan.x
            let x = thumb.center.x + xDelta

            value = findValue(x)
            super.sendActionsForControlEvents(UIControlEvents.ValueChanged)
        }
    }

    func findValue(x: CGFloat) -> CGFloat {
        return ((((maxValue - minValue) * (x - minOrigin)) / (maxOrigin - minOrigin)) + minValue)
    }

    func findPosition(x: CGFloat) -> CGFloat {
        return ((((maxOrigin - minOrigin) * (x - minValue)) / (maxValue - minValue)) + minOrigin)
    }
}
