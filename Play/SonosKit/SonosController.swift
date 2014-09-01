//
//  SonosController.swift
//  Play
//
//  Created by Nathan Borror on 6/14/14.
//  Copyright (c) 2014 Nathan Borror. All rights reserved.
//

import Foundation

enum SonosRequestType: Int {
    case AVTransport
    case ConnectionManager
    case RenderingControl
    case ContentDirectory
    case Queue
    case AlarmClock
    case MusicServices
    case AudioIn
    case DeviceProperties
    case SystemProperties
    case ZoneGroupTopology
    case GroupManagement
}

class SonosController: NSObject {

    dynamic var uuid = String()
    dynamic var name = String()
    var ip = String()
    var group = String()
    var slaves: [SonosController]?
    var coordinator = false

    init(ip: String) {
        super.init()
        self.ip = ip
    }

    func request(type: SonosRequestType, action: String, params: [String: String], completion: (([String: AnyObject]) -> Void)?) {
        let (url, schema) = self.getURLAndSchema(type)

        var requestParams = ""
        for (key, value) in params {
            requestParams += "<\(key)>\(value)</\(key)>"
        }

        var body: String = "<s:Envelope xmlns:s='http://schemas.xmlsoap.org/soap/envelope/' s:encodingStyle='http://schemas.xmlsoap.org/soap/encoding/'><s:Body><u:\(action) xmlns:u='\(schema)'>\(requestParams)</u:\(action)></s:Body></s:Envelope>"
        var headers = ["Content-Type": "text/xml", "SOAPACTION": "\(schema)#\(action)"]

        Requests.Post(url, body: body, headers: headers) { (data: NSData!, response: NSURLResponse!, err: NSError!) -> Void in
            let dict = XML.parseData(data)
            if dict != nil && completion != nil {
                completion!(dict!)
            }
        }
    }

    private func getURLAndSchema(type: SonosRequestType) -> (url: String, schema: String) {
        let service = ["AVTransport", "ConnectionManager", "RenderingControl", "ContentDirectory", "Queue", "AlarmClock", "MusicServices", "AudioIn", "DeviceProperties", "SystemProperties", "ZoneGroupTopology"]
        let prefix = ["MediaRenderer/", "MediaServer/", "MediaRenderer/", "MediaServer/", "MediaRenderer/", "", "", "", "", "", ""]
        let i = type.toRaw()

        // Construct url and schema
        let url = "http://\(ip):1400/\(prefix[i])\(service[i])/Control"
        let schema = "urn:schemas-upnp-org:service:\(service[i]):1"
        return (url, schema)
    }

    func description(block: (([String: AnyObject]) -> Void)?) {
        Requests.Get("http://\(self.ip):1400/xml/device_description.xml") { (data: NSData!, response: NSURLResponse!, error: NSError!) -> Void in
            let dict = XML.parseData(data)
            if dict != nil && block != nil {
                block!(dict!)
            }
        }
    }

    func support(block: (([String: AnyObject]) -> Void)?) {
        Requests.Get("http://\(self.ip):1400/support") { (data: NSData!, response: NSURLResponse!, error: NSError!) -> Void in
            let dict = XML.parseData(data)
            if dict != nil && block != nil {
                block!(dict!)
            }
        }
    }

    func positionInfo(block: ([String: AnyObject]) -> Void) {
        let params = ["InstanceID": "0"]
        request(SonosRequestType.AVTransport, action: "GetPositionInfo", params: params, completion: block)
    }

    func volume(block: ([String: AnyObject]) -> Void) {
        let params = ["InstanceID": "0", "Channel": "Master"]
        request(SonosRequestType.RenderingControl, action: "GetVolume", params: params, completion: block)
    }
}
