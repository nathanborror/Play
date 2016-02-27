//
//  SpeakersViewController.swift
//  Play
//
//  Created by Nathan Borror on 6/2/14.
//  Copyright (c) 2014 Nathan Borror. All rights reserved.
//

import UIKit

class SpeakersViewController: UIViewController {

    init() {
        super.init(nibName: nil, bundle: nil)
        self.title = "Speakers"
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    func tabBarItemSpeakers() -> UITabBarItem {
        return UITabBarItem(title: "Speakers", image: UIImage(named: "SpeakersTab"), selectedImage: UIImage(named: "SpeakersTabSelected"))
    }

}
