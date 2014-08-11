//
//  SettingsViewController.swift
//  Play
//
//  Created by Nathan Borror on 6/2/14.
//  Copyright (c) 2014 Nathan Borror. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {

    override init() {
        super.init(nibName: nil, bundle: nil)
        self.title = "Settings"
    }

    required init(coder aDecoder: NSCoder!) {
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    func tabBarItem() -> UITabBarItem {
        return UITabBarItem(title: "More", image: UIImage(named: "MoreTab"), selectedImage: UIImage(named: "MoreTabSelected"))
    }

}
