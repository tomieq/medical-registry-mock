// swift-tools-version:4.0
// The swift-tools-version declares the minimum version of Swift required to build this package.
import PackageDescription

let package = Package(
    name: "MedicalRegistry",
    dependencies: [
        .package(url: "https://github.com/tomieq/swifter.git", .upToNextMajor(from: "1.5.5"))
    ],
    targets: [
        .target(
            name: "MedicalRegistry",
            dependencies: ["Swifter"],
            path: "Sources")
    ]
)
