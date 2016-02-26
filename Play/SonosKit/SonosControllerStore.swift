//
//  SonosControllerStore.swift
//  Play
//
//  Created by Nathan Borror on 6/14/14.
//  Copyright (c) 2014 Nathan Borror. All rights reserved.
//

import Foundation

class SonosControllerStore {
    var allControllers: [SonosController]?
    var coordinators: [SonosController]?
    var slaves: [SonosController]?
    var data: [AnyObject]?

    class var sharedStore: SonosControllerStore {
        struct Static {
            static let instance = SonosControllerStore()
        }
        return Static.instance
    }

    init() {
//        // Unarchive pre-existing controllers
//        let path = archivePath()
//        allControllers = NSKeyedUnarchiver.unarchiveObjectWithFile(path) as? [SonosController]
//
//        if allControllers == nil {
            self.discover()
//        }
    }

//    func archivePath() -> String {
//        let dirs = NSSearchPathForDirectoriesInDomains(.DocumentationDirectory, .UserDomainMask, true)
//        let dir = dirs[0] as String
//        return dir.stringByAppendingPathComponent("sonos.controller.archive")
//    }
//
//    func saveChanges() -> Bool {
//        let path = archivePath()
//        return NSKeyedArchiver.archiveRootObject(allControllers! as [SonosController], toFile: path)
//    }

    func discover() {
        allControllers = [
            SonosController(ip: "192.168.0.18"),
            SonosController(ip: "192.168.0.12"),
            SonosController(ip: "192.168.0.13")
        ]
    }

}