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
     Sets a custom callback handler for FFmpeg log messages and their associated levels.
     
     If you provide a custom handler, you are responsible for printing messages if needed.

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
    enum Level: Int32, CaseIterable, CustomStringConvertible, Hashable, Sendable {
        /// Print no output.
        case quiet = -8
        /// Something went really wrong and we will crash now.
        case panic = 0
        /**
         Something went wrong and recovery is not possible.
         
         For example, no header was found for a format which depends on headers or an illegal combination of parameters is used.
         */
        case fatal = 8
        /// Something went wrong and cannot losslessly be recovered. However, not all future data is affected.
        case error = 16
        /// Something somehow does not look correct. This may or may not lead to problems. An example would be the use of '-vstrict -2'.
        case warning = 24
        /// Standard information.
        case info = 32
        /// Detailed information.
        case verbose = 40
        /// Stuff which is only useful for libav* developers.
        case debug = 48
        /// Extremely verbose debugging, useful for libav* development.
        case trace = 56
        
        public var description: String {
            switch self {
            case .quiet: "quiet"
            case .panic: "panic"
            case .fatal: "fatal"
            case .error: "error"
            case .warning: "warning"
            case .info: "info"
            case .verbose: "verbose"
            case .debug: "debug"
            case .trace: "trace"
            }
        }
        
        public init(rawValue: Int32) {
            self = Self.allCases.last(where: { $0.rawValue <= rawValue }) ?? .quiet
        }
    }
}
