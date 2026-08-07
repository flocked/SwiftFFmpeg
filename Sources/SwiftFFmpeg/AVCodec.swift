//
//  Codec.swift
//  SwiftFFmpeg
//
//  Created by sunlubo on 2018/6/28.
//

import CFFmpeg

// MARK: - AVCodec

typealias CAVCodec = CFFmpeg.AVCodec

public struct AVCodec {
    var native: UnsafePointer<CAVCodec>

    /// Find a registered decoder with a matching codec ID.
    ///
    /// - Parameter codecId: id of the requested decoder
    /// - Returns: A decoder if one was found, `nil` otherwise.
    public static func decoder(for codecId: AVCodecID) -> AVCodec? {
        avcodec_find_decoder(codecId.native).map { AVCodec(native: $0) }
    }

    /// Find a registered decoder with the specified name.
    ///
    /// - Parameter name: name of the requested decoder
    /// - Returns: A decoder if one was found, `nil` otherwise.
    public static func decoder(named name: String) -> AVCodec? {
        avcodec_find_decoder_by_name(name).map { AVCodec(native: $0) }
    }

    /// Find a registered encoder with a matching codec ID.
    ///
    /// - Parameter codecId: id of the requested encoder
    /// - Returns: An encoder if one was found, `nil` otherwise.
    public static func encoder(for codecId: AVCodecID) -> AVCodec? {
        avcodec_find_encoder(codecId.native).map { AVCodec(native: $0) }
    }

    /// Find a registered encoder with the specified name.
    ///
    /// - Parameter name: name of the requested encoder
    /// - Returns: An encoder if one was found, `nil` otherwise.
    public static func encoder(named name: String) -> AVCodec? {
        avcodec_find_encoder_by_name(name).map { AVCodec(native: $0) }
    }

    /// The codec's name.
    public var name: String {
        String(cString: native.pointee.name)
    }

    /// The codec's descriptive name, meant to be more human readable than name.
    public var longName: String {
        String(cString: native.pointee.long_name)
    }
    
    /// The external wrapper backing this codec implementation, or `nil` for native libavcodec codecs.
    public var wrapperName: String? {
        String(cString: native.pointee.wrapper_name)
    }
    
    /// The class describing this codec implementation's private options, or `nil` if none exists.
    public var privateClass: AVClass? {
        native.pointee.priv_class.map { AVClass(native: $0) }
    }
    
    /// Return a name for the specified profile, if available.
    public func profileName(for profile: AVProfile) -> String? {
        av_get_profile_name(native, profile.rawValue).map { String(cString: $0) }
    }

    /// The codec's media type.
    public var mediaType: AVMediaType {
        AVMediaType(native: native.pointee.type)
    }

    /// The codec's id.
    public var id: AVCodecID {
        AVCodecID(native: native.pointee.id)
    }
    
    /// The recognized profiles for this codec, or an empty array if unknown.
    public var profiles: [AVNamedProfile] {
        guard let profiles = native.pointee.profiles else { return [] }
        var result: [AVNamedProfile] = []
        var current = profiles
        while current.pointee.profile != AV_PROFILE_UNKNOWN {
            result.append(AVNamedProfile(native: current.pointee))
            current = current.advanced(by: 1)
        }
        return result
    }

    /// The codec's capabilities.
    public var capabilities: Capabilities {
        Capabilities(rawValue: native.pointee.capabilities)
    }

    /// Returns an array of the framerates supported by the codec.
    public var supportedFramerates: [AVRational]? {
        var configs: UnsafeRawPointer?
        var count: Int32 = 0
        avcodec_get_supported_config(nil, native, AV_CODEC_CONFIG_FRAME_RATE, 0, &configs, &count)
        return configs?.withMemoryRebound(to: AVRational.self, capacity: Int(count)) { ptr in
            Array(UnsafeBufferPointer(start: ptr, count: Int(count)))
        }
    }

    /// Returns an array of the pixel formats supported by the codec.
    public var supportedPixelFormats: [AVPixelFormat]? {
        var configs: UnsafeRawPointer?
        var count: Int32 = 0
        avcodec_get_supported_config(nil, native, AV_CODEC_CONFIG_PIX_FORMAT, 0, &configs, &count)
        return configs?.withMemoryRebound(to: AVPixelFormat.self, capacity: Int(count)) { ptr in
            Array(UnsafeBufferPointer(start: ptr, count: Int(count)))
        }
    }

    /// Returns an array of the audio samplerates supported by the codec.
    public var supportedSampleRates: [Int]? {
        var configs: UnsafeRawPointer?
        var count: Int32 = 0
        avcodec_get_supported_config(nil, native, AV_CODEC_CONFIG_SAMPLE_RATE, 0, &configs, &count)
        return configs?.withMemoryRebound(to: Int32.self, capacity: Int(count)) { ptr in
            Array(UnsafeBufferPointer(start: ptr, count: Int(count))).map(Int.init(_:))
        }
    }

    /// Returns an array of the sample formats supported by the codec.
    public var supportedSampleFormats: [AVSampleFormat]? {
        var configs: UnsafeRawPointer?
        var count: Int32 = 0
        avcodec_get_supported_config(nil, native, AV_CODEC_CONFIG_SAMPLE_FORMAT, 0, &configs, &count)
        return configs?.withMemoryRebound(to: Int32.self, capacity: Int(count)) { ptr in
            Array(UnsafeBufferPointer(start: ptr, count: Int(count))).compactMap(AVSampleFormat.init(rawValue:))
        }
    }

    /// Returns an array of the channel layouts supported by the codec.
    public var supportedChannelLayouts: [AVChannelLayout]? {
        var configs: UnsafeRawPointer?
        var count: Int32 = 0
        avcodec_get_supported_config(nil, native, AV_CODEC_CONFIG_CHANNEL_LAYOUT, 0, &configs, &count)
        return configs?.withMemoryRebound(to: AVChannelLayout.self, capacity: Int(count)) { ptr in
            Array(UnsafeBufferPointer(start: ptr, count: Int(count)))
        }
    }

    /// Maximum value for lowres supported by the decoder.
    public var maxLowres: UInt8 {
        native.pointee.max_lowres
    }

    /// A Boolean value indicating whether the codec is decoder.
    public var isDecoder: Bool {
        av_codec_is_decoder(native) != 0
    }

    /// A Boolean value indicating whether the codec is encoder.
    public var isEncoder: Bool {
        av_codec_is_encoder(native) != 0
    }

    /// Retrieve supported hardware configurations for a codec.
    ///
    /// Values of index from zero to some maximum return the indexed configuration descriptor;
    /// all other values return `nil`.
    /// If the codec does not support any hardware configurations then it will always return `nil`.
    public func hwConfig(at index: Int) -> AVCodecHWConfig? {
        avcodec_get_hw_config(native, Int32(index)).map(AVCodecHWConfig.init(native:))
    }

    /// Returns a name for the specified profile, if available.
    public func profileName(profile: Int32) -> String? {
        av_get_profile_name(native, profile).map { String(cString: $0) }
    }

    /// Get all registered codecs.
    public static var supportedCodecs: [AVCodec] {
        var list = [AVCodec]()
        var state: UnsafeMutableRawPointer?
        while let ptr = av_codec_iterate(&state) {
            list.append(AVCodec(native: ptr.mutable))
        }
        return list
    }
    
    /// All registered encoders.
    public static var supportedEncoders: [AVCodec] {
        supportedCodecs.filter(\.isEncoder)
    }

    /// All registered decoders.
    public static var supportedDecoders: [AVCodec] {
        supportedCodecs.filter(\.isDecoder)
    }
}

// MARK: - AVCodec.Cap

public extension AVCodec {
    /// Codec capabilities
    struct Capabilities: OptionSet, Hashable {
        /// Decoder can use draw_horiz_band callback.
        public static let drawHorizBand = Self(rawValue: AV_CODEC_CAP_DRAW_HORIZ_BAND)
        /// Codec uses get_buffer() for allocating buffers and supports custom allocators.
        /// If not set, it might not use get_buffer() at all or use operations that
        /// assume the buffer was allocated by avcodec_default_get_buffer.
        public static let dr1 = Self(rawValue: AV_CODEC_CAP_DR1)
        /// Encoder or decoder requires flushing with NULL input at the end in order to
        /// give the complete and correct output.
        ///
        /// - Note: If this flag is not set, the codec is guaranteed to never be fed with
        ///       with NULL data. The user can still send NULL data to the public encode
        ///       or decode function, but libavcodec will not pass it along to the codec
        ///       unless this flag is set.
        ///
        /// Decoders:
        /// The decoder has a non-zero delay and needs to be fed with avpkt->data=NULL,
        /// avpkt->size=0 at the end to get the delayed data until the decoder no longer
        /// returns frames.
        ///
        /// Encoders:
        /// The encoder needs to be fed with NULL data at the end of encoding until the
        /// encoder no longer returns data.
        ///
        /// - Note: For encoders implementing the AVCodec.encode2() function, setting this
        ///       flag also means that the encoder must set the pts and duration for
        ///       each output packet. If this flag is not set, the pts and duration will
        ///       be determined by libavcodec from the input frame.
        public static let delay = Self(rawValue: AV_CODEC_CAP_DELAY)
        /// Codec can be fed a final frame with a smaller size.
        /// This can be used to prevent truncation of the last audio samples.
        public static let smallLastFrame = Self(rawValue: AV_CODEC_CAP_SMALL_LAST_FRAME)
        /// Codec is experimental and is thus avoided in favor of non experimental encoders.
        public static let experimental = Self(rawValue: AV_CODEC_CAP_EXPERIMENTAL)
        /// Codec should fill in channel configuration and samplerate instead of container.
        public static let channelConf = Self(rawValue: AV_CODEC_CAP_CHANNEL_CONF)
        /// Codec supports frame-level multithreading.
        public static let frameThreads = Self(rawValue: AV_CODEC_CAP_FRAME_THREADS)
        /// Codec supports slice-based (or partition-based) multithreading.
        public static let sliceThreads = Self(rawValue: AV_CODEC_CAP_SLICE_THREADS)
        /// Codec supports changed parameters at any point.
        public static let paramChange = Self(rawValue: AV_CODEC_CAP_PARAM_CHANGE)
        /// Codec supports avctx->thread_count == 0 (auto).
        public static let otherThreads = Self(rawValue: AV_CODEC_CAP_OTHER_THREADS)
        /// Audio encoder supports receiving a different number of samples in each call.
        public static let variableFrameSize = Self(rawValue: AV_CODEC_CAP_VARIABLE_FRAME_SIZE)
        /// Decoder is not a preferred choice for probing.
        /// This indicates that the decoder is not a good choice for probing.
        /// It could for example be an expensive to spin up hardware decoder,
        /// or it could simply not provide a lot of useful information about
        /// the stream.
        /// A decoder marked with this flag should only be used as last resort
        /// choice for probing.
        public static let avoidProbing = Self(rawValue: AV_CODEC_CAP_AVOID_PROBING)
        /// Codec is backed by a hardware implementation. Typically used to identify a non-hwaccel hardware decoder.
        /// For information about hwaccels, use `hwConfig(at:)` instead.
        public static let hardware = Self(rawValue: AV_CODEC_CAP_HARDWARE)
        /// Codec is potentially backed by a hardware implementation, but not necessarily.
        /// This is used instead of `Cap.hardware`, if the implementation provides some sort of internal fallback.
        public static let hybrid = Self(rawValue: AV_CODEC_CAP_HYBRID)
        /// This codec takes the reordered_opaque field from input AVFrames
        /// and returns it in the corresponding field in `AVCodecContext` after encoding.
        public static let encoderReorderedOpaque = Self(rawValue: 1 << 20)

        public let rawValue: Int32

        public init(rawValue: Int32) {
            self.rawValue = rawValue
        }
    }
}

extension AVCodec.Capabilities: CustomStringConvertible, CustomDebugStringConvertible {
    public var description: String {
        "[\(elements().map { Self.names[$0]?.swift ?? "\($0.rawValue)" }.joined(separator: ", "))]"
    }

    public var debugDescription: String {
        "[\(elements().map { Self.names[$0]?.native ?? "\($0.rawValue)" }.joined(separator: ", "))]"
    }

    private static let names: [Self: (swift: String, native: String)] = [
        .drawHorizBand: ("drawHorizBand", "AV_CODEC_CAP_DRAW_HORIZ_BAND"),
        .dr1: ("dr1", "AV_CODEC_CAP_DR1"),
        .delay: ("delay", "AV_CODEC_CAP_DELAY"),
        .smallLastFrame: ("smallLastFrame", "AV_CODEC_CAP_SMALL_LAST_FRAME"),
        .experimental: ("experimental", "AV_CODEC_CAP_EXPERIMENTAL"),
        .channelConf: ("channelConf", "AV_CODEC_CAP_CHANNEL_CONF"),
        .frameThreads: ("frameThreads", "AV_CODEC_CAP_FRAME_THREADS"),
        .sliceThreads: ("sliceThreads", "AV_CODEC_CAP_SLICE_THREADS"),
        .paramChange: ("paramChange", "AV_CODEC_CAP_PARAM_CHANGE"),
        .otherThreads: ("otherThreads", "AV_CODEC_CAP_OTHER_THREADS"),
        .variableFrameSize: ("variableFrameSize", "AV_CODEC_CAP_VARIABLE_FRAME_SIZE"),
        .avoidProbing: ("avoidProbing", "AV_CODEC_CAP_AVOID_PROBING"),
        .hardware: ("hardware", "AV_CODEC_CAP_HARDWARE"),
        .hybrid: ("hybrid", "AV_CODEC_CAP_HYBRID"),
        .encoderReorderedOpaque: ("encoderReorderedOpaque", "AV_CODEC_CAP_ENCODER_REORDERED_OPAQUE"),
    ]
}

extension AVCodec: AVOptionSupport {
    public func withUnsafeObjectPointer<T>(_ body: (UnsafeMutableRawPointer) throws -> T) rethrows -> T {
        var tmp = native.pointee.priv_class
        return try withUnsafeMutablePointer(to: &tmp) { ptr in
            try body(ptr)
        }
    }
}
