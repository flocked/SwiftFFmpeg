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
      url: "https://github.com/flocked/ffmpeg-apple-xcframeworks/releases/download/FFmpeg-8.1.2/FFmpeg.xcframework.zip",
      checksum: "0c9e49c16b6e332f2d20cdf314cc1f05652dc12dd64c7c3e05edbe4f56c73d4d"
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
