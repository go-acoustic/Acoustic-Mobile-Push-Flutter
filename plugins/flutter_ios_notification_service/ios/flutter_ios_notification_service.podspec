#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint flutter_ios_notification_service.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'flutter_ios_notification_service'
  s.version          = '0.0.1'
  s.summary          = 'A new flutter plugin project.'
  s.description      = <<-DESC
A new flutter plugin project.
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'

  
  s.public_header_files = 'Classes/**/*.h'
  s.dependency 'Flutter'
  s.platform = :ios, '12.1'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
    # Mobile Push Addition
  # s.vendored_frameworks = 'AcousticMobilePushNotification.xcframework'
  s.preserve_paths = 'AcousticMobilePushNotification.xcframework/**/*'
  s.xcconfig = { 'OTHER_LDFLAGS' => ''}
  s.requires_arc = false

end