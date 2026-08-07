//
//  AVClass.swift
//  SwiftFFmpeg
//
//  Created by sunlubo on 2018/7/24.
//

import CFFmpeg

// MARK: - AVClass

/// Describes an FFmpeg object class and its AVOptions metadata.
public struct AVClass {
    /// The name of the class.
    public let name: String
    /// The options of the class.
    public let options: [AVOption]?
    /// The category of the class. It's used for visualization (like color).
    ///
    /// This is only set if the category is equal for all objects using this class.
    public let category: Category

    /// The libavutil version this class was created with.
    public let version: Int32

    /// The potential child classes for objects of this class.
    public let childClasses: [AVClass]

    init(native: UnsafePointer<CFFmpeg.AVClass>) {
        self.name = String(cString: native.pointee.class_name)
        self.category = Category(rawValue: native.pointee.category.rawValue)!
        self.version = native.pointee.version
        self.options = Array(native.pointee.option, until: { $0.name == nil })?.map(
            AVOption.init(cOption:)
        )
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
        case na
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
            case .na: "na"
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

public protocol AVClassSupport {
    static var `class`: AVClass { get }

    func withUnsafeObjectPointer<T>(_ body: (UnsafeMutableRawPointer) throws -> T) rethrows -> T
}
