
platform :ios, '8.0'

inhibit_all_warnings!
use_frameworks!

target 'RacTest' do
  pod 'AFNetworking', '~> 3.1.0'
  pod 'Typhoon', '~> 3.3.0'
  pod 'ReactiveCocoa', '~> 2.5'
  pod 'Masonry', '~> 0.6.3'
  pod 'Toast'
  pod 'YYKit'
  pod 'CXAlertView'
  pod 'FMDB'
  pod 'WebViewJavascriptBridge'
  pod 'FCUUID'
  pod 'TMCache'
  pod 'RFRotate'
  pod 'MJRefresh'
  pod 'M13BadgeView'
  pod 'CocoaSecurity'
  pod 'EAIntroView'
  pod 'MBProgressHUD'
  pod 'UMengAnalytics'
  pod 'UMengSocial'
  pod 'Bugly'
  pod 'IQKeyboardManager'
  pod 'NJKWebViewProgress'
  pod 'SDCycleScrollView'
  pod 'tingyunApp'
  pod 'CocoaMQTT'
end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['SWIFT_VERSION'] = '3.0'
        end
    end
end
