//
//  AppDelegate.swift
//  Play
//
//  Created by Nathan Borror on 6/2/14.
//  Copyright (c) 2014 Nathan Borror. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
                            
    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: NSDictionary?) -> Bool {
        self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
        self.window!.tintColor = UIColor.tintColor()

        let playingController = PlayingViewController()
        let speakersController = SpeakersViewController()
        let settingsController = SettingsViewController()

        let tabController = UITabBarController()
        tabController.setViewControllers([playingController, speakersController, settingsController], animated: false)

        self.window!.rootViewController = tabController

        self.window!.backgroundColor = UIColor.whiteColor()
        self.window!.makeKeyAndVisible()
        return true
    }
}

