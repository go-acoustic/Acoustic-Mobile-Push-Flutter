#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint flutter_acoustic_mobile_push.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'flutter_acoustic_mobile_push'
  s.version          = '0.0.1'
  s.summary          = 'A new flutter plugin project.'
  s.description      = <<-DESC
A new flutter plugin project.
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }
  s.source           = { :path => '../../plugins/flutter_acoustic_mobile_push/ios' }
  s.source_files = 'Classes/**/*.swift'
  s.dependency 'Flutter'
  s.platform = :ios, '12.1'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
  
  s.vendored_frameworks = 'AcousticMobilePush.xcframework'
  s.preserve_paths = 'AcousticMobilePush.xcframework/**/*'
  s.xcconfig = { 'OTHER_LDFLAGS' => '-framework AcousticMobilePush' }
  s.requires_arc = true
end

