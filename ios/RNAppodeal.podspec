
Pod::Spec.new do |s|
  s.name         = "RNAppodeal"
  s.version      = "1.0.0"
  s.summary      = "Package to run Appodeal inside a React Native Project"
  s.description  = <<-DESC
                  RNAppodeal
                   DESC
  s.homepage     = "https://esound.app"
  s.license      = "MIT"
  # s.license      = { :type => "MIT", :file => "FILE_LICENSE" }
  s.author             = { "author" => "author@domain.cn" }
  s.platform     = :ios, "7.0"
  s.source       = { :git => "https://github.com/marf/react-native-appodeal-enhanced.git", :tag => "master" }
  s.source_files  = "*.{h,m}"
  s.requires_arc = true


  s.dependency "React"
  s.dependency "Appodeal/Core"
  s.dependency "Appodeal/Interstitial"
  s.dependency "Appodeal/Video"
  s.dependency "Appodeal/TwitterMoPubAdapter"
  #s.dependency "others"

end
