# Uncomment the next line to define a global platform for your project
install! 'cocoapods', :warn_for_unused_master_specs_repo => false

target 'iOSApp' do
  platform :ios, '16.0'
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for iOSSauronPlayer
  pod 'ffmpeg-kit-ios-full', '~> 5.1'
  pod 'SnapKit', '~> 5.6.0'
  
#  pod 'OpenCV', '~> 4.3.0'
  
end

target 'macOSApp' do
  platform :osx, '13.0'
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for macOSSauronPlayer
  pod 'ffmpeg-kit-macos-full', '~> 5.1'
  pod 'SnapKit', '~> 5.6.0'
end

#修复M1芯片 模拟器运行， 之后如需在真机上运行需注释pod install一下。
#post_install do |installer|
#  installer.pods_project.build_configurations.each do |config|
#    config.build_settings["EXCLUDED_ARCHS[sdk=iphonesimulator*]"] = "arm64"
#  end
#end
