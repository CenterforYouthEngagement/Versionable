// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

/*
 We're using a 2 target structure:
    1. Versionable - contains the protocol `Versionable` and it's associated fuctionality
    2. VersionableTests - contains the testing "abstract" class that is to be subclassed in consuming apps/packages to test `Versionable` conforming model objects.
 This 2 target approach is necessary as `.xcodeproj` files can't import XCTest in their main app target and therefore the "abstract" test class can't be inside `Versionable` (which is the target improted in `.xcodeproj`s). We can't keep the default `testTarget` for `VersionableTests` since we struggled with importing `VersionableTests` in other package's test targets with that configuration.
 For this reason, we have the 2 regular targets and 2 products associated with these targets:
    1. Target: Versionable & Product: Versionable - imported into `.xcodeproj` and other SwiftPM Packages
    2. Target: VersionableTests & Product: VersionableTestingUtilities (Xcode gave us a better time when names were different) - improted into `.xcodeproj`'s and SwiftPM Package test targets
 */

let package = Package(
    name: "Versionable",
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "Versionable",
            targets: ["Versionable"]),
        .library(
            name: "VersionableTestingUtilities",
            targets: ["VersionableTests"])
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "Versionable",
            dependencies: []),
        .target(
            name: "VersionableTests",
            dependencies: ["Versionable"],
            path: "Tests/"),
    ]
)
