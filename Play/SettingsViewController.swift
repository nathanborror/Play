//
//  SettingsViewController.swift
//  Play
//
//  Created by Nathan Borror on 6/2/14.
//  Copyright (c) 2014 Nathan Borror. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {

    let kCellIdentifier = "SonosControllerCell"

    var tableView: UITableView?
    var tableData: [SonosController]?

    init() {
        super.init(nibName: nil, bundle: nil)
        self.title = "Settings"
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let addButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Add, target: self, action: "addSpeaker:")
        self.navigationItem.setRightBarButtonItem(addButton, animated: true)

        tableView = UITableView(frame: CGRectZero, style: .Plain)
        tableView!.registerClass(UITableViewCell.self, forCellReuseIdentifier: kCellIdentifier)
        tableView!.delegate = self
        tableView!.dataSource = self
        self.view.addSubview(tableView!)

        tableData = SonosControllerStore.sharedStore.allControllers
        if tableData == nil {
            print("No data")
        }
    }

    func tabBarItemSpeakers() -> UITabBarItem {
        return UITabBarItem(title: "More", image: UIImage(named: "MoreTab"), selectedImage: UIImage(named: "MoreTabSelected"))
    }

    func addSpeaker(sender: UIBarButtonItem) {
        let viewController = AddSpeakerViewController()
        let navController = UINavigationController(rootViewController: viewController)
        self.navigationController?.presentViewController(navController, animated: true, completion: nil)
    }

}

extension SettingsViewController: UITableViewDataSource {

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let count = tableData?.count {
            return count
        }
        return 0
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        _ = tableData![indexPath.row]
        let cell = tableView.dequeueReusableCellWithIdentifier(kCellIdentifier)! as UITableViewCell
        return cell as UITableViewCell
    }

}

extension SettingsViewController: UITableViewDelegate {

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // Do something
    }
    
}
