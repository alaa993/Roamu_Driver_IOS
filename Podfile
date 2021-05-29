# Uncomment the next line to define a global platform for your project
platform :ios, '10.0'

source 'https://github.com/CocoaPods/Specs.git'

target 'TaxiDriver' do
    use_frameworks!
    
    pod 'GoogleMaps'
    pod 'GooglePlaces'

    pod 'MapboxNavigation'

    pod 'Alamofire'
    #, '~> 4.4'
    pod 'IQKeyboardManagerSwift'
    pod 'Kingfisher'
    pod 'MBProgressHUD'
    #, '~> 1.0.0'

    pod 'Firebase'
    pod 'Firebase/Auth'
    pod 'Firebase/Core'
    pod 'Firebase/Database'
    pod 'Firebase/Storage'
    pod 'Firebase/Messaging'

    pod 'Fabric'
    pod 'Crashlytics'
    
    pod 'FirebaseUI/Phone'
    pod 'FirebaseUI/Auth'

end
post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['SWIFT_VERSION'] = '5'
        end
    end
end
