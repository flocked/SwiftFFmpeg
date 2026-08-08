//
//  AVOption.swift
//  SwiftFFmpeg
//
//  Created by sunlubo on 2018/7/10.
//

import CFFmpeg
import Foundation

// MARK: - AVOption

typealias CAVOption = CFFmpeg.AVOption

public struct AVOption {
    public let name: String
    /// The short English help text about the option.
    public let help: String?
    /// The offset relative to the context structure where the option value is stored.
    /// It should be 0 for named constants.
    public let offset: Int
    /// The default value for scalar options.
    public let defaultValue: Any?
    /// The minimum valid value for the option.
    public let min: Double
    /// The maximum valid value for the option.
    public let max: Double
    public let flags: Flag
    /// The logical unit to which the option belongs.
    /// Non-constant options and corresponding named constants share the same unit.
    public let unit: String?
    public let type: Kind

    init(native: CFFmpeg.AVOption) {
        self.name = String(cString: native.name)
        self.help = String(cString: native.help)
        self.unit = String(cString: native.unit)
        self.offset = Int(native.offset)
        self.min = native.min
        self.max = native.max
        self.flags = Flag(rawValue: native.flags)
        self.type = Kind(native: native.type)
        if !type.isArray {
            switch type.element {
            case .pixelFormat:
                self.defaultValue = AVPixelFormat(rawValue: Int32(clamping: native.default_val.i64))
            case .sampleFormat:
                self.defaultValue = AVSampleFormat(rawValue: Int32(clamping: native.default_val.i64))
            case .flags:
                self.defaultValue = AVOption.Flag(rawValue: Int32(clamping: native.default_val.i64))
            case .int:
                self.defaultValue = Int32(clamping: native.default_val.i64)
            case .int64, .const, .duration, .channelLayout:
                self.defaultValue = native.default_val.i64
            case .uInt:
                self.defaultValue = UInt32(clamping: native.default_val.i64)
            case .uInt64:
                self.defaultValue = UInt64(clamping: native.default_val.i64)
            case .double:
                self.defaultValue = native.default_val.dbl
            case .float:
                self.defaultValue = Float(native.default_val.dbl)
            case .bool:
                self.defaultValue = native.default_val.i64 != 0
            case .string:
                self.defaultValue = String(cString: native.default_val.str)
            case .rational, .videoRate:
                self.defaultValue =  native.default_val.q
            case .binary:
                self.defaultValue = nil
            case .dict:
                self.defaultValue = nil
            case .color:
                if let name = String(cString: native.default_val.str), let color = AVColor(name: name) {
                    self.defaultValue = color
                } else {
                    self.defaultValue = String(cString: native.default_val.str)
                }
            case .imageSize:
                if let name = String(cString: native.default_val.str), let size = AVImageSize(name: name) {
                    self.defaultValue = size
                } else {
                    self.defaultValue = String(cString: native.default_val.str)
                }
            }
        } else {
            self.defaultValue = nil
        }
    }
}

extension CFFmpeg.AVOptionArrayDef {
    func values<V: LosslessStringConvertible>(as type: V.Type = V.self) -> [V]? {
        guard let def else { return nil }
        let bytes = Array(String(cString: def).utf8)
        let separator = sep == 0 ? UInt8(ascii: ",") : UInt8(bitPattern: sep)
        var values: [V] = []
        var current: [UInt8] = []
        var isEscaped = false
        for byte in bytes {
            if isEscaped {
                current.append(byte)
                isEscaped = false
                continue
            }
            switch byte {
            case UInt8(ascii: "\\"):
                isEscaped = true
            case separator:
                guard let value = V(String(decoding: current, as: UTF8.self)) else {
                    return nil
                }
                values.append(value)
                current.removeAll(keepingCapacity: true)
            default:
                current.append(byte)
            }
        }
        if isEscaped {
            current.append(UInt8(ascii: "\\"))
        }
        guard let value = V(String(decoding: current, as: UTF8.self)) else {
            return nil
        }
        values.append(value)
        return values
    }
}

extension AVOption: CustomStringConvertible {
    public var description: String {
        var str = "{name: \"\(name)\", "
        if let help = help {
            str += "help: \"\(help)\", "
        }
        str += "offset: \(offset), type: \(type), "
        if let defaultValue = defaultValue {
            if defaultValue is String {
                str += "default: \"\(defaultValue)\", "
            } else {
                str += "default: \(defaultValue), "
            }
        } else {
            str += "default: -, "
        }
        str += "min: \(min), max: \(max), flags: \(flags), "
        if let unit = unit {
            str += "unit: \"\(unit)\""
        } else {
            str.removeLast(2)
        }
        str += "}"
        return str
    }
}

// MARK: - AVOption.Kind

public extension AVOption {
    /*
    /// https://github.com/FFmpeg/FFmpeg/blob/master/libavutil/opt.h#L221
    enum Kind: UInt32, CustomStringConvertible {
        case flags = 1
        case int
        case int64
        case double
        case float
        case string
        case rational
        /// offset must point to a pointer immediately followed by an int for the length
        case binary
        case dict
        case uint64
        case const
        /// offset must point to two consecutive integers
        case imageSize
        case pixelFormat
        case sampleFormat
        /// offset must point to `AVRational`
        case videoRate
        case duration
        case color
        case bool
        case channelLayout
        case uint
        case flagArray = 65536
        
        init(native: CFFmpeg.AVOptionType) {
            if let kind = Kind(rawValue: native.rawValue) {
                self = kind
            } else if native.rawValue & Kind.flagArray.rawValue != 0 {
                self = .flagArray
            } else {
                fatalError("Unknown option type: \(native.rawValue)")
            }
        }
        
        var native: CFFmpeg.AVOptionType {
            .init(rawValue: rawValue)
        }
        
        public var description: String {
            switch self {
            case .flags: "flags"
            case .int: "Int32"
            case .int64: "Int64"
            case .uint: "UInt32"
            case .uint64: "UInt64"
            case .float: "Float"
            case .double: "Double"
            case .string: "String"
            case .rational: "AVRational"
            case .binary: "Data"
            case .dict: "[String: String]"
            case .const: "Constant"
            case .imageSize: "image size"
            case .pixelFormat: "AVPixelFormat"
            case .sampleFormat: "AVSampleFormat"
            case .videoRate: "AVRational (video rate)"
            case .duration: "Int64 (duration)"
            case .color: "color"
            case .channelLayout: "AVChannelLayout"
            case .bool: "Bool"
            case .flagArray: "flag array"
            }
        }
    }
     */
    
    struct Kind: RawRepresentable, Hashable, CustomStringConvertible {
        public let rawValue: UInt32

        private static let arrayFlag: UInt32 = 1 << 16

        public var isArray: Bool {
            rawValue & Self.arrayFlag != 0
        }
        
        public var element: Element {
            Element(rawValue: rawValue & ~Self.arrayFlag)!
        }
        
        var native: CFFmpeg.AVOptionType {
            .init(rawValue: rawValue)
        }
        
        public static let flags = Self(.flags)
        public static let float = Self(.float)
        public static let double = Self(.double)
        public static let int = Self(.int)
        public static let int64 = Self(.int64)
        public static let uInt = Self(.uInt)
        public static let uInt64 = Self(.uInt64)
        public static let string = Self(.string)
        public static let rational = Self(.rational)
        public static let binary = Self(.binary)
        public static let dict = Self(.dict)
        public static let const = Self(.const)
        public static let imageSize = Self(.imageSize)
        public static let pixelFormat = Self(.pixelFormat)
        public static let sampleFormat = Self(.sampleFormat)
        public static let videoRate = Self(.videoRate)
        public static let duration = Self(.duration)
        public static let color = Self(.color)
        public static let bool = Self(.bool)
        public static let channelLayout = Self(.channelLayout)
        
        public static func array(_ element: Element) -> Self {
            .init(element, isArray: true)
        }
        
        init(native: CFFmpeg.AVOptionType) {
            self.rawValue = native.rawValue
        }

        public init(rawValue: UInt32) {
            self.rawValue = rawValue
        }

        public init(_ element: Element, isArray: Bool = false) {
            self.rawValue = element.rawValue | (isArray ? Self.arrayFlag : 0)
        }

        public var description: String {
            isArray ? "[\(element.description)]" : element.description
        }

        public enum Element: UInt32, CustomStringConvertible {
            case flags = 1
            case int
            case int64
            case double
            case float
            case string
            case rational
            case binary
            case dict
            case uInt64
            case const
            case imageSize
            case pixelFormat
            case sampleFormat
            case videoRate
            case duration
            case color
            case bool
            case channelLayout
            case uInt

            public var description: String {
                switch self {
                case .flags: "AVOption.Flag"
                case .int: "Int32"
                case .int64: "Int64"
                case .double: "Double"
                case .float: "Float"
                case .string: "String"
                case .rational: "AVRational"
                case .binary: "[UInt8]"
                case .dict: "[String: String]"
                case .uInt64: "UInt64"
                case .const: "Constant"
                case .imageSize: "AVImageSize"
                case .pixelFormat: "AVPixelFormat"
                case .sampleFormat: "AVSampleFormat"
                case .videoRate: "AVRational (video rate)"
                case .duration: "Int64 (duration)"
                case .color: "AVColor"
                case .bool: "Bool"
                case .channelLayout: "AVChannelLayout"
                case .uInt: "UInt32"
                }
            }
        }
    }
}

// MARK: - AVOption.Flag

public extension AVOption {
    /// https://github.com/FFmpeg/FFmpeg/blob/master/libavutil/opt.h#L221
    struct Flag: OptionSet, Hashable {
        /// A generic parameter which can be set by the user for muxing or encoding.
        public static let encoding = Flag(rawValue: AV_OPT_FLAG_ENCODING_PARAM)
        /// A generic parameter which can be set by the user for demuxing or decoding.
        public static let decoding = Flag(rawValue: AV_OPT_FLAG_DECODING_PARAM)
        /// Audio.
        public static let audio = Flag(rawValue: AV_OPT_FLAG_AUDIO_PARAM)
        /// Video.
        public static let video = Flag(rawValue: AV_OPT_FLAG_VIDEO_PARAM)
        /// Subtitle.
        public static let subtitle = Flag(rawValue: AV_OPT_FLAG_SUBTITLE_PARAM)
        /// The option is intended for exporting values to the caller.
        public static let export = Flag(rawValue: AV_OPT_FLAG_EXPORT)
        /// The option may not be set through the `AVOption` API, only read.
        /// This flag only makes sense when `export` is also set.
        public static let readonly = Flag(rawValue: AV_OPT_FLAG_READONLY)
        /// A generic parameter which can be set by the user for bit stream filtering.
        public static let bsf = Flag(rawValue: AV_OPT_FLAG_BSF_PARAM)
        /// A generic parameter which can be set by the user for filtering.
        public static let filtering = Flag(rawValue: AV_OPT_FLAG_FILTERING_PARAM)
        /// Set if option is deprecated, users should refer to `AVOption.help` text for more information.
        public static let deprecated = Flag(rawValue: AV_OPT_FLAG_DEPRECATED)

        public let rawValue: Int32

        public init(rawValue: Int32) {
            self.rawValue = rawValue
        }
    }
}

extension AVOption.Flag: CustomStringConvertible, CustomDebugStringConvertible {
    public var description: String {
        "[\(elements().map { Self.names[$0]?.swift ?? "\($0.rawValue)" }.joined(separator: ", "))]"
    }

    public var debugDescription: String {
        "[\(elements().map { Self.names[$0]?.native ?? "\($0.rawValue)" }.joined(separator: ", "))]"
    }

    private static let names: [Self: (swift: String, native: String)] = [
        .encoding: ("encoding", "AV_OPT_FLAG_ENCODING_PARAM"),
        .decoding: ("decoding", "AV_OPT_FLAG_DECODING_PARAM"),
        .audio: ("audio", "AV_OPT_FLAG_AUDIO_PARAM"),
        .video: ("video", "AV_OPT_FLAG_VIDEO_PARAM"),
        .subtitle: ("subtitle", "AV_OPT_FLAG_SUBTITLE_PARAM"),
        .export: ("export", "AV_OPT_FLAG_EXPORT"),
        .readonly: ("readonly", "AV_OPT_FLAG_READONLY"),
        .bsf: ("bsf", "AV_OPT_FLAG_BSF_PARAM"),
        .filtering: ("filtering", "AV_OPT_FLAG_FILTERING_PARAM"),
        .deprecated: ("deprecated", "AV_OPT_FLAG_DEPRECATED"),
    ]
}

// MARK: - AVOptionSearchFlag

public extension AVOption {
    /// https://github.com/FFmpeg/FFmpeg/blob/master/libavutil/opt.h#L556
    struct SearchFlag: OptionSet {
        /// Search in possible children of the given object first.
        public static let children = SearchFlag(rawValue: 1 << 0)
        /// The obj passed to `av_opt_find()` is fake – only a double pointer to `AVClass`
        /// instead of a required pointer to a struct containing `AVClass`.
        /// This is useful for searching for options without needing to allocate the corresponding object.
        public static let fakeObject = SearchFlag(rawValue: 1 << 1)
        /// In av_opt_get, return NULL if the option has a pointer type and is set to NULL,
        /// rather than returning an empty string.
        public static let nullable = SearchFlag(rawValue: 1 << 2)

        public let rawValue: Int32

        public init(rawValue: Int32) {
            self.rawValue = rawValue
        }
    }
}

// MARK: - AVOptionSupport

/// A type that exposes an FFmpeg object pointer for ``AVOption`` access.
public protocol AVOptionSupport {
    /// Calls the given closure with the underlying FFmpeg object pointer.
    func withUnsafeObjectPointer<T>(_ body: (UnsafeMutableRawPointer) throws -> T) rethrows -> T
}

public extension AVOptionSupport {
    /// Returns an array of the options supported by the type.
    var supportedOptions: [AVOption] {
        withUnsafeObjectPointer { ptr in
            var options: [AVOption] = []
            var prev: UnsafePointer<CFFmpeg.AVOption>?
            while let option = av_opt_next(ptr, prev) {
                options.append(AVOption(native: option.pointee))
                prev = option
            }
            return options
        }
    }
}

// MARK: - Option Getter

public extension AVOptionSupport {
    /// Returns the string value associated with the specified key.
    ///
    /// - Parameters:
    ///   - key: The name of the option to get.
    ///   - searchFlags: The flags passed to av_opt_find2.
    /// - Returns: The string value associated with the specified key.
    /// - Throws: AVError
    func string(forKey key: String, searchFlags: AVOption.SearchFlag = .children) throws -> String {
        try withUnsafeObjectPointer { ptr in
            var value: UnsafeMutablePointer<UInt8>!
            defer { av_free(value) }
            try throwIfFail(av_opt_get(ptr, key, searchFlags.rawValue, &value))
            return String(cString: value)
        }
    }
    
    func integer(forKey key: String, searchFlags: AVOption.SearchFlag = .children) throws -> Int64 {
        try integer(forKey: key, searchFlags: searchFlags, as: Int64.self)
    }

    /// Returns the integer value associated with the specified key.
    ///
    /// - Parameters:
    ///   - key: The name of the option to get.
    ///   - searchFlags: The flags passed to av_opt_find2.
    /// - Returns: The integer value associated with the specified key.
    /// - Throws: AVError
    func integer<T: FixedWidthInteger>(forKey key: String, searchFlags: AVOption.SearchFlag = .children, as type: T.Type = T.self) throws -> T {
        try withUnsafeObjectPointer { ptr in
            var value: Int64 = 0
            try throwIfFail(av_opt_get_int(ptr, key, searchFlags.rawValue, &value))
            return T(value)
        }
    }
    
    func flags(forKey key: String, searchFlags: AVOption.SearchFlag = .children) throws -> AVOption.Flag {
        try AVOption.Flag(rawValue: integer(forKey: key, searchFlags: searchFlags))
    }

    /// Returns the double value associated with the specified key.
    ///
    /// - Parameters:
    ///   - key: The name of the option to get.
    ///   - searchFlags: The flags passed to av_opt_find2.
    /// - Returns: The double value associated with the specified key.
    /// - Throws: AVError
    func double(forKey key: String, searchFlags: AVOption.SearchFlag = .children) throws -> Double {
        try withUnsafeObjectPointer { ptr in
            var value: Double = 0
            try throwIfFail(av_opt_get_double(ptr, key, searchFlags.rawValue, &value))
            return value
        }
    }
    
    func float(forKey key: String, searchFlags: AVOption.SearchFlag = .children) throws -> Float {
        try Float(double(forKey: key, searchFlags: searchFlags))
    }

    /// Returns the rational value associated with the specified key.
    ///
    /// - Parameters:
    ///   - key: The name of the option to get.
    ///   - searchFlags: The flags passed to av_opt_find2.
    /// - Returns: The rational value associated with the specified key.
    /// - Throws: AVError
    func rational(forKey key: String, searchFlags: AVOption.SearchFlag = .children) throws -> AVRational {
        try withUnsafeObjectPointer { ptr in
            var value = AVRational(num: 0, den: 0)
            try throwIfFail(av_opt_get_q(ptr, key, searchFlags.rawValue, &value))
            return value
        }
    }

    /// Returns the image size associated with the specified key.
    ///
    /// - Parameters:
    ///   - key: The name of the option to get.
    ///   - searchFlags: The flags passed to av_opt_find2.
    /// - Returns: The image size associated with the specified key.
    /// - Throws: AVError
    func imageSize(forKey key: String, searchFlags: AVOption.SearchFlag = .children) throws -> AVImageSize {
        try withUnsafeObjectPointer { ptr in
            var width: Int32 = 0
            var height: Int32 = 0
            try throwIfFail(av_opt_get_image_size(ptr, key, searchFlags.rawValue, &width, &height))
            return AVImageSize(width: Int(width), height: Int(height))
        }
    }

    /// Returns the pixel format associated with the specified key.
    ///
    /// - Parameters:
    ///   - key: The name of the option to get.
    ///   - searchFlags: The flags passed to av_opt_find2.
    /// - Returns: The pixel format associated with the specified key.
    /// - Throws: AVError
    func pixelFormat(orKey key: String, searchFlags: AVOption.SearchFlag = .children) throws -> AVPixelFormat {
        try withUnsafeObjectPointer { ptr in
            var value = AVPixelFormat.none
            try throwIfFail(av_opt_get_pixel_fmt(ptr, key, searchFlags.rawValue, &value))
            return value
        }
    }

    /// Returns the sample format associated with the specified key.
    ///
    /// - Parameters:
    ///   - key: The name of the option to get.
    ///   - searchFlags: The flags passed to av_opt_find2.
    /// - Returns: The sample format associated with the specified key.
    /// - Throws: AVError
    func sampleFormat(forKey key: String, searchFlags: AVOption.SearchFlag = .children) throws -> AVSampleFormat {
        try withUnsafeObjectPointer { ptr in
            var value = AV_SAMPLE_FMT_NONE
            try throwIfFail(av_opt_get_sample_fmt(ptr, key, searchFlags.rawValue, &value))
            return AVSampleFormat(native: value)
        }
    }

    /// Returns the video rate associated with the specified key.
    ///
    /// - Parameters:
    ///   - key: The name of the option to get.
    ///   - searchFlags: The flags passed to av_opt_find2.
    /// - Returns: The video rate associated with the specified key.
    /// - Throws: AVError
    func videoRate(forKey key: String, searchFlags: AVOption.SearchFlag = .children) throws -> AVRational {
        try withUnsafeObjectPointer { ptr in
            var value = AVRational(num: 0, den: 0)
            try throwIfFail(av_opt_get_video_rate(ptr, key, searchFlags.rawValue, &value))
            return value
        }
    }

    /// Returns the channel layout associated with the specified key.
    ///
    /// - Parameters:
    ///   - key: The name of the option to get.
    ///   - searchFlags: The flags passed to av_opt_find2.
    /// - Returns: The channel layout associated with the specified key.
    /// - Throws: AVError
    func channelLayout(forKey key: String, searchFlags: AVOption.SearchFlag = .children) throws -> AVChannelLayout {
        try withUnsafeObjectPointer { ptr in
            var value = AVChannelLayout()
            try throwIfFail(av_opt_get_chlayout(ptr, key, searchFlags.rawValue, &value))
            return value
        }
    }
    
    /// Returns the dictionary value associated with the specified key.
    func dictionary(forKey key: String, searchFlags: AVOption.SearchFlag = .children) throws -> [String: String] {
        try withUnsafeObjectPointer { ptr in
            var dict: OpaquePointer?
            defer { av_dict_free(&dict) }
            try throwIfFail(av_opt_get_dict_val(ptr, key, searchFlags.rawValue, &dict))
            return dict?.avDict ?? [:]
        }
    }
    
    private func array<T>(as _: T.Type = T.self, for key: String, type: AVOption.Kind, initial: T, storageElementsPerValue: Int = 1, searchFlags: AVOption.SearchFlag) throws -> [T] {
        let totalCount = try withUnsafeObjectPointer { ptr in
            var count: UInt32 = 0
            try throwIfFail(av_opt_get_array_size(ptr, key, searchFlags.rawValue, &count))
            return count
        }
        var values = Array(repeating: initial, count: Int(totalCount) * storageElementsPerValue)
        try values.withUnsafeMutableBufferPointer { buffer in
            try withUnsafeObjectPointer { ptr in
                try throwIfFail(av_opt_get_array(ptr, key, searchFlags.rawValue, 0, totalCount, type.native, buffer.baseAddress))
            }
        }
        return values
    }
    
    func intValues(forKey key: String, searchFlags: AVOption.SearchFlag = .children) throws -> [Int32] {
        try array(for: key, type: .int, initial: 0, searchFlags: searchFlags)
    }
    
    func int64Values(forKey key: String, searchFlags: AVOption.SearchFlag = .children) throws -> [Int64] {
        try array(for: key, type: .int64, initial: 0, searchFlags: searchFlags)
    }
    
    func uintValues(for key: String, searchFlags: AVOption.SearchFlag = .children) throws -> [UInt32] {
        try array(for: key, type: .uInt, initial: 0, searchFlags: searchFlags)
    }
    
    func uint64Values(forKey key: String, searchFlags: AVOption.SearchFlag = .children) throws -> [UInt64] {
        try array(for: key, type: .uInt64, initial: 0, searchFlags: searchFlags)
    }
    
    func doubleValues(forKey key: String, searchFlags: AVOption.SearchFlag = .children) throws -> [Double] {
        try array(for: key, type: .double, initial: 0, searchFlags: searchFlags)
    }
    
    func floatValues(forKey key: String, searchFlags: AVOption.SearchFlag = .children) throws -> [Float] {
        try array(for: key, type: .float, initial: 0, searchFlags: searchFlags)
    }
    
    func boolValues(forKey key: String, searchFlags: AVOption.SearchFlag = .children) throws -> [Bool] {
        try array(as: Int32.self, for: key, type: .bool, initial: 0, searchFlags: searchFlags).map({ $0 != 0 })
    }
    
    func flagsArray(forKey key: String, searchFlags: AVOption.SearchFlag = .children) throws -> [AVOption.Flag] {
        try array(as: Int32.self, for: key, type: .array(.flags), initial: 0,  searchFlags: searchFlags).map({ AVOption.Flag(rawValue: $0) })
    }
    
    func imageSizes(forKey key: String, searchFlags: AVOption.SearchFlag = .children) throws -> [AVImageSize] {
        let values: [Int32] = try array(for: key, type: .imageSize, initial: 0, storageElementsPerValue: 2, searchFlags: searchFlags)
        return stride(from: 0, to: values.count, by: 2).map {
            AVImageSize(width: Int(values[$0]), height: Int(values[$0 + 1]))
        }
    }
    
    func sampleFormats(forKey key: String, searchFlags: AVOption.SearchFlag = .children) throws -> [AVSampleFormat] {
        try array(for: key, type: .sampleFormat, initial: AV_SAMPLE_FMT_NONE, searchFlags: searchFlags).map(AVSampleFormat.init(native:))
    }
    
    func rationals(forKey key: String, searchFlags: AVOption.SearchFlag = .children) throws -> [AVRational] {
        try array(for: key, type: .rational, initial: AVRational(num: 0, den: 1),  searchFlags: searchFlags)
    }
    
    func videoRates(forKey key: String, searchFlags: AVOption.SearchFlag = .children) throws -> [AVRational] {
        try array(for: key, type: .videoRate, initial: AVRational(num: 0, den: 1),  searchFlags: searchFlags)
    }
    
    func durations(forKey key: String, searchFlags: AVOption.SearchFlag = .children) throws -> [Int64] {
        try array(for: key, type: .duration, initial: 0,  searchFlags: searchFlags)
    }
    
    func strings(forKey key: String, searchFlags: AVOption.SearchFlag = .children) throws -> [String] {
        let values: [UnsafeMutablePointer<CChar>?] = try array(for: key, type: .string, initial: nil, searchFlags: searchFlags)
        defer { values.forEach({ av_free($0) }) }
        return values.compactMap { String(cString: $0) }
    }
}

// MARK: - Option Setter

public extension AVOptionSupport {
    /// Sets the value of the specified key.
    ///
    /// If the field is not of a string type, then the given string is parsed.
    /// SI postfixes and some named scalars are supported.
    /// If the field is of a numeric type, it has to be a numeric or named
    /// scalar. Behavior with more than one scalar and +- infix operators
    /// is undefined.
    /// If the field is of a flags type, it has to be a sequence of numeric
    /// scalars or named flags separated by '+' or '-'. Prefixing a flag
    /// with '+' causes it to be set without affecting the other flags;
    /// similarly, '-' unsets a flag.
    /// If the field is of a dictionary type, it has to be a ':' separated list of
    /// key=value parameters. Values containing ':' special characters must be
    /// escaped.
    ///
    /// - Parameters:
    ///   - value: The value to set.
    ///   - key: The key with which to associate the value.
    ///   - searchFlags: The flags passed to `av_opt_find2`.
    /// - Throws: AVError
    func set(_ value: String, forKey key: String, searchFlags: AVOption.SearchFlag = .children) throws {
        try withUnsafeObjectPointer { ptr in
            try throwIfFail(av_opt_set(ptr, key, value, searchFlags.rawValue))
        }
    }

    /// Sets the value of the specified key to the integer value.
    ///
    /// - Parameters:
    ///   - value: The integer value.
    ///   - key: The key with which to associate the value.
    ///   - searchFlags: The flags passed to `av_opt_find2`.
    /// - Throws: AVError
    func set<T: FixedWidthInteger>(_ value: T, forKey key: String, searchFlags: AVOption.SearchFlag = .children) throws {
        try withUnsafeObjectPointer { ptr in
            try throwIfFail(av_opt_set_int(ptr, key, Int64(value), searchFlags.rawValue))
        }
    }
    
    func set(_ flags: AVOption.Flag, forKey key: String, searchFlags: AVOption.SearchFlag = .children) throws {
        try set(flags.rawValue, forKey: key, searchFlags: searchFlags)
    }

    /// Sets the value of the specified key to the double value.
    ///
    /// - Parameters:
    ///   - value: The double value.
    ///   - key: The key with which to associate the value.
    ///   - searchFlags: The flags passed to `av_opt_find2`.
    /// - Throws: AVError
    func set(_ value: Double, forKey key: String, searchFlags: AVOption.SearchFlag = .children) throws {
        try withUnsafeObjectPointer { ptr in
            try throwIfFail(av_opt_set_double(ptr, key, value, searchFlags.rawValue))
        }
    }

    /// Sets the value of the specified key to the rational value.
    ///
    /// - Parameters:
    ///   - value: The rational value.
    ///   - key: The key with which to associate the value.
    ///   - searchFlags: The flags passed to `av_opt_find2`.
    /// - Throws: AVError
    func set(_ value: AVRational, forKey key: String, searchFlags: AVOption.SearchFlag = .children) throws {
        try withUnsafeObjectPointer { ptr in
            try throwIfFail(av_opt_set_q(ptr, key, value, searchFlags.rawValue))
        }
    }

    /// Sets the value of the specified key to the binary value.
    ///
    /// - Parameters:
    ///   - value: The binary value.
    ///   - key: The key with which to associate the value.
    ///   - searchFlags: The flags passed to `av_opt_find2`.
    /// - Throws: AVError
    func set(_ value: UnsafeBufferPointer<UInt8>, forKey key: String, searchFlags: AVOption.SearchFlag = .children) throws {
        try withUnsafeObjectPointer { ptr in
            try throwIfFail(av_opt_set_bin(ptr, key, value.baseAddress, Int32(value.count), searchFlags.rawValue))
        }
    }
    
    func set(_ value: [UInt8], forKey key: String, searchFlags: AVOption.SearchFlag = .children) throws {
        try value.withUnsafeBufferPointer { buffer in
            try set(buffer, forKey: key, searchFlags: searchFlags)
        }
    }
    
    func set(_ value: Data, forKey key: String, searchFlags: AVOption.SearchFlag = .children) throws {
        try value.withUnsafeBytes { bytes in
            let buffer = bytes.bindMemory(to: UInt8.self)
            try set(
                UnsafeBufferPointer(start: buffer.baseAddress, count: buffer.count),
                forKey: key,
                searchFlags: searchFlags
            )
        }
    }

    /// Sets the value of the specified key to the image size.
    ///
    /// - Parameters:
    ///   - imageSize: The image size.
    ///   - key: The key with which to associate the value.
    ///   - searchFlags: The flags passed to `av_opt_find2`.
    /// - Throws: AVError
    func set(_ imageSize: AVImageSize, forKey key: String, searchFlags: AVOption.SearchFlag = .children) throws {
        try withUnsafeObjectPointer { ptr in
            try throwIfFail(av_opt_set_image_size(ptr, key, Int32(imageSize.width), Int32(imageSize.height), searchFlags.rawValue))
        }
    }

    /// Sets the value of the specified key to the pixel format.
    ///
    /// - Parameters:
    ///   - value: The pixel format.
    ///   - key: The key with which to associate the value.
    ///   - searchFlags: The flags passed to `av_opt_find2`.
    /// - Throws: AVError
    func set(_ value: AVPixelFormat, forKey key: String, searchFlags: AVOption.SearchFlag = .children) throws {
        try withUnsafeObjectPointer { ptr in
            try throwIfFail(av_opt_set_pixel_fmt(ptr, key, value, searchFlags.rawValue))
        }
    }

    /// Sets the value of the specified key to the sample format.
    ///
    /// - Parameters:
    ///   - value: The sample format.
    ///   - key: The key with which to associate the value.
    ///   - searchFlags: The flags passed to `av_opt_find2`.
    /// - Throws: AVError
    func set(_ value: AVSampleFormat, forKey key: String, searchFlags: AVOption.SearchFlag = .children) throws {
        try withUnsafeObjectPointer { ptr in
            try throwIfFail(av_opt_set_sample_fmt(ptr, key, value.native, searchFlags.rawValue))
        }
    }

    /// Sets the value of the specified key to the video rate.
    ///
    /// - Parameters:
    ///   - value: The video rate.
    ///   - key: The key with which to associate the value.
    ///   - searchFlags: The flags passed to `av_opt_find2`.
    /// - Throws: AVError
    func set(videoRate value: AVRational, forKey key: String, searchFlags: AVOption.SearchFlag = .children) throws {
        try withUnsafeObjectPointer { ptr in
            try throwIfFail(av_opt_set_video_rate(ptr, key, value, searchFlags.rawValue))
        }
    }

    /// Sets the value of the specified key to the channel layout.
    ///
    /// - Parameters:
    ///   - value: The channel layout.
    ///   - key: The key with which to associate the value.
    ///   - searchFlags: The flags passed to `av_opt_find2`.
    /// - Throws: AVError
    func set(_ value: AVChannelLayout, forKey key: String, searchFlags: AVOption.SearchFlag = .children) throws {
        try withUnsafeObjectPointer { ptr in
            try withUnsafePointer(to: value) { chl in
                try throwIfFail(av_opt_set_chlayout(ptr, key, chl, searchFlags.rawValue))
            }
        }
    }

    /// Sets the value of the specified key to the integer array.
    ///
    /// - Parameters:
    ///   - value: The integer array.
    ///   - key: The key with which to associate the value.
    ///   - searchFlags: The flags passed to `av_opt_find2`.
    /// - Throws: AVError
    func set<T: FixedWidthInteger>(binary value: [T], forKey key: String, searchFlags: AVOption.SearchFlag = .children) throws {
        try value.withUnsafeBytes { ptr in
            let ptr = ptr.bindMemory(to: UInt8.self).baseAddress
            let count = MemoryLayout<T>.size * value.count
            try set(UnsafeBufferPointer(start: ptr, count: count), forKey: key, searchFlags: searchFlags)
        }
    }

    /// Sets the value of the specified key to the dictionary value.
    ///
    /// - Parameters:
    ///   - value: The dictionary value.
    ///   - key: The key with which to associate the value.
    ///   - searchFlags: The flags passed to `av_opt_find2`.
    /// - Throws: AVError
    func set(_ value: [String: String], forKey key: String, searchFlags: AVOption.SearchFlag = .children) throws {
        try withUnsafeObjectPointer { ptr in
            var dict = value.avDict
            defer { av_dict_free(&dict) }
            try throwIfFail(av_opt_set_dict_val(ptr, key, dict, searchFlags.rawValue))
        }
    }
    
    func set(durations values: [Int64], forKey key: String, startElement: UInt32 = 0, searchFlags: AVOption.SearchFlag = .children) throws {
        try set(values, for: key, startElement: startElement, type: .array(.duration), searchFlags: searchFlags)
    }
    
     func set(_ values: [Double], forKey key: String, startElement: UInt32 = 0, searchFlags: AVOption.SearchFlag = .children) throws {
         try set(values, for: key, startElement: startElement, type: .array(.double), searchFlags: searchFlags)
    }
    
    func set(_ values: [Float], forKey key: String, startElement: UInt32 = 0, searchFlags: AVOption.SearchFlag = .children) throws {
        try set(values, for: key, startElement: startElement, type: .array(.float), searchFlags: searchFlags)
   }
    
    func set(_ values: [AVImageSize], forKey key: String, startElement: UInt32 = 0, searchFlags: AVOption.SearchFlag = .children) throws {
        try set(values.flatMap(\.nativeValues), for: key, startElement: startElement, type: .array(.imageSize), storageCountPerElement: 2, searchFlags: searchFlags)
    }
    
    func set(_ values: [AVPixelFormat], forKey key: String, startElement: UInt32 = 0, searchFlags: AVOption.SearchFlag = .children) throws {
        try set(values, for: key, startElement: startElement, type: .array(.pixelFormat), searchFlags: searchFlags)
   }
        
    func set(_ values: [AVChannelLayout], forKey key: String, startElement: UInt32 = 0, searchFlags: AVOption.SearchFlag = .children) throws {
        try set(values, for: key, startElement: startElement, type: .array(.channelLayout), searchFlags: searchFlags)
   }
    
    func set(videoRates: [AVRational], forKey key: String, startElement: UInt32 = 0, searchFlags: AVOption.SearchFlag = .children) throws {
        try set(videoRates, for: key, startElement: startElement, type: .array(.videoRate), searchFlags: searchFlags)
   }
    
    func set(_ values: [AVRational], forKey key: String, startElement: UInt32 = 0, searchFlags: AVOption.SearchFlag = .children) throws {
        try set(values, for: key, startElement: startElement, type: .array(.rational), searchFlags: searchFlags)
   }
    
    func set(_ values: [UInt32], forKey key: String, startElement: UInt32 = 0, searchFlags: AVOption.SearchFlag = .children) throws {
        try set(values, for: key, startElement: startElement, type: .array(.uInt), searchFlags: searchFlags)
   }
    
    func set(_ values: [UInt64], forKey key: String, startElement: UInt32 = 0, searchFlags: AVOption.SearchFlag = .children) throws {
        try set(values, for: key, startElement: startElement, type: .array(.uInt64), searchFlags: searchFlags)
   }
    
    func set(_ values: [Int32], forKey key: String, startElement: UInt32 = 0, searchFlags: AVOption.SearchFlag = .children) throws {
        try set(values, for: key, startElement: startElement, type: .array(.int), searchFlags: searchFlags)
   }
    
    func set(_ values: [Int64], forKey key: String, startElement: UInt32 = 0, searchFlags: AVOption.SearchFlag = .children) throws {
        try set(values, for: key, startElement: startElement, type: .array(.int64), searchFlags: searchFlags)
   }
    
    func set(_ values: [Bool], forKey key: String, startElement: UInt32 = 0, searchFlags: AVOption.SearchFlag = .children) throws {
        try set(values.map({ Int32($0 ? 1 : 0) }), for: key, startElement: startElement, type: .array(.bool), searchFlags: searchFlags)
   }
        
    func set(_ sampleFormats: [AVSampleFormat], forKey key: String, startElement: UInt32 = 0, searchFlags: AVOption.SearchFlag = .children) throws {
        try set(sampleFormats, for: key, startElement: startElement, type: .array(.sampleFormat), searchFlags: searchFlags)
   }
    
    func set(_ values: [String], forKey key: String, startElement: UInt32 = 0, searchFlags: AVOption.SearchFlag = .children) throws {
        let cStrings = values.map { strdup($0) }
        defer { cStrings.forEach { free($0) } }
        try set(cStrings, for: key, startElement: startElement, type: .array(.string), searchFlags: searchFlags)
    }
    
    func set(flags: [AVOption.Flag], forKey key: String, startElement: UInt32 = 0, searchFlags: AVOption.SearchFlag = .children) throws {
        try set(flags.map(\.rawValue), for: key, startElement: startElement, type: .array(.flags), searchFlags: searchFlags)
    }
    
    func set(_ colors: [AVColor], forKey key: String, startElement: UInt32 = 0, searchFlags: AVOption.SearchFlag = .children) throws {
        try set(colors.flatMap(\.rgbaBytes), for: key, startElement: startElement, type: .array(.color), storageCountPerElement: 4, searchFlags: searchFlags)
    }
    
    private func set<Element>(_ values: [Element], for key: String, startElement: UInt32, type: AVOption.Kind, storageCountPerElement: Int = 1, searchFlags: AVOption.SearchFlag) throws {
        try values.withUnsafeBufferPointer { buffer in
            try withUnsafeObjectPointer { ptr in
                try throwIfFail(av_opt_set_array(ptr, key, searchFlags.rawValue, startElement, UInt32(buffer.count / storageCountPerElement), type.native, buffer.baseAddress))
            }
        }
    }
}
