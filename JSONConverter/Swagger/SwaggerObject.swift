//
//  SwaggerObject.swift
//  JSONConverter
//
//  Created by ET|冰琳 on 2017/5/18.
//  Copyright © 2017年 IB. All rights reserved.
//

import Foundation

struct SwaggerObject {
    var swagger: String
    var info: [InfoObject] = []
    var host: String?
    var basePath: String?
    var schemes: [String]?
    var consumes: [String]?
    var produces: [String]?
    var paths: [PathObject]
    var definitions: [DefinitionObject]
    var parameters: [ParameterDefinitionObject]
    var responses: [ResponseDefinitionObject]
    var securityDefinitions: [SecurityDefinitionObject]
    var security: [SecurityRequirementObject]
    var tags: [TagObject]
    var externalDocs: ExternalDocumentationObject
}

struct InfoObject {
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


struct PathObject {
    
}

struct PathItemObject {
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

struct OperationObject {
    
}

struct DefinitionObject {
    
}

enum ParameterIn: String {
    case query = "query"
    case header = "header"
    case path = "path"
    case formData = "formData"
    case body = "body"
}

enum ParameterType: String {
    case string = "string"
    case number = "number"
    case integer = "integer"
    case boolean = "boolean"
    case array   = "array"
    case file    = "file"
}

struct SchemaObject {
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

enum ItemObjectType: String {
    case string = "string"
    case number = "number"
    case integer = "integer"
    case boolean = "boolean"
    case array   = "array"
}

struct ItemObject {
    var type: ItemObjectType
    var format: String?
    var items: [ItemObject]?
    var collectionFormat: [String]?
    var `enum`: [String]?
    
}

struct ParameterObject {
    var name: String
    var `in`: ParameterIn
    var description: String?
    var required: Bool
    
    //if inbody
    var schema: SchemaObject?
    
    //if in body
    var type: ParameterType
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

struct ParameterDefinitionObject {
    //{name}	Parameter Object	A single parameter definition, mapping a "name" to the parameter it defines.
    
    var key: String
    var parameter: ParameterObject
}

struct ResponseDefinitionObject {
    
}

struct SecurityDefinitionObject {
    
}

struct SecurityRequirementObject {
    
}

struct TagObject {
    var name: String
    var description: String?
    var externalDocs: ExternalDocumentationObject?
    
}

struct ExternalDocumentationObject {
    var description: String?
    var url: String
}


struct ContactObject {
    var name: String?
    var url: String?
    var email: String?
}

struct LicenseObject {
    var name: String
    var url: String?
}
