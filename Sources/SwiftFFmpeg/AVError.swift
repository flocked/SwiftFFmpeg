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
    static let tryAgain = AVError.posix(EAGAIN)
    /// Invalid argument
    static let invalidArgument = AVError.posix(EINVAL)
    /// Cannot allocate memory
    static let outOfMemory = AVError.posix(ENOMEM)
    /// The value is out of range
    static let outOfRange = AVError.posix(ERANGE)
    /// The value is not valid
    static let invalidValue = AVError.posix(EINVAL)
    /// Function not implemented
    static let noSystem = AVError.posix(ENOSYS)

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
    /// End of file.
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
    /// This is semantically identical to ``bug``. It has been introduced in Libav after our `bug` and with a modified value.
    static let bug2 = AVError(code: swift_AVERROR_BUG2)
    /// Unknown error, typically from an external library
    static let unknown = AVError(code: swift_AVERROR_UNKNOWN)
    ///  Requested feature is flagged experimental. Set strict_std_compliance if you really want to use it.
    static let experimental = AVError(code: swift_AVERROR_EXPERIMENTAL)
    /// Input changed between calls. Reconfiguration is required. (can be OR-ed with `outputChanged`)
    static let inputChanged = AVError(code: swift_AVERROR_INPUT_CHANGED)
    /// Output changed between calls. Reconfiguration is required. (can be OR-ed with `inputChanged`)
    static let outputChanged = AVError(code: swift_AVERROR_OUTPUT_CHANGED)

    /// Server returned 400 Bad Request.
    static let httpBadRequest = AVError(code: swift_AVERROR_HTTP_BAD_REQUEST)
    /// Server returned 401 Unauthorized (authorization failed).
    static let httpUnauthorized = AVError(code: swift_AVERROR_HTTP_UNAUTHORIZED)
    /// Server returned 403 Forbidden (access denied).
    static let httpForbidden = AVError(code: swift_AVERROR_HTTP_FORBIDDEN)
    /// Server returned 404 Not Found.
    static let httpNotFound = AVError(code: swift_AVERROR_HTTP_NOT_FOUND)
    /// Server returned 4XX Client Error, other than 400, 401, 402, 403, 404.
    static let httpOther4xx = AVError(code: swift_AVERROR_HTTP_OTHER_4XX)
    /// Server returned 5XX Server Error reply.
    static let httpServerError = AVError(code: swift_AVERROR_HTTP_SERVER_ERROR)
    
    /// A posix error for the specified posix error code.
    static func posix(_ code: POSIXError.Code) -> AVError {
        AVError(code: swift_AVERROR(code.rawValue))
    }
    
    /// A posix error for the specified posix error code.
    static func posix(_ code: Int32) -> AVError {
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
