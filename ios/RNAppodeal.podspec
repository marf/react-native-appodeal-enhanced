
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
  s.static_framework = true

  s.dependency "React"
  s.dependency "APDAdColonyAdapter"
  s.dependency "APDAmazonAdsAdapter"
  s.dependency "APDAppLovinAdapter"
  s.dependency "APDAppodealAdExchangeAdapter"
  s.dependency "APDChartboostAdapter"
  s.dependency "APDFacebookAudienceAdapter"
  s.dependency "APDGoogleAdMobAdapter" 
  s.dependency "APDInMobiAdapter"
  s.dependency "APDInnerActiveAdapter"
  s.dependency "APDIronSourceAdapter"
  s.dependency "APDMintegralAdapter"
  s.dependency "APDMyTargetAdapter"
  s.dependency "APDTwitterMoPubAdapter"
  s.dependency "APDOguryAdapter"
  s.dependency "APDOpenXAdapter"
  s.dependency "APDPubnativeAdapter"
  s.dependency "APDSmaatoAdapter"
  s.dependency "APDStartAppAdapter"
  s.dependency "APDTapjoyAdapter"
  s.dependency "APDUnityAdapter"
  s.dependency "APDVungleAdapter"
  s.dependency "APDYandexAdapter"

  #s.dependency "others"

end
