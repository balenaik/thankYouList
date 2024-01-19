# Uncomment the next line to define a global platform for your project
 platform :ios, '14.0'

target 'ThankYouList' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods for ThankYouList
  pod 'JTAppleCalendar', '~> 7.0'

  # Firebase
  pod 'Firebase/Core', '10.19.0'
  pod 'Firebase/Database', '10.19.0'
  pod 'Firebase/Auth', '10.19.0'
  pod 'Firebase/Firestore', '10.19.0'

  # Auth
  pod 'FBSDKCoreKit', '~> 6.5.0'
  pod 'FBSDKLoginKit', '~> 6.5.0'
  pod 'GoogleSignIn', '7.0.0'

  # R.swift
  pod 'R.swift', '7.2.4'

  # Crypto
  pod 'RNCryptor', '~> 5.0'
  pod 'CryptoSwift'

  # SkeletonView
  pod 'SkeletonView', '1.25.1'

  # SDWebImage
  pod 'SDWebImage', '~> 5.0'

  # FloatingPanel
  pod 'FloatingPanel', '2.5.5'

end

target 'ThankYouListTests' do
  pod 'R.swift', '7.2.4'
end

post_install do | installer |
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '14.0'
        end
    end
end
