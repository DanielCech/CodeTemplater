//
//  TemplateScriptInfo.swift
//  CodeTemplaterFramework
//
//  Created by Daniel Cech on 03/10/2020.
//

import Foundation

struct TemplateScriptInfo {
    /// Subjective measure - how well is template prepared?
    var completeness: Int

    /// Is template separately compilable and validatable?
    var compilable: Bool

    /// Context for template validation - for validation purposes
    var validationContext: Context

    /// For following list of file paths always  prefer the original location of file in project
    var preferOriginalLocation: [String]

    /// The list of parameter descriptions
    var parameters: [Parameter]
}
