//
//  AVLog.swift
//  SwiftFFmpeg
//
//  Created by sunlubo on 2019/1/13.
//

import CFFmpeg
import Foundation
import os

public enum AVLog {
    /// Get/set the log level.
    public static var level: Level {
        get { Level(rawValue: av_log_get_level()) }
        set { av_log_set_level(newValue.rawValue) }
    }

    /// Send the specified message to the log if the level is less than or equal
    /// to the current level. By default, all logging messages are sent to
    /// stderr. This behavior can be altered by setting a different logging callback
    /// function.
    public static func log(_ items: Any..., at level: Level, separator: String = " ", terminator: String = "\n") {
        swift_log(nil, level.rawValue, items.map { String(describing: $0) }.joined(separator: separator) + terminator)
    }

    /// Send the specified message to the log if the level is less than or equal
    /// to the current level. By default, all logging messages are sent to
    /// stderr. This behavior can be altered by setting a different logging callback
    /// function.
    public static func log(_ items: Any..., at level: Level, context: AVClassSupport, separator: String = " ", terminator: String = "\n") {
        context.withUnsafeObjectPointer { ptr in
            swift_log(ptr, level.rawValue, items.map { String(describing: $0) }.joined(separator: separator) + terminator)
        }
    }
    
    /**
     Sets the callback handler for FFmpeg log messages and their associated levels.

     Pass `nil` to restore the default logging callback.
     */
    public static func setCallback(_ handler: (@Sendable (_ level: Level, _ message: String) -> Void)?) {
        self.handler = handler
        if handler == nil {
            swift_initialize_ffmpeg_logging()
            return
        }
        av_log_set_callback { _, level, format, args in
            guard let format, let args, let handler = AVLog.handler else { return }
            let message = NSString(format: format.string, arguments: args) as String
            handler(Level(rawValue: level), message)
        }
    }
    
    private static var handler: (@Sendable (_ level: Level, _ message: String) -> Void)?
}

// MARK: - AVLog.Level

public extension AVLog {
    /// Log level
    struct Level: OptionSet, Hashable, CustomStringConvertible, CustomDebugStringConvertible {
        /// Print no output.
        public static let quiet = Level(rawValue: AV_LOG_QUIET)
        /// Something went really wrong and we will crash now.
        public static let panic = Level(rawValue: AV_LOG_PANIC)
        /// Something went wrong and recovery is not possible.
        /// For example, no header was found for a format which depends
        /// on headers or an illegal combination of parameters is used.
        public static let fatal = Level(rawValue: AV_LOG_FATAL)
        /// Something went wrong and cannot losslessly be recovered.
        /// However, not all future data is affected.
        public static let error = Level(rawValue: AV_LOG_ERROR)
        /// Something somehow does not look correct. This may or may not
        /// lead to problems. An example would be the use of '-vstrict -2'.
        public static let warning = Level(rawValue: AV_LOG_WARNING)
        /// Standard information.
        public static let info = Level(rawValue: AV_LOG_INFO)
        /// Detailed information.
        public static let verbose = Level(rawValue: AV_LOG_VERBOSE)
        /// Stuff which is only useful for libav* developers.
        public static let debug = Level(rawValue: AV_LOG_DEBUG)
        /// Extremely verbose debugging, useful for libav* development.
        public static let trace = Level(rawValue: AV_LOG_TRACE)

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
            .quiet: ("quiet", "AV_LOG_QUIET"),
            .panic: ("panic", "AV_LOG_PANIC"),
            .fatal: ("fatal", "AV_LOG_FATAL"),
            .error: ("error", "AV_LOG_ERROR"),
            .warning: ("warning", "AV_LOG_WARNING"),
            .info: ("info", "AV_LOG_INFO"),
            .verbose: ("verbose", "AV_LOG_VERBOSE"),
            .debug: ("debug", "AV_LOG_DEBUG"),
            .trace: ("trace", "AV_LOG_TRACE"),
        ]
    }
}
