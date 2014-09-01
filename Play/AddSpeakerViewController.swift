//
//  AddSpeakerViewController.swift
//  Play
//
//  Created by Nathan Borror on 7/26/14.
//  Copyright (c) 2014 Nathan Borror. All rights reserved.
//

import UIKit

class AddSpeakerViewController: UIViewController {

    let kFieldHeight:CGFloat = 48.0
    let kFieldMargin:CGFloat = 16.0

    let ip = TextField(frame: CGRectZero)
    let name = TextField(frame: CGRectZero)
    let uuid = TextField(frame: CGRectZero)

    override init() {
        super.init(nibName: nil, bundle: nil)
        self.title = "Add Speaker"
        self.view.backgroundColor = UIColor.whiteColor()
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let doneButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Done, target: self, action: "done:")
        self.navigationItem.setRightBarButtonItem(doneButton, animated: true)

        let cancelButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Cancel, target: self, action: "cancel:")
        self.navigationItem.setLeftBarButtonItem(cancelButton, animated: true)

        ip.placeholder = "IP Address"
        self.view.addSubview(ip)

        name.placeholder = "Name"
        self.view.addSubview(name)

        uuid.placeholder = "UUID"
        self.view.addSubview(uuid)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        let bounds = CGRect(x: 0.0, y: 0.0, width: CGRectGetWidth(self.view.bounds)-(kFieldMargin*2.0), height: kFieldHeight)

        ip.frame = CGRectOffset(bounds, kFieldMargin, kFieldMargin+88.0)
        name.frame = CGRectOffset(bounds, kFieldMargin, CGRectGetMaxY(ip.frame)+kFieldMargin)
        uuid.frame = CGRectOffset(bounds, kFieldMargin, CGRectGetMaxY(name.frame)+kFieldMargin)
    }

    func done(sender: UIBarButtonItem) {
        self.navigationController.dismissViewControllerAnimated(true, completion: nil)
    }

    func cancel(sender: UIBarButtonItem) {
        self.navigationController.dismissViewControllerAnimated(true, completion: nil)
    }

}
