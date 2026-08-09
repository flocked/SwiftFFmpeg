//
//  AVFormat.swift
//  SwiftFFmpeg
//
//  Created by sunlubo on 2019/1/16.
//

import CFFmpeg
import Foundation
import UniformTypeIdentifiers

// MARK: - AVInputFormat

public struct AVInputFormat {
    var native: UnsafePointer<CFFmpeg.AVInputFormat>

    init(native: UnsafePointer<CFFmpeg.AVInputFormat>) {
        self.native = native
    }
    
    /// Creates an input format with the specified short name.
    public init?(name: String) {
        guard let ptr = av_find_input_format(name) else {
            return nil
        }
        self.init(native: ptr)
    }

    /// The short name of the format.
    public var name: String {
        names[safe: 0] ?? "unknown"
    }
    
    /// The short names of the format.
    public var names: [String] {
        native.pointee.name.string.components(separatedBy: ",")
    }

    /// The human-readable name of the format.
    public var longName: String {
        native.pointee.long_name.string
    }

    /// The filename extensions supported by the format.
    public var extensions: [String] {
        native.pointee.extensions?.string.components(separatedBy: ",") ?? []
    }

    /// The MIME types supported by the format.
    public var mimeTypes: [String] {
        native.pointee.mime_type?.string.components(separatedBy: ",") ?? []
    }

    /// The flags of the input format.
    public var flags: Flag {
        Flag(rawValue: native.pointee.flags)
    }

    /// The class for the private format context.
    public var privClass: AVClass? {
        native.pointee.priv_class.map(AVClass.init(native:))
    }

    /// All registered input formats.
    public static var registeredFormats: [AVInputFormat] {
        var list = [AVInputFormat]()
        var state: UnsafeMutableRawPointer?
        while let ptr = av_demuxer_iterate(&state) {
            list.append(AVInputFormat(native: ptr.mutable))
        }
        return list
    }
}

// MARK: - AVInputFormat.Flag

public extension AVInputFormat {
    struct Flag: OptionSet, Hashable, CustomStringConvertible, CustomDebugStringConvertible {
        /// Demuxer will use avio_open, no opened file should be provided by the caller.
        public static let noFile = Flag(rawValue: AVFMT_NOFILE)
        /// Needs '%d' in filename.
        public static let needNumber = Flag(rawValue: AVFMT_NEEDNUMBER)
        /// Show format stream IDs numbers.
        public static let showIDs = Flag(rawValue: AVFMT_SHOW_IDS)
        /// Use generic index building code.
        public static let genericIndex = Flag(rawValue: AVFMT_GENERIC_INDEX)
        /// Format allows timestamp discontinuities. Note, muxers always require valid (monotone) timestamps.
        public static let tsDiscont = Flag(rawValue: AVFMT_TS_DISCONT)
        /// Format does not allow to fall back on binary search via read_timestamp.
        public static let noBinSearch = Flag(rawValue: AVFMT_NOBINSEARCH)
        /// Format does not allow to fall back on generic search.
        public static let noGenSearch = Flag(rawValue: AVFMT_NOGENSEARCH)
        /// Format does not allow seeking by bytes.
        public static let noByteSeek = Flag(rawValue: AVFMT_NO_BYTE_SEEK)
        /// Seeking is based on PTS.
        public static let seekToPTS = Flag(rawValue: AVFMT_SEEK_TO_PTS)
        
        public let rawValue: Int32
        
        public init(rawValue: Int32) {
            self.rawValue = rawValue
        }
        
        public var description: String {
            "[\(elements().map { Self.names[$0]?.swift ?? "\($0.rawValue)" }.joined(separator: ", "))]"
        }
        
        public var debugDescription: String {
            "[\(elements().map { Self.names[$0]?.native ?? "\($0.rawValue)" }.joined(separator: ", "))]"
        }
        
        private static let names: [Self: (swift: String, native: String)] = [
            .noFile: ("noFile", "AVFMT_NOFILE"),
            .needNumber: ("needNumber", "AVFMT_NEEDNUMBER"),
            .showIDs: ("showIDs", "AVFMT_SHOW_IDS"),
            .genericIndex: ("genericIndex", "AVFMT_GENERIC_INDEX"),
            .tsDiscont: ("tsDiscont", "AVFMT_TS_DISCONT"),
            .noBinSearch: ("noBinSearch", "AVFMT_NOBINSEARCH"),
            .noGenSearch: ("noGenSearch", "AVFMT_NOGENSEARCH"),
            .noByteSeek: ("noByteSeek", "AVFMT_NO_BYTE_SEEK"),
            .seekToPTS: ("seekToPTS", "AVFMT_SEEK_TO_PTS"),
        ]
    }
}

extension AVInputFormat: AVOptionSupport {
    public func withUnsafeObjectPointer<T>(_ body: (UnsafeMutableRawPointer) throws -> T) rethrows -> T {
        var tmp = native.pointee.priv_class
        return try withUnsafeMutablePointer(to: &tmp) { ptr in
            try body(ptr)
        }
    }
}

// MARK: - AVOutputFormat

public struct AVOutputFormat {
    var native: UnsafePointer<CFFmpeg.AVOutputFormat>
    
    init(native: UnsafePointer<CFFmpeg.AVOutputFormat>) {
        self.native = native
    }
    
    /// Creates an ountput format with the specified short name.
    public init?(name: String) {
        guard let ptr = av_guess_format(name, nil, nil) else {
            return nil
        }
        self.init(native: ptr)
    }
    
    public init?(fileExtension: String) {
        self.init(fileName: "file.\(fileExtension)")
    }
    
    public init?(fileName: String) {
        guard let ptr = av_guess_format(nil, fileName, nil) else {
            return nil
        }
        self.init(native: ptr)
    }
    
    public init?(url: URL) {
        self.init(fileName: url.pathOrURLString)
    }
    
    public init?(contentType: UTType) {
        let fileName = contentType.preferredFilenameExtension.map { "file.\($0)" }
        guard let mime = contentType.preferredMIMEType, let ptr = av_guess_format(nil, fileName, mime) else {
            return nil
        }
        self.init(native: ptr)
    }
    
    /// The short name of the format.
    public var name: String {
        names[safe: 0] ?? "unknown"
    }
    
    /// The short names of the format.
    public var names: [String] {
        native.pointee.name.string.components(separatedBy: ",")
    }
    
    /// The human-readable name of the format.
    public var longName: String {
        native.pointee.long_name.string
    }
    
    /// The filename extensions supported by the format.
    public var filenameExtensions: [String] {
        native.pointee.extensions?.string.components(separatedBy: ",") ?? []
    }
    
    /// The MIME types supported by the format.
    public var mimeTypes: [String] {
        native.pointee.mime_type?.string.components(separatedBy: ",") ?? []
    }
    
    /// The default audio codec of the format.
    public var audioCodec: AVCodecID? {
        AVCodecID(native: native.pointee.audio_codec).nonNil
    }
    
    /// The default video codec of the format.
    public var videoCodec: AVCodecID? {
        AVCodecID(native: native.pointee.video_codec).nonNil
    }
    
    /// The default subtitle codec of the format.
    public var subtitleCodec: AVCodecID? {
        AVCodecID(native: native.pointee.subtitle_codec).nonNil
    }
    
    /// The flags of the output format.
    public var flags: Flag {
        Flag(rawValue: native.pointee.flags)
    }
    
    /// The class for the private format context.
    public var privClass: AVClass? {
        native.pointee.priv_class.map(AVClass.init(native:))
    }
    
    /// Returns the preferred codec tag for the specified codec identifier.
    public func codecTag(for codecID: AVCodecID) -> UInt32? {
        let tag = av_codec_get_tag(native.pointee.codec_tag, codecID.native)
        return tag != 0 ? tag : nil
    }

    /// All registered output formats.
    public static var registeredFormats: [AVOutputFormat] {
        var list = [AVOutputFormat]()
        var state: UnsafeMutableRawPointer?
        while let ptr = av_muxer_iterate(&state) {
            list.append(AVOutputFormat(native: ptr.mutable))
        }
        return list
    }
    
    /// Returns a Boolean value indicating whether the output format supports the specified codec.
    public func supports(_ codecID: AVCodecID) -> Bool {
        avformat_query_codec(native, codecID.native, FF_COMPLIANCE_NORMAL) > 0
    }
}

// MARK: - AVOutputFormat.Flag

public extension AVOutputFormat {
    /// Flags used by `flags`.
    struct Flag: OptionSet, Hashable, CustomStringConvertible, CustomDebugStringConvertible {
        /// Muxer will use avio_open, no opened file should be provided by the caller.
        public static let noFile = Flag(rawValue: AVFMT_NOFILE)
        /// Needs '%d' in filename.
        public static let needNumber = Flag(rawValue: AVFMT_NEEDNUMBER)
        /// Format wants global header.
        public static let globalHeader = Flag(rawValue: AVFMT_GLOBALHEADER)
        /// Format does not need / have any timestamps.
        public static let noTimestamps = Flag(rawValue: AVFMT_NOTIMESTAMPS)
        /// Format allows variable fps.
        public static let variableFPS = Flag(rawValue: AVFMT_VARIABLE_FPS)
        /// Format does not need width/height.
        public static let noDimensions = Flag(rawValue: AVFMT_NODIMENSIONS)
        /// Format does not require any streams.
        public static let noStreams = Flag(rawValue: AVFMT_NOSTREAMS)
        /// Format does not require strictly increasing timestamps, but they must still be monotonic.
        public static let tsNonstrict = Flag(rawValue: AVFMT_TS_NONSTRICT)
        /// Format allows muxing negative timestamps. If not set the timestamp will be shifted in `writeFrame` and
        /// `interleavedWriteFrame` so they start from 0.
        /// The user or muxer can override this through AVFormatContext.avoid_negative_ts.
        public static let tsNegative = Flag(rawValue: AVFMT_TS_NEGATIVE)

        public let rawValue: Int32

        public init(rawValue: Int32) {
            self.rawValue = rawValue
        }
        
        public var description: String {
            "[\(elements().map { Self.names[$0]?.swift ?? "\($0.rawValue)" }.joined(separator: ", "))]"
        }

        public var debugDescription: String {
            "[\(elements().map { Self.names[$0]?.native ?? "\($0.rawValue)" }.joined(separator: ", "))]"
        }

        private static let names: [Self: (swift: String, native: String)] = [
            .noFile: ("noFile", "AVFMT_NOFILE"),
            .needNumber: ("needNumber", "AVFMT_NEEDNUMBER"),
            .globalHeader: ("globalHeader", "AVFMT_GLOBALHEADER"),
            .noTimestamps: ("noTimestamps", "AVFMT_NOTIMESTAMPS"),
            .variableFPS: ("variableFPS", "AVFMT_VARIABLE_FPS"),
            .noDimensions: ("noDimensions", "AVFMT_NODIMENSIONS"),
            .noStreams: ("noStreams", "AVFMT_NOSTREAMS"),
            .tsNonstrict: ("tsNonstrict", "AVFMT_TS_NONSTRICT"),
            .tsNegative: ("tsNegative", "AVFMT_TS_NEGATIVE"),
        ]
    }
}

extension AVOutputFormat: AVOptionSupport {
    public func withUnsafeObjectPointer<T>(_ body: (UnsafeMutableRawPointer) throws -> T) rethrows -> T {
        var tmp = native.pointee.priv_class
        return try withUnsafeMutablePointer(to: &tmp) { ptr in
            try body(ptr)
        }
    }
}
