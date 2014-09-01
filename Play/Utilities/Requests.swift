//
//  Requests.swift
//  Play
//
//  Created by Nathan Borror on 9/1/14.
//  Copyright (c) 2014 Nathan Borror. All rights reserved.
//

import Foundation

enum RequestsMethod: String {
    case CONNECT = "CONNECT"
    case DELETE = "DELETE"
    case GET = "GET"
    case HEAD = "HEAD"
    case OPTIONS = "OPTIONS"
    case PATCH = "PATCH"
    case POST = "POST"
    case PUT = "PUT"
    case TRACE = "TRACE"
}

class Requests {

    init(method: RequestsMethod, url: String, body: String?, headers: [String: String]?, completion: ((NSData!, NSURLResponse!, NSError!) -> Void)?) {
        var request = NSMutableURLRequest(URL: NSURL(string: url))
        request.HTTPMethod = method.toRaw()

        if body != nil {
            request.HTTPBody = body!.dataUsingEncoding(NSUTF8StringEncoding)
        }

        if headers != nil {
            for (key, value) in headers! {
                request.addValue(value, forHTTPHeaderField: key)
            }
        }

        let session = NSURLSession.sharedSession()
        session.dataTaskWithRequest(request, completionHandler: { (data: NSData!, response: NSURLResponse!, error: NSError!) -> Void in
            if error != nil {
                println("NSURLSession: \(error.localizedDescription)")
                return
            }

            dispatch_async(dispatch_get_main_queue(),{
                if let block = completion {
                    block(data, response, error)
                }
            })
        }).resume()
    }

    class func Get(url: String, completion: (NSData!, NSURLResponse!, NSError!) -> Void) {
        Requests(method: .GET, url: url, body: nil, headers: nil, completion: completion)
    }

    class func Post(url: String, body: String, headers: [String: String], completion: ((NSData!, NSURLResponse!, NSError!) -> Void)?) {
        Requests(method: .POST, url: url, body: body, headers: headers, completion: completion)
    }

    class func Put(url: String, body: String, headers: [String: String], completion: ((NSData!, NSURLResponse!, NSError!) -> Void)?) {
        Requests(method: .PUT, url: url, body: body, headers: headers, completion: completion)
    }

    class func Delete(url: String, body: String, headers: [String: String], completion: ((NSData!, NSURLResponse!, NSError!) -> Void)?) {
        Requests(method: .DELETE, url: url, body: body, headers: headers, completion: completion)
    }
}
