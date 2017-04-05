//
//  JSONAssembler.swift
//  JSONConverter
//
//  Created by ET|冰琳 on 2017/3/2.
//  Copyright © 2017年 IB. All rights reserved.
//

import Foundation



protocol JSONAssembler {
    static func assemble(jsonInfo: JSONInfo) -> String
}

extension JSONAssembler {
   
    static func assemble(jsonInfos: [JSONInfo]) -> String {
        let count = jsonInfos.count
        
        let last = jsonInfos[count - 1]
        
        
        var code = MappingAceAssembler.assemble(jsonInfo: last)
        
        for index in 0..<(count - 1) {
            code += "\n\n"
            
            let jsonInfo = jsonInfos[index]
            code += MappingAceAssembler.assemble(jsonInfo: jsonInfo)
        }
        
        return code
    }
    
    static func assemble(jsonInfos: [JSONInfo], to filePath: String) {
        let txt = assemble(jsonInfos: jsonInfos)
        do {
            try txt.write(toFile: filePath, atomically: true, encoding: String.Encoding.utf8)
            print("write to file suceed\n[Path]: \(filePath)")
        }catch (let e) {
            print("write to file failed\n[Path]: \(filePath)\n[Error]: \(e)")
        }
    }
    
    static func assemble(jsonInfos: [JSONInfo], toDocument: String){
        
        let date = Date()
        let dateFormate = DateFormatter()
        dateFormate.dateFormat = "yyyy/M/d"
        let time = dateFormate.string(from: date)
 
        for item in jsonInfos {
            
            let title = "//\n" +
                        "// \(item.name!).swift\n" +
                        "//\n" +
                        "// created by JSONConverter on \(time)" +
                        "\n\n\n"
            
            let txt = title + assemble(jsonInfo: item)
            
            let filePath = toDocument + "/\(item.name!).swift"
            
            do {
                try txt.write(toFile: filePath, atomically: true, encoding: String.Encoding.utf8)
                print("write to file suceed\n[Path]: \(filePath)")
            }catch (let e) {
                print("write to file failed\n[Path]: \(filePath)\n[Error]: \(e)")
            }
        }
    }
}

struct MappingAceAssembler: JSONAssembler {
    
    static func assemble(jsonInfo: JSONInfo) -> String {
        
        
        let name = jsonInfo.name!
        
        var code = "struct \(name): Mapping {\n"
        
        
        
        for property in jsonInfo.properties.sorted(by: { (a, b) -> Bool in a.name < b.name }) {
            
            let name = property.name
            
            let type = property.isRequired ? property.type : "\(property.type)?"
            
            let defaultValue: String
            
            if let defaultV = property.defaultValue {
                defaultValue = " = \(defaultV)"
                code = "struct \(name): InitMapping {\n"
            }
            else {
                defaultValue = ""
            }
            
            let desc: String
            if let description = property.description {
                desc = "//\(description)"
            }else {
                desc = ""
            }
            
            code += "    var \(name): \(type)\(defaultValue) \(desc)\n"
            
        }
        code += "}\n"
        return code
    }
}





