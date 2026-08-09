//
//  AVCodecContext.swift
//  SwiftFFmpeg
//
//  Created by sunlubo on 2018/6/29.
//

import CFFmpeg

#if canImport(Darwin)
import Darwin
#else
import Glibc
#endif

public typealias AVGetFormatHandler = (AVCodecContext, [AVPixelFormat]) -> AVPixelFormat

typealias CodecContextBox = Box<(opaque: UnsafeMutableRawPointer?, getFormat: AVGetFormatHandler?)>

// MARK: - AVCodecContext

typealias CAVCodecContext = CFFmpeg.AVCodecContext

public final class AVCodecContext {
    var native: UnsafeMutablePointer<CAVCodecContext>!
    var owned: Bool = false
    var opaqueBox: CodecContextBox? {
        didSet {
            if let box = opaqueBox {
                native.pointee.opaque = Unmanaged.passUnretained(box).toOpaque()
            } else {
                native.pointee.opaque = nil
            }
        }
    }

    init(native: UnsafeMutablePointer<CAVCodecContext>) {
        self.native = native
    }

    /// Creates an `AVCodecContext` and set its fields to default values.
    ///
    /// - Parameter codec: codec
    public init(codec: AVCodec? = nil) {
        self.native = avcodec_alloc_context3(codec?.native)
        self.owned = true
    }

    deinit {
        guard owned else { return }
        avcodec_free_context(&native)
    }

    /// The codec's media type.
    public var mediaType: AVMediaType {
        AVMediaType(native: native.pointee.codec_type)
    }
    
    /// The codec profile, or `nil` if the profile is unknown.
    public var profile: AVProfile? {
        get {
            guard native.pointee.profile != AV_PROFILE_UNKNOWN else {
                return nil
            }
            return AVProfile(rawValue: native.pointee.profile)
        }
        set { native.pointee.profile = newValue?.rawValue ?? AV_PROFILE_UNKNOWN }
    }
    
    /// The name of the codec profile, or `nil` if it is unknown.
    public var profileName: String? {
        guard let codec = native.pointee.codec,
              native.pointee.profile != AV_PROFILE_UNKNOWN else {
            return nil
        }
        return av_get_profile_name(codec, native.pointee.profile)?.string
    }

    /// The codec associated with the context.
    public var codec: AVCodec? {
        get { native.pointee.codec.map(AVCodec.init(native:)) }
        set { native.pointee.codec = UnsafePointer(newValue?.native) }
    }

    /// The identifier of the codec.
    public var codecId: AVCodecID {
        get { AVCodecID(native: native.pointee.codec_id) }
        set { native.pointee.codec_id = newValue.native }
    }

    /**
     The codec tag, or `nil` if no tag is specified.

     The tag is stored least-significant byte first and may contain container- or encoder-specific codec identification information.

     When encoding, it may be set by the caller; when decoding, it may be used by libavcodec for codec-specific compatibility handling.
     */
    public var codecTag: UInt32? {
        get { native.pointee.codec_tag != 0 ? native.pointee.codec_tag : nil }
        set { native.pointee.codec_tag = newValue ?? 0 }
    }
    
    /// The codec tag represented as a four-character string.
    public var codecTagString: String? {
        get { codecTag?.fourCC }
        // set { codecTag = newValue?.fourCC ?? 0 }
    }

    /// The application-specific opaque data associated with the codec context.
    public var opaque: UnsafeMutableRawPointer? {
        get { opaqueBox?.value.opaque }
        set { opaqueBox = CodecContextBox((opaque: newValue, getFormat: opaqueBox?.value.getFormat)) }
    }

    /**
     The average bit rate of the codec, in bits per second.

     When encoding, this value is unused for constant-quantizer encoding; when decoding, libavcodec may replace it with information from the bitstream.
     */
    public var bitRate: Int64 {
        get { native.pointee.bit_rate }
        set { native.pointee.bit_rate = newValue }
    }

    /**
     The number of bits by which the encoded bitstream may deviate from the target bit rate.

     This value is used during encoding and is ignored for constant-quantizer encoding.
     */
    public var bitRateTolerance: Int {
        get { Int(native.pointee.bit_rate_tolerance) }
        set { native.pointee.bit_rate_tolerance = Int32(newValue) }
    }

    /// The primary codec flags.
    public var flags: Flag {
        get { Flag(rawValue: UInt32(native.pointee.flags)) }
        set { native.pointee.flags = Int32(newValue.rawValue) }
    }

    /// The secondary codec flags.
    public var flags2: Flag2 {
        get { Flag2(rawValue: native.pointee.flags2) }
        set { native.pointee.flags2 = newValue.rawValue }
    }

    /**
     The codec-specific extra data.

     Extra data may contain information such as Huffman tables, global headers, or codec-specific configuration and must include sufficient input-buffer padding when supplied by the caller.
     */
    public var extraData: UnsafeMutablePointer<UInt8>? {
        get { native.pointee.extradata }
        set { native.pointee.extradata = newValue }
    }

    /// The size of the codec-specific extra data, in bytes.
    public var extraDataSize: Int {
        get { Int(native.pointee.extradata_size) }
        set { native.pointee.extradata_size = Int32(newValue) }
    }

    /**
     The time base used to represent codec timestamps.

     For constant-frame-rate encoding, this is typically the inverse of the frame rate; use of this value for decoding is deprecated in favor of `frameRate`.
     */
    public var timebase: AVRational {
        get { native.pointee.time_base }
        set { native.pointee.time_base = newValue }
    }

    /**
     The number of frames processed by the codec.

     For encoding, this is the number of frames submitted to the encoder; for decoding, it is the number of frames returned by the decoder.
     */
    public var frameNumber: Int {
        Int(native.pointee.frame_num)
    }

    /**
     The hardware frames context used for encoder input or decoder output.

     Set this value before opening the codec when required for hardware acceleration; after assignment, libavcodec owns the retained buffer reference.
     */
    public var hwFramesContext: AVHWFramesContext? {
        get { native.pointee.hw_frames_ctx.map(AVHWFramesContext.init(nativeBuffer:)) }
        set { native.pointee.hw_frames_ctx = av_buffer_ref(newValue?.nativeBuffer) }
    }

    /**
     The hardware device context used by the encoder or decoder.

     Set this value before opening the codec and don't modify it afterward; use `hwFramesContext` when frames are supplied or received through a specific hardware frames context.
     */
    public var hwDeviceContext: AVHWDeviceContext? {
        get { native.pointee.hw_device_ctx.map(AVHWDeviceContext.init(native:)) }
        set { native.pointee.hw_device_ctx = av_buffer_ref(newValue?.native) }
    }

    /// A Boolean value indicating whether the codec is open.
    public var isOpen: Bool {
        avcodec_is_open(native) > 0
    }

    /// Copies codec parameters into the codec context.
    public func setParameters(_ params: AVCodecParameters) {
        avcodec_parameters_to_context(native, params.native).abortIfFail()
    }

    /**
     Opens the codec context with the specified codec and options.

     - Parameters:
       - codec: The codec to open, or `nil` to use the codec already associated with the context.
       - options: The codec and codec-private options to apply when opening the context.
     - Throws: An `AVError` if the codec can't be opened.
     */
    public func openCodec(_ codec: AVCodec? = nil, options: [String: String]? = nil) throws {
        var pm = options?.avDict
        defer { av_dict_free(&pm) }
        try avcodec_open2(native, codec?.native ?? self.codec?.native, &pm).throwIfFail()
        pm?.dumpUnrecognizedOptions()
    }

    /**
     Sends encoded packet data to the decoder.

     The packet is fully consumed by the decoder and may produce multiple frames. Pass `nil` to signal the end of the stream and flush buffered frames.

     - Parameter packet: The encoded packet to decode, or `nil` to flush the decoder.
     - Throws: An `AVError` if the packet can't be accepted or decoded.
     */
    public func sendPacket(_ packet: AVPacket?) throws {
        try avcodec_send_packet(native, packet?.native).throwIfFail()
    }

    /**
     Receives a decoded frame from the decoder.

     - Parameter frame: The frame that receives the decoded video or audio data.
     - Throws: An `AVError`, including `.tryAgain` when more input is required or `.eof` when decoding is complete.
     */
    public func receiveFrame(_ frame: AVFrame) throws {
        try avcodec_receive_frame(native, frame.native).throwIfFail()
    }
    
    func receiveFrameIfAvailable(_ frame: AVFrame) throws -> Bool {
        let result = avcodec_receive_frame(native, frame.native)
        if result == swift_AVERROR(EAGAIN) || result == swift_AVERROR_EOF {
            return false
        }
        try result.throwIfFail()
        return true
    }
    
    func receiveFrames(handler: (AVFrame) throws ->()) throws {
        let frame = AVFrame()
        while try receiveFrameIfAvailable(frame) {
            defer { frame.unref() }
            try handler(frame)
        }
    }

    /**
     Sends a raw video or audio frame to the encoder.

     Pass `nil` to signal end of input and flush buffered packets from the encoder.

     - Parameter frame: The frame to encode, or `nil` to flush the encoder.
     - Throws: An `AVError` if the frame can't be accepted or encoded.
     */
    public func sendFrame(_ frame: AVFrame?) throws {
        try avcodec_send_frame(native, frame?.native).throwIfFail()
    }

    /**
     Receives an encoded packet from the encoder.

     - Parameter packet: The packet that receives the encoded data.
     - Throws: An `AVError`, including `.tryAgain` when more input is required or `.eof` when encoding is complete.
     */
    public func receivePacket(_ packet: AVPacket) throws {
        try avcodec_receive_packet(native, packet.native).throwIfFail()
    }
    
    func receivePacketIfAvailable(_ packet: AVPacket) throws -> Bool {
        let result = avcodec_receive_packet(native, packet.native)
        if result == swift_AVERROR(EAGAIN) || result == swift_AVERROR_EOF {
            return false
        }
        try result.throwIfFail()
        return true
    }
    
    func receivePackets(handler: (AVPacket) throws ->()) throws {
        let packet = AVPacket()
        while try receivePacketIfAvailable(packet) {
            defer { packet.unref() }
            try handler(packet)
        }
    }

    /// Resets the internal codec state and flushes buffered data.
    public func flush() {
        avcodec_flush_buffers(native)
    }
}

// MARK: - AVCodecContext.Flag

public extension AVCodecContext {
    /// Flags that control codec behavior.
    struct Flag: OptionSet, Hashable, CustomStringConvertible, CustomDebugStringConvertible {
        /// Allows decoders to produce frames with data planes that aren't aligned to CPU requirements.
        public static let unaligned = Flag(rawValue: UInt32(AV_CODEC_FLAG_UNALIGNED))
        /// Uses a fixed quantizer scale.
        public static let qscale = Flag(rawValue: UInt32(AV_CODEC_FLAG_QSCALE))
        /// Enables four motion vectors per macroblock or advanced prediction for H.263.
        public static let p4mv = Flag(rawValue: UInt32(AV_CODEC_FLAG_4MV))
        /// Outputs frames that may be corrupted.
        public static let outputCorrupted = Flag(rawValue: UInt32(AV_CODEC_FLAG_OUTPUT_CORRUPT))
        /// Enables quarter-pixel motion compensation.
        public static let qpel = Flag(rawValue: UInt32(AV_CODEC_FLAG_QPEL))
        /// Enables the first pass of internal two-pass rate control.
        public static let pass1 = Flag(rawValue: UInt32(AV_CODEC_FLAG_PASS1))
        /// Enables the second pass of internal two-pass rate control.
        public static let pass2 = Flag(rawValue: UInt32(AV_CODEC_FLAG_PASS2))
        /// Enables loop filtering.
        public static let loopFilter = Flag(rawValue: UInt32(AV_CODEC_FLAG_LOOP_FILTER))
        /// Restricts encoding or decoding to grayscale.
        public static let gray = Flag(rawValue: UInt32(AV_CODEC_FLAG_GRAY))
        /// Enables calculation of PSNR-related error values during encoding.
        public static let psnr = Flag(rawValue: UInt32(AV_CODEC_FLAG_PSNR))
        /// Enables interlaced discrete cosine transforms.
        public static let interlacedDCT = Flag(rawValue: UInt32(AV_CODEC_FLAG_INTERLACED_DCT))
        /// Forces low-delay operation.
        public static let lowDelay = Flag(rawValue: UInt32(AV_CODEC_FLAG_LOW_DELAY))
        /// Places global headers in extra data instead of in every keyframe.
        public static let globalHeader = Flag(rawValue: UInt32(AV_CODEC_FLAG_GLOBAL_HEADER))
        /// Enables bit-exact processing except for inverse and forward discrete cosine transforms.
        public static let bitexact = Flag(rawValue: UInt32(AV_CODEC_FLAG_BITEXACT))
        /// Enables H.263 advanced intra coding or MPEG-4 AC prediction.
        public static let acPred = Flag(rawValue: UInt32(AV_CODEC_FLAG_AC_PRED))
        /// Enables interlaced motion estimation.
        public static let interlacedME = Flag(rawValue: UInt32(AV_CODEC_FLAG_INTERLACED_ME))
        /// Uses closed groups of pictures.
        public static let closedGOP = Flag(rawValue: AV_CODEC_FLAG_CLOSED_GOP)
        
        public let rawValue: UInt32
        
        public init(rawValue: UInt32) {
            self.rawValue = rawValue
        }
        
        public var description: String {
            "[\(elements().map { Self.names[$0]?.swift ?? "\($0.rawValue)" }.joined(separator: ", "))]"
        }
        
        public var debugDescription: String {
            "[\(elements().map { Self.names[$0]?.native ?? "\($0.rawValue)" }.joined(separator: ", "))]"
        }
        
        private static let names: [Self: (swift: String, native: String)] = [
            .unaligned: ("unaligned", "AV_CODEC_FLAG_UNALIGNED"),
            .qscale: ("qscale", "AV_CODEC_FLAG_QSCALE"),
            .p4mv: ("p4mv", "AV_CODEC_FLAG_4MV"),
            .outputCorrupted: ("outputCorrupted", "AV_CODEC_FLAG_OUTPUT_CORRUPT"),
            .qpel: ("qpel", "AV_CODEC_FLAG_QPEL"),
            .pass1: ("pass1", "AV_CODEC_FLAG_PASS1"),
            .pass2: ("pass2", "AV_CODEC_FLAG_PASS2"),
            .loopFilter: ("loopFilter", "AV_CODEC_FLAG_LOOP_FILTER"),
            .gray: ("gray", "AV_CODEC_FLAG_GRAY"),
            .psnr: ("psnr", "AV_CODEC_FLAG_PSNR"),
            .interlacedDCT: ("interlacedDCT", "AV_CODEC_FLAG_INTERLACED_DCT"),
            .lowDelay: ("lowDelay", "AV_CODEC_FLAG_LOW_DELAY"),
            .globalHeader: ("globalHeader", "AV_CODEC_FLAG_GLOBAL_HEADER"),
            .bitexact: ("bitexact", "AV_CODEC_FLAG_BITEXACT"),
            .acPred: ("acPred", "AV_CODEC_FLAG_AC_PRED"),
            .interlacedME: ("interlacedME", "AV_CODEC_FLAG_INTERLACED_ME"),
            .closedGOP: ("closedGOP", "AV_CODEC_FLAG_CLOSED_GOP"),
        ]
    }
}

public extension AVCodecContext {
    /// Additional flags that control codec behavior.
    struct Flag2: OptionSet, Hashable, CustomStringConvertible, CustomDebugStringConvertible {
        /// Allows non-spec-compliant optimizations that improve performance.
        public static let fast = Flag2(rawValue: AV_CODEC_FLAG2_FAST)
        /// Skips bitstream output during encoding.
        public static let noOutput = Flag2(rawValue: AV_CODEC_FLAG2_NO_OUTPUT)
        /// Places global headers in every keyframe instead of in extra data.
        public static let localHeader = Flag2(rawValue: AV_CODEC_FLAG2_LOCAL_HEADER)
        /// Allows the input bitstream to be truncated at packet boundaries instead of only at frame boundaries.
        public static let chunks = Flag2(rawValue: AV_CODEC_FLAG2_CHUNKS)
        /// Ignores cropping information from the sequence parameter set.
        public static let ignoreCrop = Flag2(rawValue: AV_CODEC_FLAG2_IGNORE_CROP)
        /// Outputs all frames before the first keyframe.
        public static let showAll = Flag2(rawValue: AV_CODEC_FLAG2_SHOW_ALL)
        /// Exports motion vectors as frame side data.
        public static let exportMVS = Flag2(rawValue: AV_CODEC_FLAG2_EXPORT_MVS)
        /// Exports skip information as frame side data instead of skipping samples.
        public static let skipManual = Flag2(rawValue: AV_CODEC_FLAG2_SKIP_MANUAL)
        /// Preserves the ASS `ReadOrder` field when flushing subtitle decoders.
        public static let roFlushNoop = Flag2(rawValue: AV_CODEC_FLAG2_RO_FLUSH_NOOP)
        
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
            .fast: ("fast", "AV_CODEC_FLAG2_FAST"),
            .noOutput: ("noOutput", "AV_CODEC_FLAG2_NO_OUTPUT"),
            .localHeader: ("localHeader", "AV_CODEC_FLAG2_LOCAL_HEADER"),
            .chunks: ("chunks", "AV_CODEC_FLAG2_CHUNKS"),
            .ignoreCrop: ("ignoreCrop", "AV_CODEC_FLAG2_IGNORE_CROP"),
            .showAll: ("showAll", "AV_CODEC_FLAG2_SHOW_ALL"),
            .exportMVS: ("exportMVS", "AV_CODEC_FLAG2_EXPORT_MVS"),
            .skipManual: ("skipManual", "AV_CODEC_FLAG2_SKIP_MANUAL"),
            .roFlushNoop: ("roFlushNoop", "AV_CODEC_FLAG2_RO_FLUSH_NOOP"),
        ]
    }
}

// MARK: - Video

public extension AVCodecContext {
    /// The width of the picture.
    ///
    /// - encoding: Must be set by user.
    /// - decoding: May be set by the user before opening the decoder if known e.g. from the container.
    ///   Some decoders will require the dimensions to be set by the caller. During decoding, the decoder may
    ///   overwrite those values as required while parsing the data.
    var width: Int {
        get { Int(native.pointee.width) }
        set { native.pointee.width = Int32(newValue) }
    }

    /// The height of the picture.
    ///
    /// - encoding: Must be set by user.
    /// - decoding: May be set by the user before opening the decoder if known e.g. from the container.
    ///   Some decoders will require the dimensions to be set by the caller. During decoding, the decoder may
    ///   overwrite those values as required while parsing the data.
    var height: Int {
        get { Int(native.pointee.height) }
        set { native.pointee.height = Int32(newValue) }
    }

    /// Bitstream width, may be different from `width` e.g. when the decoded frame is cropped before
    /// being output or lowres is enabled.
    ///
    /// - encoding: Unused.
    /// - decoding: May be set by the user before opening the decoder if known e.g. from the container.
    ///   During decoding, the decoder may overwrite those values as required while parsing the data.
    var codedWidth: Int {
        get { Int(native.pointee.coded_width) }
        set { native.pointee.coded_width = Int32(newValue) }
    }

    /// Bitstream height, may be different from `height` e.g. when the decoded frame is cropped before
    /// being output or lowres is enabled.
    ///
    /// - encoding: Unused.
    /// - decoding: May be set by the user before opening the decoder if known e.g. from the container.
    ///   During decoding, the decoder may overwrite those values as required while parsing the data.
    var codedHeight: Int {
        get { Int(native.pointee.coded_height) }
        set { native.pointee.coded_height = Int32(newValue) }
    }

    /// The number of pictures in a group of pictures, or 0 for intra_only.
    ///
    /// - encoding: Set by user.
    /// - decoding: Unused.
    var gopSize: Int {
        get { Int(native.pointee.gop_size) }
        set { native.pointee.gop_size = Int32(newValue) }
    }

    /// The pixel format of the picture.
    ///
    /// - encoding: Set by user.
    /// - decoding: Set by user if known, overridden by codec while parsing the data.
    var pixelFormat: AVPixelFormat {
        get { native.pointee.pix_fmt }
        set { native.pointee.pix_fmt = newValue }
    }
    
    /// Indicates how the alpha channel of the video is represented.
    var alphaMode: AVAlphaMode {
        get { AVAlphaMode(native: native.pointee.alpha_mode) }
        set { native.pointee.alpha_mode = newValue.native }
    }

    /// The callback used to negotiate the pixel format.
    ///
    /// - Note: The callback may be called again immediately if initialization for
    ///   the selected (hardware-accelerated) pixel format failed.
    ///
    /// - Warning: Behavior is undefined if the callback returns a value not
    ///   in the fmt list of formats.
    ///
    /// - encoding: Unused.
    /// - decoding: Set by user, if not set the native format will be chosen.
    var getFormat: AVGetFormatHandler? {
        get { opaqueBox?.value.getFormat }
        set {
            opaqueBox = CodecContextBox((opaque: opaqueBox?.value.opaque, getFormat: newValue))
            var handler:
                (
                    @convention(c) (
                        UnsafeMutablePointer<CAVCodecContext>?, UnsafePointer<AVPixelFormat>?
                    ) -> AVPixelFormat
                )!
            if newValue != nil {
                handler = { ctx, fmts in
                    let handler = Unmanaged<CodecContextBox>.fromOpaque(
                        UnsafeRawPointer(ctx!.pointee.opaque!)
                    )
                    .takeUnretainedValue()
                    .value
                    .getFormat!
                    let list = Array(fmts, until: .none)
                    return handler(AVCodecContext(native: ctx!), list)
                }
            }
            native.pointee.get_format = handler
        }
    }

    /// Maximum number of B-frames between non-B-frames.
    ///
    /// - Note: The output will be delayed by __max_b_frames+1__ relative to the input.
    ///
    /// - encoding: Set by user.
    /// - decoding: Unused.
    var maxBFrames: Int {
        get { Int(native.pointee.max_b_frames) }
        set { native.pointee.max_b_frames = Int32(newValue) }
    }

    /// Macroblock decision mode.
    ///
    /// - encoding: Set by user.
    /// - decoding: Unused.
    var mbDecision: Int {
        get { Int(native.pointee.mb_decision) }
        set { native.pointee.mb_decision = Int32(newValue) }
    }

    /**
     The sample aspect ratio, or `nil` if unknown.

     The sample aspect ratio is the width of a pixel divided by its height.
     */
    var sampleAspectRatio: AVRational? {
        get {
            let ratio = native.pointee.sample_aspect_ratio
            return ratio.num != 0 || ratio.den != 0 ? ratio : nil
        }
        set { native.pointee.sample_aspect_ratio = newValue ?? AVRational(num: 0, den: 0) }
    }

    /// low resolution decoding, 1->1/2 size, 2->1/4 size
    ///
    /// - encoding: Unused.
    /// - decoding: Set by user.
    var lowres: Int {
        Int(native.pointee.lowres)
    }

    /// The frame rate of the video, or `nil` if unknown.
    var frameRate: AVRational? {
        get {
            let frameRate = native.pointee.framerate
            return frameRate.num != 0 ? frameRate : nil
        }
        set { native.pointee.framerate = newValue ?? AVRational(num: 0, den: 1) }
    }
}

// MARK: - Audio

public extension AVCodecContext {
    /// Samples per second.
    var sampleRate: Int {
        get { Int(native.pointee.sample_rate) }
        set { native.pointee.sample_rate = Int32(newValue) }
    }

    /// Audio sample format.
    ///
    /// - encoding: Set by user.
    /// - decoding: Set by libavcodec.
    var sampleFormat: AVSampleFormat {
        get { AVSampleFormat(native: native.pointee.sample_fmt) }
        set { native.pointee.sample_fmt = newValue.native }
    }

    /// Number of samples per channel in an audio frame.
    var frameSize: Int {
        get { Int(native.pointee.frame_size) }
        set { native.pointee.frame_size = Int32(newValue) }
    }

    /// Audio channel layout.
    ///
    /// - encoding: Set by user.
    /// - decoding: Set by user, may be overwritten by codec.
    var channelLayout: AVChannelLayout {
        get { native.pointee.ch_layout }
        set { native.pointee.ch_layout = newValue }
    }
}

// MARK: - Multithreading

public extension AVCodecContext {
    /// Which multithreading methods to use.
    /// Use of FF_THREAD_FRAME will increase decoding delay by one frame per thread,
    /// so clients which cannot provide future frames should not use it.
    ///
    /// - encoding: Set by user, otherwise the default is used.
    /// - decoding: Set by user, otherwise the default is used.
    var threadType: AVCodecContext.ThreadType {
        get { AVCodecContext.ThreadType(rawValue: native.pointee.thread_type) }
        set { native.pointee.thread_type = newValue.rawValue }
    }

    /// thread count
    /// is used to decide how many independent tasks should be passed to execute()
    /// - encoding: Set by user.
    /// - decoding: Set by user.
    var threadCount: Int32 {
        get { native.pointee.thread_count }
        set { native.pointee.thread_count = newValue }
    }

    /// Which multithreading methods are in use by the codec.
    /// - encoding: Set by libavcodec.
    /// - decoding: Set by libavcodec.
    var activeThreadType: AVCodecContext.ThreadType {
        AVCodecContext.ThreadType(rawValue: native.pointee.active_thread_type)
    }
}

extension AVCodecContext: AVClassSupport {
    public static let `class` = AVClass(native: avcodec_get_class())

    public func withUnsafeObjectPointer<T>(_ body: (UnsafeMutableRawPointer) throws -> T) rethrows -> T {
        try body(native)
    }
}

public extension AVCodecContext {
struct ThreadType: Equatable, OptionSet {
    /// Decode more than one frame at once
    public static let frame = AVCodecContext.ThreadType(rawValue: FF_THREAD_FRAME)
    /// Decode more than one part of a single frame at once
    public static let slice = AVCodecContext.ThreadType(rawValue: FF_THREAD_SLICE)

    public let rawValue: Int32

    public init(rawValue: Int32) {
        self.rawValue = rawValue
    }
}
}
