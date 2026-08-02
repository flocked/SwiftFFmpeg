// swift-tools-version:5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "SwiftFFmpeg",
  products: [
    .library(
      name: "SwiftFFmpeg",
      targets: ["SwiftFFmpeg"]
    )
  ],
  targets: [
    .binaryTarget(
      name: "FFmpegMacOS",
      url: "https://github.com/flocked/SwiftFFmpeg/releases/download/XCFrameworks/FFmpeg-macOS.xcframework.zip",
      checksum: "ba9899c6a40455b53927ef1ab1dbb435a27336e016486ebae43f7470e93bb1cf"
    ),
    .binaryTarget(
      name: "FFmpegIOS",
      url: "https://github.com/flocked/SwiftFFmpeg/releases/download/XCFrameworks/FFmpeg-iOS.xcframework.zip",
      checksum: "9b34f1325b86cae4c86e028abfa41458029846bfd2244fc1f42503de15b72e9a"
    ),
    .binaryTarget(
      name: "FFmpegTVOS",
      url: "https://github.com/flocked/SwiftFFmpeg/releases/download/XCFrameworks/FFmpeg-tvOS.xcframework.zip",
      checksum: "c071bfaf8a8dd3b03c4ced1277277a357f68b7f5dfad9bca1df956fcaa91893b"
    ),
    .binaryTarget(
      name: "FFmpegWatchOS",
      url: "https://github.com/flocked/SwiftFFmpeg/releases/download/XCFrameworks/FFmpeg-watchOS.xcframework.zip",
      checksum: "9f07846ce821d6ccaaa2da66c54130884742483d53590fa9d4fddaed323735d6"
    ),
    .binaryTarget(
      name: "FFmpegVisionOS",
      url: "https://github.com/flocked/SwiftFFmpeg/releases/download/XCFrameworks/FFmpeg-visionOS.xcframework.zip",
      checksum: "26c3c2a60e80641f49d5b9410a93e2072a07dbe2dc60a6057c7cb3e32ca65e99"
    ),
    .target(
      name: "CFFmpeg",
      dependencies: [
        .target(name: "FFmpegMacOS", condition: .when(platforms: [.macOS])),
        .target(name: "FFmpegIOS", condition: .when(platforms: [.iOS])),
        .target(name: "FFmpegTVOS", condition: .when(platforms: [.tvOS])),
        .target(name: "FFmpegWatchOS", condition: .when(platforms: [.watchOS])),
        .target(name: "FFmpegVisionOS", condition: .when(platforms: [.visionOS])),
      ],
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
