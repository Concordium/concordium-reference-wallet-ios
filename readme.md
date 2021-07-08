# Concordium Mobile Wallet 

**Concordium** 
is a science-based proof-of-stake blockchain, the first in the world with identification built into the protocol and designed to meet regulatory requirements.
**Concordium Mobile Wallet App** is a free and open-source app reference implementation for iPhone 13.0+ devices. 
## App Store
You can download the latest version on [App Store](https://apps.apple.com/us/app/concordium-mobile-wallet/id1566996491) 
## Getting started

1. Install Xcode from the Mac App Store.
2. Clone this repository.
3. Install and run cocoapods:

	`sudo gem install cocoapods`
	
	`pod install`
    
4. Run `brew install swiftlint` to install swiftlint. 
5. Install quicktype from [quicktype.io](https://quicktype.io) to generate models and serializers from JSON.
6. Install Xcode template for creating MVP files:

	open folder in project `cd Scripts/Swift-MVP-Template`

	and run `swift install.swift`
	
	Learn more about [MVP tempate](https://github.com/khacchan/Swift-MVP-Module)
7. Open `ConcordiumWallet.xcworkspace` in Xcode. 

### Following targets can be selected:

**mock**: Allows the app to use mocked data

**localhost**: Allows the app to use a local server

**staging**: Will make the app run against the staging server

**prodTestNet**: Will make the app run against the TestNet server

**prodMainNet**: Will make the app run against the MainNet production server

## License
```
Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at
http://www.apache.org/licenses/LICENSE-2.0
Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```
See the full license [here](LICENSE-APACHE.txt)
