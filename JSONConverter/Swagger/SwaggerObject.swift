//
//  SwaggerObject.swift
//  JSONConverter
//
//  Created by ET|冰琳 on 2017/5/18.
//  Copyright © 2017年 IB. All rights reserved.
//

import Foundation

// ----------------------------------------------------------------
struct SwaggerMainInfo {
    
    var paths: [PathItemObject]
    var parameters: [ParameterObject]
    var definitions: [DefinitionObject]
}

struct SwaggerPathObject {
    var path: String
    var method: String
    var operation: OperationObject?
}

// 全局parameters
struct SwaggerParameterObject {
    var key: String
    var parameter: ParameterObject
}


// ----------------------------------------------------------------
struct SwaggerObject: Mapping {
    var swagger: String?
    var info: [InfoObject] = []
    var host: String?
    var basePath: String?
    var schemes: [String]?
    var consumes: [String]?
    var produces: [String]?

    //   var paths: [PathObject]
//    var definitions: [DefinitionObject]
//    var parameters: [ParameterDefinitionObject]
    
//    var securityDefinitions: [SecurityDefinitionObject]
//    var security: [SecurityRequirementObject]
    var tags: [TagObject]?
    var externalDocs: ExternalDocumentationObject?
    
    var pathObjects: [SwaggerPathObject]?
    var parameterObjects: [SwaggerParameterObject]?
}

struct InfoObject: Mapping {
    var title: String
    var description: String?
    var termsOfService: String?
    var contact: [ContactObject]?
    var license: [LicenseObject]?
    var version: String
    
    /*
    Patterned Objects
    
    Field Pattern	Type	Description
    ^x-	Any	Allows extensions to the Swagger Schema. The field name MUST begin with x-, for example, x-internal-id. The value can be null, a primitive, an array or an object. See Vendor Extensions for further details.
    */
}


struct PathItemObject: Mapping {
    var ref: String
    var get: OperationObject?
    var put: OperationObject?
    var post: OperationObject?
    var delete: OperationObject?
    var options: OperationObject?
    var head: OperationObject?
    var patch: OperationObject?
    var parameters: [ParameterObject]?
    
}

struct OperationObject: Mapping {
    var tags: [String]?
    var summary: String?
    var description: String?
    var externalDocs: ExternalDocumentationObject?
    var operationId: String?
    var consumes: [String]?
    var produces: [String]?
    
    var parameters: [ParameterObject]
    //var response: ResponseObject
    
    var schemes: [String]?
    var deprecated: Bool?
    
}

struct DefinitionObject: Mapping {
    var ref: String?
    var title: String?
    var description: String?
    var `enum`: [String]?
    var required: Bool?
    var items: [String]?
    var discriminator: String?
    var type: ItemObjectType?
    var format: String?
}

enum ParameterIn: String, EnumString {
    case query = "query"
    case header = "header"
    case path = "path"
    case formData = "formData"
    case body = "body"
}

enum ParameterType: String, EnumString {
    case string = "string"
    case number = "number"
    case integer = "integer"
    case boolean = "boolean"
    case array   = "array"
    case file    = "file"
}

struct SchemaObject: Mapping {
    var ref: String?// - As a JSON Reference
    var format: String? // (See Data Type Formats for further details)
    var title: String?//
    var description: String?// (GFM syntax can be used for rich text representation)
    var `default`:  Any?//(Unlike JSON Schema, the value MUST conform to the defined type for the Schema Object)
    var multipleOf: Int?
    var maximum: Int?
    var exclusiveMaximum: Int?
    var minimum: Int?
    var exclusiveMinimum: Int?
    var maxLength: Int?
    var minLength: Int?
    var pattern: String?
    var maxItems: Int?
    var minItems: Int?
    var uniqueItems: Bool?
    var maxProperties: Int?
    var minProperties: Int?
    var required: Bool?
    var `enum`: [String]?
    var type: String?
}

enum ItemObjectType: String, EnumString {
    case string = "string"
    case number = "number"
    case integer = "integer"
    case boolean = "boolean"
    case array   = "array"
}

struct ItemObject: Mapping {
    var type: ItemObjectType
    var format: String?
    var items: [ItemObject]?
    var collectionFormat: [String]?
    
    var `default`: Any
    
    var maxinum: Int?
    var exclusiveMaximum: Bool?
    var minimum: Int?
    var exclusiveMinimum: Bool?
    var maxLength: Int?
    var minLength: Int?
    var pattern: String?
    var maxItems: Int?
    var minItems: Int?
    var uniqueItems: Bool?
    var `enum`: [String]
    var multipleOf: Int
    
}

struct ParameterObject: Mapping, KeyMapping {
    var ref: String?
    var name: String?
    var `in`: ParameterIn?
    var description: String?
    var required: Bool?
    
    //if inbody
    var schema: SchemaObject?
    
    //if in body
    var type: ParameterType?
    var formate: String?
    var allowEmptyValue: Bool?
    
    // type is array? is required
    var items: [ItemObject]?
    
    /** required if in query or formData
     * 
     csv - comma separated values foo,bar.
     ssv - space separated values foo bar.
     tsv - tab separated values foo\tbar.
     pipes - pipe separated values foo|bar.
     multi - c
     */
    var collectionFormat: String? //
    
    //var `default`: Any
    
    var maxinum: Int?
    var exclusiveMaximum: Bool?
    var minimum: Int?
    var exclusiveMinimum: Bool?
    var maxLength: Int?
    var minLength: Int?
    var pattern: String?
    var maxItems: Int?
    var minItems: Int?
    var uniqueItems: Bool?
    var `enum`: [String]?
    var multipleOf: Int?
    
    static func mappedKeyFor(key: String) -> String? {
        
        if key == "ref" {
            return "$ref"
        }
        return nil
    }
}

struct ParameterDefinitionObject: Mapping {
    //{name}	Parameter Object	A single parameter definition, mapping a "name" to the parameter it defines.
    
    var key: String
    var parameter: ParameterObject
}

struct TagObject: Mapping {
    var name: String
    var description: String?
    var externalDocs: ExternalDocumentationObject?
    
}

struct ExternalDocumentationObject: Mapping {
    var description: String?
    var url: String
}


struct ContactObject: Mapping {
    var name: String?
    var url: String?
    var email: String?
}

struct LicenseObject: Mapping {
    var name: String
    var url: String?
}
