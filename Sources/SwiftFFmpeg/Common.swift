//
//  CType.swift
//  SwiftFFmpeg
//
//  Created by sunlubo on 2018/7/4.
//

import CFFmpeg

// MARK: - AVMediaType

public enum AVMediaType: Int32, CustomStringConvertible {
    /// Unknown (usually treated as ``data``).
    case unknown = -1
    /// Video.
    case video
    /// Audio.
    case audio
    /// Opaque data information usually continuous
    case data
    /// Subtitle.
    case subtitle
    /// Opaque data information usually sparse
    case attachment

    var native: CFFmpeg.AVMediaType {
        CFFmpeg.AVMediaType(rawValue)
    }

    init(native: CFFmpeg.AVMediaType) {
        guard let type = AVMediaType(rawValue: native.rawValue) else {
            fatalError("Unknown media type: \(native)")
        }
        self = type
    }
    
    public var description: String {
        switch self {
        case .video: "video"
        case .audio: "audio"
        case .data: "data"
        case .subtitle: "subtitle"
        case .attachment: "attachment"
        case .unknown: "unknown"
        }
    }
}
public enum FFmpeg {
    /// Do global initialization of network libraries.
    /// This is optional, and not recommended anymore.
    ///
    /// This functions only exists to work around thread-safety issues
    /// with older GnuTLS or OpenSSL libraries. If libavformat is linked
    /// to newer versions of those libraries, or if you do not use them,
    /// calling this function is unnecessary. Otherwise, you need to call
    /// this function before any other threads using them are started.
    ///
    /// This function will be deprecated once support for older GnuTLS and
    /// OpenSSL libraries is removed, and this function has no purpose
    /// anymore.
    public static func networkInit() throws {
        try avformat_network_init().throwIfFail()
    }

    /// Undo the initialization done by `networkInit()`.
    /// Call it only once for each time you called `networkInit()`.
    public static func networkDeinit() {
        avformat_network_deinit()
    }
}
