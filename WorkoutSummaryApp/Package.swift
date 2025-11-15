// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "WorkoutSummaryApp",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "WorkoutSummaryApp",
            targets: ["WorkoutSummaryApp"]),
    ],
    dependencies: [
        // No external dependencies - keeping it simple
    ],
    targets: [
        .target(
            name: "WorkoutSummaryApp",
            dependencies: [],
            path: "WorkoutSummaryApp/WorkoutSummaryApp",
            exclude: ["Info.plist", "WorkoutSummaryApp.entitlements"]),
        .testTarget(
            name: "WorkoutSummaryAppTests",
            dependencies: ["WorkoutSummaryApp"],
            path: "WorkoutSummaryApp/WorkoutSummaryAppTests"),
    ]
)
