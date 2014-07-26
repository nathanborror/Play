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
        let playingNav = UINavigationController(rootViewController: playingController)

        let speakersController = SpeakersViewController()
        let speakersNav = UINavigationController(rootViewController: speakersController)

        let settingsController = SettingsViewController()
        let settingsNav = UINavigationController(rootViewController: settingsController)

        let tabController = UITabBarController()
        tabController.setViewControllers([playingNav, speakersNav, settingsNav], animated: false)

        self.window!.rootViewController = tabController

        self.window!.backgroundColor = UIColor.whiteColor()
        self.window!.makeKeyAndVisible()
        return true
    }
}

