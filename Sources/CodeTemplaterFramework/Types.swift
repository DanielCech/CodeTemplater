//
//  Types.swift
//  CodeTemplates
//
//  Created by Daniel Cech on 13/06/2020.
//

import Foundation


struct ProcessedPaths {
    var templatePath: String
    var middlePath: String
    var projectPath: String
}


/// The simple struct that collects related template file, generated file and project file
struct ProcessedFile {
    var templateFile: String
    var middleFile: String
    var projectFile: String?
}


/// Review mode after code generation
public enum ReviewMode: String {
    /// Do not review
    case none

    /// Review files separately
    case individual

    /// Review files together as folder comparison
    case overall
}

/// The way howo templates should be updated
public enum UpdateTemplateMode: String {
    /// Update all templates
    case all

    /// Update only when parent template modification date is newer than child template modification date
    case new
}

/// For particular template, we want to update also:
public enum UpdateScopeMode: String {
    /// Update all ancestors of current template
    case acestors

    /// Update all descendants of current template
    case descendants

    /// Update ancestors and descendants
    case both
}

/// The current program operation - generate code, update template or validate template
public enum ProgramMode: String {
    case generate
    case updateAll
    case updateNew
    case validate
    case prepare
}

public enum LocationType: String {
    case project = "_project"
    case sources = "_sources"
    case location = "_location"
}

public enum ValueType: String {
    case bool
    case string
    case stringArray
}
