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
        var err: NSError?
        let obj = XMLReader.dictionaryForXMLData(xml, options: XMLReaderOptions.ProcessNamespaces, error: &err) as? [String: AnyObject]
        if err != nil {
            return nil
        }
        return obj
    }

    class func parseString(xml: String) -> [String: AnyObject]? {
        var err: NSError?
        let obj = XMLReader.dictionaryForXMLString(xml, options: XMLReaderOptions.ProcessNamespaces, error: &err) as? [String: AnyObject]
        if err != nil {
            return nil
        }
        return obj
    }
}