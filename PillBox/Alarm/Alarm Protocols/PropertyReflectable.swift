//
//  PropertyReflectable.swift
//  PillBox
//
//  Created by Hannah Hoff on 5/17/19.
//  Copyright © 2019 Hannah Hoff. All rights reserved.
//

import Foundation

protocol PropertyReflectable {
    typealias RepresentationType = [String:Any]
    typealias ValuesType = [Any]
    typealias NamesType = [String]
    var propertyDictRepresentation: RepresentationType {get}
    var propertyValues: ValuesType {get}
    var propertyNames: NamesType {get}
    static var propertyCount: Int {get}
    
    init(_ r:RepresentationType)
}

extension PropertyReflectable {
    var propertyDictRepresentation: RepresentationType {
        var ret: [String: Any] = [:]
        for case let (label, value) in Mirror(reflecting: self).children {
            guard let l = label else{
                continue
            }
            ret.updateValue(value, forKey: l)
        }
        return ret
    }
    var propertyValues: ValuesType {
        return Array(propertyDictRepresentation.values)
    }
    
    var propertyNames: NamesType {
        return Array(propertyDictRepresentation.keys)
    }
}
