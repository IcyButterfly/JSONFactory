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
                
                
                
                //definitions 里的entity 定义
                
                
                
                //definition  api response里的entity
                
                
            }catch (let e) {
                print(e)
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



