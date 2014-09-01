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
        self.description { (response, error) in
            let device = response["root"]["device"] as NSDictionary

            self.name = device["roomName"]["text"] as String
            self.uuid = device["UDN"]["text"] as String
        }
    }

//    required init(coder decoder: NSCoder!) {
//        uuid = decoder.decodeObjectForKey("uuid") as String
//        name =  decoder.decodeObjectForKey("name") as String
//        ip = decoder.decodeObjectForKey("ip") as String
//    }

    func request(type: SonosRequestType, action: String, params: [String: String], completion: (NSDictionary!, NSError!) -> Void) {
        let (url, schema) = self.getURLAndSchema(type)

        var requestParams = ""
        for (key, value) in params {
            requestParams += "<\(key)>\(value)</\(key)>"
        }

        var body: String = "<s:Envelope xmlns:s='http://schemas.xmlsoap.org/soap/envelope/' s:encodingStyle='http://schemas.xmlsoap.org/soap/encoding/'><s:Body><u:\(action) xmlns:u='\(schema)'>\(requestParams)</u:\(action)></s:Body></s:Envelope>"

        var request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        request.addValue("text/xml", forHTTPHeaderField: "Content-Type")
        request.addValue("\(schema)#\(action)", forHTTPHeaderField: "SOAPACTION")
        request.HTTPBody = body.dataUsingEncoding(NSUTF8StringEncoding)

        let session = NSURLSession.sharedSession()
        session.dataTaskWithRequest(request, completionHandler: { (data:NSData!, response:NSURLResponse!, error:NSError!) -> Void in
            if (response as NSHTTPURLResponse).statusCode != 200 {
                return completion(nil, error)
            }

            var err: NSError?
            let dict = XMLReader.dictionaryForXMLData(data, options: XMLReaderOptions.ProcessNamespaces, error: &err) as NSDictionary

            if err != nil {
                completion(nil, err)
            }

            completion(dict, nil)
        }).resume()
    }

    private func getURLAndSchema(type: SonosRequestType) -> (url: NSURL, schema: String) {
        let service = ["AVTransport", "ConnectionManager", "RenderingControl", "ContentDirectory", "Queue", "AlarmClock", "MusicServices", "AudioIn", "DeviceProperties", "SystemProperties", "ZoneGroupTopology"]
        let prefix = ["MediaRenderer/", "MediaServer/", "MediaRenderer/", "MediaServer/", "MediaRenderer/", "", "", "", "", "", ""]
        let i = type.toRaw()

        // Construct url and schema
        let url = NSURL(string: "http://\(ip):1400/\(prefix[i])\(service[i])/Control")
        let schema = "urn:schemas-upnp-org:service:\(service[i]):1"
        return (url, schema)
    }

    func description(block: (NSDictionary!, NSError!) -> Void) {
        Alamofire.request(.GET, "http://\(self.ip):1400/xml/device_description.xml").response { (request, response, data, error) in
            var err: NSError?
            var dict = XMLReader.dictionaryForXMLData(data as NSData, options: XMLReaderOptions.ProcessNamespaces, error: &err)
            block(dict, err)
        }
    }

    func support(block: (NSDictionary!, NSError!) -> Void) {
        Alamofire.request(.GET, "http://\(self.ip):1400/support").response { (request, response, data, error) in
            var err: NSError?
            var dict = XMLReader.dictionaryForXMLData(data as NSData, options: XMLReaderOptions.ProcessNamespaces, error: &err)
            block(dict, err)
        }
    }

    func positionInfo(block: (NSDictionary!, NSError!) -> Void) {
        let params = ["InstanceID": "0"]
        request(SonosRequestType.AVTransport, action: "GetPositionInfo", params: params, completion: block)
    }

    func volume(block: (NSDictionary!, NSError!) -> Void) {
        let params = ["InstanceID": "0", "Channel": "Master"]
        request(SonosRequestType.RenderingControl, action: "GetVolume", params: params, completion: block)
    }
}
