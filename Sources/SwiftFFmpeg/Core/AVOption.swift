//
//  AVOption.swift
//  SwiftFFmpeg
//
//  Created by sunlubo on 2018/7/10.
//

import CFFmpeg
import Foundation

// MARK: - AVOption

public struct AVOption {
    /// The name of the option.
    public let name: String
    /// The short English help text about the option.
    public let help: String?
    /// The offset relative to the context structure where the option value is stored.
    public let offset: Int
    /// The default value for scalar options.
    public let defaultValue: Any?
    /// The minimum valid value of the option.
    public let min: Any?
    /// The maximum valid value of the option.
    public let max: Any?
    /// The flags of the option.
    public let flags: Flag
    /// The logical unit to which the option belongs.
    public let unit: String?
    /// The type of the option.
    public let type: Kind

    /// The named constant values associated with this option.
    public internal(set) var constants: [Constant] = []

    func withConstants(_ options: [Self]) -> Self {
        var option = self
        let defaultValue = option.defaultIntegerValue
        let isFlag = option.type == .flags
        option.constants = options.map {
            Constant($0, defaultValue, isFlag)
        }
        return option
    }

    /// The named constant value associated with an option.
    public struct Constant: CustomStringConvertible {
        /// The symbolic name used to set the option to this value.
        public let name: String
        /// The integer value represented by the constant.
        public let value: Int64
        /// The short English help text for the constant.
        public let help: String?
        /// A Boolean value indicating whether this constant is the parent option's default value.
        public let isDefault: Bool
        /// The flags describing where this constant is applicable.
        public let flags: Flag

        public var description: String {
            "(\"\(name)\", \(value)\(isDefault ? " (default)" : "")"
        }

        init(_ option: AVOption, _ defaultValue: Int64?, _ isFlag: Bool) {
            name = option.name
            let _value = option.defaultValue as? Int64 ?? 0
            value = _value
            help = option.help
            flags = option.flags
            if isFlag {
                isDefault = defaultValue.map { _value == 0 ? $0 == 0 : ($0 & _value) == _value } ?? false
            } else {
                isDefault = defaultValue == _value
            }
        }
    }

    init(native: CFFmpeg.AVOption) {
        self.name = native.name.string
        self.help = native.help?.string.nonEmpty
        self.unit = native.unit?.string.nonEmpty
        self.offset = Int(native.offset)
        self.flags = Flag(rawValue: native.flags)
        self.type = Kind(native: native.type)
        if !type.isArray {
            switch type.element {
            case .pixelFormat:
                self.min = AVPixelFormat(rawValue: Int32(clamping: native.min))
                self.max = AVPixelFormat(rawValue: Int32(clamping: native.max))
                self.defaultValue = AVPixelFormat(rawValue: Int32(clamping: native.default_val.i64))
            case .sampleFormat:
                self.min = AVSampleFormat(rawValue: Int32(clamping: native.min))
                self.max = AVSampleFormat(rawValue: Int32(clamping: native.max))
                self.defaultValue = AVSampleFormat(rawValue: Int32(clamping: native.default_val.i64))
            case .flags:
                self.min = nil
                self.max = nil
                self.defaultValue = UInt32(exactly: native.default_val.i64).map(FlagValue.init(rawValue:))
            case .int:
                self.min = Int32(clamping: native.min)
                self.max = Int32(clamping: native.max)
                self.defaultValue = Int32(clamping: native.default_val.i64)
            case .channelLayout:
                self.min = nil
                self.max = nil
                self.defaultValue = native.default_val.str.flatMap { AVChannelLayout(name: $0.string) }
            case .int64, .const, .duration:
                self.min = Int64(clamping: native.min)
                self.max = Int64(clamping: native.max)
                self.defaultValue = native.default_val.i64
            case .uint:
                self.min = UInt32(clamping: native.min)
                self.max = UInt32(clamping: native.max)
                self.defaultValue = UInt32(clamping: native.default_val.i64)
            case .uint64:
                self.min = UInt64(clamping: native.min)
                self.max = UInt64(clamping: native.max)
                self.defaultValue = UInt64(clamping: native.default_val.i64)
            case .double:
                self.min = native.min
                self.max = native.max
                self.defaultValue = native.default_val.dbl
            case .float:
                self.min = Float(native.min)
                self.max = Float(native.max)
                self.defaultValue = Float(native.default_val.dbl)
            case .bool:
                self.min = nil
                self.max = nil
                self.defaultValue = native.default_val.i64 != 0
            case .string:
                self.min = nil
                self.max = nil
                self.defaultValue = native.default_val.str?.string
            case .rational, .videoRate:
                self.min = native.min
                self.max = native.max
                self.defaultValue = native.default_val.q
            case .binary:
                self.min = nil
                self.max = nil
                self.defaultValue = nil
            case .dict:
                self.min = nil
                self.max = nil
                self.defaultValue = nil
            case .color:
                self.min = nil
                self.max = nil
                self.defaultValue = native.default_val.str.flatMap { AVColor(name: $0.string) }
            case .imageSize:
                self.min = nil
                self.max = nil
                self.defaultValue = native.default_val.str.flatMap { AVImageSize(name: $0.string) }
            }
        } else {
            self.min = nil
            self.max = nil
            guard let array = native.default_val.arr?.pointee else {
                self.defaultValue = nil
                return
            }
            switch type.element {
            case .int:
                self.defaultValue = array.values(as: Int32.self)
            case .uint:
                self.defaultValue = array.values(as: UInt32.self)
            case .int64, .duration:
                self.defaultValue = array.values(as: Int64.self)
            case .uint64:
                self.defaultValue = array.values(as: UInt64.self)
            case .double:
                self.defaultValue = array.values(as: Double.self)
            case .float:
                self.defaultValue = array.values(as: Float.self)
            case .bool:
                self.defaultValue = array.values(as: Int32.self)?.map { $0 != 0 }
            case .string:
                self.defaultValue = array.values
            case .color:
                self.defaultValue = array.values?.map(AVColor.init(name:))
            case .imageSize:
                self.defaultValue = array.values?.map(AVImageSize.init(name:))
            case .channelLayout:
                self.defaultValue = array.values?.map(AVChannelLayout.init(name:))
            case .flags:
                self.defaultValue = nil
            case .rational, .videoRate:
                self.defaultValue = nil
            case .pixelFormat:
                self.defaultValue = array.values?.compactMap(AVPixelFormat.init(name:))
            case .sampleFormat:
                self.defaultValue = array.values?.compactMap(AVSampleFormat.init(name:))
            case .binary, .dict, .const:
                self.defaultValue = nil
            }
        }
    }
}

extension CFFmpeg.AVOptionArrayDef {
    var values: [String]? {
        guard let def else { return nil }
        let bytes = Array(def.string.utf8)
        let separator = sep == 0 ? UInt8(ascii: ",") : UInt8(bitPattern: sep)
        var values: [String] = []
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
                values.append(String(decoding: current, as: UTF8.self))
                current.removeAll(keepingCapacity: true)
            default:
                current.append(byte)
            }
        }
        if isEscaped {
            current.append(UInt8(ascii: "\\"))
        }
        values.append(String(decoding: current, as: UTF8.self))
        return values
    }

    func values<V: LosslessStringConvertible>(as _: V.Type = V.self) -> [V]? {
        values?.compactMap(V.init)
    }
}

extension AVOption: CustomStringConvertible {
    public var description: String {
        var strings = ["\(name.quoted())", "type: \(type)"]
        if let unit = unit {
            strings.append("unit: \(unit.quoted())")
        }
        if let defaultDescription {
            strings.append("default: " + defaultDescription)
        }
        if let minMax = minMaxDescription {
            strings.append(minMax)
        }

        if !constants.isEmpty {
            strings.append("constants: \(constants)")
        }

        if !flags.isEmpty {
            strings.append("flags: \(flags)")
        }
        //  strings.append("offset: \(offset)")
        if let help = help {
            strings.append("help: \(help.quoted())")
        }
        return "(\(strings.joined(separator: ", ")))"
    }
    
    fileprivate var defaultDescription: String? {
        guard let defaultValue = defaultValue else { return nil }
        if let string = defaultValue as? String {
            return "\(string.quoted())"
        } else {
            let defaultConstants = constants.filter(\.isDefault)
            if !defaultConstants.isEmpty {
                let names = defaultConstants.map { "\"\($0.name)\"" }.joined(separator: ", ")
               return "\(defaultValue) (\(names))"
            } else {
                return "\(defaultValue)"
            }
        }
    }
    
    fileprivate var minMaxDescription: String? {
        if let min, let max {
           return "range: \(min)...\(max)"
        } else if let min {
       return "min: \(min)"
        } else if let max {
          return "max: \(max)"
        }
        return nil
    }
}

extension AVOption: CustomDebugStringConvertible {
    public var debugDescription: String {
        var lines = ["\(name.quoted()) (\(type))"]
        if let unit {
            lines.append("  unit: \(unit.quoted())")
        }
        if let defaultDescription {
            lines.append("  default: \(defaultDescription)")
        }
        if let minMax = minMaxDescription {
            lines.append("  " + minMax)
        }
        lines.append("  flags: \(flags)")
        if let help {
            lines.append("  help: \(help.quoted())")
        }
        if !constants.isEmpty {
            lines.append("  constants:")
            lines.append(contentsOf: constants.flatMap({ $0.debugLines(parentFlags: flags) }))
        }
        return lines.joined(separator: "\n")
    }
}

fileprivate extension AVOption.Constant {
    func debugLines(parentFlags: AVOption.Flag) -> [String] {
        var line = "    - \(value): \(name.quoted())"
        if flags != parentFlags, !flags.isEmpty {
            line += " \(flags)"
        }
        if isDefault {
            line += " (default)"
        }
        var lines = [line]
        if let help {
            lines.append("      help: \(help.quoted())")
        }
        return lines
    }
}

// MARK: - AVOption.Kind

public extension AVOption {
    /// A type describing the value represented by an `AVOption`.
    struct Kind: RawRepresentable, Hashable, CustomStringConvertible, Sendable {
        public let rawValue: UInt32

        private static let arrayFlag: UInt32 = 1 << 16

        /// A Boolean value indicating whether the option represents an array.
        public var isArray: Bool {
            rawValue & Self.arrayFlag != 0
        }

        /// The element type represented by the option.
        public var element: Element {
            Element(rawValue: rawValue & ~Self.arrayFlag)!
        }

        var native: CFFmpeg.AVOptionType {
            .init(rawValue: rawValue)
        }

        /// A flag value.
        public static let flags = Self(.flags)
        /// A floating-point value.
        public static let float = Self(.float)
        /// A double-precision floating-point value.
        public static let double = Self(.double)
        /// A 32-bit signed integer value.
        public static let int = Self(.int)
        /// A 64-bit signed integer value.
        public static let int64 = Self(.int64)
        /// A 32-bit unsigned integer value.
        public static let uInt = Self(.uint)
        /// A 64-bit unsigned integer value.
        public static let uInt64 = Self(.uint64)
        /// A string value.
        public static let string = Self(.string)
        /// A rational value.
        public static let rational = Self(.rational)
        /// Binary data.
        public static let binary = Self(.binary)
        /// A dictionary value.
        public static let dict = Self(.dict)
        /// A named constant.
        public static let const = Self(.const)
        /// An image size.
        public static let imageSize = Self(.imageSize)
        /// A pixel format.
        public static let pixelFormat = Self(.pixelFormat)
        /// A sample format.
        public static let sampleFormat = Self(.sampleFormat)
        /// A video rate.
        public static let videoRate = Self(.videoRate)
        /// A duration.
        public static let duration = Self(.duration)
        /// A color.
        public static let color = Self(.color)
        /// A Boolean value.
        public static let bool = Self(.bool)
        /// A channel layout.
        public static let channelLayout = Self(.channelLayout)

        /// Returns an array option type containing elements of the specified type.
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

        public enum Element: UInt32, CustomStringConvertible, Hashable, Sendable {
            /// A flag value.
            case flags = 1
            /// A 32-bit signed integer value.
            case int
            /// A 64-bit signed integer value.
            case int64
            /// A double-precision floating-point value.
            case double
            /// A floating-point value.
            case float
            /// A string value.
            case string
            /// A rational value.
            case rational
            /// Binary data.
            case binary
            /// A dictionary value.
            case dict
            /// A 64-bit unsigned integer value.
            case uint64
            /// A named constant.
            case const
            /// An image size.
            case imageSize
            /// A pixel format.
            case pixelFormat
            /// A sample format.
            case sampleFormat
            /// A video rate.
            case videoRate
            /// A duration.
            case duration
            /// A color.
            case color
            /// A Boolean value.
            case bool
            /// A channel layout.
            case channelLayout
            /// A 32-bit unsigned integer value.
            case uint

            /// A textual representation of the Swift type used for the element.
            public var description: String {
                switch self {
                case .flags: "AVOption.FlagValue"
                case .int: "Int32"
                case .int64: "Int64"
                case .double: "Double"
                case .float: "Float"
                case .string: "String"
                case .rational: "AVRational"
                case .binary: "[UInt8]"
                case .dict: "[String: String]"
                case .uint64: "UInt64"
                case .const: "Constant"
                case .imageSize: "AVImageSize"
                case .pixelFormat: "AVPixelFormat"
                case .sampleFormat: "AVSampleFormat"
                case .videoRate: "AVRational (video rate)"
                case .duration: "Int64 (duration)"
                case .color: "AVColor"
                case .bool: "Bool"
                case .channelLayout: "AVChannelLayout"
                case .uint: "UInt32"
                }
            }
        }
    }
}

public extension AVOption {
    struct Flag: OptionSet, Hashable, Sendable {
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
        /// The option can only be read.
        public static let readonly = Flag(rawValue: AV_OPT_FLAG_READONLY)
        /// A generic parameter which can be set by the user for bit stream filtering.
        public static let bsf = Flag(rawValue: AV_OPT_FLAG_BSF_PARAM)
        /// A generic parameter which can be set by the user at runtime.
        public static let runtime = Flag(rawValue: AV_OPT_FLAG_RUNTIME_PARAM)
        /// A generic parameter which can be set by the user for filtering.
        public static let filtering = Flag(rawValue: AV_OPT_FLAG_FILTERING_PARAM)
        /// The option is deprecated, sers should refer to `AVOption` ``AVOption/help``.
        public static let deprecated = Flag(rawValue: AV_OPT_FLAG_DEPRECATED)

        public let rawValue: Int32

        public init(rawValue: Int32) {
            self.rawValue = rawValue
        }
    }

    struct FlagValue: RawRepresentable, OptionSet {
        public let rawValue: UInt32
        public init(rawValue: UInt32) {
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
        .runtime: ("runtime", "AV_OPT_FLAG_RUNTIME_PARAM"),
        .filtering: ("filtering", "AV_OPT_FLAG_FILTERING_PARAM"),
        .deprecated: ("deprecated", "AV_OPT_FLAG_DEPRECATED"),
    ]
}

// MARK: - AVOptionSearchFlag

public extension AVOption {
    /// https://github.com/FFmpeg/FFmpeg/blob/master/libavutil/opt.h#L556
    struct SearchFlag: OptionSet, Hashable, Sendable {
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

extension Array where Element == AVOption {
    func withConstants() -> [AVOption] {
        let options = self
        let constOptions = options.filter { $0.type == .const }.grouped(by: \.unit)
        return options.filter { $0.type != .const }.map {
            if let unit = $0.unit {
                return $0.withConstants(constOptions[unit] ?? [])
            } else {
                return $0
            }
        }
    }
}

private extension AVOption {
    var defaultIntegerValue: Int64? {
        guard let defaultValue else { return nil }
        switch defaultValue {
        case let value as Int:
            return Int64(value)
        case let value as Int32:
            return Int64(value)
        case let value as Int64:
            return value
        case let value as UInt:
            return value <= UInt(Int64.max) ? Int64(value) : nil
        case let value as UInt32:
            return Int64(value)
        case let value as UInt64:
            return value <= UInt64(Int64.max) ? Int64(value) : nil
        case let value as FlagValue:
            return Int64(value.rawValue)
        default:
            return nil
        }
    }
}

public extension AVOptionSupport {
    /// Returns an array of the options supported by the type.
    var supportedOptions: [AVOption] {
        rawOptions.withConstants()
    }

    var rawOptions: [AVOption] {
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

    /**
     Returns the valid value ranges for the specified option.

     Some options provide multiple valid ranges or ranges that depend on the current state of the object.

     - Parameters:
       - key: The name of the option.
       - searchFlags: The flags that control how the option is searched.
     - Returns: The valid value ranges for the option.
     - Throws: An error if the option cannot be found or its ranges cannot be queried.
     */
    func ranges(forKey key: String, searchFlags: AVOption.SearchFlag = .children) throws -> (ranges: [AVOptionRange], componentCount: Int) {
        try withUnsafeObjectPointer { ptr in
            var ranges: UnsafeMutablePointer<CFFmpeg.AVOptionRanges>?
            try av_opt_query_ranges(&ranges, ptr, key, searchFlags.rawValue).throwIfFail()
            defer { av_opt_freep_ranges(&ranges) }
            guard let ranges else {
                throw AVError.invalidValue
            }
            return ((0 ..< Int(ranges.pointee.nb_ranges)).compactMap { index in
                ranges.pointee.range[index].map { AVOptionRange(native: $0.pointee) }
            }, Int(ranges.pointee.nb_components))
        }
    }

    /**
     Returns whether the specified option is currently set to its default value.

     - Parameters:
       - key: The name of the option.
       - searchFlags: The flags that control how the option is searched.
     - Returns: `true` if the option is set to its default value; otherwise, `false`.
     - Throws: An error if the option cannot be found or its value cannot be queried.
     */
    func isSetToDefault(forKey key: String, searchFlags: AVOption.SearchFlag = .children) throws -> Bool {
        try withUnsafeObjectPointer { ptr in
            let result = av_opt_is_set_to_default_by_name(ptr, key, searchFlags.rawValue)
            try result.throwIfFail()
            return result != 0
        }
    }

    /**
     Sets multiple options from a dictionary of option names and values.

     Successfully applied options are removed from the dictionary. The returned dictionary contains any options that were not recognized or could not be applied.

     - Parameters:
       - options: A dictionary containing the option names and values to set.
       - searchFlags: The flags that control how the options are searched.
     - Returns: A dictionary containing the options that were not applied.
     - Throws: An error if applying the options fails.
     */
    @discardableResult
    func set(options: [String: String], searchFlags: AVOption.SearchFlag = .children) throws -> [String: String] {
        try withUnsafeObjectPointer { ptr in
            var dict = options.avDict
            defer { av_dict_free(&dict) }
            try av_opt_set_dict2(ptr, &dict, searchFlags.rawValue).throwIfFail()
            return dict?.avDict ?? [:]
        }
    }

    func option(forKey key: String, unit: String? = nil, requiredFlags: AVOption.Flag = [], searchFlags: AVOption.SearchFlag = .children) -> AVOption? {
        withUnsafeObjectPointer { ptr in
            key.withCString { key in
                if let unit {
                    return unit.withCString { av_opt_find(ptr, key, $0, requiredFlags.rawValue, searchFlags.rawValue) }
                } else {
                    return av_opt_find(ptr, key, nil, requiredFlags.rawValue, searchFlags.rawValue)
                }
            }.map { AVOption(native: $0.pointee) }
        }
    }
}

public extension AVOptionSupport {
    /**
     Returns the string value for the specified option.

     - Parameters:
       - key: The name of the option.
       - searchFlags: The flags that control how the option is searched.
     - Returns: The string value of the option.
     - Throws: An error if the option cannot be found or its value cannot be retrieved.
     */
    func string(forKey key: String, searchFlags: AVOption.SearchFlag = .children) throws -> String {
        try withUnsafeObjectPointer { ptr in
            var value: UnsafeMutablePointer<UInt8>!
            defer { av_free(value) }
            try av_opt_get(ptr, key, searchFlags.rawValue, &value).throwIfFail()
            return String(cString: value)
        }
    }

    /**
     Returns the string values for the specified option.

     - Parameters:
       - key: The name of the option.
       - searchFlags: The flags that control how the option is searched.
     - Returns: The string values of the option.
     - Throws: An error if the option cannot be found or its values cannot be retrieved.
     */
    func stringValues(forKey key: String, searchFlags: AVOption.SearchFlag = .children) throws -> [String] {
        let values: [UnsafeMutablePointer<CChar>?] = try array(for: key, type: .array(.string), initial: nil, searchFlags: searchFlags)
        defer { values.forEach { av_free($0) } }
        return values.compactMap { $0?.string }
    }

    /**
     Returns the unsigned 32-bit integer value for the specified option.

     - Parameters:
       - key: The name of the option.
       - searchFlags: The flags that control how the option is searched.
     - Returns: The unsigned 32-bit integer value of the option.
     - Throws: An error if the option cannot be found or its value cannot be retrieved.
     */
    func uint(forKey key: String, searchFlags: AVOption.SearchFlag = .children) throws -> UInt32 {
        try integer(forKey: key, searchFlags: searchFlags)
    }

    /**
     Returns the unsigned 32-bit integer values for the specified option.

     - Parameters:
       - key: The name of the option.
       - searchFlags: The flags that control how the option is searched.
     - Returns: The unsigned 32-bit integer values of the option.
     - Throws: An error if the option cannot be found or its values cannot be retrieved.
     */
    func uintValues(forKey key: String, searchFlags: AVOption.SearchFlag = .children) throws -> [UInt32] {
        try array(for: key, type: .array(.uint), initial: 0, searchFlags: searchFlags)
    }

    /**
     Returns the unsigned 64-bit integer value for the specified option.

     - Parameters:
       - key: The name of the option.
       - searchFlags: The flags that control how the option is searched.
     - Returns: The unsigned 64-bit integer value of the option.
     - Throws: An error if the option cannot be found or its value cannot be retrieved.
     */
    func uint64(forKey key: String, searchFlags: AVOption.SearchFlag = .children) throws -> UInt64 {
        try integer(forKey: key, searchFlags: searchFlags)
    }

    /**
     Returns the unsigned 64-bit integer values for the specified option.

     - Parameters:
       - key: The name of the option.
       - searchFlags: The flags that control how the option is searched.
     - Returns: The unsigned 64-bit integer values of the option.
     - Throws: An error if the option cannot be found or its values cannot be retrieved.
     */
    func uint64Values(forKey key: String, searchFlags: AVOption.SearchFlag = .children) throws -> [UInt64] {
        try array(for: key, type: .array(.uint64), initial: 0, searchFlags: searchFlags)
    }

    /**
     Returns the signed 32-bit integer value for the specified option.

     - Parameters:
       - key: The name of the option.
       - searchFlags: The flags that control how the option is searched.
     - Returns: The signed 32-bit integer value of the option.
     - Throws: An error if the option cannot be found or its value cannot be retrieved.
     */
    func int32(forKey key: String, searchFlags: AVOption.SearchFlag = .children) throws -> Int32 {
        try integer(forKey: key, searchFlags: searchFlags)
    }

    /**
     Returns the signed 32-bit integer values for the specified option.

     - Parameters:
       - key: The name of the option.
       - searchFlags: The flags that control how the option is searched.
     - Returns: The signed 32-bit integer values of the option.
     - Throws: An error if the option cannot be found or its values cannot be retrieved.
     */
    func int32Values(forKey key: String, searchFlags: AVOption.SearchFlag = .children) throws -> [Int32] {
        try array(for: key, type: .array(.int), initial: 0, searchFlags: searchFlags)
    }

    /**
     Returns the signed 64-bit integer value for the specified option.

     - Parameters:
       - key: The name of the option.
       - searchFlags: The flags that control how the option is searched.
     - Returns: The signed 64-bit integer value of the option.
     - Throws: An error if the option cannot be found or its value cannot be retrieved.
     */
    func int64(forKey key: String, searchFlags: AVOption.SearchFlag = .children) throws -> Int64 {
        try integer(forKey: key, searchFlags: searchFlags)
    }

    /**
     Returns the signed 64-bit integer values for the specified option.

     - Parameters:
       - key: The name of the option.
       - searchFlags: The flags that control how the option is searched.
     - Returns: The signed 64-bit integer values of the option.
     - Throws: An error if the option cannot be found or its values cannot be retrieved.
     */
    func int64Values(forKey key: String, searchFlags: AVOption.SearchFlag = .children) throws -> [Int64] {
        try array(for: key, type: .array(.int64), initial: 0, searchFlags: searchFlags)
    }

    private func integer<T: FixedWidthInteger>(forKey key: String, searchFlags: AVOption.SearchFlag = .children, as _: T.Type = T.self) throws -> T {
        try withUnsafeObjectPointer { ptr in
            var value: Int64 = 0
            try av_opt_get_int(ptr, key, searchFlags.rawValue, &value).throwIfFail()
            return T(value)
        }
    }

    /**
     Returns the flag value for the specified option.

     - Parameters:
       - key: The name of the option.
       - searchFlags: The flags that control how the option is searched.
     - Returns: The flag value of the option.
     - Throws: An error if the option cannot be found or its value cannot be retrieved.
     */
    func flags(forKey key: String, searchFlags: AVOption.SearchFlag = .children) throws -> AVOption.FlagValue {
        try .init(rawValue: integer(forKey: key, searchFlags: searchFlags))
    }

    /**
     Returns the flag values for the specified option.

     - Parameters:
       - key: The name of the option.
       - searchFlags: The flags that control how the option is searched.
     - Returns: The flag values of the option.
     - Throws: An error if the option cannot be found or its values cannot be retrieved.
     */
    func flagsValues(forKey key: String, searchFlags: AVOption.SearchFlag = .children) throws -> [AVOption.FlagValue] {
        try array(as: UInt32.self, for: key, type: .array(.flags), initial: 0, searchFlags: searchFlags).map { .init(rawValue: $0) }
    }

    /**
     Returns the double-precision floating-point value for the specified option.

     - Parameters:
       - key: The name of the option.
       - searchFlags: The flags that control how the option is searched.
     - Returns: The double-precision floating-point value of the option.
     - Throws: An error if the option cannot be found or its value cannot be retrieved.
     */
    func double(forKey key: String, searchFlags: AVOption.SearchFlag = .children) throws -> Double {
        try withUnsafeObjectPointer { ptr in
            var value: Double = 0
            try av_opt_get_double(ptr, key, searchFlags.rawValue, &value).throwIfFail()
            return value
        }
    }

    /**
     Returns the double-precision floating-point values for the specified option.

     - Parameters:
       - key: The name of the option.
       - searchFlags: The flags that control how the option is searched.
     - Returns: The double-precision floating-point values of the option.
     - Throws: An error if the option cannot be found or its values cannot be retrieved.
     */
    func doubleValues(forKey key: String, searchFlags: AVOption.SearchFlag = .children) throws -> [Double] {
        try array(for: key, type: .array(.double), initial: 0, searchFlags: searchFlags)
    }

    /**
     Returns the single-precision floating-point value for the specified option.

     - Parameters:
       - key: The name of the option.
       - searchFlags: The flags that control how the option is searched.
     - Returns: The single-precision floating-point value of the option.
     - Throws: An error if the option cannot be found or its value cannot be retrieved.
     */
    func float(forKey key: String, searchFlags: AVOption.SearchFlag = .children) throws -> Float {
        try Float(double(forKey: key, searchFlags: searchFlags))
    }

    /**
     Returns the single-precision floating-point values for the specified option.

     - Parameters:
       - key: The name of the option.
       - searchFlags: The flags that control how the option is searched.
     - Returns: The single-precision floating-point values of the option.
     - Throws: An error if the option cannot be found or its values cannot be retrieved.
     */
    func floatValues(forKey key: String, searchFlags: AVOption.SearchFlag = .children) throws -> [Float] {
        try array(for: key, type: .array(.float), initial: 0, searchFlags: searchFlags)
    }

    /**
     Returns the Boolean value for the specified option.

     - Parameters:
       - key: The name of the option.
       - searchFlags: The flags that control how the option is searched.
     - Returns: The Boolean value of the option.
     - Throws: An error if the option cannot be found or its value cannot be retrieved.
     */
    func bool(forKey key: String, searchFlags: AVOption.SearchFlag = .children) throws -> Bool {
        try integer(forKey: key, searchFlags: searchFlags, as: Int64.self) != 0
    }

    /**
     Returns the Boolean values for the specified option.

     - Parameters:
       - key: The name of the option.
       - searchFlags: The flags that control how the option is searched.
     - Returns: The Boolean values of the option.
     - Throws: An error if the option cannot be found or its values cannot be retrieved.
     */
    func boolValues(forKey key: String, searchFlags: AVOption.SearchFlag = .children) throws -> [Bool] {
        try array(as: Int32.self, for: key, type: .array(.bool), initial: 0, searchFlags: searchFlags).map { $0 != 0 }
    }

    /**
     Returns the rational value for the specified option.

     - Parameters:
       - key: The name of the option.
       - searchFlags: The flags that control how the option is searched.
     - Returns: The rational value of the option.
     - Throws: An error if the option cannot be found or its value cannot be retrieved.
     */
    func rational(forKey key: String, searchFlags: AVOption.SearchFlag = .children) throws -> AVRational {
        try withUnsafeObjectPointer { ptr in
            var value = AVRational(num: 0, den: 0)
            try av_opt_get_q(ptr, key, searchFlags.rawValue, &value).throwIfFail()
            return value
        }
    }

    /**
     Returns the rational values for the specified option.

     - Parameters:
       - key: The name of the option.
       - searchFlags: The flags that control how the option is searched.
     - Returns: The rational values of the option.
     - Throws: An error if the option cannot be found or its values cannot be retrieved.
     */
    func rationalValues(forKey key: String, searchFlags: AVOption.SearchFlag = .children) throws -> [AVRational] {
        try array(for: key, type: .array(.rational), initial: AVRational(num: 0, den: 1), searchFlags: searchFlags)
    }

    /**
     Returns the image size for the specified option.

     - Parameters:
       - key: The name of the option.
       - searchFlags: The flags that control how the option is searched.
     - Returns: The image size of the option.
     - Throws: An error if the option cannot be found or its value cannot be retrieved.
     */
    func imageSize(forKey key: String, searchFlags: AVOption.SearchFlag = .children) throws -> AVImageSize {
        try withUnsafeObjectPointer { ptr in
            var width: Int32 = 0
            var height: Int32 = 0
            try av_opt_get_image_size(ptr, key, searchFlags.rawValue, &width, &height).throwIfFail()
            return AVImageSize(width: Int(width), height: Int(height))
        }
    }

    /**
     Returns the image sizes for the specified option.

     - Parameters:
       - key: The name of the option.
       - searchFlags: The flags that control how the option is searched.
     - Returns: The image sizes of the option.
     - Throws: An error if the option cannot be found or its values cannot be retrieved.
     */
    func imageSizeValues(forKey key: String, searchFlags: AVOption.SearchFlag = .children) throws -> [AVImageSize] {
        let values: [Int32] = try array(for: key, type: .array(.imageSize), initial: 0, storageElementsPerValue: 2, searchFlags: searchFlags)
        return stride(from: 0, to: values.count, by: 2).map {
            AVImageSize(width: Int(values[$0]), height: Int(values[$0 + 1]))
        }
    }

    /**
     Returns the pixel format for the specified option.

     - Parameters:
       - key: The name of the option.
       - searchFlags: The flags that control how the option is searched.
     - Returns: The pixel format of the option.
     - Throws: An error if the option cannot be found or its value cannot be retrieved.
     */
    func pixelFormat(forKey key: String, searchFlags: AVOption.SearchFlag = .children) throws -> AVPixelFormat {
        try withUnsafeObjectPointer { ptr in
            var value = AVPixelFormat.none
            try av_opt_get_pixel_fmt(ptr, key, searchFlags.rawValue, &value).throwIfFail()
            return value
        }
    }

    /**
     Returns the pixel formats for the specified option.

     - Parameters:
       - key: The name of the option.
       - searchFlags: The flags that control how the option is searched.
     - Returns: The pixel formats of the option.
     - Throws: An error if the option cannot be found or its values cannot be retrieved.
     */
    func pixelFormatValues(forKey key: String, searchFlags: AVOption.SearchFlag = .children) throws -> [AVPixelFormat] {
        try array(for: key, type: .array(.pixelFormat), initial: .none, searchFlags: searchFlags)
    }

    /**
     Returns the sample format for the specified option.

     - Parameters:
       - key: The name of the option.
       - searchFlags: The flags that control how the option is searched.
     - Returns: The sample format of the option.
     - Throws: An error if the option cannot be found or its value cannot be retrieved.
     */
    func sampleFormat(forKey key: String, searchFlags: AVOption.SearchFlag = .children) throws -> AVSampleFormat {
        try withUnsafeObjectPointer { ptr in
            var value = AV_SAMPLE_FMT_NONE
            try av_opt_get_sample_fmt(ptr, key, searchFlags.rawValue, &value).throwIfFail()
            return AVSampleFormat(native: value)
        }
    }

    /**
     Returns the sample formats for the specified option.

     - Parameters:
       - key: The name of the option.
       - searchFlags: The flags that control how the option is searched.
     - Returns: The sample formats of the option.
     - Throws: An error if the option cannot be found or its values cannot be retrieved.
     */
    func sampleFormatValues(forKey key: String, searchFlags: AVOption.SearchFlag = .children) throws -> [AVSampleFormat] {
        try array(for: key, type: .array(.sampleFormat), initial: AV_SAMPLE_FMT_NONE, searchFlags: searchFlags).map(AVSampleFormat.init(native:))
    }

    /**
     Returns the video rate for the specified option.

     - Parameters:
       - key: The name of the option.
       - searchFlags: The flags that control how the option is searched.
     - Returns: The video rate of the option.
     - Throws: An error if the option cannot be found or its value cannot be retrieved.
     */
    func videoRate(forKey key: String, searchFlags: AVOption.SearchFlag = .children) throws -> AVRational {
        try withUnsafeObjectPointer { ptr in
            var value = AVRational(num: 0, den: 0)
            try av_opt_get_video_rate(ptr, key, searchFlags.rawValue, &value).throwIfFail()
            return value
        }
    }

    /**
     Returns the video rates for the specified option.

     - Parameters:
       - key: The name of the option.
       - searchFlags: The flags that control how the option is searched.
     - Returns: The video rates of the option.
     - Throws: An error if the option cannot be found or its values cannot be retrieved.
     */
    func videoRateValues(forKey key: String, searchFlags: AVOption.SearchFlag = .children) throws -> [AVRational] {
        try array(for: key, type: .array(.videoRate), initial: AVRational(num: 0, den: 1), searchFlags: searchFlags)
    }

    /**
     Returns the channel layout for the specified option.

     - Parameters:
       - key: The name of the option.
       - searchFlags: The flags that control how the option is searched.
     - Returns: The channel layout of the option.
     - Throws: An error if the option cannot be found or its value cannot be retrieved.
     */
    func channelLayout(forKey key: String, searchFlags: AVOption.SearchFlag = .children) throws -> AVChannelLayout {
        try withUnsafeObjectPointer { ptr in
            var value = AVChannelLayout()
            try av_opt_get_chlayout(ptr, key, searchFlags.rawValue, &value).throwIfFail()
            return value
        }
    }

    /**
     Returns the channel layouts for the specified option.

     - Parameters:
       - key: The name of the option.
       - searchFlags: The flags that control how the option is searched.
     - Returns: The channel layouts of the option.
     - Throws: An error if the option cannot be found or its values cannot be retrieved.
     */
    func channelLayoutValues(forKey key: String, searchFlags: AVOption.SearchFlag = .children) throws -> [AVChannelLayout] {
        try array(for: key, type: .array(.channelLayout), searchFlags: searchFlags)
    }

    /**
     Returns the dictionary value for the specified option.

     - Parameters:
       - key: The name of the option.
       - searchFlags: The flags that control how the option is searched.
     - Returns: The dictionary value of the option.
     - Throws: An error if the option cannot be found or its value cannot be retrieved.
     */
    func dictionary(forKey key: String, searchFlags: AVOption.SearchFlag = .children) throws -> [String: String] {
        try withUnsafeObjectPointer { ptr in
            var dict: OpaquePointer?
            defer { av_dict_free(&dict) }
            try av_opt_get_dict_val(ptr, key, searchFlags.rawValue, &dict).throwIfFail()
            return dict?.avDict ?? [:]
        }
    }

    /**
     Returns the dictionary values for the specified option.

     - Parameters:
       - key: The name of the option.
       - searchFlags: The flags that control how the option is searched.
     - Returns: The dictionary values of the option.
     - Throws: An error if the option cannot be found or its values cannot be retrieved.
     */
    func dictionaryValues(forKey key: String, searchFlags: AVOption.SearchFlag = .children) throws -> [[String: String]] {
        var dictionaries: [OpaquePointer?] = try array(for: key, type: .array(.dict), searchFlags: searchFlags)
        defer { dictionaries.indices.forEach { av_dict_free(&dictionaries[$0]) } }
        return dictionaries.map { $0?.avDict ?? [:] }
    }

    /**
     Returns the duration for the specified option.

     - Parameters:
       - key: The name of the option.
       - searchFlags: The flags that control how the option is searched.
     - Returns: The duration value of the option.
     - Throws: An error if the option cannot be found or its value cannot be retrieved.
     */
    func duration(forKey key: String, searchFlags: AVOption.SearchFlag = .children) throws -> Int64 {
        try integer(forKey: key, searchFlags: searchFlags, as: Int64.self)
    }

    /**
     Returns the durations for the specified option.

     - Parameters:
       - key: The name of the option.
       - searchFlags: The flags that control how the option is searched.
     - Returns: The duration values of the option.
     - Throws: An error if the option cannot be found or its values cannot be retrieved.
     */
    func durationValues(forKey key: String, searchFlags: AVOption.SearchFlag = .children) throws -> [Int64] {
        try array(for: key, type: .array(.duration), initial: 0, searchFlags: searchFlags)
    }

    /**
     Returns the binary data for the specified option.

     - Parameters:
       - key: The name of the option.
       - searchFlags: The flags that control how the option is searched.
     - Returns: The binary data of the option.
     - Throws: An error if the option cannot be found, its value cannot be retrieved, or the binary data is invalid.
     */
    func data(forKey key: String, searchFlags: AVOption.SearchFlag = .children) throws -> Data {
        try withUnsafeObjectPointer { ptr in
            var value: UnsafeMutablePointer<UInt8>?
            try av_opt_get(ptr, key, searchFlags.rawValue, &value).throwIfFail()
            guard let value else { return Data() }
            defer { av_free(value) }
            guard let data = UnsafePointer(value).hexData else {
                throw AVError.invalidData
            }
            return data
        }
    }

    private func array<T>(as _: T.Type = T.self, for key: String, type: AVOption.Kind, initial: T, storageElementsPerValue: Int = 1, searchFlags: AVOption.SearchFlag) throws -> [T] {
        let totalCount = try totalCount(for: key, searchFlags: searchFlags)
        var values = Array(repeating: initial, count: Int(totalCount) * storageElementsPerValue)
        try values.withUnsafeMutableBufferPointer { buffer in
            try withUnsafeObjectPointer { ptr in
                try av_opt_get_array(ptr, key, searchFlags.rawValue, 0, totalCount, type.native, buffer.baseAddress).throwIfFail()
            }
        }
        return values
    }

    private func array<T>(as _: T.Type = T.self, for key: String, type: AVOption.Kind, storageElementsPerValue: Int = 1, searchFlags: AVOption.SearchFlag) throws -> [T] {
        let totalCount = try totalCount(for: key, searchFlags: searchFlags)
        let count = Int(totalCount) * storageElementsPerValue
        return try [T](unsafeUninitializedCapacity: count) { buffer, initializedCount in
            try withUnsafeObjectPointer { ptr in
                try av_opt_get_array(ptr, key, searchFlags.rawValue, 0, totalCount, type.native, buffer.baseAddress).throwIfFail()
            }
            initializedCount = count
        }
    }

    private func totalCount(for key: String, searchFlags: AVOption.SearchFlag) throws -> UInt32 {
        try withUnsafeObjectPointer { ptr in
            var count: UInt32 = 0
            try av_opt_get_array_size(ptr, key, searchFlags.rawValue, &count).throwIfFail()
            return count
        }
    }
}

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
            try av_opt_set(ptr, key, value, searchFlags.rawValue).throwIfFail()
        }
    }

    /**
     Sets the string values for the specified option.

     - Parameters:
       - values: The string values to set.
       - key: The name of the option.
       - startIndex: The index of the first array element to set.
       - searchFlags: The flags that control how the option is searched.
     - Throws: An error if the option cannot be found or its values cannot be set.
     */
    func set(_ values: [String], forKey key: String, startingAt startIndex: UInt32 = 0, searchFlags: AVOption.SearchFlag = .children) throws {
        let cStrings = values.map { strdup($0) }
        defer { cStrings.forEach { free($0) } }
        try set(cStrings, for: key, startIndex: startIndex, type: .array(.string), searchFlags: searchFlags)
    }

    /**
     Sets the Boolean value for the specified option.

     - Parameters:
       - value: The Boolean value to set.
       - key: The name of the option.
       - searchFlags: The flags that control how the option is searched.
     - Throws: An error if the option cannot be found or its value cannot be set.
     */
    func set(_ value: Bool, forKey key: String, searchFlags: AVOption.SearchFlag = .children) throws {
        try set(Int32(value ? 1 : 0), forKey: key, searchFlags: searchFlags)
    }

    /**
     Sets the Boolean values for the specified option.

     - Parameters:
       - values: The Boolean values to set.
       - key: The name of the option.
       - startIndex: The index of the first array element to set.
       - searchFlags: The flags that control how the option is searched.
     - Throws: An error if the option cannot be found or its values cannot be set.
     */
    func set(_ values: [Bool], forKey key: String, startingAt startIndex: UInt32 = 0, searchFlags: AVOption.SearchFlag = .children) throws {
        try set(values.map { Int32($0 ? 1 : 0) }, for: key, startIndex: startIndex, type: .array(.bool), searchFlags: searchFlags)
    }

    /**
     Sets the integer value for the specified option.

     - Parameters:
       - value: The integer value to set.
       - key: The name of the option.
       - searchFlags: The flags that control how the option is searched.
     - Throws: An error if the option cannot be found, the value cannot be represented as a signed 64-bit integer, or the value cannot be set.
     */
    func set<T: FixedWidthInteger>(_ value: T, forKey key: String, searchFlags: AVOption.SearchFlag = .children) throws {
        guard let value = Int64(exactly: value) else {
            throw AVError.invalidValue
        }
        try withUnsafeObjectPointer { ptr in
            try av_opt_set_int(ptr, key, value, searchFlags.rawValue).throwIfFail()
        }
    }

    /**
     Sets the unsigned 32-bit integer values for the specified option.

     - Parameters:
       - values: The unsigned 32-bit integer values to set.
       - key: The name of the option.
       - startIndex: The index of the first array element to set.
       - searchFlags: The flags that control how the option is searched.
     - Throws: An error if the option cannot be found or its values cannot be set.
     */
    func set(_ values: [UInt32], forKey key: String, startingAt startIndex: UInt32 = 0, searchFlags: AVOption.SearchFlag = .children) throws {
        try set(values, for: key, startIndex: startIndex, type: .array(.uint), searchFlags: searchFlags)
    }

    /**
     Sets the unsigned 64-bit integer values for the specified option.

     - Parameters:
       - values: The unsigned 64-bit integer values to set.
       - key: The name of the option.
       - startIndex: The index of the first array element to set.
       - searchFlags: The flags that control how the option is searched.
     - Throws: An error if the option cannot be found or its values cannot be set.
     */
    func set(_ values: [UInt64], forKey key: String, startingAt startIndex: UInt32 = 0, searchFlags: AVOption.SearchFlag = .children) throws {
        try set(values, for: key, startIndex: startIndex, type: .array(.uint64), searchFlags: searchFlags)
    }

    /**
     Sets the signed 32-bit integer values for the specified option.

     - Parameters:
       - values: The signed 32-bit integer values to set.
       - key: The name of the option.
       - startIndex: The index of the first array element to set.
       - searchFlags: The flags that control how the option is searched.
     - Throws: An error if the option cannot be found or its values cannot be set.
     */
    func set(_ values: [Int32], forKey key: String, startingAt startIndex: UInt32 = 0, searchFlags: AVOption.SearchFlag = .children) throws {
        try set(values, for: key, startIndex: startIndex, type: .array(.int), searchFlags: searchFlags)
    }

    /**
     Sets the signed 64-bit integer values for the specified option.

     - Parameters:
       - values: The signed 64-bit integer values to set.
       - key: The name of the option.
       - startIndex: The index of the first array element to set.
       - searchFlags: The flags that control how the option is searched.
     - Throws: An error if the option cannot be found or its values cannot be set.
     */
    func set(_ values: [Int64], forKey key: String, startingAt startIndex: UInt32 = 0, searchFlags: AVOption.SearchFlag = .children) throws {
        try set(values, for: key, startIndex: startIndex, type: .array(.int64), searchFlags: searchFlags)
    }

    /**
     Sets the flag value for the specified option.

     - Parameters:
       - value: The flag value to set.
       - key: The name of the option.
       - searchFlags: The flags that control how the option is searched.
     - Throws: An error if the option cannot be found or its value cannot be set.
     */
    func set(_ value: AVOption.FlagValue, forKey key: String, searchFlags: AVOption.SearchFlag = .children) throws {
        try set(value.rawValue, forKey: key, searchFlags: searchFlags)
    }

    /**
     Sets the flag values for the specified option.

     - Parameters:
       - values: The flag values to set.
       - key: The name of the option.
       - startIndex: The index of the first array element to set.
       - searchFlags: The flags that control how the option is searched.
     - Throws: An error if the option cannot be found or its values cannot be set.
     */
    func set(_ values: [AVOption.FlagValue], forKey key: String, startingAt startIndex: UInt32 = 0, searchFlags: AVOption.SearchFlag = .children) throws {
        try set(values.map(\.rawValue), for: key, startIndex: startIndex, type: .array(.flags), searchFlags: searchFlags)
    }

    /**
     Sets the double-precision floating-point value for the specified option.

     - Parameters:
       - value: The double-precision floating-point value to set.
       - key: The name of the option.
       - searchFlags: The flags that control how the option is searched.
     - Throws: An error if the option cannot be found or its value cannot be set.
     */
    func set(_ value: Double, forKey key: String, searchFlags: AVOption.SearchFlag = .children) throws {
        try withUnsafeObjectPointer { ptr in
            try av_opt_set_double(ptr, key, value, searchFlags.rawValue).throwIfFail()
        }
    }

    /**
     Sets the double-precision floating-point values for the specified option.

     - Parameters:
       - values: The double-precision floating-point values to set.
       - key: The name of the option.
       - startIndex: The index of the first array element to set.
       - searchFlags: The flags that control how the option is searched.
     - Throws: An error if the option cannot be found or its values cannot be set.
     */
    func set(_ values: [Double], forKey key: String, startingAt startIndex: UInt32 = 0, searchFlags: AVOption.SearchFlag = .children) throws {
        try set(values, for: key, startIndex: startIndex, type: .array(.double), searchFlags: searchFlags)
    }

    /**
     Sets the single-precision floating-point value for the specified option.

     - Parameters:
       - value: The single-precision floating-point value to set.
       - key: The name of the option.
       - searchFlags: The flags that control how the option is searched.
     - Throws: An error if the option cannot be found or its value cannot be set.
     */
    func set(_ value: Float, forKey key: String, searchFlags: AVOption.SearchFlag = .children) throws {
        try set(Double(value), forKey: key, searchFlags: searchFlags)
    }

    /**
     Sets the single-precision floating-point values for the specified option.

     - Parameters:
       - values: The single-precision floating-point values to set.
       - key: The name of the option.
       - startIndex: The index of the first array element to set.
       - searchFlags: The flags that control how the option is searched.
     - Throws: An error if the option cannot be found or its values cannot be set.
     */
    func set(_ values: [Float], forKey key: String, startingAt startIndex: UInt32 = 0, searchFlags: AVOption.SearchFlag = .children) throws {
        try set(values, for: key, startIndex: startIndex, type: .array(.float), searchFlags: searchFlags)
    }

    /**
     Sets the rational value for the specified option.

     - Parameters:
       - value: The rational value to set.
       - key: The name of the option.
       - searchFlags: The flags that control how the option is searched.
     - Throws: An error if the option cannot be found or its value cannot be set.
     */
    func set(_ value: AVRational, forKey key: String, searchFlags: AVOption.SearchFlag = .children) throws {
        try withUnsafeObjectPointer { ptr in
            try av_opt_set_q(ptr, key, value, searchFlags.rawValue).throwIfFail()
        }
    }

    /**
     Sets the rational values for the specified option.

     - Parameters:
       - values: The rational values to set.
       - key: The name of the option.
       - startIndex: The index of the first array element to set.
       - searchFlags: The flags that control how the option is searched.
     - Throws: An error if the option cannot be found or its values cannot be set.
     */
    func set(_ values: [AVRational], forKey key: String, startingAt startIndex: UInt32 = 0, searchFlags: AVOption.SearchFlag = .children) throws {
        try set(values, for: key, startIndex: startIndex, type: .array(.rational), searchFlags: searchFlags)
    }

    /**
     Sets the color value for the specified option.

     - Parameters:
       - value: The color value to set.
       - key: The name of the option.
       - searchFlags: The flags that control how the option is searched.
     - Throws: An error if the option cannot be found or its value cannot be set.
     */
    func set(_ value: AVColor, forKey key: String, searchFlags: AVOption.SearchFlag = .children) throws {
        try value.rgbaBytes.withUnsafeBufferPointer { buffer in
            try withUnsafeObjectPointer { ptr in
                try av_opt_set(ptr, key, buffer.baseAddress, searchFlags.rawValue).throwIfFail()
            }
        }
    }

    /**
     Sets the color values for the specified option.

     - Parameters:
       - values: The color values to set.
       - key: The name of the option.
       - startIndex: The index of the first array element to set.
       - searchFlags: The flags that control how the option is searched.
     - Throws: An error if the option cannot be found or its values cannot be set.
     */
    func set(_ values: [AVColor], forKey key: String, startingAt startIndex: UInt32 = 0, searchFlags: AVOption.SearchFlag = .children) throws {
        try set(values.flatMap(\.rgbaBytes), for: key, startIndex: startIndex, type: .array(.color), storageCountPerElement: 4, searchFlags: searchFlags)
    }

    private func set(_ value: UnsafeBufferPointer<UInt8>, forKey key: String, searchFlags: AVOption.SearchFlag = .children) throws {
        try withUnsafeObjectPointer { ptr in
            try av_opt_set_bin(ptr, key, value.baseAddress, Int32(value.count), searchFlags.rawValue).throwIfFail()
        }
    }

    /**
     Sets the binary data for the specified option.

     - Parameters:
       - value: The binary data to set.
       - key: The name of the option.
       - searchFlags: The flags that control how the option is searched.
     - Throws: An error if the option cannot be found or its value cannot be set.
     */
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

    /**
     Sets the image size for the specified option.

     - Parameters:
       - value: The image size to set.
       - key: The name of the option.
       - searchFlags: The flags that control how the option is searched.
     - Throws: An error if the option cannot be found or its value cannot be set.
     */
    func set(_ value: AVImageSize, forKey key: String, searchFlags: AVOption.SearchFlag = .children) throws {
        try withUnsafeObjectPointer { ptr in
            try av_opt_set_image_size(ptr, key, Int32(value.width), Int32(value.height), searchFlags.rawValue).throwIfFail()
        }
    }

    /**
     Sets the image sizes for the specified option.

     - Parameters:
       - values: The image sizes to set.
       - key: The name of the option.
       - startIndex: The index of the first array element to set.
       - searchFlags: The flags that control how the option is searched.
     - Throws: An error if the option cannot be found or its values cannot be set.
     */
    func set(_ values: [AVImageSize], forKey key: String, startingAt startIndex: UInt32 = 0, searchFlags: AVOption.SearchFlag = .children) throws {
        try set(values.flatMap(\.nativeValues), for: key, startIndex: startIndex, type: .array(.imageSize), storageCountPerElement: 2, searchFlags: searchFlags)
    }

    /**
     Sets the pixel format for the specified option.

     - Parameters:
       - value: The pixel format to set.
       - key: The name of the option.
       - searchFlags: The flags that control how the option is searched.
     - Throws: An error if the option cannot be found or its value cannot be set.
     */
    func set(_ value: AVPixelFormat, forKey key: String, searchFlags: AVOption.SearchFlag = .children) throws {
        try withUnsafeObjectPointer { ptr in
            try av_opt_set_pixel_fmt(ptr, key, value, searchFlags.rawValue).throwIfFail()
        }
    }

    /**
     Sets the pixel formats for the specified option.

     - Parameters:
       - values: The pixel formats to set.
       - key: The name of the option.
       - startIndex: The index of the first array element to set.
       - searchFlags: The flags that control how the option is searched.
     - Throws: An error if the option cannot be found or its values cannot be set.
     */
    func set(_ values: [AVPixelFormat], forKey key: String, startingAt startIndex: UInt32 = 0, searchFlags: AVOption.SearchFlag = .children) throws {
        try set(values, for: key, startIndex: startIndex, type: .array(.pixelFormat), searchFlags: searchFlags)
    }

    /**
     Sets the sample format for the specified option.

     - Parameters:
       - value: The sample format to set.
       - key: The name of the option.
       - searchFlags: The flags that control how the option is searched.
     - Throws: An error if the option cannot be found or its value cannot be set.
     */
    func set(_ value: AVSampleFormat, forKey key: String, searchFlags: AVOption.SearchFlag = .children) throws {
        try withUnsafeObjectPointer { ptr in
            try av_opt_set_sample_fmt(ptr, key, value.native, searchFlags.rawValue).throwIfFail()
        }
    }

    /**
     Sets the sample formats for the specified option.

     - Parameters:
       - values: The sample formats to set.
       - key: The name of the option.
       - startIndex: The index of the first array element to set.
       - searchFlags: The flags that control how the option is searched.
     - Throws: An error if the option cannot be found or its values cannot be set.
     */
    func set(_ values: [AVSampleFormat], forKey key: String, startingAt startIndex: UInt32 = 0, searchFlags: AVOption.SearchFlag = .children) throws {
        try set(values, for: key, startIndex: startIndex, type: .array(.sampleFormat), searchFlags: searchFlags)
    }

    /**
     Sets the video rate for the specified option.

     - Parameters:
       - value: The video rate to set.
       - key: The name of the option.
       - searchFlags: The flags that control how the option is searched.
     - Throws: An error if the option cannot be found or its value cannot be set.
     */
    func set(videoRate value: AVRational, forKey key: String, searchFlags: AVOption.SearchFlag = .children) throws {
        try withUnsafeObjectPointer { ptr in
            try av_opt_set_video_rate(ptr, key, value, searchFlags.rawValue).throwIfFail()
        }
    }

    /**
     Sets the video rates for the specified option.

     - Parameters:
       - videoRates: The video rates to set.
       - key: The name of the option.
       - startIndex: The index of the first array element to set.
       - searchFlags: The flags that control how the option is searched.
     - Throws: An error if the option cannot be found or its values cannot be set.
     */
    func set(videoRates: [AVRational], forKey key: String, startingAt startIndex: UInt32 = 0, searchFlags: AVOption.SearchFlag = .children) throws {
        try set(videoRates, for: key, startIndex: startIndex, type: .array(.videoRate), searchFlags: searchFlags)
    }

    /**
     Sets the channel layout for the specified option.

     - Parameters:
       - value: The channel layout to set.
       - key: The name of the option.
       - searchFlags: The flags that control how the option is searched.
     - Throws: An error if the option cannot be found or its value cannot be set.
     */
    func set(_ value: AVChannelLayout, forKey key: String, searchFlags: AVOption.SearchFlag = .children) throws {
        try withUnsafeObjectPointer { ptr in
            try withUnsafePointer(to: value) { chl in
                try av_opt_set_chlayout(ptr, key, chl, searchFlags.rawValue).throwIfFail()
            }
        }
    }

    /**
     Sets the channel layouts for the specified option.

     - Parameters:
       - values: The channel layouts to set.
       - key: The name of the option.
       - startIndex: The index of the first array element to set.
       - searchFlags: The flags that control how the option is searched.
     - Throws: An error if the option cannot be found or its values cannot be set.
     */
    func set(_ values: [AVChannelLayout], forKey key: String, startingAt startIndex: UInt32 = 0, searchFlags: AVOption.SearchFlag = .children) throws {
        try set(values, for: key, startIndex: startIndex, type: .array(.channelLayout), searchFlags: searchFlags)
    }

    /**
     Sets the binary representation of the integer values for the specified option.

     The values are passed using their native in-memory byte representation.

     - Parameters:
       - value: The integer values whose binary representation is set.
       - key: The name of the option.
       - searchFlags: The flags that control how the option is searched.
     - Throws: An error if the option cannot be found or its value cannot be set.
     */
    func set<T: FixedWidthInteger>(binary value: [T], forKey key: String, searchFlags: AVOption.SearchFlag = .children) throws {
        try value.withUnsafeBytes { bytes in
            try set(bytes.bindMemory(to: UInt8.self), forKey: key, searchFlags: searchFlags)
        }
    }

    /**
     Sets the dictionary value for the specified option.

     - Parameters:
       - value: The dictionary value to set.
       - key: The name of the option.
       - searchFlags: The flags that control how the option is searched.
     - Throws: An error if the option cannot be found or its value cannot be set.
     */
    func set(_ value: [String: String], forKey key: String, searchFlags: AVOption.SearchFlag = .children) throws {
        try withUnsafeObjectPointer { ptr in
            var dict = value.avDict
            defer { av_dict_free(&dict) }
            try av_opt_set_dict_val(ptr, key, dict, searchFlags.rawValue).throwIfFail()
        }
    }

    /**
     Sets the dictionaries for the specified option.

     - Parameters:
       - values: The dictionary values to set.
       - key: The name of the option.
       - startIndex: The index of the first array element to set.
       - searchFlags: The flags that control how the option is searched.
     - Throws: An error if the option cannot be found or its values cannot be set.
     */
    func set(_ values: [[String: String]], forKey key: String, startingAt startIndex: UInt32 = 0, searchFlags: AVOption.SearchFlag = .children) throws {
        var dictionaries = values.map(\.avDict)
        defer { dictionaries.indices.forEach { av_dict_free(&dictionaries[$0]) } }
        try set(dictionaries, for: key, startIndex: startIndex, type: .array(.dict), searchFlags: searchFlags)
    }

    /**
     Sets the duration values for the specified option.

     - Parameters:
       - values: The duration values to set.
       - key: The name of the option.
       - startIndex: The index of the first array element to set.
       - searchFlags: The flags that control how the option is searched.
     - Throws: An error if the option cannot be found or its values cannot be set.
     */
    func set(durations values: [Int64], forKey key: String, startingAt startIndex: UInt32 = 0, searchFlags: AVOption.SearchFlag = .children) throws {
        try set(values, for: key, startIndex: startIndex, type: .array(.duration), searchFlags: searchFlags)
    }

    private func set<Element>(_ values: [Element], for key: String, startIndex: UInt32, type: AVOption.Kind, storageCountPerElement: Int = 1, searchFlags: AVOption.SearchFlag) throws {
        try values.withUnsafeBufferPointer { buffer in
            try withUnsafeObjectPointer { ptr in
                try av_opt_set_array(ptr, key, searchFlags.rawValue, startIndex, UInt32(buffer.count / storageCountPerElement), type.native, buffer.baseAddress).throwIfFail()
            }
        }
    }
}

private extension UnsafePointer<UInt8> {
    var hexData: Data? {
        let count = strlen(UnsafePointer<CChar>(OpaquePointer(self)))
        guard count.isMultiple(of: 2) else { return nil }
        @inline(__always)
        func nibble(_ byte: UInt8) -> UInt8? {
            switch byte {
            case 48...57: return byte - 48
            case 65...70: return byte - 65 + 10
            case 97...102: return byte - 97 + 10
            default: return nil
            }
        }
        var data = Data(capacity: count / 2)
        for index in stride(from: 0, to: count, by: 2) {
            guard let high = nibble(self[index]), let low = nibble(self[index + 1])
            else { return nil }
            data.append(high << 4 | low)
        }
        return data
    }
}

private extension FixedWidthInteger {
    init(clamping value: Double) {
        if value.isNaN {
            self = 0
        } else if value <= Double(Self.min) {
            self = .min
        } else if value >= Double(Self.max) {
            self = .max
        } else {
            self = Self(value)
        }
    }
}
