#
# Be sure to run `pod lib lint MockingPlace.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "MockingPlace"
  s.version          = "0.2.3"
  s.summary          = "A complete CLLocationManager simulator."

  s.description      = <<-DESC
                        Simulates locations and tracks using geojson. Apple keeps changing how the location simulation in Xcode works and it kept breaking my projects. Enter MockingPlace. Also works on real devices.
                       DESC

  s.homepage         = "https://github.com/maciekish/MockingPlace"
  s.license          = 'MIT'
  s.author           = { "Maciej Swic" => "maciej@swic.name" }
  s.source           = { :git => "https://github.com/maciekish/MockingPlace.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/maciekish'

  s.platform     = :ios, '7.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes/**/*'
  s.resource_bundles = {
    'MockingPlace' => ['Pod/Assets/*.png']
  }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  s.frameworks = 'UIKit', 'CoreLocation'
  s.dependency 'JRSwizzle', '~> 1.0'
end
