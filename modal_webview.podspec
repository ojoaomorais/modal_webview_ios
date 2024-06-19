#
# Be sure to run `pod lib lint modal_webview.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'modal_webview'
  s.version          = '0.1.0'
  s.summary          = 'A simple but effective modal webview.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = "A modal webview created to display pages inside your app. With 2 lines of code you can display a beautiful and simple webview."

  s.homepage         = 'https://github.com/João Pedro/modal_webview'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'João Pedro' => 'joaopedromorais.eu@gmail.com' }
  s.source           = { :git => 'https://github.com/João Pedro/modal_webview.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '10.0'

  s.source_files = 'modal_webview/Classes/**/*'
  
  # s.resource_bundles = {
  #   'modal_webview' => ['modal_webview/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
