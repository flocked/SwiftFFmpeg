//
//  AVStream.swift
//  SwiftFFmpeg
//
//  Created by sunlubo on 2018/6/29.
//

import CFFmpeg
import Foundation

// MARK: - AVDiscard

public enum AVDiscard: Int32 {
    /// discard nothing
    case none = -16
    /// discard useless packets like 0 size packets in avi
    case `default` = 0
    /// discard all non reference
    case nonRef = 8
    /// discard all bidirectional frames
    case bidir = 16
    /// discard all non intra frames
    case nonIntra = 24
    /// discard all frames except keyframes
    case nonKey = 32
    /// discard all
    case all = 48
    
    var native: CFFmpeg.AVDiscard {
        CFFmpeg.AVDiscard(rawValue)
    }
    
    init(native: CFFmpeg.AVDiscard) {
        guard let discard = AVDiscard(rawValue: native.rawValue) else {
            fatalError("Unknown discard: \(native)")
        }
        self = discard
    }
}

// MARK: - AVStream

typealias CAVStream = CFFmpeg.AVStream

/// Stream structure.
public final class AVStream {
    let native: UnsafeMutablePointer<CAVStream>
    
    init(native: UnsafeMutablePointer<CAVStream>) {
        self.native = native
    }
    
    /// Stream index in `AVFormatContext`.
    public var index: Int {
        Int(native.pointee.index)
    }
    
    /// Format-specific stream ID.
    ///
    /// - encoding: Set by the user, replaced by libavformat if left unset.
    /// - decoding: Set by libavformat.
    public var id: Int32 {
        get { native.pointee.id }
        set { native.pointee.id = newValue }
    }
    
    /// This is the fundamental unit of time (in seconds) in terms of which frame timestamps are represented.
    ///
    /// - encoding: May be set by the caller before `AVFormatContext.writeHeader(options:)` to provide a hint
    ///   to the muxer about the desired timebase. In `AVFormatContext.writeHeader(options:)`, the muxer will
    ///   overwrite this field with the timebase that will actually be used for the timestamps written into the
    ///   file (which may or may not be related to the user-provided one, depending on the format).
    /// - decoding: Set by libavformat.
    public var timebase: AVRational {
        get { native.pointee.time_base }
        set { native.pointee.time_base = newValue }
    }
    
    /// pts of the first frame of the stream in presentation order, in stream timebase.
    public var startTime: Int64 {
        native.pointee.start_time
    }
    
    /// The presentation time of the first frame in seconds, or `nil` if it is unknown.
    public var startTimeSeconds: TimeInterval? {
        guard startTime != AVTimestamp.noPTS else { return nil }
        return Double(startTime) * timebase.toDouble
    }
    
    public var duration: Int64 {
        native.pointee.duration
    }
    
    /// The stream duration in seconds, or `nil` if it is unknown.
    public var durationSeconds: TimeInterval? {
        guard duration != AVTimestamp.noPTS else { return nil }
        return Double(duration) * timebase.toDouble
    }
    
    /// Number of frames in this stream if known or 0.
    public var frameCount: Int {
        Int(native.pointee.nb_frames)
    }
    
    /// Selects which packets can be discarded at will and do not need to be demuxed.
    public var discard: AVDiscard {
        get { AVDiscard(native: native.pointee.discard) }
        set { native.pointee.discard = newValue.native }
    }
    
    /// sample aspect ratio (0 if unknown)
    ///
    /// - encoding: Set by user.
    /// - decoding: Set by libavformat.
    /// The sample aspect ratio of the stream, or `nil` if unknown.
    public var sampleAspectRatio: AVRational? {
        get {
            let ratio = native.pointee.sample_aspect_ratio
            return ratio.num != 0 ? ratio : nil
        }
        set { native.pointee.sample_aspect_ratio = newValue ?? AVRational(num: 0, den: 1) }
    }
    
    /// The metadata of the stream.
    public var metadata: [String: String] {
        get { native.pointee.metadata?.avDict ?? [:] }
        set { native.pointee.metadata.replace(with: newValue) }
    }
    
    /// Returns the metadata value for the specified key.
    public func metadata(for key: AVMetadataKey) -> String? {
        metadata[key.rawValue]
    }
    
    /**
     The average frame rate of the stream, or `nil` if unknown.

     When demuxing, this value may be determined by libavformat; when muxing, it may be set before writing the header.
     */
    public var averageFrameRate: AVRational? {
        get {
            let frameRate = native.pointee.avg_frame_rate
            return frameRate.num != 0 ? frameRate : nil
        }
        set { native.pointee.avg_frame_rate = newValue ?? AVRational(num: 0, den: 1) }
    }
    
    /// The average frame rate as frames per second, or `nil` if it is unknown.
    public var averageFrameRateFps: Double? {
        guard let frameRate = averageFrameRate, frameRate.den != 0 else { return nil }
        return frameRate.toDouble
    }
    
    /**
     The lowest frame rate with which all timestamps in the stream can be represented accurately, or `nil` if unknown.

     This value is estimated by libavformat and may not represent the actual average frame rate.
     */
    public var realFrameRate: AVRational? {
        let frameRate = native.pointee.r_frame_rate
        return frameRate.num != 0 ? frameRate : nil
    }
    
    /// The real base frame rate as frames per second, or `nil` if it is unknown.
    public var realFrameRateFps: Double? {
        guard let frameRate = realFrameRate, frameRate.den != 0 else { return nil }
        return frameRate.toDouble
    }
    
    /// Codec parameters associated with this stream.
    ///
    /// - demuxing: Filled by libavformat on stream creation or in `AVFormatContext.findStreamInfo(options:)`.
    /// - muxing: Filled by the caller before `AVFormatContext.writeHeader(options:)`.
    public var codecParameters: AVCodecParameters {
        AVCodecParameters(native: native.pointee.codecpar)
    }
    
    /// The media type of the stream.
    public var mediaType: AVMediaType {
        codecParameters.mediaType
    }
    
    /// The disposition flags that describe the stream's intended use and characteristics, such as default, forced, caption, or attached picture flags.
    public var disposition: AVStreamDisposition {
        get { AVStreamDisposition(rawValue: native.pointee.disposition) }
        set { native.pointee.disposition = newValue.rawValue }
    }
    
    /// The stream language metadata, usually an ISO 639 language code such as `eng`, or `nil` if unavailable.
    public var language: String? { metadata["language"] }
    /// The stream title metadata, or `nil` if unavailable.
    public var title: String? { metadata["title"] }
    /// The stream handler name metadata, or `nil` if unavailable.
    public var handlerName: String? { metadata["handler_name"] }
}

import Foundation

extension AVStream {
    public func matches(locale: Locale) -> Bool {
        guard let languageCode = metadata["language"]?.trimmingCharacters(in: .whitespacesAndNewlines).lowercased(), !languageCode.isEmpty, languageCode != "und" else {
            return false
        }
        guard let localeLanguageCode = locale.languageCode?.lowercased() else {
            return false
        }
        guard let streamLanguageName = Self.referenceLocale.localizedString(forLanguageCode: languageCode)?.lowercased(), let localeLanguageName = Self.referenceLocale.localizedString(forLanguageCode: localeLanguageCode)?.lowercased() else {
            return false
        }
        return streamLanguageName == localeLanguageName
    }
    private static let referenceLocale = Locale(identifier: "en")
}


extension AVFormatContext {
    /// Returns streams whose language metadata matches the specified locale.
    public func streams(matching locale: Locale) -> [AVStream] {
        streams.filter { $0.matches(locale: locale) }
    }
    
    /// Returns streams of the specified media type whose language metadata matches the specified locale.
    public func streams(matching locale: Locale, mediaType: AVMediaType) -> [AVStream] {
        streams.filter { $0.mediaType == mediaType && $0.matches(locale: locale) }
    }
}
