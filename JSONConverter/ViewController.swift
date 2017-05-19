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
                        print(paths)
                    }
                }
            }
        }
        
        for (tag, tagPathes) in tagsMap {
            print("😄😄", tag)
            
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
                    
                    let pathesName = str.components(separatedBy: "/").joined(separator: "_")
                    print("--------------------------", pathesName)
                }else {
                    let pathesName = path.components(separatedBy: "/").joined(separator: "_")
                    print("--------------------------", pathesName)
                }
                
            }
        }
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



