//
//  AVFormat.swift
//  SwiftFFmpeg
//
//  Created by sunlubo on 2019/1/16.
//

import CFFmpeg

// MARK: - AVInputFormat

typealias CAVInputFormat = CFFmpeg.AVInputFormat

public struct AVInputFormat {
    var native: UnsafePointer<CAVInputFormat>

    init(native: UnsafePointer<CAVInputFormat>) {
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
        String(cString: native.pointee.name).components(separatedBy: ",")
    }

    /// The human-readable name of the format.
    public var longName: String {
        String(cString: native.pointee.long_name)
    }

    /// The filename extensions supported by the format.
    public var extensions: [String] {
        String(cString: native.pointee.extensions)?.components(separatedBy: ",") ?? []
    }

    /// The MIME types supported by the format.
    public var mimeTypes: [String] {
        String(cString: native.pointee.mime_type)?.components(separatedBy: ",") ?? []
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
    struct Flag: OptionSet, Hashable {
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
    }
}

// MARK: - AVInputFormat.Flag + CustomStringConvertible

extension AVInputFormat.Flag: CustomStringConvertible, CustomDebugStringConvertible {
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

// MARK: - AVInputFormat + AVOptionSupport

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
    
    /// Find `AVOutputFormat` based on the short name of the output format.
    ///
    /// - Parameter name: name of the input format
    public init?(name: String) {
        guard let ptr = av_guess_format(name, nil, nil) else {
            return nil
        }
        self.init(native: ptr)
    }
    
    /// The name of the format.
    public var name: String {
        String(cString: native.pointee.name)
    }
    
    /// The human-readable name of the format.
    public var longName: String {
        String(cString: native.pointee.long_name)
    }
    
    /// The filename extensions supported by the format.
    public var extensions: [String] {
        String(cString: native.pointee.extensions)?.components(separatedBy: ",") ?? []
    }
    
    /// The MIME types supported by the format.
    public var mimeTypes: [String] {
        String(cString: native.pointee.mime_type)?.components(separatedBy: ",") ?? []
    }
    
    /// The default audio codec of the format.
    public var audioCodec: AVCodecID {
        AVCodecID(native: native.pointee.audio_codec)
    }
    
    /// The default video codec of the format.
    public var videoCodec: AVCodecID {
        AVCodecID(native: native.pointee.video_codec)
    }
    
    /// The default subtitle codec of the format.
    public var subtitleCodec: AVCodecID {
        AVCodecID(native: native.pointee.subtitle_codec)
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
}

// MARK: - AVOutputFormat.Flag

public extension AVOutputFormat {
    /// Flags used by `flags`.
    struct Flag: OptionSet, Hashable {
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
    }
}

// MARK: - AVOutputFormat.Flag + CustomStringConvertible

extension AVOutputFormat.Flag: CustomStringConvertible, CustomDebugStringConvertible {
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

// MARK: - AVOutputFormat + AVOptionSupport

extension AVOutputFormat: AVOptionSupport {
    public func withUnsafeObjectPointer<T>(_ body: (UnsafeMutableRawPointer) throws -> T) rethrows -> T {
        var tmp = native.pointee.priv_class
        return try withUnsafeMutablePointer(to: &tmp) { ptr in
            try body(ptr)
        }
    }
}
