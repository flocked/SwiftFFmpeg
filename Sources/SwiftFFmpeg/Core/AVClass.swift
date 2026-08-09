//
//  AVClass.swift
//  SwiftFFmpeg
//
//  Created by sunlubo on 2018/7/24.
//

import CFFmpeg

/// An `FFmpeg` class that describes the options and metadata shared by one or more `FFmpeg` objects.
public struct AVClass {
    /// The name of the class.
    public let name: String
    /// The options of the class.
    public let options: [AVOption]
    /// The category of the class
    public let category: Category
    /// The `libavutil` version the class was created with.
    public let version: Int32
    /// The child classes of the class.
    public let childClasses: [AVClass]
    
    /// All options of the class, including those of its child classes.
    public var allOptions: [AVOption] {
        var options = options
        options.append(contentsOf: childClasses.flatMap(\.allOptions))
        return options
    }
    
    /// All child classes, including the child classes of descendant classes.
    public var allChildClasses: [AVClass] {
        var result = childClasses
        result.append(contentsOf: childClasses.flatMap(\.allChildClasses))
        return result
    }

    init(native: UnsafePointer<CFFmpeg.AVClass>) {
        self.name = native.pointee.class_name.string
        self.category = Category(rawValue: native.pointee.category.rawValue)!
        self.version = native.pointee.version
        self.options = Array(native.pointee.option, until: { $0.name == nil }).map(AVOption.init(native:)).withConstants()
        var childClasses: [AVClass] = []
        if let iterate = native.pointee.child_class_iterate {
            var state: UnsafeMutableRawPointer?
            while let child = iterate(&state) {
                childClasses.append(AVClass(native: child))
            }
        }
        self.childClasses = childClasses
    }
}

// MARK: - AVClass.Category

public extension AVClass {
    enum Category: UInt32, CustomStringConvertible {
        /// No specific class category is known.
        case none
        /// An input object.
        case input
        /// An output object.
        case output
        /// A muxer object.
        case muxer
        /// A demuxer object.
        case demuxer
        /// An encoder object.
        case encoder
        /// A decoder object.
        case decoder
        /// A filter object.
        case filter
        /// A bitstream filter object.
        case bitStreamFilter
        /// A software scaler object.
        case swscaler
        /// A software resampler object.
        case swresampler
        /// A hardware device object.
        case hwDevice
        /// A video output device object.
        case deviceVideoOutput = 40
        /// A video input device object.
        case deviceVideoInput
        /// An audio output device object.
        case deviceAudioOutput
        /// An audio input device object.
        case deviceAudioInput
        /// A generic output device object.
        case deviceOutput
        /// A generic input device object.
        case deviceInput

        /// A Boolean value indicating whether this category represents an input device.
        public var isInputDevice: Bool {
            self == .deviceVideoInput
                || self == .deviceAudioInput
                || self == .deviceInput
        }

        /// A Boolean value indicating whether this category represents an output device.
        public var isOutputDevice: Bool {
            self == .deviceVideoOutput
                || self == .deviceAudioOutput
                || self == .deviceOutput
        }
        
        public var description: String {
            switch self {
            case .none: "none"
            case .input: "input"
            case .output: "output"
            case .muxer: "muxer"
            case .demuxer: "demuxer"
            case .encoder: "encoder"
            case .decoder: "decoder"
            case .filter: "filter"
            case .bitStreamFilter: "bitStreamFilter"
            case .swscaler: "swscaler"
            case .swresampler: "swresampler"
            case .hwDevice: "hwDevice"
            case .deviceVideoOutput: "deviceVideoOutput"
            case .deviceVideoInput: "deviceVideoInput"
            case .deviceAudioOutput: "deviceAudioOutput"
            case .deviceAudioInput: "deviceAudioInput"
            case .deviceOutput: "deviceOutput"
            case .deviceInput: "deviceInput"
            }
        }
    }
}

// MARK: - AVClassSupport

/// A type that exposes FFmpeg class metadata and supports AVOption access.
public protocol AVClassSupport: AVOptionSupport {
    /// The FFmpeg class metadata for this type.
    static var `class`: AVClass { get }
}
