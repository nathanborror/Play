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
        let obj = XMLReader.dictionaryForXMLData(xml, options: XMLReaderOptions.ProcessNamespaces) as? [String: AnyObject]

        return obj
    }

    class func parseString(xml: String) -> [String: AnyObject]? {
        let obj = XMLReader.dictionaryForXMLString(xml, options: XMLReaderOptions.ProcessNamespaces) as? [String: AnyObject]

        return obj
    }
}