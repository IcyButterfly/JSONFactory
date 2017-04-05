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
                    
                    MappingAceAssembler.assemble(jsonInfos: explained, toDocument: "/Users/Binglin/Desktop/JSONConverter/JSONConverter/JSONDocument")
                }
                
            }catch (let e) {
                print(e)
            }
        }
        
        transfer.target = self
        transfer.action = #selector(transferAction)
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



