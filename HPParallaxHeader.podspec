#
# Be sure to run `pod lib lint HPParallaxHeader.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'HPParallaxHeader'
  s.version          = '1.1.2'
  s.summary          = 'Simple parallax header for UIScrollView.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
  HPParallaxHeader is a simple header class for UIScrolView.
  In addition, MXScrollView is a UIScrollView subclass with the ability to hook the vertical scroll from its subviews, this can be used to add a parallax header to complex view hierachy.
  Moreover, MXScrollViewController allows you to add a MXParallaxHeader to any kind of UIViewController.
                       DESC

  s.homepage         = 'https://github.com/ngochiencse/HPParallaxHeader.git'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Hien Pham' => 'ngochiencse@gmail.com' }
  s.source           = { :git => 'https://github.com/ngochiencse/HPParallaxHeader.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '10.0'
  s.swift_version = '5.0'

  s.source_files = 'HPParallaxHeader/Classes/**/*'
  
  # s.resource_bundles = {
  #   'HPParallaxHeader' => ['HPParallaxHeader/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
