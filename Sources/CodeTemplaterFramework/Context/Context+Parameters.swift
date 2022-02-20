//
//  Context+Parameters.swift
//  codeTemplater
//
//  Created by Daniel Cech on 13/09/2020.
//

import Foundation

extension Context {
    
    private func saveParameter(parameterName: String, value: ParameterValue) {
        switch value {
        case .none:
            break
        case let .bool(value):
            dictionary[parameterName] = value
        case let .string(value):
            dictionary[parameterName] = value
        case let .stringArray(value):
            dictionary[parameterName] = value
        }
    }
    
    /// Universal method for asking for missing parameter
    private func askForParameter(parameterName: String, type: ParameterType) -> ParameterValue {
        guard let parameter = parameterProcessor.getParameter(name: parameterName) else {
            fatalError("Unknown parameter: \(parameterName)")
        }
        
        guard parameter.type == type else {
            fatalError("Parameter type mismatch: \(parameterName):\(parameter.type) vs \(type)")
        }
        
        let defaultValueAvailable = (parameter.defaultValue != .none)
        
        // Select default value immediately
        if defaultValueAvailable && !parameter.alwaysAsk {
            saveParameter(parameterName: parameterName, value: parameter.defaultValue)
            return parameter.defaultValue
        }
        
        var hint: String
        switch type {
        case .bool:
            hint = "[tf]"
        case .string:
            hint = ""
        case .stringArray:
            hint = "[comma-separated]"
        }
        
        if defaultValueAvailable {
            if !hint.isEmpty {
                hint += " "
            }
            hint += "(keep empty for default value)"
        }
        
        return questionIteration(
            parameterName: parameterName,
            parameter: parameter,
            hint: hint,
            defaultValueAvailable: defaultValueAvailable,
            type: type
        )
    }
    
    func questionIteration(
        parameterName: String,
        parameter: Parameter,
        hint: String,
        defaultValueAvailable: Bool,
        type: ParameterType
    ) -> ParameterValue {
        var showHeader = true
        
        while true {
            if showHeader {
                print("🧩 Missing parameter '\(parameterName)': \(parameter.description).")
                if parameter.possibleValues != nil {
                    print("🧩 The list of possible values is available (type '?')")
                }
            }
            
            if defaultValueAvailable {
                print("📌  Default value: '\(parameter.defaultValue.description)'.")
                print("❔ Enter '\(parameterName)' value \(hint): ", terminator: "")
            }
            else {
                print("❔ Enter '\(parameterName)': ", terminator: "")
            }
            
            
            if let input = readLine() {
                if input == "?" {
                    if let possibleValues = parameter.possibleValues {
                        if let selectedValue = selectFrom(
                            possibleValues: possibleValues,
                            parameterName: parameterName,
                            parameter: parameter,
                            input: ""
                        ) {
                            dictionary[parameterName] = selectedValue
                            return .string(selectedValue)
                        }
                    }
                    else {
                        print("❗️ List of possible values is not available\n")
                        showHeader = true
                        continue
                    }
                }
                
                if !input.isEmpty {
                    switch type {
                    case .bool:
                        if input == "t" || input == "f" {
                            let trueOrFalse = (input == "t") ? true : false
                            dictionary[parameterName] = trueOrFalse
                            print("")
                            return .bool(trueOrFalse)
                        }
                    case .string:
                        // Possible values are available
                        if let possibleValues = parameter.possibleValues {
                            let possibleValueStrings = parameterValuesList(possibleValues: possibleValues)
                            if possibleValueStrings.contains(input) {
                                dictionary[parameterName] = input
                                print("")
                                return .string(input)
                            }
                            else {
                                if let selectedValue = selectFrom(
                                    possibleValues: possibleValues,
                                    parameterName: parameterName,
                                    parameter: parameter,
                                    input: input
                                ) {
                                    dictionary[parameterName] = selectedValue
                                    print("")
                                    return .string(selectedValue)
                                }
                                else {
                                    showHeader = false
                                    continue
                                }
                            }
                        }
                        else {
                            dictionary[parameterName] = input
                            print("")
                            return .string(input)
                        }
                        
                    case .stringArray:
                        let list = input.split(separator: ",").map { String($0) }
                        dictionary[parameterName] = list
                        print("")
                        return .stringArray(list)
                    }
                }
                else {
                    if defaultValueAvailable {
                        saveParameter(parameterName: parameterName, value: parameter.defaultValue)
                        print("")
                        return parameter.defaultValue
                    }
                }
            }
            
            showHeader = true
            print("❗️ Incorrect input\n")
        }
    }
    
    func parameterValuesList(possibleValues: [ParameterValue]) -> [String] {
        let array = possibleValues.compactMap { parameterValue -> String? in
            if case let .string(stringValue) = parameterValue {
                return stringValue
            }
            else {
                return nil
            }
        }
        
        return array
    }
    
    func selectFrom(possibleValues: [ParameterValue], parameterName: String, parameter: Parameter, input: String) -> String? {
        let possibleValueStrings = parameterValuesList(possibleValues: possibleValues)
        let sortedValueStrings = possibleValueStrings.sorted()
        
        let filteredValueStrings: [String]
        if input.isEmpty {
            filteredValueStrings = sortedValueStrings
        }
        else {
            filteredValueStrings = sortedValueStrings.filter { $0.lowercased().contains(input.lowercased()) }
        }
        
        if filteredValueStrings.isEmpty {
            print("❗️ Invalid value")
            return nil
        }
        
        for (index, item) in filteredValueStrings.enumerated() {
            print("    #\(index): \(item)")
        }
        
        print("❔ Enter index (or `X` for interruption): ", terminator: "")
        if let input = readLine() {
            if input == "X" {
                return nil
            }
            else {
                if let choiceIndex = Int(input) {
                    if (choiceIndex >= 0) && (choiceIndex < filteredValueStrings.count) {
                        return filteredValueStrings[choiceIndex]
                    }
                    else {
                        print("❗️ Index outside of bounds")
                        return nil
                    }
                }
                else {
                    print("❗️ Incorrect input")
                    return nil
                }
            }
            
        }
        else {
            return nil
        }
    }
    
    // MARK: - Bool parameters
    
    /// Obtaining a bool value for default bool parameter ; if value is not present it will ask the user
    public func boolValue(_ parameter: DefaultBoolParameter) -> Bool {
        return boolValue(parameter.rawValue)
    }
    
    /// Obtaining a bool value for parameter with name parameterName ; if value is not present it will ask the user
    @discardableResult public func boolValue(_ parameterName: String) -> Bool {
        if let boolValue = dictionary[parameterName] as? Bool {
            return boolValue
        }

        return askForParameter(parameterName: parameterName, type: .bool).boolValue()
    }

    /// Obtaining optional bool value by key from context; if value is not present it will return nil
    public func optionalBoolValue(_ parameter: DefaultBoolParameter) -> Bool? {
        return optionalBoolValue(parameter.rawValue)
    }
    
    /// Obtaining optional bool value by key from context; if value is not present it will return nil
    public func optionalBoolValue(_ parameterName: String) -> Bool? {
        if let boolValue = dictionary[parameterName] as? Bool {
            return boolValue
        }

        return nil
    }
    
    // MARK: - String parameters

    /// Obtaining a string value by key from context; if value is not present it will ask the user
    public func stringValue(_ parameter: DefaultStringParameter) -> String {
        return stringValue(parameter.rawValue)
    }
    
    /// Obtaining a string value for parameter with name parameterName ; if value is not present it will ask the user
    @discardableResult public func stringValue(_ parameterName: String) -> String {
        if let stringValue = dictionary[parameterName] as? String {
            return stringValue
        }

        return askForParameter(parameterName: parameterName, type: .string).stringValue()
    }

    /// Obtaining optional string value by key from context; if value is not present it will return nil
    public func optionalStringValue(_ parameter: DefaultStringParameter) -> String? {
        return optionalStringValue(parameter.rawValue)
    }
    
    /// Obtaining optional string value by key from context; if value is not present it will return nil
    public func optionalStringValue(_ parameterName: String) -> String? {
        if let stringValue = dictionary[parameterName] as? String {
            return stringValue
        }
        return nil
    }
    
    // MARK: - String array parameters

    /// Obtaining string array value by key for default parameter; if value is not present it will ask the user
    public func stringArrayValue(_ parameter: DefaultStringArrayParameter) -> [String] {
        return stringArrayValue(parameter.rawValue)
    }
    
    /// Obtaining string array value by parameter name; if value is not present it will ask the user
    @discardableResult public func stringArrayValue(_ parameterName: String) -> [String] {
        if let stringArrayValue = dictionary[parameterName] as? [String] {
            return stringArrayValue
        }

        return askForParameter(parameterName: parameterName, type: .stringArray).stringArrayValue()
    }

    /// Obtaining optional string array value for default parameter; if value is not present it will return nil
    public func optionalStringArrayValue(_ parameter: DefaultStringArrayParameter) -> [String]? {
        return optionalStringArrayValue(parameter.rawValue)
    }
    
    /// Obtaining optional string array value by parameter name; if value is not present it will return nil
    public func optionalStringArrayValue(_ parameterName: String) -> [String]? {
        if let stringArrayValue = dictionary[parameterName] as? [String] {
            return stringArrayValue
        }
        return nil
    }
}
