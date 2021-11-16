platform :ios, '13.0'
use_frameworks!

def pods
  pod 'MaterialComponents/Tabs+TabBarView', '124.2.0'
  pod 'RealmSwift', '10.19.0'
  pod 'SwiftCBOR', '0.4.4'
end

target 'Mock' do
  use_frameworks!

  # Pods for ConcordiumWallet
  pods
  target 'ConcordiumWalletTests' do
    inherit! :search_paths
    # Pods for testing
  end

end

target 'StagingNet' do
  use_frameworks!

  # Pods for "MOCK ConcordiumWallet"
  pods
end

target 'ProdTestNet' do
  use_frameworks!

  # Pods for "MOCK ConcordiumWallet"
  pods
end

target 'ProdMainNet' do
  use_frameworks!

  # Pods for "MOCK ConcordiumWallet"
  pods
end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['DEBUG_INFORMATION_FORMAT'] = 'dwarf'
            config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'
        end
    end
end
