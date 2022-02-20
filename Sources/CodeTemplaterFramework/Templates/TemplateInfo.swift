//
//  TemplateInfo.swift
//  CodeTemplater
//
//  Created by Daniel Cech on 07/07/2020.
//

import Foundation

struct TemplateInfo {
    /// Description of template - the meaning and usage
    var description: String
    
    /// The status of template in terms of validation - possible values are "draft", "failing", "passing"
    var status: String
    
    /// List of templates that are dependencies for current template (e.g. some view controller is not compilable without his view model)
    var dependencies: [String]

    /// Context for template validation - for validation purposes
    var validationContext: Context

    /// For following list of file paths always  prefer the original location of file in project
    var preferOriginalLocation: [String]

    /// The list of parameter descriptions
    var parameters: [Parameter]
}
