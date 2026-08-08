//
//  AVCodecParser.swift
//  SwiftFFmpeg
//
//  Created by sunlubo on 2018/7/1.
//

import CFFmpeg

// MARK: - AVCodecParser

typealias CAVCodecParser = CFFmpeg.AVCodecParser

public struct AVCodecParser {
    let native: UnsafeMutablePointer<CAVCodecParser>

    /// Several codec IDs are permitted
    public var codecIds: [AVCodecID] {
        [native.pointee.codec_ids.0, native.pointee.codec_ids.1, native.pointee.codec_ids.2, native.pointee.codec_ids.3,].map { AVCodecID(native: $0) }.filter { $0 != .none }
    }

    /// Get all registered codec parsers.
    public static var supportedParsers: [AVCodecParser] {
        var list = [AVCodecParser]()
        var state: UnsafeMutableRawPointer?
        while let ptr = av_parser_iterate(&state) {
            list.append(AVCodecParser(native: ptr.mutable))
        }
        return list
    }
}

/// Describes whether a picture is coded as a frame or as one field.
public enum AVPictureStructure: UInt32 {
    /// The picture structure is unknown.
    case unknown
    /// The picture is coded as a top field.
    case topField
    /// The picture is coded as a bottom field.
    case bottomField
    /// The picture is coded as a frame.
    case frame

    init(native: CFFmpeg.AVPictureStructure) {
        guard let structure = Self(rawValue: native.rawValue) else {
            fatalError("Unknown picture structure: \(native)")
        }
        self = structure
    }

    var native: CFFmpeg.AVPictureStructure {
        CFFmpeg.AVPictureStructure(rawValue)
    }
}

public final class AVCodecParserContext {
    let native: UnsafeMutablePointer<CFFmpeg.AVCodecParserContext>
    let codecContext: AVCodecContext

    public init?(codecContext: AVCodecContext) {
        precondition(codecContext.codec != nil, "'AVCodecContext.codec' must not be nil.")
        guard let ptr = av_parser_init(codecContext.codec!.id.native) else {
            return nil
        }
        self.native = ptr
        self.codecContext = codecContext
    }
    
    /// Parse a packet.
    ///
    /// - Parameters:
    ///   - data: input buffer.
    ///   - size: buffer size in bytes without the padding.
    ///     I.e. the full buffer size is assumed to be `buf_size + AVConstant.inputBufferPaddingSize`.
    ///     To signal EOF, this should be 0 (so that the last frame can be output).
    ///   - pts: input presentation timestamp.
    ///   - dts: input decoding timestamp.
    ///   - pos: input byte position in stream.
    /// - Returns: The parsed result.
    /// - Throws: AVError
    public func parse(
        data: UnsafePointer<UInt8>,
        size: Int,
        pts: Int64 = AVTimestamp.noPTS,
        dts: Int64 = AVTimestamp.noPTS,
        pos: Int64 = 0
    ) throws -> (buffer: UnsafeMutablePointer<UInt8>?, bufferSize: Int, bytesUsed: Int) {
        var buf: UnsafeMutablePointer<UInt8>?
        var bufSize: Int32 = 0
        let ret = av_parser_parse2(
            native,
            codecContext.native,
            &buf,
            &bufSize,
            data,
            Int32(size),
            pts,
            dts,
            pos
        )
        try ret.throwIfFail()
        return (buf, Int(bufSize), Int(ret))
    }

    /// The byte offset of the current frame.
    public var frameOffset: Int64 {
        native.pointee.frame_offset
    }

    /// The current parser byte offset, incremented as input is parsed.
    public var currentOffset: Int64 {
        native.pointee.cur_offset
    }

    /// The byte offset of the next frame.
    public var nextFrameOffset: Int64 {
        native.pointee.next_frame_offset
    }

    /// The picture type of the current frame.
    public var pictureType: AVPictureType {
        AVPictureType(native: CFFmpeg.AVPictureType(UInt32(native.pointee.pict_type)))
    }

    /**
     The repeat-picture count used to compute frame duration.

     This is used by codecs such as H.264 when displaying telecined material.
     */
    public var repeatPicture: Int {
        Int(native.pointee.repeat_pict)
    }

    /// The presentation timestamp of the current frame.
    public var pts: Int64 {
        native.pointee.pts
    }

    /// The decoding timestamp of the current frame.
    public var dts: Int64 {
        native.pointee.dts
    }

    /// The byte offset from the start of the input packet.
    public var offset: Int64 {
        native.pointee.offset
    }

    /// Whether the current frame is a key frame, or `nil` if unknown.
    public var isKeyFrame: Bool? {
        let keyFrame = native.pointee.key_frame
        return keyFrame >= 0 ? keyFrame == 1 : nil
    }

    /// The timestamp synchronization point used for timestamp generation.
    public var dtsSyncPoint: Int {
        Int(native.pointee.dts_sync_point)
    }

    /**
     The current timestamp offset from the last timestamp synchronization point.

     This is expressed in units of the codec context timebase.
     */
    public var dtsReferenceDelta: Int {
        Int(native.pointee.dts_ref_dts_delta)
    }

    /**
     The presentation delay of the current frame.

     This is expressed in units of the codec context timebase.
     */
    public var ptsDtsDelta: Int {
        Int(native.pointee.pts_dts_delta)
    }

    /// The byte position of the currently parsed frame in the stream.
    public var position: Int64 {
        native.pointee.pos
    }

    /// The byte position of the previous frame in the stream.
    public var lastPosition: Int64 {
        native.pointee.last_pos
    }

    /**
     The duration of the current frame.

     For audio, this is in units of `1 / sampleRate`; for other media types, this is in units of the codec context timebase.
     */
    public var duration: Int {
        Int(native.pointee.duration)
    }

    /// The field order of the parsed video.
    public var fieldOrder: AVFieldOrder {
        AVFieldOrder(native: native.pointee.field_order)
    }

    /// Whether the picture is coded as a frame, top field, or bottom field.
    public var pictureStructure: AVPictureStructure {
        AVPictureStructure(native: native.pointee.picture_structure)
    }

    /// The picture number incremented in presentation or output order.
    public var outputPictureNumber: Int {
        Int(native.pointee.output_picture_number)
    }

    /// The decoded video width intended for presentation.
    public var width: Int {
        Int(native.pointee.width)
    }

    /// The decoded video height intended for presentation.
    public var height: Int {
        Int(native.pointee.height)
    }

    /// The coded video width.
    public var codedWidth: Int {
        Int(native.pointee.coded_width)
    }

    /// The coded video height.
    public var codedHeight: Int {
        Int(native.pointee.coded_height)
    }

    /// The pixel format when the parser context describes video data.
    public var pixelFormat: AVPixelFormat {
        .init(rawValue: native.pointee.format)
    }

    /// The sample format when the parser context describes audio data.
    public var sampleFormat: AVSampleFormat {
        .init(native: .init(native.pointee.format))
    }

    deinit {
        av_parser_close(native)
    }
}
