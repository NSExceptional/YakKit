Pod::Spec.new do |s|
  s.name             = "YakKit"
  s.version          = "0.2.2"
  s.summary          = "An Objective-C implementation of Yik Yak's private API." 
  s.homepage         = "https://github.com/NSExceptional/YakKit"
  s.license          = 'MIT'
  s.author           = { "NSExceptional" => "tannerbennett@me.com" }
  s.source           = { :git => "https://github.com/NSExceptional/YakKit.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/NSExceptional'

  s.requires_arc = true
  s.ios.deployment_target = '7.0'
  s.osx.deployment_target = '10.8'

  s.source_files = 'YakKit/*', 'YakKit/**/*'
  s.dependency 'Mantle'
  s.dependency 'TBURLRequestOptions'
  s.dependency 'Firebase/Auth'
  s.dependency 'Firebase/Firestore'
end
