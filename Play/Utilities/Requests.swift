//
//  Requests.swift
//  Play
//
//  Created by Nathan Borror on 9/1/14.
//  Copyright (c) 2014 Nathan Borror. All rights reserved.
//

import Foundation

internal enum RequestsMethod : String {
    
    case CONNECT
    
    case DELETE
    
    case GET
    
    case HEAD
    
    case OPTIONS
    
    case PATCH
    
    case POST
    
    case PUT
    
    case TRACE
}

internal class Requests {

    internal init(method: RequestsMethod, url: String, body: String?, headers: [String: String]?, completion: ((NSData!, NSURLResponse!, NSError!) -> Void)?) {
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

    
    internal class func Get(url: String, completion: (NSData!, NSURLResponse!, NSError!) -> Void) {
        Requests(method: .GET, url: url, body: nil, headers: nil, completion: completion)
    }
    
    internal class func Post(url: String, body: String, headers: [String : String], completion: ((NSData!, NSURLResponse!, NSError!) -> Void)?) {
        Requests(method: .POST, url: url, body: body, headers: headers, completion: completion)
    }
    
    internal class func Put(url: String, body: String, headers: [String : String], completion: ((NSData!, NSURLResponse!, NSError!) -> Void)?) {
        Requests(method: .PUT, url: url, body: body, headers: headers, completion: completion)
    }
    
    internal class func Delete(url: String, body: String, headers: [String : String], completion: ((NSData!, NSURLResponse!, NSError!) -> Void)?) {
        Requests(method: .DELETE, url: url, body: body, headers: headers, completion: completion)
    }
}