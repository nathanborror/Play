//
//  XML.swift
//  Play
//
//  Created by Nathan Borror on 9/1/14.
//  Copyright (c) 2014 Nathan Borror. All rights reserved.
//

import Foundation

class XML {
    
    class func parseData(xml: NSData) -> [String: AnyObject]? {
        do {
            let obj = try XMLReader.dictionaryForXMLData(xml, options: XMLReaderOptions.ProcessNamespaces) as? [String: AnyObject]
            
            return obj
        } catch let error as NSError {
            print("Error: \(error.localizedDescription)")
            abort()
        }
    }
    
    class func parseString(xml: String) -> [String: AnyObject]? {
        do {
            let obj = try XMLReader.dictionaryForXMLString(xml, options: XMLReaderOptions.ProcessNamespaces) as? [String: AnyObject]
            
            return obj
        } catch let error as NSError {
            print("Error: \(error.localizedDescription)")
            abort()
        }
    }
}