// swift-tools-version:5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "SwiftFFmpeg",
  platforms: [
    .macOS(.v11),
    .iOS(.v13),
    .tvOS(.v13),
    .watchOS(.v7),
    .visionOS(.v1),
  ],
  products: [
    .library(
      name: "SwiftFFmpeg",
      targets: ["SwiftFFmpeg"]
    )
  ],
  targets: [
    .binaryTarget(
      name: "FFmpeg",
      url: "https://github.com/flocked/ffmpeg-apple-xcframeworks/releases/download/FFmpeg-9.0/FFmpeg.xcframework.zip",
      checksum: "71ce26922179688d5e07afe42a7ac630656ba9a7766ec00d1293575d75cd1cb4"
    ),
    .target(
      name: "CFFmpeg",
      dependencies: ["FFmpeg"],
      publicHeadersPath: ".",
      linkerSettings: [
        .linkedFramework("AudioToolbox", .when(platforms: [.macOS, .iOS, .tvOS, .visionOS])),
        .linkedFramework("CoreFoundation"),
        .linkedFramework("CoreMedia"),
        .linkedFramework("CoreVideo"),
        .linkedFramework("VideoToolbox", .when(platforms: [.macOS, .iOS, .tvOS, .visionOS])),
        .linkedLibrary("bz2"),
        .linkedLibrary("iconv"),
        .linkedLibrary("z"),
      ]
    ),
    .target(
      name: "SwiftFFmpeg",
      dependencies: ["CFFmpeg"]
    ),
    .executableTarget(
      name: "Examples",
      dependencies: ["SwiftFFmpeg"]
    ),
    .testTarget(
      name: "Tests",
      dependencies: ["SwiftFFmpeg"]
    ),
  ]
)
