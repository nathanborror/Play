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
        let request = NSMutableURLRequest(URL: NSURL(string: url)!)
        request.HTTPMethod = method.rawValue

        if body != nil {
            request.HTTPBody = body!.dataUsingEncoding(NSUTF8StringEncoding)
        }

        if headers != nil {
            for (key, value) in headers! {
                request.addValue(value, forHTTPHeaderField: key)
            }
        }
        
        let session = NSURLSession.sharedSession().dataTaskWithRequest(request)
            {
                data, response, error in
                if error != nil {
                    print("NSURLSession: \(error?.localizedDescription)")
                    print("NSURLSession: \(url)")
                    return
                }
                
                dispatch_async(dispatch_get_main_queue(),{
                    if let block = completion {
                        block(data, response, error)
                    }
                })
                
                let responseString = NSString(data: data!, encoding: NSUTF8StringEncoding)
                print("responseString = \(responseString!)")
                
        }
        session.resume()
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