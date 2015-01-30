Pod::Spec.new do |s|
  s.name         = "Keynode"
  s.version      = "1.1.1"
  s.summary      = "Interactive Keyboard Controller for Swift"
  s.homepage     = "https://github.com/KyoheiG3/Keynode"
  s.license      = { :type => 'MIT', :file => 'LICENSE' }
  s.author       = { "Kyohei Ito" => "je.suis.kyohei@gmail.com" }
  s.platform     = :ios, "8.0"
  s.source       = { :git => "https://github.com/KyoheiG3/Keynode.git", :tag => s.version.to_s }
  s.source_files  = "Keynode/**/*.{h,swift}"
  s.requires_arc = true
  s.frameworks = 'UIKit'
end
