//
//  JSON.swift
//  JSONConverter
//
//  Created by ET|冰琳 on 2017/3/2.
//  Copyright © 2017年 IB. All rights reserved.
//

import Foundation

struct JSONInfo {
    var name: String?
    var properties: [JSONProperty] = []
}

struct JSONProperty {
    var name: String
    var type: String
    var defaultValue: String?
    var isRequired = false
    var description: String?
}

struct JSONEnum {
    var name: String
    var type: String
}

struct JSONEnumItem {
    var name: String
    var value: String
}
