#
# Be sure to run `pod lib lint Magnetic.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'Magnetic'
  s.version          = '2.0.10'
  s.summary          = 'SpriteKit Floating Bubble Picker (inspired by Apple Music)'
  s.homepage         = 'https://github.com/efremidze/Magnetic'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'efremidze' => 'efremidzel@hotmail.com' }
  s.documentation_url = 'https://efremidze.github.io/Magnetic/'
  s.source           = { :git => 'https://github.com/efremidze/Magnetic.git', :tag => s.version.to_s }
  s.ios.deployment_target = '9.0'
  s.source_files = 'Sources/*.swift'
end
