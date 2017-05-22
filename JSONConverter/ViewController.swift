//
//  ViewController.swift
//  JSONConverter
//
//  Created by ET|冰琳 on 2017/3/2.
//  Copyright © 2017年 IB. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {

    @IBOutlet weak var transfer: NSButton!
    
    @IBOutlet var inputText: NSTextView!
    
    @IBOutlet var outputTextView: NSTextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        transfer.target = self
        transfer.action = #selector(transferAction)
        
        transferYml()
    }
    
    func transferYml() {
        let url = Bundle.main.path(forResource: "swagger", ofType: "json")
        
        if let url = url {
            
            print(url)
            
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: url))
                let json = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments)
                //print(json)
                
                guard let dic = json as? [String : Any] else { return }
                
                var swagger = SwaggerObject(fromDic: dic)
                
                guard let paths = dic["paths"] as? [String: [String: Any]] else { return }
                
                // paths
                var pathObjects: [SwaggerPathObject] = []
                
                for (key, value) in paths {
                    
                    let path = key
                    
                    let method = value.keys.first!
                    
                    var pathObject = SwaggerPathObject(path: path, method: method, operation: nil)
                    
                    if let opertionObject = value[method] as? [String: Any] {
                        
                        let operate = OperationObject(fromDic: opertionObject)
                        pathObject.operation = operate
                        
                        print("path:", path, "  method", method)
                    }
                    pathObjects.append(pathObject)
                }
                
                swagger.pathObjects = pathObjects
                

                // global parameters
                var sparameterObj: [SwaggerParameterObject] = []
                if let parameters = dic["parameters"] as? [String: [String: Any]] {
                    
                    for (key, value) in parameters {
                        
                        let parameterObj = ParameterObject(fromDic: value)
                        
                        let obj = SwaggerParameterObject(key: key, parameter: parameterObj)
                        sparameterObj.append(obj)
                    }
                }
                swagger.parameterObjects = sparameterObj
                
                analyzeTags(in: swagger)
                
                //definitions 里的entity 定义
                
                
                //definition  api response里的entity
                if let definitions = dic["definitions"] as? [String: [String: Any]] {
                    
                    let defObj = definitions.map({ (key, value) -> SwaggerDefinitionObject in
                        let schema = SchemaObject(fromDic: value)
                        return SwaggerDefinitionObject(key: key, definition: schema)
                    })
                    
                    swagger.definitionsObject = defObj
                    
                    analyzeDefinition(swagger: swagger)
                }
                
                
            }catch (let e) {
                print(e)
            }
        }
    }
    
    func getPathResponse(in swagger: SwaggerObject) {
        
    }
    
    func analyzeTags(in swagger: SwaggerObject) {
        
        var tags = Set<String>()
        
        guard let paths = swagger.pathObjects else {
            return
        }
       
        for pathObj in paths {
            
            if let operation = pathObj.operation, let optTags = operation.tags {
                
                tags = tags.union(optTags)
            }
        }
    
        var tagsMap = [String: [SwaggerPathObject]](minimumCapacity: tags.count)
        
        for item in tags {
            tagsMap.updateValue([SwaggerPathObject](), forKey: item)
        }
        
        
        let definitionMapping: [String: String] = ["Result": "Any"]
        
        for pathObj in paths {

            if let operation = pathObj.operation, let optTags = operation.tags {
                
                for tag in optTags {
                    
                    if var paths = tagsMap[tag] {
                        paths.append(pathObj)
                        tagsMap[tag] = paths
                    }
                }
            }
            
            
            
            if let responses = pathObj.operation?.responsesObj {
                
                print("\n\n\n🍃🍃🍃🍃🍃🍃🍃🍃🍃🍃🍃🍃🍃🍃🍃🍃🍃🍃")
                print(responses.ref ?? "")
                
                if let all = responses.allOf, all.count == 1 && all[0].ref != "#/definition/Result" {
                    print(pathObj.path , "Any")
                }
                
                if let all = responses.allOf {
                    
                    for item in all {
                        
                        if let properties = item.propertiesObjs {
                            
                            for p in properties {
                                
                                
                                print("Path: ",pathObj.path, "name", p.key, "type", p.definition?.type ,   p.definition?.ref ?? "")
                                
                                
                                if let type = p.definition?.type, type == "array" {
                                    print("array item is: ", p.definition?.items?.ref)
                                }
                            }
                        }
                    }
                }
                print("🍃🍃🍃🍃🍃🍃🍃🍃🍃🍃🍃🍃🍃🍃🍃🍃🍃🍃")
            }
        }
        
        for (tag, tagPathes) in tagsMap {
            print("😄😄", tag)
            
            let tagFileName = "\(tag)ServiceImpl.swift"
            
            var serviceImplCode = "public class \(tag)ServiceImpl: NSObject {\n\n"
            
            var tagPath = "//\n"
            tagPath += "// \(tag)ServiceImpl.swift\n"
            tagPath += "//\n"
            tagPath += "// Create by JSONConverter\n"
            tagPath += "//\n"
            tagPath += "\n"
            tagPath += "import ReactiveSwift\n"
            tagPath += "\n"
            tagPath += "// \(tag)\n"
            tagPath += "extension Path {\n"
            
            let whiteTab = "    "
            
            for pathObj in tagPathes {
                
                /**
                 /user/devices/binding
                 /user/devices/{type}
                 */
                let path = pathObj.path
                
                if let range = path.range(of: "{") {
                    
                    let str = path.substring(to: range.lowerBound)
                    let parameter = path.substring(from: range.upperBound).replacingOccurrences(of: "}", with: "")
                    print("🍎", parameter)
                    
                    let pathesComponent = generatePathComponent(pathName: str, tagName: tag)
                    
                    let pathesName = pathesComponent.enumerated().map({ (offset, elem) -> String in
                        if offset == 0 {
                            return elem
                        }
                        return elem.capitalized
                        
                    }).joined(separator: "")
                    
                    
                    if let parameters = pathObj.operation?.parameters {
                        
                    
                        let paramObjects = parameters.filter({ (obj) -> Bool in
                        
                            if let `in` = obj.in {
                                return `in` == .path
                            }
                            return false
                        })
                        
                        let pathParameter = paramObjects.flatMap({ (obj) -> String? in
                            guard let name = obj.name, let type = obj.type?.swiftType() else {
                                return nil
                            }
                            
                            return name + ": " + type
                        })
                        
                        var funcName = "\n"
                        
                        if let descrip = pathObj.operation?.description {
                            funcName += whiteTab
                            funcName += "// DESC: \(descrip)"
                        }
                        
                        if let summary = pathObj.operation?.summary {
                            funcName += whiteTab
                            funcName += "// SUMMARY: \(summary)"
                        }
                        
                        funcName += "\n"
                        funcName += whiteTab
                        funcName += "fileprivate static func \(pathesName)("
                        funcName += pathParameter.joined(separator: ", ")
                        funcName += ") -> Path {\n"
                        funcName += whiteTab
                        funcName += "    return "
                        
                        
                        var pathReturn = path
                        
                        let names = paramObjects.flatMap({ $0.name })
                        
                        for name in names {
                            pathReturn = pathReturn.replacingOccurrences(of: "{\(name)}", with: "\\(\(name))")
                        }
                        
                        funcName += "Path(path: \"\(pathReturn)\")"
                        funcName += "\n"
                        funcName += whiteTab
                        funcName += "}"
                        
                        funcName += "\n"

                        tagPath += funcName
                    }
                    
                }
                else {
                    
                    let pathesComponent = generatePathComponent(pathName: path, tagName: tag)
                    
                    let pathesName = pathesComponent.enumerated().map({ (offset, elem) -> String in
                        if offset == 0 {
                            return elem
                        }
                        return elem.capitalized
                        
                    }).joined(separator: "")
                    
                    var pathCode = "\n"
                    
                    if let descrip = pathObj.operation?.description {
                        pathCode += whiteTab
                        pathCode += "// DESC: \(descrip)"
                        
                        serviceImplCode += "\n"
                        serviceImplCode += whiteTab
                        serviceImplCode += "// DESC: \(descrip)"
                    }
                    
                    if let summary = pathObj.operation?.summary {
                        pathCode += whiteTab
                        pathCode += "// SUMMARY: \(summary)"
                        
                        serviceImplCode += "\n"
                        serviceImplCode += whiteTab
                        serviceImplCode += "// SUMMARY: \(summary)"
                    }
                    
                    
                    pathCode += "\n"
                    pathCode += whiteTab
                    pathCode += "fileprivate static let \(pathesName) = Path(path: \"\(path)\")"
                    pathCode += "\n"
                    
                    tagPath += pathCode
                    
                    let serviceFuncName = pathesComponent.map{ $0.capitalized }.joined()
                

                    serviceImplCode += "\n"
                    serviceImplCode += whiteTab
                    serviceImplCode += "public func \(pathObj.method)\(serviceFuncName)("
                    
                    var paramsBuilder = "\n" + whiteTab + whiteTab
                    
                    paramsBuilder += "var params: [String: Any] = [:]\n"
                    
                    if let parameters = pathObj.operation?.parameters {
                        
                        
                        let paramObjects = parameters.filter({ (obj) -> Bool in
                            
                            if let `in` = obj.in {
                                return `in` == .query
                            }
                            return false
                        })
                        
                        let funcParameter = paramObjects.flatMap({ (obj) -> String? in
                            guard let name = obj.name, let type = obj.type?.swiftType() else {
                                return nil
                            }
                            
                            return name + ": " + type
                        })
                        
                        serviceImplCode += funcParameter.joined(separator: ", ")
                        
                        paramObjects.forEach({ (obj) in
                            
                            if let name = obj.name {
                                paramsBuilder += whiteTab
                                paramsBuilder += whiteTab
                                paramsBuilder += "params[\"\(name)\"] = \(name)\n"
                            }
                        })
                    }
                    
                    serviceImplCode += ") -> SignalProducer<Any, NSError> {"
                    serviceImplCode += whiteTab
                    serviceImplCode += paramsBuilder
                    serviceImplCode += whiteTab
                    serviceImplCode += whiteTab
                    serviceImplCode += "return request(path: .\(pathesName), method: .\(pathObj.method), parameters: params)"
                    serviceImplCode += "\n"
                    serviceImplCode += whiteTab
                    serviceImplCode += "}\n\n"
                    
                    
                    print("✨✨✨✨✨✨✨✨✨✨✨✨✨✨✨✨✨✨✨✨✨\n")
                    print(serviceImplCode)
                    print("✨✨✨✨✨✨✨✨✨✨✨✨✨✨✨✨✨✨✨✨✨\n")
                    
                }
            }
            
            tagPath += "}"
//            print("✨✨✨✨✨✨✨✨✨✨✨✨✨✨✨✨✨✨✨✨✨\n")
//            print(tagPath)
            
            tagPath += "\n\n\n"
            
            serviceImplCode += "}"
            
            tagPath += serviceImplCode
//            tagPath += "}\n"
            
            
            
            do {
                try tagPath.write(toFile: "/Users/Binglin/Documents/MyselfProjects/JSONFactory/CodeFactory/Service/\(tagFileName)", atomically: true, encoding: String.Encoding.utf8)
            }
            catch let err {
                print(err)
            }
            
//            print("✨✨✨✨✨✨✨✨✨✨✨✨✨✨✨✨✨✨✨✨✨\n")
        }
    }
    
    
    
    // TODO 解析definition -> Entity
    func analyzeDefinition(swagger: SwaggerObject) {
        
        guard let definitionsObjs = swagger.definitionsObject else { return }
        
        for obj in definitionsObjs {
            
            if let def = obj.definition {
                
                print("\n")
                print("\n")
                print("🍎🍎🍎🍎🍎🍎🍎🍎🍎🍎🍎🍎\n", obj.key, def.description ?? "" , obj.definition?.type ?? "", "\n")
                
                var entityName = obj.key
                
                
                if !entityName.lowercased().contains("entity") {
                    entityName += "Entity"
                }
                
                if let type = obj.definition?.type {
                    
                    if type == "string" {
                        
                        var structObjectCode = "//\n// \(entityName).swift\n//\n\n"
                        structObjectCode += "typealias \(entityName) = String"
                        
                        print("🍎----------------------------🍎")
                        print(structObjectCode)
                        print("🍎----------------------------🍎")
                        
                    }else if type == "object" {
                        
                        var structObjectCode = "//\n// \(entityName).swift\n//\n\n"
                        
                        structObjectCode += "import MappingAce\n\n"
                        
                        if let desc = def.description {
                            structObjectCode += "/// \(desc)\n"
                        }
                        structObjectCode += "public struct \(entityName): Mapping {\n"
                        
                        let whiteCode = "    "
                        
                        if let properties = def.propertiesObjs {
                            
                            for prop in properties {
                                
                                print("\(prop.key)", prop.definition?.type ?? "", prop.definition?.description ?? "")
                                
                                var isRequired = false
                                
                                if let require = prop.definition?.required {
                                    isRequired = require
                                }
                                
                                let type = prop.definition?.type
                                
                                if let type = type {
                                    
                                    if let desc = prop.definition?.description {
                                        structObjectCode += "\n"
                                        structObjectCode += whiteCode
                                        structObjectCode += "//\(desc)\n"
                                    }else {
                                        structObjectCode += "\n"
                                    }
                                    
                                    structObjectCode += whiteCode
                                    structObjectCode += "public var \(prop.key): "
                                    
                                    switch type {
                                    case "integer":
                                        structObjectCode += "Int"
                                    case "string":
                                        structObjectCode += "String"
                                    case "boolean":
                                        structObjectCode += "Bool"
                                    case "number":
                                        
                                        if prop.definition?.format == "double" {
                                            structObjectCode += "Double"
                                        }else {
                                            structObjectCode += "NSNumber"
                                        }
                                    case "array":
                                        
                                        if let items = prop.definition?.items, let ref = items.ref {
                                            
                                            if let className = ref.components(separatedBy: "/").last {
                                                structObjectCode += "[\(className)]"
                                            }
                                        }
                                        break
                                    default:
                                        break
                                    }
                                    if isRequired == false {
                                        structObjectCode += "?\n"
                                    }else{
                                        structObjectCode += "\n"
                                    }
                                }else if type == nil {
                                    let ref = prop.definition?.ref
                                    print("type nil", ref)
                                }
                            }
                        }
                        
                        structObjectCode += "}"
                        print("🍎----------------------------🍎")
                        print(structObjectCode)
                        print("🍎----------------------------🍎")
                        
                        /* TO OPEN
                        try? structObjectCode.write(toFile: "/Users/Binglin/Documents/MyselfProjects/JSONFactory/CodeFactory/Entity/\(entityName).swift", atomically: true, encoding: String.Encoding.utf8)
                        */
                    }
                    
                }
                
              

            }
        }
    }
    
    func generatePathComponent(pathName: String, tagName: String) -> [String] {
        
        
        let r = pathName.components(separatedBy: "/").filter { (s) -> Bool in
            return s.characters.count > 0
        }
        if r.count > 1 && r[0].lowercased() == tagName.lowercased() {
            return r[1..<r.count].map{ $0 }
        }

        return r
    }
    
    
    func transferJSONMode() {
        
        let url = Bundle.main.path(forResource: "JSONModel", ofType: "json")
        if let url = url {
            print(url)
            
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: url))
                let json = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments)
                print(json)
                
                if let dic = json as? [String : Any] {
                    let explained = JSONInfoParser.parseJSON(from: dic, name: "<#Root#>")
                    print(explained)
                    
                    MappingAceAssembler.assemble(jsonInfos: explained, toDocument: "/Users/Binglin/Desktop/JSONResult")
                }
                
            }catch (let e) {
                print(e)
            }
        }
    
    }
    
    func transferAction() {
        
        if let json = inputText.string {
            do {
                let data = json.data(using: .utf8)
                
                guard let d = data else {
                    return
                }
                
                
                
                let json = try JSONSerialization.jsonObject(with: d, options: JSONSerialization.ReadingOptions.mutableContainers)
                print(json)
                
                if let dic = json as? [String : Any] {
                    let explained = JSONInfoParser.parseJSON(from: dic, name: "<#Root#>")
                    
                    let txt = MappingAceAssembler.assemble(jsonInfos: explained)
                    self.outputTextView.string = txt
                }
                
            }catch (let e) {
                print(e)
            }
        }
    }
    
    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}



