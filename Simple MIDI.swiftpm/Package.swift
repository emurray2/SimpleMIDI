// swift-tools-version: 5.5

// WARNING:
// This file is automatically generated.
// Do not edit it by hand because the contents will be replaced.

import PackageDescription
import AppleProductTypes

let package = Package(
    name: "Simple MIDI",
    platforms: [
        .iOS("15.2")
    ],
    products: [
        .iOSApplication(
            name: "Simple MIDI",
            targets: ["AppModule"],
            bundleIdentifier: "io.auraaudio.simple-midi",
            teamIdentifier: "6CV59M265C",
            displayVersion: "1.0.0",
            bundleVersion: "4",
            iconAssetName: "AppIcon",
            accentColorAssetName: "AccentColor",
            supportedDeviceFamilies: [
                .pad,
                .phone
            ],
            supportedInterfaceOrientations: [
                .portrait,
                .landscapeRight,
                .landscapeLeft,
                .portraitUpsideDown(.when(deviceFamilies: [.phone]))
            ]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/AudioKit/AudioKit", "5.3.0"..<"6.0.0")
    ],
    targets: [
        .executableTarget(
            name: "AppModule",
            dependencies: [
                .product(name: "AudioKit", package: "AudioKit")
            ],
            path: ".",
            resources: [
                .process("Resources")
            ]
        )
    ]
)