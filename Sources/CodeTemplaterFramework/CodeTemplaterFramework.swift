//
//  CodeTemplaterFramework.swift
//  CodeTemplater
//
//  Created by Daniel Cech on 10/07/2020.
//

import Files
import Foundation
import Moderator
import ScriptToolkit
import Stencil
import XCGLogger

/// Logger
let log = XCGLogger.default

/// Stencil environment for templates
let environment = stencilEnvironment()

/// Manager of script setup
var scriptSetup = ScriptSetup()

/// Parameter processing
// swiftlint:disable:next implicitly_unwrapped_optional
var parameterProcessor: ParameterProcessor!

/// Date formatter
let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "dd/MM/YYYY"
    return formatter
}()
