Pod::Spec.new do |s|
  s.name             = "YakKit"
  s.version          = "0.1.0"
  s.summary          = "An Objective-C implementation of Yik Yak's private API." 
  s.homepage         = "https://github.com/ThePantsThief/YakKit"
  s.license          = 'MIT'
  s.author           = { "ThePantsThief" => "tannerbennett@me.com" }
  s.source           = { :git => "https://github.com/ThePantsThief/YakKit.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/ThePantsThief'

  s.requires_arc = true
  s.ios.deployment_target = '7.0'
  s.osx.deployment_target = '10.8'

  s.source_files = 'Pod/Classes/*', 'Pod/Classes/**/*', 'Pod/Dependencies/*', 'Pod/Dependencies/**/*'
  s.dependency 'Mantle'
end