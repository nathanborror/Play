//
//  PlayingViewController.swift
//  Play
//
//  Created by Nathan Borror on 6/2/14.
//  Copyright (c) 2014 Nathan Borror. All rights reserved.
//

import UIKit

class PlayingViewController: UIViewController {

    let playingTable: UITableView = UITableView(frame: CGRectZero, style: .Plain)
    let kCellIdentifier = "VolumeCell"
    let kCellHeight:CGFloat = 96.0

    init() {
        super.init(nibName: nil, bundle: nil)
        self.title = "Playing"
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        playingTable.registerClass(VolumeCell.self, forCellReuseIdentifier: kCellIdentifier)
        playingTable.delegate = self
        playingTable.dataSource = self
        playingTable.rowHeight = kCellHeight
        playingTable.separatorStyle = .None
        playingTable.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 96.0, right: 0)
        self.view.addSubview(playingTable)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        playingTable.frame = self.view.bounds
    }

    func tabBarItem() -> UITabBarItem {
        return UITabBarItem(title: "Playing", image: UIImage(named: "PlayingTab"), selectedImage: UIImage(named: "PlayingTabSelected"))
    }

    func showLibrary(sender: UIButton) {
        println("Show library")
    }
}

extension PlayingViewController: UITableViewDataSource {
    func numberOfSectionsInTableView(tableView: UITableView!) -> Int {
        return 5
    }

    func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell! {
        let cell: VolumeCell! = tableView.dequeueReusableCellWithIdentifier(kCellIdentifier) as VolumeCell
        return cell as UITableViewCell
    }
}

extension PlayingViewController: UITableViewDelegate {
    func tableView(tableView: UITableView!, viewForHeaderInSection section: Int) -> UIView! {
        let header = VolumeHeader(frame: CGRect(x: 0.0, y: 0.0, width: CGRectGetWidth(self.view.bounds), height: 64.0))
        header.addTarget(self, action: "showLibrary:", forControlEvents: .TouchUpInside)
        return header;
    }

    func tableView(tableView: UITableView!, heightForHeaderInSection section: Int) -> CGFloat {
        return 64.0
    }
}