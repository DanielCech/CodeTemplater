//
//  Context+Subscripts.swift
//  codeTemplater
//
//  Created by Daniel Cech on 13/09/2020.
//

import Foundation

// swiftlint:disable implicit_getter

extension Context {
    // MARK: - Subscripts
    
    /// Obtaining optional bool value by key by subscript
    subscript(parameter: DefaultBoolParameter) -> Bool? {
        get {
            optionalBoolValue(parameter)
        }

        set {
            dictionary[parameter.rawValue] = newValue
        }
    }

    /// Obtaining optional string value by key by subscript
    subscript(parameter: DefaultStringParameter) -> String? {
        get {
            optionalStringValue(parameter)
        }

        set {
            dictionary[parameter.rawValue] = newValue
        }
    }

    /// Obtaining optional string array value by key by subscript
    subscript(parameter: DefaultStringArrayParameter) -> [String]? {
        get {
            optionalStringArrayValue(parameter)
        }

        set {
            dictionary[parameter.rawValue] = newValue
        }
    }
}
