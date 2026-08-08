//
//  VideoUtil.swift
//  SwiftFFmpeg
//
//  Created by sunlubo on 2018/8/2.
//

import CFFmpeg

// MARK: - AVPictureType

public enum AVPictureType: UInt32 {
    /// Undefined
    case none = 0
    /// Intra
    case I
    /// Predicted
    case P
    /// Bi-dir predicted
    case B
    /// S(GMC)-VOP MPEG-4
    case S
    /// Switching Intra
    case SI
    /// Switching Predicted
    case SP
    /// BI type
    case BI

    var native: CFFmpeg.AVPictureType {
        CFFmpeg.AVPictureType(rawValue)
    }

    init(native: CFFmpeg.AVPictureType) {
        guard let type = AVPictureType(rawValue: native.rawValue) else {
            fatalError("Unknown picture type: \(native)")
        }
        self = type
    }
}

// MARK: - AVPictureType + CustomStringConvertible

extension AVPictureType: CustomStringConvertible {
    public var description: String {
        let char = av_get_picture_type_char(native)
        let scalar = Unicode.Scalar(Int(char))!
        return String(Character(scalar))
    }
}

public struct AVPixelFormatDescriptor {
    let native: UnsafePointer<AVPixFmtDescriptor>

    /// The name of the pixel format.
    public var name: String {
        String(cString: native.pointee.name) ?? "unknown"
    }

    /// The number of components each pixel has.
    public var numberOfComponents: Int {
        Int(native.pointee.nb_components)
    }
    
    /// Returns the chroma width for the given luma width.
    public func chromaWidth(forLumaWidth width: Int) -> Int {
        let shift = Int(native.pointee.log2_chroma_w)
        return (width + (1 << shift) - 1) >> shift
    }

    /// Returns the chroma height for the given luma height.
    public func chromaHeight(forLumaHeight height: Int) -> Int {
        let shift = Int(native.pointee.log2_chroma_h)
        return (height + (1 << shift) - 1) >> shift
    }

    /// Returns the chroma size for the given luma size.
    public func chromaSize(forLumaSize size: (width: Int, height: Int)) -> (width: Int, height: Int) {
        (chromaWidth(forLumaWidth: size.width), chromaHeight(forLumaHeight: size.height))
    }

    /**
     Parameters that describe how pixels are packed.

     - If the format has 1 or 2 components, then luma is 0.
     - If the format has 3 or 4 components:
        - if the ``AVPixelFormatFlags/rgb`` flag is set then 0 is red, 1 is green and 2 is blue;
        - otherwise 0 is luma, 1 is chroma-U and 2 is chroma-V.

     If present, theaAlpha channel is always the last component.
     */
    public var componentDescriptors: [AVComponentDescriptor] {
        [native.pointee.comp.0, native.pointee.comp.1, native.pointee.comp.2, native.pointee.comp.3].map { AVComponentDescriptor(native: $0) }
    }

    /// The flags of the pixel format.
    public var flags: AVPixelFormatFlags {
        AVPixelFormatFlags(rawValue: native.pointee.flags)
    }

    /// Alternative names of the pixel format.
    public var alias: [String] {
        String(cString: native.pointee.alias)?.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespaces) } ?? []
    }

    /**
     Tthe number of bits per pixel used by the pixel format.

     Note that this is not the same as the number The returned number of bits refers to the number of bits actually used for storing the pixel information, that is padding bits are not counted.
      */
    public var bitsPerPixel: Int {
        Int(av_get_bits_per_pixel(native))
    }

    /// The number of bits per pixel for the pixel format, including any padding or unused bits.
    public var bitsPerPixelPadded: Int {
        Int(av_get_padded_bits_per_pixel(native))
    }

    /*
     /// @return an AVPixelFormat id described by desc, or AV_PIX_FMT_NONE if desc
     /// is not a valid pointer to a pixel format descriptor.
     public var id: AVPixelFormat {
         av_pix_fmt_desc_get_id(native)
     }
     */
}

public struct AVComponentDescriptor {
    /// Which of the 4 planes contains the component.
    public let plane: Int32

    /**
     Number of elements between 2 horizontally consecutive pixels.

     Elements are bits for bitstream formats, bytes otherwise.
     */
    public let step: Int32

    /**
     Number of elements before the component of the first pixel.

     Elements are bits for bitstream formats, bytes otherwise.
     */
    public let offset: Int32

    /// Number of least significant bits that must be shifted away to get the value.
    public let shift: Int32

    /// Number of bits in the component.
    public let depth: Int32

    init(native: CFFmpeg.AVComponentDescriptor) {
        self.depth = native.depth
        self.shift = native.shift
        self.offset = native.offset
        self.step = native.step
        self.plane = native.plane
    }
}

public struct AVPixelFormatFlags: OptionSet, Hashable, CustomStringConvertible, CustomDebugStringConvertible {
    public let rawValue: UInt64

    public init(rawValue: UInt64) {
        self.rawValue = rawValue
    }

    /// Pixel format is big-endian.
    public static let bigEndian = AVPixelFormatFlags(rawValue: UInt64(AV_PIX_FMT_FLAG_BE))

    /// Pixel format has a palette in data[1], values are indexes in this palette.
    public static let palette = AVPixelFormatFlags(rawValue: UInt64(AV_PIX_FMT_FLAG_PAL))

    /// All values of a component are bit-wise packed end to end.
    public static let bitstream = AVPixelFormatFlags(rawValue: UInt64(AV_PIX_FMT_FLAG_BITSTREAM))

    /// Pixel format is an HW accelerated format.
    public static let hwAccelerated = AVPixelFormatFlags(rawValue: UInt64(AV_PIX_FMT_FLAG_HWACCEL))

    /// At least one pixel component is not in the first data plane.
    public static let planar = AVPixelFormatFlags(rawValue: UInt64(AV_PIX_FMT_FLAG_PLANAR))

    /// The pixel format contains RGB-like data (as opposed to YUV/grayscale).
    public static let rgb = AVPixelFormatFlags(rawValue: UInt64(AV_PIX_FMT_FLAG_RGB))

    /// The pixel format has an alpha channel. This is set on all formats that
    /// support alpha in some way, including AV_PIX_FMT_PAL8. The alpha is always
    /// straight, never pre-multiplied.
    /// If a codec or a filter does not support alpha, it should set all alpha to
    /// opaque, or use the equivalent pixel formats without alpha component, e.g.
    /// AV_PIX_FMT_RGB0 (or AV_PIX_FMT_RGB24 etc.) instead of AV_PIX_FMT_RGBA.
    public static let alpha = AVPixelFormatFlags(rawValue: UInt64(AV_PIX_FMT_FLAG_ALPHA))

    /// The pixel format is following a Bayer pattern
    public static let bayer = AVPixelFormatFlags(rawValue: UInt64(AV_PIX_FMT_FLAG_BAYER))

    /// The pixel format contains IEEE-754 floating point values. Precision (double,
    /// single, or half) should be determined by the pixel size (64, 32, or 16 bits).
    public static let floatingPoint = AVPixelFormatFlags(rawValue: UInt64(AV_PIX_FMT_FLAG_FLOAT))

    public var description: String {
        "[\(elements().map { Self.names[$0]?.0 ?? "\($0.rawValue)" }.joined(separator: ", "))]"
    }

    public var debugDescription: String {
        "[\(elements().map { Self.names[$0]?.1 ?? "\($0.rawValue)" }.joined(separator: ", "))]"
    }

    private static let names = [
        Self.alpha: ("alpha", "AV_PIX_FMT_FLAG_ALPHA"),
        .bayer: ("bayer", "AV_PIX_FMT_FLAG_BAYER"),
        .floatingPoint: ("floatingPoint", "AV_PIX_FMT_FLAG_FLOAT"),
        .bigEndian: ("bigEndian", "AV_PIX_FMT_FLAG_BE"),
        .bitstream: ("bitstream", "AV_PIX_FMT_FLAG_BITSTREAM"),
        .palette: ("palette", "AV_PIX_FMT_FLAG_PAL"),
        .planar: ("planar", "AV_PIX_FMT_FLAG_PLANAR"),
        .rgb: ("rgb", "AV_PIX_FMT_FLAG_RGB"),
        .hwAccelerated: ("hwAccelerated", "AV_PIX_FMT_FLAG_HWACCEL"),
    ]
}

/// Describes the field order of interlaced video.
public enum AVFieldOrder: UInt32, CustomStringConvertible, CustomDebugStringConvertible {
    /// The field order is unknown.
    case unknown
    /// The video is progressive and has no field order.
    case progressive
    /// Top coded first, top displayed first.
    case tt
    /// Bottom coded first, bottom displayed first.
    case bb
    /// Top coded first, bottom displayed first.
    case tb
    /// Bottom coded first, top displayed first.
    case bt

    public var description: String {
        switch self {
        case .unknown: "unknown"
        case .progressive: "progressive"
        case .tt: "tt"
        case .bb: "bb"
        case .tb: "tb"
        case .bt: "bt"
        }
    }

    public var debugDescription: String {
        switch self {
        case .unknown: "AV_FIELD_UNKNOWN"
        case .progressive: "AV_FIELD_PROGRESSIVE"
        case .tt: "AV_FIELD_TT"
        case .bb: "AV_FIELD_BB"
        case .tb: "AV_FIELD_TB"
        case .bt: "AV_FIELD_BT"
        }
    }

    init(native: CFFmpeg.AVFieldOrder) {
        guard let value = Self(rawValue: native.rawValue) else {
            fatalError("Unknown field order: \(native)")
        }
        self = value
    }

    var native: CFFmpeg.AVFieldOrder {
        CFFmpeg.AVFieldOrder(rawValue)
    }
}
