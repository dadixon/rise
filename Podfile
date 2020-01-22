# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'Rise' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods for Rise
  pod 'Firebase/Core'
  pod 'Firebase/Database'
  pod 'Firebase/Auth'
  pod 'SVProgressHUD'
  pod 'Eureka'

  target 'RiseTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'RiseUITests' do
    inherit! :search_paths
    # Pods for testing
  end

end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        
        if  target.name == 'Eureka'
            target.build_configurations.each do |config|
                config.build_settings['SWIFT_VERSION'] = '4.0'
            end
        end
    end
end
