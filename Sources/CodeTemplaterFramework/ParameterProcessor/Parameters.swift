//
//  Parameters.swift
//  CodeTemplater
//
//  Created by Daniel Cech on 24/07/2020.
//

import Foundation

enum ParameterType: String, Codable {
    case bool
    case string
    case stringArray
}

enum ParameterValue: Codable {
    case none
    case bool(Bool)
    case string(String)
    case stringArray([String])

    init(from _: Decoder) throws {
        self = .none
    }

    func encode(to _: Encoder) throws {}
    
    var description: String {
        switch self {
        case .none:
            return "<none>"
        case let .bool(value):
            return value ? "true" :  "false"
        case let .string(value):
            return value
        case let .stringArray(value):
            return value.joined(separator: ",")
        }
    }
    
    func boolValue() -> Bool {
        if case let .bool(value) = self {
            return value
        }
        else {
            fatalError("Type mismatch")
        }
    }
    
    func stringValue() -> String {
        if case let .string(value) = self {
            return value
        }
        else {
            fatalError("Type mismatch")
        }
    }
    
    func stringArrayValue() -> [String] {
        if case let .stringArray(value) = self {
            return value
        }
        else {
            fatalError("Type mismatch")
        }
    }
    
    init(bool: Bool?) {
        if let unwrappedBool = bool {
            self = .bool(unwrappedBool)
        }
        else {
            self = .none
        }
    }
    
    init(string: String?) {
        if let unwrappedString = string {
            self = .string(unwrappedString)
        }
        else {
            self = .none
        }
    }
    
    init(stringArray: [String]?) {
        if let unwrappedStringArray = stringArray {
            self = .stringArray(unwrappedStringArray)
        }
        else {
            self = .none
        }
    }
}

extension ParameterValue: Equatable {}


public enum DefaultBoolParameter: String, CaseIterable {
    case none                       // Dummy value is needed to make type compilable
}

public enum DefaultStringParameter: String, CaseIterable {
    // Script setup
    case mode
    case reviewMode
        
    // Template parameters
    case template
    case templateCombo
    case category
    case context
    case name
    case projectName
    case targetName
    case author
    case copyright
        
    // Auto-generated parameters
    case fileName
    case date

    // Paths
    case scriptPath
    case locationPath
    case projectPath
    case sourcesPath
    case templatePath
    case generatePath
    case validatePath
    case preparePath
      
    // Template preparation
    case deriveFromTemplate
}

public  enum DefaultStringArrayParameter: String, CaseIterable {
    case projectFiles
}


/// Abstract parameter class - I couldn't use protocol here because parameters is polymorphic array
class Parameter {
    /// The name of parameter
    var name: String
    
    /// Parameter type - bool, string, stringArray
    var type: ParameterType
    
    /// Description of parameter meaning
    var description: String
    
    /// Default value of parameter
    var defaultValue: ParameterValue
    
    /// Optional list of possible values
    var possibleValues: [ParameterValue]?
    
    /// Is it mandatory to have this parameter filled?
    var mandatory: Bool
    
    /// Should be user always asked for the value even if defaultValue is present
    var alwaysAsk: Bool
    
    init(
        name: String,
        type: ParameterType,
        description: String,
        defaultValue: ParameterValue,
        possibleValues: [ParameterValue]? = nil,
        mandatory: Bool = true,
        alwaysAsk: Bool = true
    ) {
        self.name = name
        self.type = type
        self.description = description
        self.defaultValue = defaultValue
        self.possibleValues = possibleValues
        self.mandatory = mandatory
        self.alwaysAsk = alwaysAsk
    }
}

class BoolParameter: Parameter {
    init(
        name: String,
        description: String,
        defaultValue: Bool? = nil,
        mandatory: Bool = true,
        alwaysAsk: Bool = true
    ) {
        super.init(
            name: name,
            type: .bool,
            description: description,
            defaultValue: .init(bool: defaultValue),
            mandatory: mandatory,
            alwaysAsk: alwaysAsk
        )
    }
    
    init(_ dict: [String: Any]) throws {
        guard let name = dict["name"] as? String, let description = dict["description"] as? String else {
            throw CodeTemplaterError.generalError(message: "parameters name or description are missing")
        }
        
        let defaultValue = dict["defaultValue"] as? Bool
        let mandatory = dict["mandatory"] as? Bool ?? true
        let alwaysAsk = dict["alwaysAsk"] as? Bool ?? true
        
        super.init(
            name: name,
            type: .bool,
            description: description,
            defaultValue: .init(bool: defaultValue),
            mandatory: mandatory,
            alwaysAsk: alwaysAsk
        )
    }
}

class StringParameter: Parameter {
    init(
        name: String,
        description: String,
        defaultValue: String? = nil,
        possibleValues: [ParameterValue]? = nil,
        mandatory: Bool = true,
        alwaysAsk: Bool = true
    ) {
        super.init(
            name: name,
            type: .string,
            description: description,
            defaultValue: .init(string: defaultValue),
            possibleValues: possibleValues,
            mandatory: mandatory,
            alwaysAsk: alwaysAsk
        )
    }
    
    init(_ dict: [String: Any]) throws {
        guard let name = dict["name"] as? String, let description = dict["description"] as? String else {
            throw CodeTemplaterError.generalError(message: "parameters name, description or defaultValue is missing")
        }
        
        let defaultValue = dict["defaultValue"] as? String
        let mandatory = dict["mandatory"] as? Bool ?? true
        let alwaysAsk = dict["alwaysAsk"] as? Bool ?? true
        
        super.init(
            name: name,
            type: .string,
            description: description,
            defaultValue: .init(string: defaultValue),
            mandatory: mandatory,
            alwaysAsk: alwaysAsk
        )
    }
}

class StringArrayParameter: Parameter {
    init(
        name: String,
        description: String,
        defaultValue: [String]? = nil,
        mandatory: Bool = true,
        alwaysAsk: Bool = true
    ) {
        super.init(
            name: name,
            type: .stringArray,
            description: description,
            defaultValue: .init(stringArray: defaultValue),
            mandatory: mandatory,
            alwaysAsk: alwaysAsk
        )
    }
    
    init(_ dict: [String: Any]) throws {
        guard let name = dict["name"] as? String, let description = dict["description"] as? String else {
            throw CodeTemplaterError.generalError(message: "parameters name, description or defaultValue is missing")
        }
        
        let defaultValue = dict["defaultValue"] as? [String]
        let mandatory = dict["mandatory"] as? Bool ?? true
        let alwaysAsk = dict["alwaysAsk"] as? Bool ?? true
        
        super.init(
            name: name,
            type: .stringArray,
            description: description,
            defaultValue: .init(stringArray: defaultValue),
            mandatory: mandatory,
            alwaysAsk: alwaysAsk
        )
    }
}
