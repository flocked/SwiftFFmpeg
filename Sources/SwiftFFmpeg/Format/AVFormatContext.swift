//
//  AVFormatContext.swift
//  SwiftFFmpeg
//
//  Created by sunlubo on 2018/6/29.
//

import CFFmpeg
import Foundation

// MARK: - AVFormatContext

typealias CAVFormatContext = CFFmpeg.AVFormatContext

/// Format I/O context.
public final class AVFormatContext {
    var native: UnsafeMutablePointer<CAVFormatContext>!
    var _ioContext: AVIOContext?

    /// Create an `AVFormatContext`.
    public init() {
        self.native = avformat_alloc_context()
    }

    /**
     Opens an input and creates a format context.

     - Parameters:
       - url: The URL or file path of the input.
       - format: The input format, or `nil` to automatically detect the format.
       - options: The options to use when opening the input.
     */
    public init(url: String, format: AVInputFormat? = nil, options: [String: String]? = nil) throws {
        var pm = options?.avDict
        defer { av_dict_free(&pm) }
        try avformat_open_input(&native, url, format?.native, &pm).throwIfFail()
        pm?.dumpUnrecognizedOptions()
    }

    /**
     Opens an input and creates a format context.

     - Parameters:
       - url: The URL of the input.
       - format: The input format, or `nil` to automatically detect the format.
       - options: The options to use when opening the input.
     */
    public convenience init(url: URL, format: AVInputFormat? = nil, options: [String: String]? = nil) throws {
        try self.init(url: url.pathOrURLString, format: format, options: options)
    }

    /**
     Creates an output format context with the specified output format.

     - Parameters:
       - format: The output format.
       - filename: The output filename, if available.
     */
    public init(format: AVOutputFormat, filename: String? = nil) throws {
        try avformat_alloc_output_context2(&native, format.native, nil, filename).throwIfFail()
    }

    /**
     Creates an output format context with the specified format name.

     - Parameters:
       - formatName: The short name of the output format.
       - filename: The output filename, if available.
     */
    public init(formatName: String, filename: String? = nil) throws {
        try avformat_alloc_output_context2(&native, nil, formatName, filename).throwIfFail()
    }

    /// Creates an output format context by determining the output format from the specified filename.
    public init(filename: String) throws {
        try avformat_alloc_output_context2(&native, nil, nil, filename).throwIfFail()
    }

    deinit {
        avformat_close_input(&native)
    }

    /**
     The input or output URL associated with the format context.

     When demuxing, this value is set when the input is opened; when muxing, it may be set by the caller before writing the header.
     */
    public var url: String? {
        get { native.pointee.url?.string }
        set { native.pointee.url = av_strdup(newValue) }
    }

    /**
     The I/O context used to read or write media data.

     When demuxing, the context may be provided by the caller before opening the input or created by libavformat; when muxing, it must normally be provided by the caller before writing the header.

     The caller is responsible for closing an I/O context it provides.
     */
    public var ioContext: AVIOContext? {
        get { native.pointee.pb.map(AVIOContext.init(native:)) }
        set {
            _ioContext = newValue
            native.pointee.pb = newValue?.native
        }
    }

    /// The number of streams in the format context.
    public var streamCount: Int {
        Int(native.pointee.nb_streams)
    }

    /**
     The method used to estimate the duration of the input.

     This value is available when demuxing and indicates how libavformat determined the duration.
     */
    public var durationEstimationMethod: AVFormatContext.DurationEstimationMethod {
        AVFormatContext.DurationEstimationMethod(rawValue: native.pointee.duration_estimation_method)
    }

    /**
     The streams in the format context.

     When demuxing, streams are created by libavformat and additional streams may appear while reading packets for formats without a header; when muxing, streams are created by the caller before writing the header.
     */
    public var streams: [AVStream] {
        native.pointee.streams?.buffer(count: native.pointee.nb_streams).map { AVStream(native: $0!) } ?? []
    }

    /// The streams grouped by their language metadata.
    public var streamsByLanguage: [String: [AVStream]] {
        streams.reduce(into: [:]) { dic, stream in
            guard let language = stream.language, !language.isEmpty else { return }
            dic[language, default: []].append(stream)
        }
    }

    /**
     The flags that control demuxing or muxing behavior.

     Set this value before opening an input or writing an output header.
     */
    public var flags: Flag {
        get { Flag(rawValue: native.pointee.flags) }
        set { native.pointee.flags = newValue.rawValue }
    }

    /**
     The maximum amount of input data, in bytes, used to probe the container format.

     This value applies only to demuxing and should be set before opening the input.
     */
    public var probeSize: Int64 {
        get { native.pointee.probesize }
        set { native.pointee.probesize = newValue }
    }

    /**
     The chapters in the format context.

     When demuxing, chapters are populated by libavformat; when muxing, chapters are provided by the caller and are normally set before writing the header.

     Some muxers can write chapters in the trailer when no chapters are present while writing the header and chapters are added before writing the trailer.
     */
    public var chapters: [AVChapter] {
        get { native.pointee.chapters.buffer(count: native.pointee.nb_chapters).map({ AVChapter(native: $0!) }) }
        set {
            let cchapters = UnsafeMutablePointer<UnsafeMutablePointer<CAVChapter>?>.allocate(
                capacity: newValue.count)
            for (index, chapter) in newValue.enumerated() {
                let cchapter = UnsafeMutablePointer<CAVChapter>.allocate(capacity: 1)
                cchapter.initialize(to: chapter.native)
                cchapters.advanced(by: index).pointee = cchapter
            }
            native.pointee.chapters = cchapters
            native.pointee.nb_chapters = UInt32(newValue.count)
        }
    }

    /**
     The metadata that applies to the entire file.

     When demuxing, metadata is populated by libavformat; when muxing, it may be set by the caller before writing the header.
     */
    public var metadata: [String: String] {
        get { native.pointee.metadata?.avDict ?? [:] }
        set { native.pointee.metadata.replace(with: newValue) }
    }

    /**
     The callback used to interrupt blocking I/O operations.

     Set this callback before opening an input or writing an output header; when opening output I/O separately, pass the callback to the corresponding I/O operation as well.
     */
    public var interruptCallback: AVIOInterruptCallback {
        get { native.pointee.interrupt_callback }
        set { native.pointee.interrupt_callback = newValue }
    }

    /**
     Prints detailed information about the input or output format.

     - Parameters:
       - url: The URL displayed for the input or output, or `nil` to use the context's URL.
       - isOutput: A Boolean value indicating whether the context represents an output.
     */
    public func dumpFormat(at url: String? = nil, isOutput: Bool = false) {
        av_dump_format(native, 0, url ?? self.url, isOutput ? 1 : 0)
    }
    
    /**
     Prints detailed information about the input or output format.

     - Parameters:
       - url: The URL displayed for the input or output.
       - isOutput: A Boolean value indicating whether the context represents an output.
     */
    public func dumpFormat(at url: URL, isOutput: Bool = false) {
        dumpFormat(at: url.pathOrURLString, isOutput: isOutput)
    }
}

// MARK: - AVFormatContext.DurationEstimationMethod

public extension AVFormatContext {
struct DurationEstimationMethod: Equatable {
    /// Duration accurately estimated from PTSes
    public static let fromPTS = AVFormatContext.DurationEstimationMethod(rawValue: AVFMT_DURATION_FROM_PTS)

    /// Duration estimated from a stream with a known duration
    public static let fromStream = AVFormatContext.DurationEstimationMethod(rawValue: AVFMT_DURATION_FROM_STREAM)

    /// Duration estimated from bitrate (less accurate)
    public static let fromBitrate = AVFormatContext.DurationEstimationMethod(rawValue: AVFMT_DURATION_FROM_BITRATE)

    public let rawValue: CFFmpeg.AVDurationEstimationMethod
    public init(rawValue: CFFmpeg.AVDurationEstimationMethod) {
        self.rawValue = rawValue
    }
}
}

// MARK: - AVFormatContext.Flag

public extension AVFormatContext {
    /// Flags used to modify the (de)muxer behaviour.
    struct Flag: OptionSet, Hashable {
        /// Generate missing pts even if it requires parsing future frames.
        public static let genPTS = Flag(rawValue: AVFMT_FLAG_GENPTS)
        /// Ignore index.
        public static let ignIdx = Flag(rawValue: AVFMT_FLAG_IGNIDX)
        /// Do not block when reading packets from input.
        public static let nonBlock = Flag(rawValue: AVFMT_FLAG_NONBLOCK)
        /// Ignore DTS on frames that contain both DTS & PTS.
        public static let ignDTS = Flag(rawValue: AVFMT_FLAG_IGNDTS)
        /// Do not infer any values from other values, just return what is stored in the container.
        public static let noFillIn = Flag(rawValue: AVFMT_FLAG_NOFILLIN)
        /// Do not use AVParsers, you also must set `noFillIn` as the fillin code works on frames and
        /// no parsing -> no frames. Also seeking to frames can not work if parsing to find frame boundaries has
        /// been disabled.
        public static let noParse = Flag(rawValue: AVFMT_FLAG_NOPARSE)
        /// Do not buffer frames when possible.
        public static let noBuffer = Flag(rawValue: AVFMT_FLAG_NOBUFFER)
        /// The caller has supplied a custom AVIOContext, don't avio_close() it.
        public static let customIO = Flag(rawValue: AVFMT_FLAG_CUSTOM_IO)
        /// Discard frames marked corrupted.
        public static let discardCorrupt = Flag(rawValue: AVFMT_FLAG_DISCARD_CORRUPT)
        /// Flush the `AVIOContext` every packet.
        public static let flushPackets = Flag(rawValue: AVFMT_FLAG_FLUSH_PACKETS)
        /// When muxing, try to avoid writing any random/volatile data to the output.
        /// This includes any random IDs, real-time timestamps/dates, muxer version, etc.
        ///
        /// This flag is mainly intended for testing.
        public static let bitexact = Flag(rawValue: AVFMT_FLAG_BITEXACT)
        /// Try to interleave outputted packets by dts (using this flag can slow demuxing down).
        public static let sortDTS = Flag(rawValue: AVFMT_FLAG_SORT_DTS)
        /// Enable fast, but inaccurate seeks for some formats.
        public static let fastSeek = Flag(rawValue: AVFMT_FLAG_FAST_SEEK)
        /// Add bitstream filters as requested by the muxer.
        public static let autoBSF = Flag(rawValue: AVFMT_FLAG_AUTO_BSF)

        public let rawValue: Int32

        public init(rawValue: Int32) {
            self.rawValue = rawValue
        }
    }
}

extension AVFormatContext.Flag: CustomStringConvertible, CustomDebugStringConvertible {
    public var description: String {
        "[\(elements().map { Self.names[$0]?.swift ?? "\($0.rawValue)" }.joined(separator: ", "))]"
    }

    public var debugDescription: String {
        "[\(elements().map { Self.names[$0]?.native ?? "\($0.rawValue)" }.joined(separator: ", "))]"
    }

    private static let names: [Self: (swift: String, native: String)] = [
        .genPTS: ("genPTS", "AVFMT_FLAG_GENPTS"),
        .ignIdx: ("ignIdx", "AVFMT_FLAG_IGNIDX"),
        .nonBlock: ("nonBlock", "AVFMT_FLAG_NONBLOCK"),
        .ignDTS: ("ignDTS", "AVFMT_FLAG_IGNDTS"),
        .noFillIn: ("noFillIn", "AVFMT_FLAG_NOFILLIN"),
        .noParse: ("noParse", "AVFMT_FLAG_NOPARSE"),
        .noBuffer: ("noBuffer", "AVFMT_FLAG_NOBUFFER"),
        .customIO: ("customIO", "AVFMT_FLAG_CUSTOM_IO"),
        .discardCorrupt: ("discardCorrupt", "AVFMT_FLAG_DISCARD_CORRUPT"),
        .flushPackets: ("flushPackets", "AVFMT_FLAG_FLUSH_PACKETS"),
        .bitexact: ("bitexact", "AVFMT_FLAG_BITEXACT"),
        .sortDTS: ("sortDTS", "AVFMT_FLAG_SORT_DTS"),
        .fastSeek: ("fastSeek", "AVFMT_FLAG_FAST_SEEK"),
        .autoBSF: ("autoBSF", "AVFMT_FLAG_AUTO_BSF"),
    ]
}

// MARK: - Demuxing

public extension AVFormatContext {
    /// The input container format.
    var inputFormat: AVInputFormat? {
        get { native.pointee.iformat.map(AVInputFormat.init(native:)) }
        set { native.pointee.iformat = newValue?.native }
    }

    /// The start time in `AVTimestamp.timebase` units, or `AVTimestamp.noPTS` if unknown.
    var startTime: Int64 {
        native.pointee.start_time
    }

    /// The duration in `AVTimestamp.timebase` units, or `AVTimestamp.noPTS` if unknown.
    var duration: Int64 {
        native.pointee.duration
    }
    
    /// The start time in seconds, or `nil` if unknown.
    var startTimeSeconds: Double? {
        guard startTime != AVTimestamp.noPTS else { return nil }
        return Double(startTime) / Double(AVTimestamp.timebase)
    }

    /// The duration in seconds, or `nil` if unknown.
    var durationSeconds: Double? {
        guard duration != AVTimestamp.noPTS else { return nil }
        return Double(duration) / Double(AVTimestamp.timebase)
    }

    /// Total stream bitrate in bit/s, 0 if not available.
    var bitRate: Int64 {
        native.pointee.bit_rate
    }

    /// The size of the file.
    var size: Int64 {
        (try? ioContext?.size()) ?? 0
    }

    /// Open an input stream and read the header.
    ///
    /// - Parameter url: URL of the stream to open.
    ///   - url: URL of the stream to open.
    ///   - format: If non-nil, this parameter forces a specific input format. Otherwise the format is autodetected.
    ///   - options: A dictionary filled with `AVFormatContext` and demuxer-private options.
    /// - Throws: AVError
    func openInput(at url: String? = nil, format: AVInputFormat? = nil, options: [String: String]? = nil) throws {
        var pm = options?.avDict
        defer { av_dict_free(&pm) }
        try avformat_open_input(&native, url, format?.native, &pm).throwIfFail()
        pm?.dumpUnrecognizedOptions()
    }
    
    func openInput(at url: URL, format: AVInputFormat? = nil, options: [String: String]? = nil) throws {
        try openInput(at: url.pathOrURLString, format: format, options: options)
    }

    /// Read packets of a media file to get stream information.
    ///
    /// This is useful for file formats with no headers such as MPEG.
    /// This function also computes the real framerate in case of MPEG-2 repeat frame mode.
    /// The logical file position is not changed by this function; examined packets may be buffered
    /// for later processing.
    ///
    /// - Note: This function isn't guaranteed to open all the codecs, so options being non-empty at return
    ///   is a perfectly normal behavior.
    ///
    /// - Parameter options: If non-NULL, an `streamCount` long array of pointers to dictionaries,
    ///   where i-th member contains options for codec corresponding to i-th stream. On return each dictionary
    ///   will be filled with options that were not found.
    /// - Throws: AVError
    func findStreamInfo(options: [[String: String]]? = nil) throws {
        guard let options, !options.isEmpty else {
            try avformat_find_stream_info(native, nil).throwIfFail()
            return
        }
        
        var dictionaries = [OpaquePointer?](repeating: nil, count: streams.count)

        for (index, options) in options.prefix(dictionaries.count).enumerated() {
            dictionaries[index] = options.avDict
        }

        defer {
            for index in dictionaries.indices {
                dictionaries[index]?.dumpUnrecognizedOptions()
                av_dict_free(&dictionaries[index])
            }
        }

        try avformat_find_stream_info(native, &dictionaries).throwIfFail()
    }

    /// Find the "best" stream in the file.
    ///
    /// - Parameters:
    ///   - type: stream type
    ///   - wantedStreamIndex: user-requested stream index, or -1 for automatic selection
    ///   - relatedStreamIndex: try to find a stream related (eg. in the same program) to this one, or -1 if none
    /// - Returns: stream index if it exists
    func findBestStream(
        type: AVMediaType,
        wantedStreamIndex: Int = -1,
        relatedStreamIndex: Int = -1
    ) -> Int? {
        let ret = av_find_best_stream(
            native, type.native, Int32(wantedStreamIndex), Int32(relatedStreamIndex), nil, 0
        )
        return ret >= 0 ? Int(ret) : nil
    }

    /**
     Returns the estimated sample aspect ratio for a frame based on the stream and frame information.

     The stream aspect ratio is preferred when valid, allowing container information to override the value encoded in the frame.

     - Parameters:
       - stream: The stream containing the frame.
       - frame: The frame whose sample aspect ratio to estimate.
     - Returns: The estimated sample aspect ratio, or `nil` if it can't be determined.
     */
    func guessSampleAspectRatio(stream: AVStream?, frame: AVFrame? = nil) -> AVRational? {
        let ratio = av_guess_sample_aspect_ratio(native, stream?.native, frame?.native)
        return ratio.num != 0 ? ratio : nil
    }

    /**
     Returns the estimated frame rate based on container and codec information.

     - Parameters:
       - stream: The stream whose frame rate to estimate.
       - frame: The frame to use when estimating the frame rate.
     - Returns: The estimated frame rate, or `nil` if it can't be determined.
     */
    func guessFrameRate(stream: AVStream, frame: AVFrame? = nil) -> AVRational? {
        let frameRate = av_guess_frame_rate(native, stream.native, frame?.native)
        return frameRate.num != 0 ? frameRate : nil
    }

    /// Return the next frame of a stream.
    ///
    /// This function returns what is stored in the file, and does not validate that what is there are valid frames
    /// for the decoder. It will split what is stored in the file into frames and return one for each call. It will
    /// not omit invalid data between valid frames so as to give the decoder the maximum information possible for
    /// decoding.
    ///
    /// - Parameter packet: the packet used to store data
    /// - Throws: AVError
    func readFrame(into packet: AVPacket) throws {
        try av_read_frame(native, packet.native).throwIfFail()
    }

    /// Seek to the keyframe at timestamp.
    ///
    /// - Parameters:
    ///   - timestamp: Timestamp in `AVStream.timebase` units or, if no stream is specified,
    ///     in `AVTimestamp.timebase` units.
    ///   - trackIndex: If `trackIndex` is -1, a default stream is selected, and timestamp
    ///     is automatically converted from `AVTimestamp.timebase` units to the stream specific timebase.
    ///   - flags: flags which select direction and seeking mode
    /// - Throws: AVError
    func seekFrame(to timestamp: Int64, streamIndex: Int = -1, flags: SeekFlag = []) throws {
        try av_seek_frame(native, Int32(streamIndex), timestamp, flags.rawValue).throwIfFail()
    }
    
    /// Seeks to the keyframe at the given timestamp in seconds.
    func seekFrame(toSeconds seconds: Double, streamIndex: Int = -1, flags: SeekFlag = []) throws {
        let timestamp = streamIndex >= 0 ? Int64(seconds / streams[streamIndex].timebase.toDouble) :  Int64(seconds * Double(AVTimestamp.timebase))
        try seekFrame(to: timestamp, streamIndex: streamIndex, flags: flags)
    }

    /// Discard all internally buffered data. This can be useful when dealing with
    /// discontinuities in the byte stream. Generally works only with formats that
    /// can resync. This includes headerless formats like MPEG-TS/TS but should also
    /// work with NUT, Ogg and in a limited way AVI for example.
    ///
    /// The set of tracks, the detected duration, stream parameters and codecs do
    /// not change when calling this function. If you want a complete reset, it's
    /// better to open a new `AVFormatContext`.
    ///
    /// This does not flush the `AVIOContext` (`pb`). If necessary, call `pb.flush`
    /// before calling this function.
    func flush() {
        avformat_flush(native)
    }

    /// Start playing a network-based stream (e.g. RTSP stream) at the current position.
    ///
    /// - Throws: AVError
    func play() throws {
        try av_read_play(native).throwIfFail()
    }

    /// Pause a network-based stream (e.g. RTSP stream).
    ///
    /// Use `play` to resume it.
    ///
    /// - Throws: AVError
    func pause() throws {
        try av_read_pause(native).throwIfFail()
    }
}

// MARK: - AVFormatContext.SeekFlag

public extension AVFormatContext {
    struct SeekFlag: OptionSet {
        /// seek backward
        public static let backward = SeekFlag(rawValue: AVSEEK_FLAG_BACKWARD)
        /// seeking based on position in bytes
        public static let byte = SeekFlag(rawValue: AVSEEK_FLAG_BYTE)
        /// seek to any frame, even non-keyframes
        public static let any = SeekFlag(rawValue: AVSEEK_FLAG_ANY)
        /// seeking based on frame number
        public static let frame = SeekFlag(rawValue: AVSEEK_FLAG_FRAME)

        public let rawValue: Int32

        public init(rawValue: Int32) {
            self.rawValue = rawValue
        }
    }
}

// MARK: - Muxing

public extension AVFormatContext {
    /// The output container format.
    var outputFormat: AVOutputFormat? {
        get { native.pointee.oformat.map(AVOutputFormat.init(native:)) }
        set { native.pointee.oformat = newValue?.native }
    }

    /// Create and initialize a `AVIOContext` for accessing the resource indicated by url.
    ///
    /// - Parameters:
    ///   - url: resource to access
    ///   - flags: flags which control how the resource indicated by url is to be opened
    /// - Throws: AVError
    func openOutput(at url: String, flags: AVIOContext.Flag) throws {
        ioContext = try AVIOContext(url: url, flags: flags)
    }
    
    func openOutput(at url: URL, flags: AVIOContext.Flag) throws {
        try openOutput(at: url.pathOrURLString, flags: flags)
    }

    /// Add a new stream to a media file.
    ///
    /// - Parameter codec: If non-nil, the `AVCodecContext` corresponding to the new stream will be
    ///   initialized to use this codec. This is needed for e.g. codec-specific defaults to be set,
    ///   so codec should be provided if it is known.
    /// - Returns: newly created stream or `nil` on error.
    func addStream(codec: AVCodec? = nil) -> AVStream? {
        avformat_new_stream(native, codec?.native).map(AVStream.init(native:))
    }

    /// Allocate the stream private data and write the stream header to an output media file.
    ///
    /// - Note: The `outputFormat` field must be set to the desired output format;
    ///   The `pb` field must be set to an already opened `AVIOContext`.
    ///
    /// - Parameter options: the `AVFormatContext` and muxer-private options
    /// - Throws: AVError
    func writeHeader(options: [String: String]? = nil) throws {
        var pm = options?.avDict
        defer { av_dict_free(&pm) }
        try avformat_write_header(native, &pm).throwIfFail()
        pm?.dumpUnrecognizedOptions()
    }

    /// Write a packet to an output media file.
    ///
    /// This function passes the packet directly to the muxer, without any buffering or reordering.
    /// The caller is responsible for correctly interleaving the packets if the format requires it.
    /// Callers that want libavformat to handle the interleaving should call
    /// `AVFormatContext.interleavedWriteFrame(_:)` instead of this function.
    ///
    /// - Parameter pkt: The packet containing the data to be written. Note that unlike
    ///   `AVFormatContext.interleavedWriteFrame(_:)`, this function does not take ownership of the
    ///   packet passed to it (though some muxers may make an internal reference to the input packet).
    ///
    ///   This parameter can be `nil` (at any time, not just at the end), in order to immediately flush
    ///   data buffered within the muxer, for muxers that buffer up data internally before writing it
    ///   to the output.
    ///
    ///   Packet's `AVPacket.trackIndex` field must be set to the index of the corresponding stream in
    ///   `tracks`.
    ///
    ///   The timestamps (`AVPacket.pts`, `AVPacket.dts`) must be set to correct values in the stream's
    ///   timebase (unless the output format is flagged with the `AVOutputFormat.Flag.noTimestamps` flag,
    ///   then they can be set to `AVTimestamp.noPTS`).
    ///   The dts for subsequent packets passed to this function must be strictly increasing when compared
    ///   in their respective timebases (unless the output format is flagged with the
    ///   `AVOutputFormat.Flag.tsNonstrict`, then they merely have to be nondecreasing).
    ///   `AVPacket.duration` should also be set if known.
    /// - Throws: AVError
    func writeFrame(_ pkt: AVPacket?) throws {
        try av_write_frame(native, pkt?.native).throwIfFail()
    }

    /// Write a packet to an output media file ensuring correct interleaving.
    ///
    /// This function will buffer the packets internally as needed to make sure the packets in the output file
    /// are properly interleaved in the order of increasing dts.
    /// Callers doing their own interleaving should call `AVFormatContext.writeFrame(_:)` instead of this function.
    ///
    /// Using this function instead of `AVFormatContext.writeFrame(_:)` can give muxers advance knowledge of
    /// future packets, improving e.g. the behaviour of the mp4 muxer for VFR content in fragmenting mode.
    ///
    /// - Parameter pkt: The packet containing the data to be written.
    ///
    ///   If the packet is reference-counted, this function will take ownership of this reference and
    ///   unreference it later when it sees fit.
    ///   The caller must not access the data through this reference after this function returns.
    ///   If the packet is not reference-counted, libavformat will make a copy.
    ///
    ///   This parameter can be `nil` (at any time, not just at the end), to flush the interleaving queues.
    ///
    ///   Packet's `AVPacket.trackIndex` field must be set to the index of the corresponding stream in `tracks`.
    ///
    ///   The timestamps (`AVPacket.pts`, `AVPacket.dts`) must be set to correct values in the stream's timebase
    ///   (unless the output format is flagged with the `AVOutputFormat.Flag.noTimestamps` flag, then they can be
    ///   set to `AVTimestamp.noPTS`).
    ///   The dts for subsequent packets in one stream must be strictly increasing (unless the output format is
    ///   flagged with the `AVOutputFormat.Flag.tsNonstrict`, then they merely have to be nondecreasing).
    ///  `AVPacket.duration` should also be set if known.
    /// - Throws: AVError
    /// - SeeAlso: writeFrame
    func interleavedWriteFrame(_ pkt: AVPacket?) throws {
        try av_interleaved_write_frame(native, pkt?.native).throwIfFail()
    }

    /// Write the stream trailer to an output media file and free the file private data.
    ///
    /// May only be called after a successful call to `writeHeader(options:)`.
    ///
    /// - Throws: AVError
    func writeTrailer() throws {
        try av_write_trailer(native).throwIfFail()
    }
}

extension AVFormatContext: AVClassSupport {
    public static let `class` = AVClass(native: avformat_get_class())

    public func withUnsafeObjectPointer<T>(_ body: (UnsafeMutableRawPointer) throws -> T) rethrows -> T {
        try body(native)
    }
}
