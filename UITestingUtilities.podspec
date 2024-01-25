#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|
  s.name         = "UITestingUtilities"
  s.version      = "0.0.1"
  s.summary      = "Common code for Unit/UI Testing"

  s.homepage     = "https://github.com/scott-mccoy-modolabs/UITestingUtilities.git"


  s.author       = {
    "Scott McCoy" => "scott.mccoy@modolabs.com",
  }
  s.license      = "Modo Labs"

  s.platform     = :ios, '13.0'
  s.source       = { git: "https://github.com/scott-mccoy-modolabs/UITestingUtilities.git", tag: s.version }

  s.source_files = "Code/**/*{swift,h,m}"
  s.public_header_files = 'Code/**/*.h'
  
  s.frameworks = 'XCTest'
  
end
