# Project setup
- install and run cocoapods:
     
      sudo gem install cocoapods
      pod install 
    
- install swiftlint:

      brew install swiftlint

- install quicktype from quicktype.io

- install Xcode template for creating MVP files:

      cd Scripts/Swift-MVP-Template
      swift install.swift

- install fastlane:

    https://docs.fastlane.tools/getting-started/ios/setup/

# Deployment to Test Flight

To deploy the app to test flight, run the following command:

    fastlane beta
