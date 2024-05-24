

In Terminal cd to the root folder of the Framework project

Archive for iOS

xcodebuild archive \
-scheme BadElfSdk \
-configuration Release \
-destination 'generic/platform=iOS' \
-archivePath './build/BadElfSdk.framework-iphoneos.xcarchive' \
SKIP_INSTALL=NO \
BUILD_LIBRARY_FOR_DISTRIBUTION=YES


Archive for Simulator

xcodebuild archive \
-scheme BadElfSdk \
-configuration Release \
-destination 'generic/platform=iOS Simulator' \
-archivePath './build/BadElfSdk.framework-iphonesimulator.xcarchive' \
SKIP_INSTALL=NO \
BUILD_LIBRARY_FOR_DISTRIBUTION=YES


Archive for macOS

xcodebuild archive \
-scheme BadElfSdk \
-configuration Release \
-destination 'platform=macOS,arch=x86_64,variant=Mac Catalyst' \
-archivePath './build/BadElfSdk.framework-catalyst.xcarchive' \
SKIP_INSTALL=NO \
BUILD_LIBRARY_FOR_DISTRIBUTION=YES


Create Framework

xcodebuild -create-xcframework \
-framework './build/BadElfSdk.framework-iphonesimulator.xcarchive/Products/Library/Frameworks/BadElfSdk.framework' \
-framework './build/BadElfSdk.framework-iphoneos.xcarchive/Products/Library/Frameworks/BadElfSdk.framework' \
-framework './build/BadElfSdk.framework-catalyst.xcarchive/Products/Library/Frameworks/BadElfSdk.framework' \
-output './build/BadElfSdk.xcframework'

All in one

xcodebuild archive \
-scheme BadElfSdk \
-configuration Release \
-destination 'generic/platform=iOS' \
-archivePath './build/BadElfSdk.framework-iphoneos.xcarchive' \
SKIP_INSTALL=NO \
BUILD_LIBRARY_FOR_DISTRIBUTION=YES
xcodebuild archive \
-scheme BadElfSdk \
-configuration Release \
-destination 'generic/platform=iOS Simulator' \
-archivePath './build/BadElfSdk.framework-iphonesimulator.xcarchive' \
SKIP_INSTALL=NO \
BUILD_LIBRARY_FOR_DISTRIBUTION=YES
xcodebuild archive \
-scheme BadElfSdk \
-configuration Release \
-destination 'platform=macOS,arch=x86_64,variant=Mac Catalyst' \
-archivePath './build/BadElfSdk.framework-catalyst.xcarchive' \
SKIP_INSTALL=NO \
BUILD_LIBRARY_FOR_DISTRIBUTION=YES
xcodebuild -create-xcframework \
-framework './build/BadElfSdk.framework-iphonesimulator.xcarchive/Products/Library/Frameworks/BadElfSdk.framework' \
-framework './build/BadElfSdk.framework-iphoneos.xcarchive/Products/Library/Frameworks/BadElfSdk.framework' \
-framework './build/BadElfSdk.framework-catalyst.xcarchive/Products/Library/Frameworks/BadElfSdk.framework' \
-output './build/BadElfSdk.xcframework'

Once you build your Unity Project you will need to update the info.plist by adding these values 

    <key>UISupportedExternalAccessoryProtocols</key>
    <array>
      <string>com.bad-elf.gnss</string>
      <string>com.bad-elf.gps</string>
    </array>

    <key>UIBackgroundModes</key>
    <array>
      <string>external-accessory</string>
    </array>
