//
//  AVPixelFormat.swift
//  SwiftFFmpeg
//
//  Created by sunlubo on 2020/7/1.
//

import CFFmpeg

public typealias AVPixelFormat = CFFmpeg.AVPixelFormat

extension AVPixelFormat: @retroactive CustomStringConvertible {
    /// Return the pixel format corresponding to name.
    ///
    /// If there is no pixel format with name name, then looks for a pixel format with the name
    /// corresponding to the native endian format of name.
    /// For example in a little-endian system, first looks for "gray16", then for "gray16le".
    ///
    /// Finally if no pixel format has been found, returns `nil`.
    public init?(name: String) {
        let type = av_get_pix_fmt(name)
        guard type != .none else {
            return nil
        }
        self = type
    }
    
    public init(_ rawValue: Int32) {
        self = AVPixelFormat(rawValue: rawValue)
    }

    /// The name of the pixel format.
    public var name: String {
        String(cString: av_get_pix_fmt_name(self)) ?? "\(rawValue)"
    }

    /// The number of planes in the pixel format.
    public var planeCount: Int {
        max(Int(av_pix_fmt_count_planes(self)), 0)
    }

    /// The number of components each pixel has.
    public var numberOfComponents: Int? {
        desc.map { Int($0.pointee.nb_components) }
    }

    /**
     The number of bits per pixel used.

     Note that this is not the same as the number of bits per sample. he returned number of bits refers to the number of bits actually used for storing the pixel information, that is padding bits are not counted.
     */
    public var bitsPerPixel: Int32? {
        desc.map { av_get_bits_per_pixel($0) }
    }

    /// The number of bits per pixel, including any padding or unused bits.
    public var bitsPerPixelPadded: Int32? {
        desc.map { av_get_padded_bits_per_pixel($0) }
    }

    /// Alternative names.
    public var alias: [String] {
        String(cString: desc?.pointee.alias)?.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespaces) } ?? []
    }

    /**
     Amount to shift the luma width right to find the chroma width.
     For YV12 this is 1 for example.

     chroma_width = AV_CEIL_RSHIFT(luma_width, log2_chroma_w)
     The note above is needed to ensure rounding up.
     This value only refers to the chroma components.
      */
    public var log2ChromaW: Int? {
        desc.map { Int($0.pointee.log2_chroma_w) }
    }

    /**
     Amount to shift the luma height right to find the chroma height.

     For YV12 this is 1 for example.
     chroma_height= AV_CEIL_RSHIFT(luma_height, log2_chroma_h)
     The note above is needed to ensure rounding up.
     This value only refers to the chroma components.
      */
    public var log2ChromaH: Int? {
        desc.map { Int($0.pointee.log2_chroma_h) }
    }

    public var desc: UnsafePointer<AVPixFmtDescriptor>? {
        av_pix_fmt_desc_get(self)
    }

    /*
     public var numberOfComponents: Int {
       Int(native.pointee.nb_components)
     }
     */

    /// The pixel format descriptor of the pixel format.
    public var descriptor: AVPixelFormatDescriptor? {
        av_pix_fmt_desc_get(self).map(AVPixelFormatDescriptor.init(native:))
    }
    
    public var description: String {
        name
    }
}

extension AVPixelFormat {
    /// None.
    public static let none = AV_PIX_FMT_NONE
    /// planar YUV 4:2:0, 12bpp, (1 Cr & Cb sample per 2x2 Y samples)
    public static let yuv420p = AV_PIX_FMT_YUV420P
    /// packed YUV 4:2:2, 16bpp, Y0 Cb Y1 Cr
    public static let yuyv422 = AV_PIX_FMT_YUYV422
    /**
     packed RGB 8:8:8, 24bpp, RGBRGB...
     */
    public static let rgb24 = AV_PIX_FMT_RGB24
    /**
     packed RGB 8:8:8, 24bpp, BGRBGR...
     */
    public static let bgr24 = AV_PIX_FMT_BGR24
    /// planar YUV 4:2:2, 16bpp, (1 Cr & Cb sample per 2x1 Y samples)
    public static let yuv422p = AV_PIX_FMT_YUV422P
    /// planar YUV 4:4:4, 24bpp, (1 Cr & Cb sample per 1x1 Y samples)
    public static let yuv444p = AV_PIX_FMT_YUV444P
    /// planar YUV 4:1:0,  9bpp, (1 Cr & Cb sample per 4x4 Y samples)
    public static let yuv410p = AV_PIX_FMT_YUV410P
    /// planar YUV 4:1:1, 12bpp, (1 Cr & Cb sample per 4x1 Y samples)
    public static let yuv411p = AV_PIX_FMT_YUV411P
    /// Y        ,  8bpp
    public static let gray8 = AV_PIX_FMT_GRAY8
    /**
     Y        ,  1bpp, 0 is white, 1 is black, in each byte pixels are ordered from the msb to the lsb
     */
    public static let monowhite = AV_PIX_FMT_MONOWHITE
    /**
     Y        ,  1bpp, 0 is black, 1 is white, in each byte pixels are ordered from the msb to the lsb
     */
    public static let monoblack = AV_PIX_FMT_MONOBLACK
    /// 8 bits with AV_PIX_FMT_RGB32 palette
    public static let pal8 = AV_PIX_FMT_PAL8
    /**
     planar YUV 4:2:0, 12bpp, full scale (JPEG), deprecated in favor of AV_PIX_FMT_YUV420P and setting color_range
     */
    public static let yuvj420p = AV_PIX_FMT_YUVJ420P
    /**
     planar YUV 4:2:2, 16bpp, full scale (JPEG), deprecated in favor of AV_PIX_FMT_YUV422P and setting color_range
     */
    public static let yuvj422p = AV_PIX_FMT_YUVJ422P
    /**
     planar YUV 4:4:4, 24bpp, full scale (JPEG), deprecated in favor of AV_PIX_FMT_YUV444P and setting color_range
     */
    public static let yuvj444p = AV_PIX_FMT_YUVJ444P
    /// packed YUV 4:2:2, 16bpp, Cb Y0 Cr Y1
    public static let uyvy422 = AV_PIX_FMT_UYVY422
    /// packed YUV 4:1:1, 12bpp, Cb Y0 Y1 Cr Y2 Y3
    public static let uyyvyy411 = AV_PIX_FMT_UYYVYY411
    /// packed RGB 3:3:2,  8bpp, (msb)2B 3G 3R(lsb)
    public static let bgr8 = AV_PIX_FMT_BGR8
    /**
     packed RGB 1:2:1 bitstream,  4bpp, (msb)1B 2G 1R(lsb), a byte contains two pixels, the first pixel in the byte is the one composed by the 4 msb bits
     */
    public static let bgr4 = AV_PIX_FMT_BGR4
    /// packed RGB 1:2:1,  8bpp, (msb)1B 2G 1R(lsb)
    public static let bgr4Byte = AV_PIX_FMT_BGR4_BYTE
    /// packed RGB 3:3:2,  8bpp, (msb)3R 3G 2B(lsb)
    public static let rgb8 = AV_PIX_FMT_RGB8
    /**
     packed RGB 1:2:1 bitstream,  4bpp, (msb)1R 2G 1B(lsb), a byte contains two pixels, the first pixel in the byte is the one composed by the 4 msb bits
     */
    public static let rgb4 = AV_PIX_FMT_RGB4
    /// packed RGB 1:2:1,  8bpp, (msb)1R 2G 1B(lsb)
    public static let rgb4Byte = AV_PIX_FMT_RGB4_BYTE
    /**
     planar YUV 4:2:0, 12bpp, 1 plane for Y and 1 plane for the UV components, which are interleaved (first byte U and the following byte V)
     */
    public static let nv12 = AV_PIX_FMT_NV12
    /// as above, but U and V bytes are swapped
    public static let nv21 = AV_PIX_FMT_NV21
    /**
     packed ARGB 8:8:8:8, 32bpp, ARGBARGB...
     */
    public static let argb = AV_PIX_FMT_ARGB
    /**
     packed RGBA 8:8:8:8, 32bpp, RGBARGBA...
     */
    public static let rgba = AV_PIX_FMT_RGBA
    /**
     packed ABGR 8:8:8:8, 32bpp, ABGRABGR...
     */
    public static let abgr = AV_PIX_FMT_ABGR
    /**
     packed BGRA 8:8:8:8, 32bpp, BGRABGRA...
     */
    public static let bgra = AV_PIX_FMT_BGRA
    /// Y        , 16bpp, big-endian
    public static let gray16be = AV_PIX_FMT_GRAY16BE
    /// Y        , 16bpp, little-endian
    public static let gray16le = AV_PIX_FMT_GRAY16LE
    /// planar YUV 4:4:0 (1 Cr & Cb sample per 1x2 Y samples)
    public static let yuv440p = AV_PIX_FMT_YUV440P
    /**
     planar YUV 4:4:0 full scale (JPEG), deprecated in favor of AV_PIX_FMT_YUV440P and setting color_range
     */
    public static let yuvj440p = AV_PIX_FMT_YUVJ440P
    /// planar YUV 4:2:0, 20bpp, (1 Cr & Cb sample per 2x2 Y & A samples)
    public static let yuva420p = AV_PIX_FMT_YUVA420P
    /**
     packed RGB 16:16:16, 48bpp, 16R, 16G, 16B, the 2-byte value for each R/G/B component is stored as big-endian
     */
    public static let rgb48be = AV_PIX_FMT_RGB48BE
    /**
     packed RGB 16:16:16, 48bpp, 16R, 16G, 16B, the 2-byte value for each R/G/B component is stored as little-endian
     */
    public static let rgb48le = AV_PIX_FMT_RGB48LE
    /// packed RGB 5:6:5, 16bpp, (msb)   5R 6G 5B(lsb), big-endian
    public static let rgb565be = AV_PIX_FMT_RGB565BE
    /// packed RGB 5:6:5, 16bpp, (msb)   5R 6G 5B(lsb), little-endian
    public static let rgb565le = AV_PIX_FMT_RGB565LE
    /// packed RGB 5:5:5, 16bpp, (msb)1X 5R 5G 5B(lsb), big-endian   , X=unused/undefined
    public static let rgb555be = AV_PIX_FMT_RGB555BE
    /// packed RGB 5:5:5, 16bpp, (msb)1X 5R 5G 5B(lsb), little-endian, X=unused/undefined
    public static let rgb555le = AV_PIX_FMT_RGB555LE
    /// packed BGR 5:6:5, 16bpp, (msb)   5B 6G 5R(lsb), big-endian
    public static let bgr565be = AV_PIX_FMT_BGR565BE
    /// packed BGR 5:6:5, 16bpp, (msb)   5B 6G 5R(lsb), little-endian
    public static let bgr565le = AV_PIX_FMT_BGR565LE
    /// packed BGR 5:5:5, 16bpp, (msb)1X 5B 5G 5R(lsb), big-endian   , X=unused/undefined
    public static let bgr555be = AV_PIX_FMT_BGR555BE
    /// packed BGR 5:5:5, 16bpp, (msb)1X 5B 5G 5R(lsb), little-endian, X=unused/undefined
    public static let bgr555le = AV_PIX_FMT_BGR555LE
    public static let vaapi = AV_PIX_FMT_VAAPI
    /// planar YUV 4:2:0, 24bpp, (1 Cr & Cb sample per 2x2 Y samples), little-endian
    public static let yuv420p16le = AV_PIX_FMT_YUV420P16LE
    /// planar YUV 4:2:0, 24bpp, (1 Cr & Cb sample per 2x2 Y samples), big-endian
    public static let yuv420p16be = AV_PIX_FMT_YUV420P16BE
    /// planar YUV 4:2:2, 32bpp, (1 Cr & Cb sample per 2x1 Y samples), little-endian
    public static let yuv422p16le = AV_PIX_FMT_YUV422P16LE
    /// planar YUV 4:2:2, 32bpp, (1 Cr & Cb sample per 2x1 Y samples), big-endian
    public static let yuv422p16be = AV_PIX_FMT_YUV422P16BE
    /// planar YUV 4:4:4, 48bpp, (1 Cr & Cb sample per 1x1 Y samples), little-endian
    public static let yuv444p16le = AV_PIX_FMT_YUV444P16LE
    /// planar YUV 4:4:4, 48bpp, (1 Cr & Cb sample per 1x1 Y samples), big-endian
    public static let yuv444p16be = AV_PIX_FMT_YUV444P16BE
    /**
     HW decoding through DXVA2, Picture.data[3] contains a LPDIRECT3DSURFACE9 pointer
     */
    public static let dxva2Vld = AV_PIX_FMT_DXVA2_VLD
    /// packed RGB 4:4:4, 16bpp, (msb)4X 4R 4G 4B(lsb), little-endian, X=unused/undefined
    public static let rgb444le = AV_PIX_FMT_RGB444LE
    /// packed RGB 4:4:4, 16bpp, (msb)4X 4R 4G 4B(lsb), big-endian,    X=unused/undefined
    public static let rgb444be = AV_PIX_FMT_RGB444BE
    /// packed BGR 4:4:4, 16bpp, (msb)4X 4B 4G 4R(lsb), little-endian, X=unused/undefined
    public static let bgr444le = AV_PIX_FMT_BGR444LE
    /// packed BGR 4:4:4, 16bpp, (msb)4X 4B 4G 4R(lsb), big-endian,    X=unused/undefined
    public static let bgr444be = AV_PIX_FMT_BGR444BE
    /// 8 bits gray, 8 bits alpha
    public static let ya8 = AV_PIX_FMT_YA8
    /// alias for AV_PIX_FMT_YA8
    public static let y400a = ya8
    /// alias for AV_PIX_FMT_YA8
    public static let gray8a = ya8
    /**
     packed RGB 16:16:16, 48bpp, 16B, 16G, 16R, the 2-byte value for each R/G/B component is stored as big-endian
     */
    public static let bgr48be = AV_PIX_FMT_BGR48BE
    /**
     packed RGB 16:16:16, 48bpp, 16B, 16G, 16R, the 2-byte value for each R/G/B component is stored as little-endian
     */
    public static let bgr48le = AV_PIX_FMT_BGR48LE
    /**
     planar YUV 4:2:0, 13.5bpp, (1 Cr & Cb sample per 2x2 Y samples), big-endian
     */
    public static let yuv420p9be = AV_PIX_FMT_YUV420P9BE
    /**
     planar YUV 4:2:0, 13.5bpp, (1 Cr & Cb sample per 2x2 Y samples), little-endian
     */
    public static let yuv420p9le = AV_PIX_FMT_YUV420P9LE
    /// planar YUV 4:2:0, 15bpp, (1 Cr & Cb sample per 2x2 Y samples), big-endian
    public static let yuv420p10be = AV_PIX_FMT_YUV420P10BE
    /// planar YUV 4:2:0, 15bpp, (1 Cr & Cb sample per 2x2 Y samples), little-endian
    public static let yuv420p10le = AV_PIX_FMT_YUV420P10LE
    /// planar YUV 4:2:2, 20bpp, (1 Cr & Cb sample per 2x1 Y samples), big-endian
    public static let yuv422p10be = AV_PIX_FMT_YUV422P10BE
    /// planar YUV 4:2:2, 20bpp, (1 Cr & Cb sample per 2x1 Y samples), little-endian
    public static let yuv422p10le = AV_PIX_FMT_YUV422P10LE
    /// planar YUV 4:4:4, 27bpp, (1 Cr & Cb sample per 1x1 Y samples), big-endian
    public static let yuv444p9be = AV_PIX_FMT_YUV444P9BE
    /// planar YUV 4:4:4, 27bpp, (1 Cr & Cb sample per 1x1 Y samples), little-endian
    public static let yuv444p9le = AV_PIX_FMT_YUV444P9LE
    /// planar YUV 4:4:4, 30bpp, (1 Cr & Cb sample per 1x1 Y samples), big-endian
    public static let yuv444p10be = AV_PIX_FMT_YUV444P10BE
    /// planar YUV 4:4:4, 30bpp, (1 Cr & Cb sample per 1x1 Y samples), little-endian
    public static let yuv444p10le = AV_PIX_FMT_YUV444P10LE
    /// planar YUV 4:2:2, 18bpp, (1 Cr & Cb sample per 2x1 Y samples), big-endian
    public static let yuv422p9be = AV_PIX_FMT_YUV422P9BE
    /// planar YUV 4:2:2, 18bpp, (1 Cr & Cb sample per 2x1 Y samples), little-endian
    public static let yuv422p9le = AV_PIX_FMT_YUV422P9LE
    /// planar GBR 4:4:4 24bpp
    public static let gbrp = AV_PIX_FMT_GBRP
    /// planar GBR 4:4:4 27bpp, big-endian
    public static let gbrp9be = AV_PIX_FMT_GBRP9BE
    /// planar GBR 4:4:4 27bpp, little-endian
    public static let gbrp9le = AV_PIX_FMT_GBRP9LE
    /// planar GBR 4:4:4 30bpp, big-endian
    public static let gbrp10be = AV_PIX_FMT_GBRP10BE
    /// planar GBR 4:4:4 30bpp, little-endian
    public static let gbrp10le = AV_PIX_FMT_GBRP10LE
    /// planar GBR 4:4:4 48bpp, big-endian
    public static let gbrp16be = AV_PIX_FMT_GBRP16BE
    /// planar GBR 4:4:4 48bpp, little-endian
    public static let gbrp16le = AV_PIX_FMT_GBRP16LE
    /// planar YUV 4:2:2 24bpp, (1 Cr & Cb sample per 2x1 Y & A samples)
    public static let yuva422p = AV_PIX_FMT_YUVA422P
    /// planar YUV 4:4:4 32bpp, (1 Cr & Cb sample per 1x1 Y & A samples)
    public static let yuva444p = AV_PIX_FMT_YUVA444P
    /**
     planar YUV 4:2:0 22.5bpp, (1 Cr & Cb sample per 2x2 Y & A samples), big-endian
     */
    public static let yuva420p9be = AV_PIX_FMT_YUVA420P9BE
    /**
     planar YUV 4:2:0 22.5bpp, (1 Cr & Cb sample per 2x2 Y & A samples), little-endian
     */
    public static let yuva420p9le = AV_PIX_FMT_YUVA420P9LE
    /// planar YUV 4:2:2 27bpp, (1 Cr & Cb sample per 2x1 Y & A samples), big-endian
    public static let yuva422p9be = AV_PIX_FMT_YUVA422P9BE
    /// planar YUV 4:2:2 27bpp, (1 Cr & Cb sample per 2x1 Y & A samples), little-endian
    public static let yuva422p9le = AV_PIX_FMT_YUVA422P9LE
    /// planar YUV 4:4:4 36bpp, (1 Cr & Cb sample per 1x1 Y & A samples), big-endian
    public static let yuva444p9be = AV_PIX_FMT_YUVA444P9BE
    /// planar YUV 4:4:4 36bpp, (1 Cr & Cb sample per 1x1 Y & A samples), little-endian
    public static let yuva444p9le = AV_PIX_FMT_YUVA444P9LE
    /// planar YUV 4:2:0 25bpp, (1 Cr & Cb sample per 2x2 Y & A samples, big-endian)
    public static let yuva420p10be = AV_PIX_FMT_YUVA420P10BE
    /// planar YUV 4:2:0 25bpp, (1 Cr & Cb sample per 2x2 Y & A samples, little-endian)
    public static let yuva420p10le = AV_PIX_FMT_YUVA420P10LE
    /// planar YUV 4:2:2 30bpp, (1 Cr & Cb sample per 2x1 Y & A samples, big-endian)
    public static let yuva422p10be = AV_PIX_FMT_YUVA422P10BE
    /// planar YUV 4:2:2 30bpp, (1 Cr & Cb sample per 2x1 Y & A samples, little-endian)
    public static let yuva422p10le = AV_PIX_FMT_YUVA422P10LE
    /// planar YUV 4:4:4 40bpp, (1 Cr & Cb sample per 1x1 Y & A samples, big-endian)
    public static let yuva444p10be = AV_PIX_FMT_YUVA444P10BE
    /// planar YUV 4:4:4 40bpp, (1 Cr & Cb sample per 1x1 Y & A samples, little-endian)
    public static let yuva444p10le = AV_PIX_FMT_YUVA444P10LE
    /// planar YUV 4:2:0 40bpp, (1 Cr & Cb sample per 2x2 Y & A samples, big-endian)
    public static let yuva420p16be = AV_PIX_FMT_YUVA420P16BE
    /// planar YUV 4:2:0 40bpp, (1 Cr & Cb sample per 2x2 Y & A samples, little-endian)
    public static let yuva420p16le = AV_PIX_FMT_YUVA420P16LE
    /// planar YUV 4:2:2 48bpp, (1 Cr & Cb sample per 2x1 Y & A samples, big-endian)
    public static let yuva422p16be = AV_PIX_FMT_YUVA422P16BE
    /// planar YUV 4:2:2 48bpp, (1 Cr & Cb sample per 2x1 Y & A samples, little-endian)
    public static let yuva422p16le = AV_PIX_FMT_YUVA422P16LE
    /// planar YUV 4:4:4 64bpp, (1 Cr & Cb sample per 1x1 Y & A samples, big-endian)
    public static let yuva444p16be = AV_PIX_FMT_YUVA444P16BE
    /// planar YUV 4:4:4 64bpp, (1 Cr & Cb sample per 1x1 Y & A samples, little-endian)
    public static let yuva444p16le = AV_PIX_FMT_YUVA444P16LE
    /**
     HW acceleration through VDPAU, Picture.data[3] contains a VdpVideoSurface
     */
    public static let vdpau = AV_PIX_FMT_VDPAU
    /**
     packed XYZ 4:4:4, 36 bpp, (msb) 12X, 12Y, 12Z (lsb), the 2-byte value for each X/Y/Z is stored as little-endian, the 4 lower bits are set to 0
     */
    public static let xyz12le = AV_PIX_FMT_XYZ12LE
    /**
     packed XYZ 4:4:4, 36 bpp, (msb) 12X, 12Y, 12Z (lsb), the 2-byte value for each X/Y/Z is stored as big-endian, the 4 lower bits are set to 0
     */
    public static let xyz12be = AV_PIX_FMT_XYZ12BE
    /// interleaved chroma YUV 4:2:2, 16bpp, (1 Cr & Cb sample per 2x1 Y samples)
    public static let nv16 = AV_PIX_FMT_NV16
    /// interleaved chroma YUV 4:2:2, 20bpp, (1 Cr & Cb sample per 2x1 Y samples), little-endian
    public static let nv20le = AV_PIX_FMT_NV20LE
    /// interleaved chroma YUV 4:2:2, 20bpp, (1 Cr & Cb sample per 2x1 Y samples), big-endian
    public static let nv20be = AV_PIX_FMT_NV20BE
    /**
     packed RGBA 16:16:16:16, 64bpp, 16R, 16G, 16B, 16A, the 2-byte value for each R/G/B/A component is stored as big-endian
     */
    public static let rgba64be = AV_PIX_FMT_RGBA64BE
    /**
     packed RGBA 16:16:16:16, 64bpp, 16R, 16G, 16B, 16A, the 2-byte value for each R/G/B/A component is stored as little-endian
     */
    public static let rgba64le = AV_PIX_FMT_RGBA64LE
    /**
     packed RGBA 16:16:16:16, 64bpp, 16B, 16G, 16R, 16A, the 2-byte value for each R/G/B/A component is stored as big-endian
     */
    public static let bgra64be = AV_PIX_FMT_BGRA64BE
    /**
     packed RGBA 16:16:16:16, 64bpp, 16B, 16G, 16R, 16A, the 2-byte value for each R/G/B/A component is stored as little-endian
     */
    public static let bgra64le = AV_PIX_FMT_BGRA64LE
    /// packed YUV 4:2:2, 16bpp, Y0 Cr Y1 Cb
    public static let yvyu422 = AV_PIX_FMT_YVYU422
    /// 16 bits gray, 16 bits alpha (big-endian)
    public static let ya16be = AV_PIX_FMT_YA16BE
    /// 16 bits gray, 16 bits alpha (little-endian)
    public static let ya16le = AV_PIX_FMT_YA16LE
    /// planar GBRA 4:4:4:4 32bpp
    public static let gbrap = AV_PIX_FMT_GBRAP
    /// planar GBRA 4:4:4:4 64bpp, big-endian
    public static let gbrap16be = AV_PIX_FMT_GBRAP16BE
    /// planar GBRA 4:4:4:4 64bpp, little-endian
    public static let gbrap16le = AV_PIX_FMT_GBRAP16LE
    /**
     HW acceleration through QSV, data[3] contains a pointer to the mfxFrameSurface1 structure.
     */
    public static let qsv = AV_PIX_FMT_QSV
    public static let mmal = AV_PIX_FMT_MMAL
    /**
     HW decoding through Direct3D11 via old API, Picture.data[3] contains a ID3D11VideoDecoderOutputView pointer
     */
    public static let d3d11vaVld = AV_PIX_FMT_D3D11VA_VLD
    public static let cuda = AV_PIX_FMT_CUDA
    /**
     packed RGB 8:8:8, 32bpp, XRGBXRGB..
       X=unused/undefined
     */
    public static let format0rgb = AV_PIX_FMT_0RGB
    /**
     packed RGB 8:8:8, 32bpp, RGBXRGBX..
       X=unused/undefined
     */
    public static let rgb0 = AV_PIX_FMT_RGB0
    /**
     packed BGR 8:8:8, 32bpp, XBGRXBGR..
       X=unused/undefined
     */
    public static let format0bgr = AV_PIX_FMT_0BGR
    /**
     packed BGR 8:8:8, 32bpp, BGRXBGRX..
       X=unused/undefined
     */
    public static let bgr0 = AV_PIX_FMT_BGR0
    /// planar YUV 4:2:0,18bpp, (1 Cr & Cb sample per 2x2 Y samples), big-endian
    public static let yuv420p12be = AV_PIX_FMT_YUV420P12BE
    /// planar YUV 4:2:0,18bpp, (1 Cr & Cb sample per 2x2 Y samples), little-endian
    public static let yuv420p12le = AV_PIX_FMT_YUV420P12LE
    /// planar YUV 4:2:0,21bpp, (1 Cr & Cb sample per 2x2 Y samples), big-endian
    public static let yuv420p14be = AV_PIX_FMT_YUV420P14BE
    /// planar YUV 4:2:0,21bpp, (1 Cr & Cb sample per 2x2 Y samples), little-endian
    public static let yuv420p14le = AV_PIX_FMT_YUV420P14LE
    /// planar YUV 4:2:2,24bpp, (1 Cr & Cb sample per 2x1 Y samples), big-endian
    public static let yuv422p12be = AV_PIX_FMT_YUV422P12BE
    /// planar YUV 4:2:2,24bpp, (1 Cr & Cb sample per 2x1 Y samples), little-endian
    public static let yuv422p12le = AV_PIX_FMT_YUV422P12LE
    /// planar YUV 4:2:2,28bpp, (1 Cr & Cb sample per 2x1 Y samples), big-endian
    public static let yuv422p14be = AV_PIX_FMT_YUV422P14BE
    /// planar YUV 4:2:2,28bpp, (1 Cr & Cb sample per 2x1 Y samples), little-endian
    public static let yuv422p14le = AV_PIX_FMT_YUV422P14LE
    /// planar YUV 4:4:4,36bpp, (1 Cr & Cb sample per 1x1 Y samples), big-endian
    public static let yuv444p12be = AV_PIX_FMT_YUV444P12BE
    /// planar YUV 4:4:4,36bpp, (1 Cr & Cb sample per 1x1 Y samples), little-endian
    public static let yuv444p12le = AV_PIX_FMT_YUV444P12LE
    /// planar YUV 4:4:4,42bpp, (1 Cr & Cb sample per 1x1 Y samples), big-endian
    public static let yuv444p14be = AV_PIX_FMT_YUV444P14BE
    /// planar YUV 4:4:4,42bpp, (1 Cr & Cb sample per 1x1 Y samples), little-endian
    public static let yuv444p14le = AV_PIX_FMT_YUV444P14LE
    /// planar GBR 4:4:4 36bpp, big-endian
    public static let gbrp12be = AV_PIX_FMT_GBRP12BE
    /// planar GBR 4:4:4 36bpp, little-endian
    public static let gbrp12le = AV_PIX_FMT_GBRP12LE
    /// planar GBR 4:4:4 42bpp, big-endian
    public static let gbrp14be = AV_PIX_FMT_GBRP14BE
    /// planar GBR 4:4:4 42bpp, little-endian
    public static let gbrp14le = AV_PIX_FMT_GBRP14LE
    /**
     planar YUV 4:1:1, 12bpp, (1 Cr & Cb sample per 4x1 Y samples) full scale (JPEG), deprecated in favor of AV_PIX_FMT_YUV411P and setting color_range
     */
    public static let yuvj411p = AV_PIX_FMT_YUVJ411P
    /**
     bayer, BGBG..(odd line), GRGR..(even line), 8-bit samples
     */
    public static let bayerBggr8 = AV_PIX_FMT_BAYER_BGGR8
    /**
     bayer, RGRG..(odd line), GBGB..(even line), 8-bit samples
     */
    public static let bayerRggb8 = AV_PIX_FMT_BAYER_RGGB8
    /**
     bayer, GBGB..(odd line), RGRG..(even line), 8-bit samples
     */
    public static let bayerGbrg8 = AV_PIX_FMT_BAYER_GBRG8
    /**
     bayer, GRGR..(odd line), BGBG..(even line), 8-bit samples
     */
    public static let bayerGrbg8 = AV_PIX_FMT_BAYER_GRBG8
    /**
     bayer, BGBG..(odd line), GRGR..(even line), 16-bit samples, little-endian
     */
    public static let bayerBggr16le = AV_PIX_FMT_BAYER_BGGR16LE
    /**
     bayer, BGBG..(odd line), GRGR..(even line), 16-bit samples, big-endian
     */
    public static let bayerBggr16be = AV_PIX_FMT_BAYER_BGGR16BE
    /**
     bayer, RGRG..(odd line), GBGB..(even line), 16-bit samples, little-endian
     */
    public static let bayerRggb16le = AV_PIX_FMT_BAYER_RGGB16LE
    /**
     bayer, RGRG..(odd line), GBGB..(even line), 16-bit samples, big-endian
     */
    public static let bayerRggb16be = AV_PIX_FMT_BAYER_RGGB16BE
    /**
     bayer, GBGB..(odd line), RGRG..(even line), 16-bit samples, little-endian
     */
    public static let bayerGbrg16le = AV_PIX_FMT_BAYER_GBRG16LE
    /**
     bayer, GBGB..(odd line), RGRG..(even line), 16-bit samples, big-endian
     */
    public static let bayerGbrg16be = AV_PIX_FMT_BAYER_GBRG16BE
    /**
     bayer, GRGR..(odd line), BGBG..(even line), 16-bit samples, little-endian
     */
    public static let bayerGrbg16le = AV_PIX_FMT_BAYER_GRBG16LE
    /**
     bayer, GRGR..(odd line), BGBG..(even line), 16-bit samples, big-endian
     */
    public static let bayerGrbg16be = AV_PIX_FMT_BAYER_GRBG16BE
    /// planar YUV 4:4:0,20bpp, (1 Cr & Cb sample per 1x2 Y samples), little-endian
    public static let yuv440p10le = AV_PIX_FMT_YUV440P10LE
    /// planar YUV 4:4:0,20bpp, (1 Cr & Cb sample per 1x2 Y samples), big-endian
    public static let yuv440p10be = AV_PIX_FMT_YUV440P10BE
    /// planar YUV 4:4:0,24bpp, (1 Cr & Cb sample per 1x2 Y samples), little-endian
    public static let yuv440p12le = AV_PIX_FMT_YUV440P12LE
    /// planar YUV 4:4:0,24bpp, (1 Cr & Cb sample per 1x2 Y samples), big-endian
    public static let yuv440p12be = AV_PIX_FMT_YUV440P12BE
    /// packed AYUV 4:4:4,64bpp (1 Cr & Cb sample per 1x1 Y & A samples), little-endian
    public static let ayuv64le = AV_PIX_FMT_AYUV64LE
    /// packed AYUV 4:4:4,64bpp (1 Cr & Cb sample per 1x1 Y & A samples), big-endian
    public static let ayuv64be = AV_PIX_FMT_AYUV64BE
    /// hardware decoding through Videotoolbox
    public static let videotoolbox = AV_PIX_FMT_VIDEOTOOLBOX
    /**
     like NV12, with 10bpp per component, data in the high bits, zeros in the low bits, little-endian
     */
    public static let p010le = AV_PIX_FMT_P010LE
    /**
     like NV12, with 10bpp per component, data in the high bits, zeros in the low bits, big-endian
     */
    public static let p010be = AV_PIX_FMT_P010BE
    /// planar GBR 4:4:4:4 48bpp, big-endian
    public static let gbrap12be = AV_PIX_FMT_GBRAP12BE
    /// planar GBR 4:4:4:4 48bpp, little-endian
    public static let gbrap12le = AV_PIX_FMT_GBRAP12LE
    /// planar GBR 4:4:4:4 40bpp, big-endian
    public static let gbrap10be = AV_PIX_FMT_GBRAP10BE
    /// planar GBR 4:4:4:4 40bpp, little-endian
    public static let gbrap10le = AV_PIX_FMT_GBRAP10LE
    /// hardware decoding through MediaCodec
    public static let mediacodec = AV_PIX_FMT_MEDIACODEC
    /// Y        , 12bpp, big-endian
    public static let gray12be = AV_PIX_FMT_GRAY12BE
    /// Y        , 12bpp, little-endian
    public static let gray12le = AV_PIX_FMT_GRAY12LE
    /// Y        , 10bpp, big-endian
    public static let gray10be = AV_PIX_FMT_GRAY10BE
    /// Y        , 10bpp, little-endian
    public static let gray10le = AV_PIX_FMT_GRAY10LE
    /// like NV12, with 16bpp per component, little-endian
    public static let p016le = AV_PIX_FMT_P016LE
    /// like NV12, with 16bpp per component, big-endian
    public static let p016be = AV_PIX_FMT_P016BE
    public static let d3d11 = AV_PIX_FMT_D3D11
    /// Y        , 9bpp, big-endian
    public static let gray9be = AV_PIX_FMT_GRAY9BE
    /// Y        , 9bpp, little-endian
    public static let gray9le = AV_PIX_FMT_GRAY9LE
    /// IEEE-754 single precision planar GBR 4:4:4,     96bpp, big-endian
    public static let gbrpf32be = AV_PIX_FMT_GBRPF32BE
    /// IEEE-754 single precision planar GBR 4:4:4,     96bpp, little-endian
    public static let gbrpf32le = AV_PIX_FMT_GBRPF32LE
    /// IEEE-754 single precision planar GBRA 4:4:4:4, 128bpp, big-endian
    public static let gbrapf32be = AV_PIX_FMT_GBRAPF32BE
    /// IEEE-754 single precision planar GBRA 4:4:4:4, 128bpp, little-endian
    public static let gbrapf32le = AV_PIX_FMT_GBRAPF32LE
    public static let drmPRIME = AV_PIX_FMT_DRM_PRIME
    public static let opencl = AV_PIX_FMT_OPENCL
    /// Y        , 14bpp, big-endian
    public static let gray14be = AV_PIX_FMT_GRAY14BE
    /// Y        , 14bpp, little-endian
    public static let gray14le = AV_PIX_FMT_GRAY14LE
    /// IEEE-754 single precision Y, 32bpp, big-endian
    public static let grayf32be = AV_PIX_FMT_GRAYF32BE
    /// IEEE-754 single precision Y, 32bpp, little-endian
    public static let grayf32le = AV_PIX_FMT_GRAYF32LE
    /// planar YUV 4:2:2,24bpp, (1 Cr & Cb sample per 2x1 Y samples), 12b alpha, big-endian
    public static let yuva422p12be = AV_PIX_FMT_YUVA422P12BE
    /// planar YUV 4:2:2,24bpp, (1 Cr & Cb sample per 2x1 Y samples), 12b alpha, little-endian
    public static let yuva422p12le = AV_PIX_FMT_YUVA422P12LE
    /// planar YUV 4:4:4,36bpp, (1 Cr & Cb sample per 1x1 Y samples), 12b alpha, big-endian
    public static let yuva444p12be = AV_PIX_FMT_YUVA444P12BE
    /// planar YUV 4:4:4,36bpp, (1 Cr & Cb sample per 1x1 Y samples), 12b alpha, little-endian
    public static let yuva444p12le = AV_PIX_FMT_YUVA444P12LE
    /**
     planar YUV 4:4:4, 24bpp, 1 plane for Y and 1 plane for the UV components, which are interleaved (first byte U and the following byte V)
     */
    public static let nv24 = AV_PIX_FMT_NV24
    /// as above, but U and V bytes are swapped
    public static let nv42 = AV_PIX_FMT_NV42
    public static let vulkan = AV_PIX_FMT_VULKAN
    /// packed YUV 4:2:2 like YUYV422, 20bpp, data in the high bits, big-endian
    public static let y210be = AV_PIX_FMT_Y210BE
    /// packed YUV 4:2:2 like YUYV422, 20bpp, data in the high bits, little-endian
    public static let y210le = AV_PIX_FMT_Y210LE
    /// packed RGB 10:10:10, 30bpp, (msb)2X 10R 10G 10B(lsb), little-endian, X=unused/undefined
    public static let x2rgb10le = AV_PIX_FMT_X2RGB10LE
    /// packed RGB 10:10:10, 30bpp, (msb)2X 10R 10G 10B(lsb), big-endian, X=unused/undefined
    public static let x2rgb10be = AV_PIX_FMT_X2RGB10BE
    /// packed BGR 10:10:10, 30bpp, (msb)2X 10B 10G 10R(lsb), little-endian, X=unused/undefined
    public static let x2bgr10le = AV_PIX_FMT_X2BGR10LE
    /// packed BGR 10:10:10, 30bpp, (msb)2X 10B 10G 10R(lsb), big-endian, X=unused/undefined
    public static let x2bgr10be = AV_PIX_FMT_X2BGR10BE
    /// interleaved chroma YUV 4:2:2, 20bpp, data in the high bits, big-endian
    public static let p210be = AV_PIX_FMT_P210BE
    /// interleaved chroma YUV 4:2:2, 20bpp, data in the high bits, little-endian
    public static let p210le = AV_PIX_FMT_P210LE
    /// interleaved chroma YUV 4:4:4, 30bpp, data in the high bits, big-endian
    public static let p410be = AV_PIX_FMT_P410BE
    /// interleaved chroma YUV 4:4:4, 30bpp, data in the high bits, little-endian
    public static let p410le = AV_PIX_FMT_P410LE
    /// interleaved chroma YUV 4:2:2, 32bpp, big-endian
    public static let p216be = AV_PIX_FMT_P216BE
    /// interleaved chroma YUV 4:2:2, 32bpp, little-endian
    public static let p216le = AV_PIX_FMT_P216LE
    /// interleaved chroma YUV 4:4:4, 48bpp, big-endian
    public static let p416be = AV_PIX_FMT_P416BE
    /// interleaved chroma YUV 4:4:4, 48bpp, little-endian
    public static let p416le = AV_PIX_FMT_P416LE
    /**
     packed VUYA 4:4:4:4, 32bpp (1 Cr & Cb sample per 1x1 Y & A samples), VUYAVUYA...
     */
    public static let vuya = AV_PIX_FMT_VUYA
    /**
     IEEE-754 half precision packed RGBA 16:16:16:16, 64bpp, RGBARGBA..., big-endian
     */
    public static let rgbaf16be = AV_PIX_FMT_RGBAF16BE
    /**
     IEEE-754 half precision packed RGBA 16:16:16:16, 64bpp, RGBARGBA..., little-endian
     */
    public static let rgbaf16le = AV_PIX_FMT_RGBAF16LE
    /// packed VUYX 4:4:4:4, 32bpp, Variant of VUYA where alpha channel is left undefined
    public static let vuyx = AV_PIX_FMT_VUYX
    /**
     like NV12, with 12bpp per component, data in the high bits, zeros in the low bits, little-endian
     */
    public static let p012le = AV_PIX_FMT_P012LE
    /**
     like NV12, with 12bpp per component, data in the high bits, zeros in the low bits, big-endian
     */
    public static let p012be = AV_PIX_FMT_P012BE
    /**
     packed YUV 4:2:2 like YUYV422, 24bpp, data in the high bits, zeros in the low bits, big-endian
     */
    public static let y212be = AV_PIX_FMT_Y212BE
    /**
     packed YUV 4:2:2 like YUYV422, 24bpp, data in the high bits, zeros in the low bits, little-endian
     */
    public static let y212le = AV_PIX_FMT_Y212LE
    /**
     packed XVYU 4:4:4, 32bpp, (msb)2X 10V 10Y 10U(lsb), big-endian, variant of Y410 where alpha channel is left undefined
     */
    public static let xv30be = AV_PIX_FMT_XV30BE
    /**
     packed XVYU 4:4:4, 32bpp, (msb)2X 10V 10Y 10U(lsb), little-endian, variant of Y410 where alpha channel is left undefined
     */
    public static let xv30le = AV_PIX_FMT_XV30LE
    /**
     packed XVYU 4:4:4, 48bpp, data in the high bits, zeros in the low bits, big-endian, variant of Y412 where alpha channel is left undefined
     */
    public static let xv36be = AV_PIX_FMT_XV36BE
    /**
     packed XVYU 4:4:4, 48bpp, data in the high bits, zeros in the low bits, little-endian, variant of Y412 where alpha channel is left undefined
     */
    public static let xv36le = AV_PIX_FMT_XV36LE
    /**
     IEEE-754 single precision packed RGB 32:32:32, 96bpp, RGBRGB..., big-endian
     */
    public static let rgbf32be = AV_PIX_FMT_RGBF32BE
    /**
     IEEE-754 single precision packed RGB 32:32:32, 96bpp, RGBRGB..., little-endian
     */
    public static let rgbf32le = AV_PIX_FMT_RGBF32LE
    /**
     IEEE-754 single precision packed RGBA 32:32:32:32, 128bpp, RGBARGBA..., big-endian
     */
    public static let rgbaf32be = AV_PIX_FMT_RGBAF32BE
    /**
     IEEE-754 single precision packed RGBA 32:32:32:32, 128bpp, RGBARGBA..., little-endian
     */
    public static let rgbaf32le = AV_PIX_FMT_RGBAF32LE
    /// interleaved chroma YUV 4:2:2, 24bpp, data in the high bits, big-endian
    public static let p212be = AV_PIX_FMT_P212BE
    /// interleaved chroma YUV 4:2:2, 24bpp, data in the high bits, little-endian
    public static let p212le = AV_PIX_FMT_P212LE
    /// interleaved chroma YUV 4:4:4, 36bpp, data in the high bits, big-endian
    public static let p412be = AV_PIX_FMT_P412BE
    /// interleaved chroma YUV 4:4:4, 36bpp, data in the high bits, little-endian
    public static let p412le = AV_PIX_FMT_P412LE
    /// planar GBR 4:4:4:4 56bpp, big-endian
    public static let gbrap14be = AV_PIX_FMT_GBRAP14BE
    /// planar GBR 4:4:4:4 56bpp, little-endian
    public static let gbrap14le = AV_PIX_FMT_GBRAP14LE
    public static let d3d12 = AV_PIX_FMT_D3D12
    /**
     packed AYUV 4:4:4:4, 32bpp (1 Cr & Cb sample per 1x1 Y & A samples), AYUVAYUV...
     */
    public static let ayuv = AV_PIX_FMT_AYUV
    /**
     packed UYVA 4:4:4:4, 32bpp (1 Cr & Cb sample per 1x1 Y & A samples), UYVAUYVA...
     */
    public static let uyva = AV_PIX_FMT_UYVA
    /**
     packed VYU 4:4:4, 24bpp (1 Cr & Cb sample per 1x1 Y), VYUVYU...
     */
    public static let vyu444 = AV_PIX_FMT_VYU444
    /// packed VYUX 4:4:4 like XV30, 32bpp, (msb)10V 10Y 10U 2X(lsb), big-endian
    public static let v30xbe = AV_PIX_FMT_V30XBE
    /// packed VYUX 4:4:4 like XV30, 32bpp, (msb)10V 10Y 10U 2X(lsb), little-endian
    public static let v30xle = AV_PIX_FMT_V30XLE
    /**
     IEEE-754 half precision packed RGB 16:16:16, 48bpp, RGBRGB..., big-endian
     */
    public static let rgbf16be = AV_PIX_FMT_RGBF16BE
    /**
     IEEE-754 half precision packed RGB 16:16:16, 48bpp, RGBRGB..., little-endian
     */
    public static let rgbf16le = AV_PIX_FMT_RGBF16LE
    /**
     packed RGBA 32:32:32:32, 128bpp, RGBARGBA..., big-endian
     */
    public static let rgba128be = AV_PIX_FMT_RGBA128BE
    /**
     packed RGBA 32:32:32:32, 128bpp, RGBARGBA..., little-endian
     */
    public static let rgba128le = AV_PIX_FMT_RGBA128LE
    /**
     packed RGBA 32:32:32, 96bpp, RGBRGB..., big-endian
     */
    public static let rgb96be = AV_PIX_FMT_RGB96BE
    /**
     packed RGBA 32:32:32, 96bpp, RGBRGB..., little-endian
     */
    public static let rgb96le = AV_PIX_FMT_RGB96LE
    /// packed YUV 4:2:2 like YUYV422, 32bpp, big-endian
    public static let y216be = AV_PIX_FMT_Y216BE
    /// packed YUV 4:2:2 like YUYV422, 32bpp, little-endian
    public static let y216le = AV_PIX_FMT_Y216LE
    /**
     packed XVYU 4:4:4, 64bpp, big-endian, variant of Y416 where alpha channel is left undefined
     */
    public static let xv48be = AV_PIX_FMT_XV48BE
    /**
     packed XVYU 4:4:4, 64bpp, little-endian, variant of Y416 where alpha channel is left undefined
     */
    public static let xv48le = AV_PIX_FMT_XV48LE
    /// IEEE-754 half precision planer GBR 4:4:4, 48bpp, big-endian
    public static let gbrpf16be = AV_PIX_FMT_GBRPF16BE
    /// IEEE-754 half precision planer GBR 4:4:4, 48bpp, little-endian
    public static let gbrpf16le = AV_PIX_FMT_GBRPF16LE
    /// IEEE-754 half precision planar GBRA 4:4:4:4, 64bpp, big-endian
    public static let gbrapf16be = AV_PIX_FMT_GBRAPF16BE
    /// IEEE-754 half precision planar GBRA 4:4:4:4, 64bpp, little-endian
    public static let gbrapf16le = AV_PIX_FMT_GBRAPF16LE
    /// IEEE-754 half precision Y, 16bpp, big-endian
    public static let grayf16be = AV_PIX_FMT_GRAYF16BE
    /// IEEE-754 half precision Y, 16bpp, little-endian
    public static let grayf16le = AV_PIX_FMT_GRAYF16LE
    public static let amfSurface = AV_PIX_FMT_AMF_SURFACE
    /// Y        , 32bpp, big-endian
    public static let gray32be = AV_PIX_FMT_GRAY32BE
    /// Y        , 32bpp, little-endian
    public static let gray32le = AV_PIX_FMT_GRAY32LE
    /// IEEE-754 single precision packed YA, 32 bits gray, 32 bits alpha, 64bpp, big-endian
    public static let yaf32be = AV_PIX_FMT_YAF32BE
    /// IEEE-754 single precision packed YA, 32 bits gray, 32 bits alpha, 64bpp, little-endian
    public static let yaf32le = AV_PIX_FMT_YAF32LE
    /// IEEE-754 half precision packed YA, 16 bits gray, 16 bits alpha, 32bpp, big-endian
    public static let yaf16be = AV_PIX_FMT_YAF16BE
    /// IEEE-754 half precision packed YA, 16 bits gray, 16 bits alpha, 32bpp, little-endian
    public static let yaf16le = AV_PIX_FMT_YAF16LE
    /// planar GBRA 4:4:4:4 128bpp, big-endian
    public static let gbrap32be = AV_PIX_FMT_GBRAP32BE
    /// planar GBRA 4:4:4:4 128bpp, little-endian
    public static let gbrap32le = AV_PIX_FMT_GBRAP32LE
    /**
     planar YUV 4:4:4, 30bpp, (1 Cr & Cb sample per 1x1 Y samples), lowest bits zero, big-endian
     */
    public static let yuv444p10msbbe = AV_PIX_FMT_YUV444P10MSBBE
    /**
     planar YUV 4:4:4, 30bpp, (1 Cr & Cb sample per 1x1 Y samples), lowest bits zero, little-endian
     */
    public static let yuv444p10msble = AV_PIX_FMT_YUV444P10MSBLE
    /**
     planar YUV 4:4:4, 30bpp, (1 Cr & Cb sample per 1x1 Y samples), lowest bits zero, big-endian
     */
    public static let yuv444p12msbbe = AV_PIX_FMT_YUV444P12MSBBE
    /**
     planar YUV 4:4:4, 30bpp, (1 Cr & Cb sample per 1x1 Y samples), lowest bits zero, little-endian
     */
    public static let yuv444p12msble = AV_PIX_FMT_YUV444P12MSBLE
    /// planar GBR 4:4:4 30bpp, lowest bits zero, big-endian
    public static let gbrp10msbbe = AV_PIX_FMT_GBRP10MSBBE
    /// planar GBR 4:4:4 30bpp, lowest bits zero, little-endian
    public static let gbrp10msble = AV_PIX_FMT_GBRP10MSBLE
    /// planar GBR 4:4:4 36bpp, lowest bits zero, big-endian
    public static let gbrp12msbbe = AV_PIX_FMT_GBRP12MSBBE
    /// planar GBR 4:4:4 36bpp, lowest bits zero, little-endian
    public static let gbrp12msble = AV_PIX_FMT_GBRP12MSBLE
    
    public static let nb = AV_PIX_FMT_NB
}

// MARK: - AVColorPrimaries

/// Chromaticity coordinates of the source primaries.
/// These values match the ones defined by ISO/IEC 23001-8_2013 § 7.1.
public enum AVColorPrimaries: UInt32 {
    /// Reserved.
    case RESERVED0
    /// also ITU-R BT1361 / IEC 61966-2-4 / SMPTE RP177 Annex B
    case BT709
    /// Unspecified.
    case unspecified
    /// Reserved.
    case reserved
    /// also FCC Title 47 Code of Federal Regulations 73.682 (a)(20)
    case BT470M
    /// also ITU-R BT601-6 625 / ITU-R BT1358 625 / ITU-R BT1700 625 PAL & SECAM
    case BT470BG
    /// also ITU-R BT601-6 525 / ITU-R BT1358 525 / ITU-R BT1700 NTSC
    case SMPTE170M
    /// functionally identical to above
    case SMPTE240M
    /// colour filters using Illuminant C
    case FILM
    /// ITU-R BT2020
    case BT2020
    /// SMPTE ST 428-1 (CIE 1931 XYZ)
    case SMPTEST428_1 // SMPTE428
    /// SMPTE ST 431-2 (2011) / DCI P3
    case SMPTE431
    /// SMPTE ST 432-1 (2010) / P3 D65 / Display P3
    case SMPTE432
    /// EBU Tech. 3213-E / JEDEC P22 phosphors
    case JEDEC_P22 // EBU3213
    /// Panasonic V-Gamut color primaries.
    case V_GAMUT = 256

    var native: CFFmpeg.AVColorPrimaries {
        CFFmpeg.AVColorPrimaries(rawValue)
    }

    init(native: CFFmpeg.AVColorPrimaries) {
        guard let primaries = AVColorPrimaries(rawValue: native.rawValue) else {
            fatalError("Unknown color primaries: \(native)")
        }
        self = primaries
    }

    /// Return the color primaries corresponding to name, or `nil` if the color primaries does not exist.
    ///
    /// - Parameter name: The name of the color primaries.
    public init?(name: String) {
        let primaries = av_color_primaries_from_name(name)
        guard primaries >= 0 else {
            return nil
        }
        self = AVColorPrimaries(rawValue: UInt32(primaries))!
    }

    /// The name of the color primaries.
    public var name: String {
        String(cString: av_color_primaries_name(native))
    }
}

/// Correlation between the alpha channel and color values.
public enum AVAlphaMode: UInt32 {
    /// Unknown alpha handling, or no alpha channel.
    case unspecified
    /// Alpha channel is multiplied into color values.
    case premultiplied
    /// Alpha channel is independent of color values.
    case straight

    init(native: CFFmpeg.AVAlphaMode) {
        guard let alphaMode = Self(rawValue: native.rawValue) else {
            fatalError("Unknown alpha mode: \(native)")
        }
        self = alphaMode
    }

    var native: CFFmpeg.AVAlphaMode {
        .init(rawValue: rawValue)
    }

    /// Return the alpha mode corresponding to name, or `nil` if the alpha mode does not exist.
    public init?(name: String) {
        self.init(rawValue: av_alpha_mode_from_name(name).rawValue)
    }

    /// The name of the alpha mode.
    public var name: String {
        String(cString: av_alpha_mode_name(native))
    }
}

// MARK: - AVColorTransferCharacteristic

/// Color Transfer Characteristic.
/// These values match the ones defined by ISO/IEC 23001-8_2013 § 7.2.
public enum AVColorTransferCharacteristic: UInt32 {
    case RESERVED0
    /// also ITU-R BT1361
    case BT709
    case UNSPECIFIED
    case RESERVED
    /// also ITU-R BT470M / ITU-R BT1700 625 PAL & SECAM
    case GAMMA22
    /// also ITU-R BT470BG
    case GAMMA28
    /// also ITU-R BT601-6 525 or 625 / ITU-R BT1358 525 or 625 / ITU-R BT1700 NTSC
    case SMPTE170M
    case SMPTE240M
    /// "Linear transfer characteristics"
    case LINEAR
    /// "Logarithmic transfer characteristic (100:1 range)"
    case LOG
    /// "Logarithmic transfer characteristic (100 * Sqrt(10) : 1 range)"
    case LOG_SQRT
    /// IEC 61966-2-4
    case IEC61966_2_4
    /// ITU-R BT1361 Extended Colour Gamut
    case BT1361_ECG
    /// IEC 61966-2-1 (sRGB or sYCC)
    case IEC61966_2_1
    /// ITU-R BT2020 for 10-bit system
    case BT2020_10
    /// ITU-R BT2020 for 12-bit system
    case BT2020_12
    /// SMPTE ST 2084 for 10-, 12-, 14- and 16-bit systems
    case SMPTEST2084 // SMPTE2084
    /// SMPTE ST 428-1
    case SMPTEST428_1 // SMPTE428
    /// ARIB STD-B67, known as "Hybrid log-gamma"
    case ARIB_STD_B67
    /// Panasonic V-Log transfer characteristics.
    case V_LOG = 256

    var native: CFFmpeg.AVColorTransferCharacteristic {
        CFFmpeg.AVColorTransferCharacteristic(rawValue)
    }

    init(native: CFFmpeg.AVColorTransferCharacteristic) {
        guard let transfer = AVColorTransferCharacteristic(rawValue: native.rawValue) else {
            fatalError("Unknown color transfer characteristic: \(native)")
        }
        self = transfer
    }

    /// Return the color transfer characteristic corresponding to name, or `nil` if the color transfer characteristic does not exist.
    ///
    /// - Parameter name: The name of the color transfer characteristic.
    public init?(name: String) {
        let transfer = av_color_transfer_from_name(name)
        guard transfer >= 0 else {
            return nil
        }
        self = AVColorTransferCharacteristic(rawValue: UInt32(transfer))!
    }

    /// The name of the color transfer characteristic.
    public var name: String {
        String(cString: av_color_transfer_name(native))
    }
}

// MARK: - AVColorSpace

/// YUV colorspace type.
/// These values match the ones defined by ISO/IEC 23001-8_2013 § 7.3.
public enum AVColorSpace: UInt32 {
    /// order of coefficients is actually GBR, also IEC 61966-2-1 (sRGB)
    case RGB
    /// also ITU-R BT1361 / IEC 61966-2-4 xvYCC709 / SMPTE RP177 Annex B
    case BT709
    case UNSPECIFIED
    case RESERVED
    /// FCC Title 47 Code of Federal Regulations 73.682 (a)(20)
    case FCC
    /// also ITU-R BT601-6 625 / ITU-R BT1358 625 / ITU-R BT1700 625 PAL & SECAM / IEC 61966-2-4 xvYCC601
    case BT470BG
    /// also ITU-R BT601-6 525 / ITU-R BT1358 525 / ITU-R BT1700 NTSC
    case SMPTE170M
    /// functionally identical to above
    case SMPTE240M
    /// Used by Dirac / VC-2 and H.264 FRext, see ITU-T SG16
    case YCOCG // YCGCO
    /// ITU-R BT2020 non-constant luminance system
    case BT2020_NCL
    /// ITU-R BT2020 constant luminance system
    case BT2020_CL
    /// SMPTE 2085, Y'D'zD'x
    case SMPTE2085
    /// Chromaticity-derived non-constant luminance system
    case CHROMA_DERIVED_NCL
    /// Chromaticity-derived constant luminance system
    case CHROMA_DERIVED_CL
    /// ITU-R BT.2100-0, ICtCp
    case ICTCP
    /// SMPTE ST 2128, IPT-C2.
    case IPT_C2
    /// YCgCo-R, even addition of bits.
    case YCGCO_RE
    /// YCgCo-R, odd addition of bits.
    case YCGCO_RO

    var native: CFFmpeg.AVColorSpace {
        CFFmpeg.AVColorSpace(rawValue)
    }

    init(native: CFFmpeg.AVColorSpace) {
        guard let space = AVColorSpace(rawValue: native.rawValue) else {
            fatalError("Unknown color space: \(native)")
        }
        self = space
    }

    /// Return the color space corresponding to name, or `nil` if the color space does not exist.
    ///
    /// - Parameter name: The name of the color space.
    public init?(name: String) {
        let space = av_color_space_from_name(name)
        guard space >= 0 else {
            return nil
        }
        self = AVColorSpace(rawValue: UInt32(space))!
    }

    /// The name of the color space.
    public var name: String {
        String(cString: av_color_space_name(native))
    }
}

/// MPEG vs JPEG YUV range.
public enum AVColorRange: UInt32 {
    case unspecified
    /// The normal 219*2^(n-8) "MPEG" YUV ranges - also known as "Legal" or "Video" range
    case mpeg
    /// The normal     2^n-1   "JPEG" YUV ranges - also known as "Full" range
    case jpeg

    var native: CFFmpeg.AVColorRange {
        CFFmpeg.AVColorRange(rawValue)
    }

    init(native: CFFmpeg.AVColorRange) {
        guard let range = AVColorRange(rawValue: native.rawValue) else {
            fatalError("Unknown color range: \(native)")
        }
        self = range
    }

    /// Return the color range corresponding to name, or `nil` if the color range does not exist.
    ///
    /// - Parameter name: The name of the color range.
    public init?(name: String) {
        let range = av_color_range_from_name(name)
        guard range >= 0 else {
            return nil
        }
        self = AVColorRange(rawValue: UInt32(range))!
    }

    /// The name of the color range.
    public var name: String {
        String(cString: av_color_range_name(native))
    }
}

// MARK: - AVChromaLocation

/// Location of chroma samples.
///
/// Illustration showing the location of the first (top left) chroma sample of the
/// image, the left shows only luma, the right
/// shows the location of the chroma sample, the 2 could be imagined to overlay
/// each other but are drawn separately due to limitations of ASCII
///
///                1st 2nd       1st 2nd horizontal luma sample positions
///                 v   v         v   v
///                 ______        ______
/// *1st luma line > |X   X ...    |3 4 X ...     X are luma samples,
///                |             |1 2           1-6 are possible chroma positions
/// *2nd luma line > |X   X ...    |5 6 X ...     0 is undefined/unknown position
public enum AVChromaLocation: UInt32 {
    case unspecified
    /// MPEG-2/4 4:2:0, H.264 default for 4:2:0
    case left
    /// MPEG-1 4:2:0, JPEG 4:2:0, H.263 4:2:0
    case center
    /// ITU-R 601, SMPTE 274M 296M S314M(DV 4:1:1), mpeg2 4:2:2
    case topLeft
    case top
    case bottomLeft
    case bottom

    var native: CFFmpeg.AVChromaLocation {
        CFFmpeg.AVChromaLocation(rawValue)
    }

    init(native: CFFmpeg.AVChromaLocation) {
        guard let location = AVChromaLocation(rawValue: native.rawValue) else {
            fatalError("Unknown chroma location: \(native)")
        }
        self = location
    }

    /// Return the chroma location corresponding to name, or `nil` if the chroma location does not exist.
    ///
    /// - Parameter name: The name of the chroma location.
    public init?(name: String) {
        let range = av_chroma_location_from_name(name)
        guard range >= 0 else {
            return nil
        }
        self = AVChromaLocation(rawValue: UInt32(range))!
    }

    /// The name of the chroma location.
    public var name: String {
        String(cString: av_chroma_location_name(native))
    }
}
