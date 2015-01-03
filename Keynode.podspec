Pod::Spec.new do |s|
  s.name         = "Keynode"
  s.version      = "0.1.1"
  s.summary      = "Interactive Keyboard Controller"
  s.homepage     = "https://github.com/KyoheiG3/Keynode"
  s.license      = { :type => 'MIT', :file => 'LICENSE' }
  s.author       = { "Kyohei Ito" => "je.suis.kyohei@gmail.com" }
  s.platform     = :ios, "7.0"
  s.source       = { :git => "https://github.com/KyoheiG3/Keynode.git", :tag => "0.1.1" }
  s.source_files  = "Keynode/**/*.{h,swift}"
end
