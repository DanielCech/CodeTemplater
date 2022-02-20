Pod::Spec.new do |s|
  s.name                      = 'codeTemplater'
  s.module_name               = 'codeTemplater'
  s.version                   = '0.1.0'
  s.summary                   = 'CodeTemplater is Swift script for code generation based on Stencil templates'
  s.homepage                  = 'https://github.com/strvcom/ios-code-templates'
  s.license                   = 'MIT'
  s.author                    = { "Daniel Cech" => "daniel.cech@gmail.com" }
  s.platform                  = :ios, '8.0'
  s.ios.deployment_target     = '8.0'
  s.requires_arc              = true
  s.source                    = { :git => 'https://github.com/strvcom/ios-code-templates', :tag => s.version.to_s }
  s.preserve_paths            = 'Bin/**/*'
  s.swift_version             = '4.0'
end
