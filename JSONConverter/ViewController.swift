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
        
        for pathObj in paths {

            if let operation = pathObj.operation, let optTags = operation.tags {
                
                for tag in optTags {
                    
                    if var paths = tagsMap[tag] {
                        paths.append(pathObj)
                        tagsMap[tag] = paths
                    }
                }
            }
        }
        
        for (tag, tagPathes) in tagsMap {
            print("😄😄", tag)
            
            let tagFileName = "\(tag).Path.swift"
            var tagPath = "//\n"
            tagPath += "// \(tag).Path.swift\n"
            tagPath += "//\n"
            tagPath += "// Create by JSONConverter\n"
            tagPath += "//\n\n\n"
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
                    
                    
                    let pathesName = generatePathComponent(pathName: str).enumerated().map({ (offset, elem) -> String in
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
                        
                        funcName += "Path(path: \"\(pathReturn)\""
                        funcName += "\n"
                        funcName += whiteTab
                        funcName += "}"
                        
                        funcName += "\n"

                        tagPath += funcName
                    }
                    
                }else {
                    
                    let pathesName = generatePathComponent(pathName: path).enumerated().map({ (offset, elem) -> String in
                        if offset == 0 {
                            return elem
                        }
                        return elem.capitalized
                        
                    }).joined(separator: "")
                    
                    var pathCode = "\n"
                    
                    if let descrip = pathObj.operation?.description {
                        pathCode += whiteTab
                        pathCode += "// DESC: \(descrip)"
                    }
                    
                    if let summary = pathObj.operation?.summary {
                        pathCode += whiteTab
                        pathCode += "// SUMMARY: \(summary)"
                    }
                    
                    pathCode += "\n"
                    pathCode += whiteTab
                    pathCode += "fileprivate static let \(pathesName) = Path(path: \"\(path)\")"
                    pathCode += "\n"
                    
                    tagPath += pathCode
                    
                }
            }
            
            tagPath += "}"
            print("✨✨✨✨✨✨✨✨✨✨✨✨✨✨✨✨✨✨✨✨✨\n")
            print(tagPath)
            
            
            do {
                try tagPath.write(toFile: "/Users/Binglin/Documents/MyselfProjects/JSONFactory/CodeFactory/\(tagFileName)", atomically: true, encoding: String.Encoding.utf8)
            }
            catch let err {
                print(err)
            }
            
            print("✨✨✨✨✨✨✨✨✨✨✨✨✨✨✨✨✨✨✨✨✨\n")
        }
    }
    
    // TODO 解析definition -> Entity
    func analyzeDefinition(swagger: SwaggerObject) {
        
        guard let definitionsObjs = swagger.definitionsObject else { return }
        
        for obj in definitionsObjs {
            
            if let def = obj.definition {
                
                print("\n")
                print("\n")
                print("🍎🍎🍎🍎🍎🍎🍎🍎🍎🍎🍎🍎\n", obj.key, def.description ?? "nil" , obj.definition?.type ?? "nil", "\n")
                
                if let properties = def.propertiesObjs {
                    
                    for prop in properties {
                        
                        print("\(prop.key)", prop.definition?.type ?? "nil", prop.definition?.description ?? "nil")
                        
                    }
                }
            }
        }
    }
    
    func generatePathComponent(pathName: String) -> [String] {
        
        
        let r = pathName.components(separatedBy: "/").filter { (s) -> Bool in
            return s.characters.count > 0
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
//            do {
                let data = json.data(using: .utf8)
                
                guard let d = data else {
                    return
                }
                
                let json = try! JSONSerialization.jsonObject(with: d, options: JSONSerialization.ReadingOptions.allowFragments)
                print(json)
                
                if let dic = json as? [String : Any] {
                    let explained = JSONInfoParser.parseJSON(from: dic, name: "<#Root#>")
                    
                    let txt = MappingAceAssembler.assemble(jsonInfos: explained)
                    self.outputTextView.string = txt
                }
                
//            }catch (let e) {
//                print(e)
//            }
        }
    }
    
    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}



