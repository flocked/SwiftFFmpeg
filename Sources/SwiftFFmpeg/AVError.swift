//
//  AVError.swift
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

public struct AVError: Error, Equatable {
    public var code: Int32
    public var message: String

    init(code: Int32) {
        self.code = code
        self.message = Self.message(for: code)
    }
    
    private static func message(for code: Int32) -> String {
        let buf = UnsafeMutablePointer<Int8>.allocate(capacity: Int(AV_ERROR_MAX_STRING_SIZE))
        buf.initialize(repeating: 0, count: Int(AV_ERROR_MAX_STRING_SIZE))
        defer { buf.deallocate() }
        return String(cString: av_make_error_string(buf, Int(AV_ERROR_MAX_STRING_SIZE), code))
    }
}

public extension AVError {
    /// Resource temporarily unavailable
    static let tryAgain = AVError(code: swift_AVERROR(EAGAIN))
    /// Invalid argument
    static let invalidArgument = AVError(code: swift_AVERROR(EINVAL))
    /// Cannot allocate memory
    static let outOfMemory = AVError(code: swift_AVERROR(ENOMEM))
    /// The value is out of range
    static let outOfRange = AVError(code: swift_AVERROR(ERANGE))
    /// The value is not valid
    static let invalidValue = AVError(code: swift_AVERROR(EINVAL))
    /// Function not implemented
    static let noSystem = AVError(code: swift_AVERROR(ENOSYS))

    /// Bitstream filter not found
    static let bitstreamFilterNotFound = AVError(code: swift_AVERROR_BSF_NOT_FOUND)
    /// Internal bug, also see `bug2`
    static let bug = AVError(code: swift_AVERROR_BUG)
    /// Buffer too small
    static let bufferTooSmall = AVError(code: swift_AVERROR_BUFFER_TOO_SMALL)
    /// Decoder not found
    static let decoderNotFound = AVError(code: swift_AVERROR_DECODER_NOT_FOUND)
    /// Demuxer not found
    static let demuxerNotFound = AVError(code: swift_AVERROR_DEMUXER_NOT_FOUND)
    /// Encoder not found
    static let encoderNotFound = AVError(code: swift_AVERROR_ENCODER_NOT_FOUND)
    /// End of file
    static let eof = AVError(code: swift_AVERROR_EOF)
    /// Immediate exit was requested; the called function should not be restarted
    static let exit = AVError(code: swift_AVERROR_EXIT)
    /// Generic error in an external library
    static let external = AVError(code: swift_AVERROR_EXTERNAL)
    /// Filter not found
    static let filterNotFound = AVError(code: swift_AVERROR_FILTER_NOT_FOUND)
    /// Invalid data found when processing input
    static let invalidData = AVError(code: swift_AVERROR_INVALIDDATA)
    /// Muxer not found
    static let muxerNotFound = AVError(code: swift_AVERROR_MUXER_NOT_FOUND)
    /// Option not found
    static let optionNotFound = AVError(code: swift_AVERROR_OPTION_NOT_FOUND)
    /// Not yet implemented in FFmpeg, patches welcome
    static let patchWelcome = AVError(code: swift_AVERROR_PATCHWELCOME)
    /// Protocol not found
    static let protocolNotFound = AVError(code: swift_AVERROR_PROTOCOL_NOT_FOUND)
    /// Stream not found
    static let streamNotFound = AVError(code: swift_AVERROR_STREAM_NOT_FOUND)
    /// This is semantically identical to `bug`. It has been introduced in Libav after our `bug` and
    /// with a modified value.
    static let bug2 = AVError(code: swift_AVERROR_BUG2)
    /// Unknown error, typically from an external library
    static let unknown = AVError(code: swift_AVERROR_UNKNOWN)
    ///  Requested feature is flagged experimental. Set strict_std_compliance if you really want to use it.
    static let experimental = AVError(code: swift_AVERROR_EXPERIMENTAL)
    /// Input changed between calls. Reconfiguration is required. (can be OR-ed with `outputChanged`)
    static let inputChanged = AVError(code: swift_AVERROR_INPUT_CHANGED)
    /// Output changed between calls. Reconfiguration is required. (can be OR-ed with `inputChanged`)
    static let outputChanged = AVError(code: swift_AVERROR_OUTPUT_CHANGED)

    /* HTTP & RTSP errors */
    static let httpBadRequest = AVError(code: swift_AVERROR_HTTP_BAD_REQUEST)
    static let httpUnauthorized = AVError(code: swift_AVERROR_HTTP_UNAUTHORIZED)
    static let httpForbidden = AVError(code: swift_AVERROR_HTTP_FORBIDDEN)
    static let httpNotFound = AVError(code: swift_AVERROR_HTTP_NOT_FOUND)
    static let httpOther4xx = AVError(code: swift_AVERROR_HTTP_OTHER_4XX)
    static let httpServerError = AVError(code: swift_AVERROR_HTTP_SERVER_ERROR)
}

func throwIfFail(_ condition: @autoclosure () -> Int32) throws {
    let code = condition()
    if code < 0 {
        throw AVError(code: code)
    }
}

func throwIfFail<Input: BinaryInteger, Output: BinaryInteger>(_ condition: @autoclosure () -> Input) throws -> Output {
    let code = Int32(condition())
    if code < 0 {
        throw AVError(code: code)
    }
    return Output(code)
}

func abortIfFail(_ condition: @autoclosure () -> Int32) {
    let code = condition()
    if code < 0 {
        abort("error: \(AVError(code: code))")
    }
}

func abort(_ message: String) -> Never {
    AVLog.log(level: .fatal, message: message)
    fatalError(message)
}
