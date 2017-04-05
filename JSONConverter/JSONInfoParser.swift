//
//  JSONStringParser.swift
//  JSONConverter
//
//  Created by ET|冰琳 on 2017/3/2.
//  Copyright © 2017年 IB. All rights reserved.
//

import Foundation


struct JSONInfoParser {
    
    static func parseJSON(from: [String : Any], name: String) -> [JSONInfo] {
        
        var parsed: [JSONInfo] = []
        
        var json = JSONInfo()
        json.name = name
        
        for (key, value) in from {
            
            if let value = value as? [String: Any] {
                let name = key.capitalized
                let p = JSONProperty(name: key, type: name, defaultValue: nil, isRequired: false, description: nil)
                parsed.append(contentsOf: self.parseJSON(from: value, name: name))
                json.properties.append(p)
            }
            else if let value = value as? [[String : Any]] {
                let name = key.capitalized
                let p = JSONProperty(name: key, type: "[\(name)]", defaultValue: nil, isRequired: false, description: nil)
                json.properties.append(p)
                
                if let first = value.first {
                    parsed.append(contentsOf: self.parseJSON(from: first, name: name))
                }
            }
            else if value is NSNull {
                let p = JSONProperty(name: key, type: "String", defaultValue: nil, isRequired: false, description: nil)
                json.properties.append(p)
            }
            else if value is String {
                let p = JSONProperty(name: key, type: "String", defaultValue: nil, isRequired: true, description: nil)
                json.properties.append(p)
            }
            else if value is Int {
                let p = JSONProperty(name: key, type: "Int", defaultValue: nil, isRequired: true, description: nil)
                json.properties.append(p)
            }
            else if value is CGFloat {
                let p = JSONProperty(name: key, type: "CGFloat", defaultValue: nil, isRequired: true, description: nil)
                json.properties.append(p)
            }
            else if value is Bool {
                let p = JSONProperty(name: key, type: "Bool", defaultValue: nil, isRequired: true, description: nil)
                json.properties.append(p)
            }
            else {
                fatalError("do not processed")
            }
        }
        
        parsed.append(json)
        return parsed
        
    }
}
