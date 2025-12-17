# Uncomment the next line to define a global platform for your project
 platform :ios, '16.0'

target 'ThankYouList' do
  use_frameworks!

  # Calendar
  pod 'JTAppleCalendar', '~> 7.0'

  # Auth
  pod 'GoogleSignIn', '7.0.0'

  # SkeletonView
  pod 'SkeletonView', '1.25.1'

  # SDWebImage
  pod 'SDWebImage', '~> 5.0'

  # FloatingPanel
  pod 'FloatingPanel', '2.5.5'

  target 'ThankYouListTests' do
      inherit! :search_paths
    end
end

post_install do | installer |
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '16.0'
        end
    end
end
