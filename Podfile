platform :ios, '17.0'

target 'lich-plus' do
  pod 'VietnameseLunar'
  pod 'GoogleSignIn', '~> 7.0'
  pod 'MSAL', '~> 1.3'

  target 'lich-plusTests' do
    inherit! :search_paths
  end
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '17.0'
    end
  end
  installer.generated_projects.each do |project|
    project.targets.each do |target|
      target.build_configurations.each do |config|
        config.build_settings['ENABLE_USER_SCRIPT_SANDBOXING'] = 'NO'
      end
    end
  end
end
