//
//  PlayingViewController.swift
//  Play
//
//  Created by Nathan Borror on 6/2/14.
//  Copyright (c) 2014 Nathan Borror. All rights reserved.
//

import UIKit

class PlayingViewController: UIViewController {

    let kCellIdentifier = "VolumeCell"
    let kCellHeight:CGFloat = 96.0

    var controllerStore = SonosControllerStore.sharedStore
    var tableView: UITableView?
    var tableData: [AnyObject]? {
    didSet{
        self.tableView!.reloadData()
    }
    }

    init() {
        super.init(nibName: nil, bundle: nil)
        self.title = "Playing"
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView = UITableView(frame: CGRectZero, style: .Plain)
        tableView!.registerClass(VolumeCell.self, forCellReuseIdentifier: kCellIdentifier)
        tableView!.delegate = self
        tableView!.dataSource = self
        tableView!.rowHeight = kCellHeight
        tableView!.separatorStyle = .None
        tableView!.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 96.0, right: 0)
        self.view.addSubview(tableView!)

        // Populate controllers
        tableData = controllerStore.allControllers
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView!.frame = self.view.bounds
    }

    func tabBarItemSpeakers() -> UITabBarItem {
        return UITabBarItem(title: "Playing", image: UIImage(named: "PlayingTab"), selectedImage: UIImage(named: "PlayingTabSelected"))
    }

    func showLibrary(sender: UIButton) {
        print("Show library")
    }
}

extension PlayingViewController: UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let count = tableData?.count {
            return count
        }
        return 0
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let controller = tableData![indexPath.item] as! SonosController
        let cell: VolumeCell! = tableView.dequeueReusableCellWithIdentifier(kCellIdentifier) as! VolumeCell
        cell.controller = controller
        return cell as UITableViewCell
    }
}

extension PlayingViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = VolumeHeader(frame: CGRect(x: 0.0, y: 0.0, width: CGRectGetWidth(self.view.bounds), height: 64.0))
        header.addTarget(self, action: "showLibrary:", forControlEvents: .TouchUpInside)
        return header;
    }

    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 64.0
    }
}
