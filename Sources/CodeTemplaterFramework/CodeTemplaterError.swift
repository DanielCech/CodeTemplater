//
//  CodeTemplaterError.swift
//  CodeTemplater
//
//  Created by Daniel Cech on 10/07/2020.
//

import Files
import Foundation
import ScriptToolkit

public enum CodeTemplaterError: Error {
    case argumentError(message: String)
    case generalError(message: String)
    case fileNotFound(message: String)
    case folderNotFound(message: String)
    case moreInfoNeeded(message: String)
    case unknownParameter(message: String)
    case defaultParameterOverride(message: String)
    case invalidFormatOfData(message: String)
    case dataInconsistency(message: String)

    case missingCodeTemplaterJson
    case missingTemplaterFolder
    case stencilTemplateError(message: String)
    case parameterNotSpecified(message: String)
    case invalidProjectFilePath(message: String)
    case invalidReviewMode(message: String)
}

extension CodeTemplaterError: PrintableError {
    public var errorDescription: String {
        let prefix = "💥 error: "
        var errorDescription = ""

        switch self {
        case let .argumentError(message: message):
            errorDescription = "argument error: \(message)"
        case let .generalError(message: message):
            errorDescription = "general error: \(message)"
        case let .fileNotFound(message: message):
            errorDescription = "file not found: \(message)"
        case let .folderNotFound(message: message):
            errorDescription = "folder not found: \(message)"
        case let .moreInfoNeeded(message: message):
            errorDescription = "more info needed: \(message)"
        case let .unknownParameter(message: message):
            errorDescription = "unknown parameter: \(message)"
        case let .defaultParameterOverride(message: message):
            errorDescription = "template parameter is in conflict with default parameter: \(message)"
        case let .invalidFormatOfData(message: message):
            errorDescription = "data not valid: \(message)"
        case let .dataInconsistency(message: message):
            errorDescription = "data inconsistency: \(message)"
            
        case .missingCodeTemplaterJson:
            errorDescription = "missing CodeTemplater.json in current folder."
        case .missingTemplaterFolder:
            errorDescription = "missing folder 'templater'."
        case let .stencilTemplateError(message):
            errorDescription = "stencil syntax error: \(message)"
        case let .parameterNotSpecified(message):
            errorDescription = "parameter not specified: \(message)"
        case let .invalidProjectFilePath(message):
            errorDescription = "invalid project file path: \(message)"
        case let .invalidReviewMode(message):
            errorDescription = "invalid review mode: \(message)"
        }

        return prefix + errorDescription
    }
}

extension FilesError: PrintableError {
    public var errorDescription: String {
        return description
    }
}
