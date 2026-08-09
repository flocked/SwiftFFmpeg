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
import Foundation

public struct AVError: Error, Equatable {
    /// The code of the error.
    public var code: Int32
    /// The message of the error.
    public var message: String

    init(code: Int32) {
        self.code = code
        let buf = UnsafeMutablePointer<Int8>.allocate(capacity: Int(AV_ERROR_MAX_STRING_SIZE))
        buf.initialize(repeating: 0, count: Int(AV_ERROR_MAX_STRING_SIZE))
        defer { buf.deallocate() }
        self.message = av_make_error_string(buf, Int(AV_ERROR_MAX_STRING_SIZE), code).string
    }

    /// Resource temporarily unavailable
    public static let tryAgain = AVError.posix(EAGAIN)
    /// Invalid argument
    public static let invalidArgument = AVError.posix(EINVAL)
    /// Cannot allocate memory
    public static let outOfMemory = AVError.posix(ENOMEM)
    /// The value is out of range
    public static let outOfRange = AVError.posix(ERANGE)
    /// The value is not valid
    public static let invalidValue = AVError.posix(EINVAL)
    /// Function not implemented
    public static let noSystem = AVError.posix(ENOSYS)

    /// Bitstream filter not found
    public static let bitstreamFilterNotFound = AVError(code: swift_AVERROR_BSF_NOT_FOUND)
    /// Internal bug, also see `bug2`
    public static let bug = AVError(code: swift_AVERROR_BUG)
    /// Buffer too small
    public static let bufferTooSmall = AVError(code: swift_AVERROR_BUFFER_TOO_SMALL)
    /// Decoder not found
    public static let decoderNotFound = AVError(code: swift_AVERROR_DECODER_NOT_FOUND)
    /// Demuxer not found
    public static let demuxerNotFound = AVError(code: swift_AVERROR_DEMUXER_NOT_FOUND)
    /// Encoder not found
    public static let encoderNotFound = AVError(code: swift_AVERROR_ENCODER_NOT_FOUND)
    /// End of file.
    public static let eof = AVError(code: swift_AVERROR_EOF)
    /// Immediate exit was requested; the called function should not be restarted
    public static let exit = AVError(code: swift_AVERROR_EXIT)
    /// Generic error in an external library
    public static let external = AVError(code: swift_AVERROR_EXTERNAL)
    /// Filter not found
    public static let filterNotFound = AVError(code: swift_AVERROR_FILTER_NOT_FOUND)
    /// Invalid data found when processing input
    public static let invalidData = AVError(code: swift_AVERROR_INVALIDDATA)
    /// Muxer not found
    public static let muxerNotFound = AVError(code: swift_AVERROR_MUXER_NOT_FOUND)
    /// Option not found
    public static let optionNotFound = AVError(code: swift_AVERROR_OPTION_NOT_FOUND)
    /// Not yet implemented in FFmpeg, patches welcome
    public static let patchWelcome = AVError(code: swift_AVERROR_PATCHWELCOME)
    /// Protocol not found
    public static let protocolNotFound = AVError(code: swift_AVERROR_PROTOCOL_NOT_FOUND)
    /// Stream not found
    public static let streamNotFound = AVError(code: swift_AVERROR_STREAM_NOT_FOUND)
    /// This is semantically identical to ``bug``. It has been introduced in Libav after our `bug` and with a modified value.
    public static let bug2 = AVError(code: swift_AVERROR_BUG2)
    /// Unknown error, typically from an external library
    public static let unknown = AVError(code: swift_AVERROR_UNKNOWN)
    ///  Requested feature is flagged experimental. Set strict_std_compliance if you really want to use it.
    public static let experimental = AVError(code: swift_AVERROR_EXPERIMENTAL)
    /// Input changed between calls. Reconfiguration is required. (can be OR-ed with `outputChanged`)
    public static let inputChanged = AVError(code: swift_AVERROR_INPUT_CHANGED)
    /// Output changed between calls. Reconfiguration is required. (can be OR-ed with `inputChanged`)
    public static let outputChanged = AVError(code: swift_AVERROR_OUTPUT_CHANGED)

    /// Server returned 400 Bad Request.
    public static let httpBadRequest = AVError(code: swift_AVERROR_HTTP_BAD_REQUEST)
    /// Server returned 401 Unauthorized (authorization failed).
    public static let httpUnauthorized = AVError(code: swift_AVERROR_HTTP_UNAUTHORIZED)
    /// Server returned 403 Forbidden (access denied).
    public static let httpForbidden = AVError(code: swift_AVERROR_HTTP_FORBIDDEN)
    /// Server returned 404 Not Found.
    public static let httpNotFound = AVError(code: swift_AVERROR_HTTP_NOT_FOUND)
    /// Server returned 4XX Client Error, other than 400, 401, 402, 403, 404.
    public static let httpOther4xx = AVError(code: swift_AVERROR_HTTP_OTHER_4XX)
    /// Server returned 5XX Server Error reply.
    public static let httpServerError = AVError(code: swift_AVERROR_HTTP_SERVER_ERROR)
    
    /// Returns the FFmpeg error for the specified POSIX error code.
    public static func posix(_ code: POSIXError.Code) -> AVError {
        AVError(code: swift_AVERROR(code.rawValue))
    }
    
    /// Returns the FFmpeg error for the specified POSIX error code.
    public static func posix(_ code: Int32) -> AVError {
        AVError(code: swift_AVERROR(code))
    }
}

extension BinaryInteger {
    func throwIfFail<Output: BinaryInteger>() throws -> Output {
        guard self >= 0 else { throw AVError(code: Int32(self)) }
        return Output(self)
    }
    
    func throwIfFail() throws {
        guard self >= 0 else { throw AVError(code: Int32(self)) }
    }
    
    func abortIfFail() {
        guard self >= 0 else { abort("error: \(AVError(code: Int32(self)))") }
    }
}

func abort(_ message: String) -> Never {
    AVLog.log(message, at: .fatal)
    fatalError(message)
}
