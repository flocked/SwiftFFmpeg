//
//  AVPixelFormatAA.swift
//  SwiftFFmpeg
//
//  Created by Florian Zand on 07.08.26.
//

import CFFmpeg
import Foundation

public struct AVPixelFormatAA: RawRepresentable {
    /// planar YUV 4:2:0, 12bpp, (1 Cr & Cb sample per 2x2 Y samples)
    public static let yuv420p = Self(AV_PIX_FMT_YUV420P)
    /// packed YUV 4:2:2, 16bpp, Y0 Cb Y1 Cr
    public static let yuyv422 = Self(AV_PIX_FMT_YUYV422)
    /// packed RGB 8:8:8, 24bpp, RGBRGB...
    public static let rgb24 = Self(AV_PIX_FMT_RGB24)
    /// packed RGB 8:8:8, 24bpp, BGRBGR...
    public static let bgr24 = Self(AV_PIX_FMT_BGR24)
    /// planar YUV 4:2:2, 16bpp, (1 Cr & Cb sample per 2x1 Y samples)
    public static let yuv422p = Self(AV_PIX_FMT_YUV422P)
    /// planar YUV 4:4:4, 24bpp, (1 Cr & Cb sample per 1x1 Y samples)
    public static let yuv444p = Self(AV_PIX_FMT_YUV444P)
    /// planar YUV 4:1:0,  9bpp, (1 Cr & Cb sample per 4x4 Y samples)
    public static let yuv410p = Self(AV_PIX_FMT_YUV410P)
    /// planar YUV 4:1:1, 12bpp, (1 Cr & Cb sample per 4x1 Y samples)
    public static let yuv411p = Self(AV_PIX_FMT_YUV411P)
    /// Y,  8bpp
    public static let gray8 = Self(AV_PIX_FMT_GRAY8)
    /// Y,  1bpp, 0 is white, 1 is black, in each byte pixels are ordered from the msb to the lsb
    public static let monowhite = Self(AV_PIX_FMT_MONOWHITE)
    /// Y,  1bpp, 0 is black, 1 is white, in each byte pixels are ordered from the msb to the lsb
    public static let monoblack = Self(AV_PIX_FMT_MONOBLACK)
    /// 8 bits with AV_PIX_FMT_RGB32 palette
    public static let pal8 = Self(AV_PIX_FMT_PAL8)
    /// planar YUV 4:2:0, 12bpp, full scale (JPEG), deprecated in favor of AV_PIX_FMT_YUV420P and setting color_range
    public static let yuvj420p = Self(AV_PIX_FMT_YUVJ420P)
    /// planar YUV 4:2:2, 16bpp, full scale (JPEG), deprecated in favor of AV_PIX_FMT_YUV422P and setting color_range
    public static let yuvj422p = Self(AV_PIX_FMT_YUVJ422P)
    /// planar YUV 4:4:4, 24bpp, full scale (JPEG), deprecated in favor of AV_PIX_FMT_YUV444P and setting color_range
    public static let yuvj444p = Self(AV_PIX_FMT_YUVJ444P)
    /// packed YUV 4:2:2, 16bpp, Cb Y0 Cr Y1
    public static let uyvy422 = Self(AV_PIX_FMT_UYVY422)
    /// packed YUV 4:1:1, 12bpp, Cb Y0 Y1 Cr Y2 Y3
    public static let uyyvyy411 = Self(AV_PIX_FMT_UYYVYY411)
    /// packed RGB 3:3:2,  8bpp, (msb)2B 3G 3R(lsb)
    public static let bgr8 = Self(AV_PIX_FMT_BGR8)
    /// packed RGB 1:2:1 bitstream,  4bpp, (msb)1B 2G 1R(lsb), a byte contains two pixels, the first pixel in the byte is the one composed by the 4 msb bits
    public static let bgr4 = Self(AV_PIX_FMT_BGR4)
    /// packed RGB 1:2:1,  8bpp, (msb)1B 2G 1R(lsb)
    public static let bgr4Byte = Self(AV_PIX_FMT_BGR4_BYTE)
    /// packed RGB 3:3:2,  8bpp, (msb)3R 3G 2B(lsb)
    public static let rgb8 = Self(AV_PIX_FMT_RGB8)
    /// packed RGB 1:2:1 bitstream,  4bpp, (msb)1R 2G 1B(lsb), a byte contains two pixels, the first pixel in the byte is the one composed by the 4 msb bits
    public static let rgb4 = Self(AV_PIX_FMT_RGB4)
    /// packed RGB 1:2:1,  8bpp, (msb)1R 2G 1B(lsb)
    public static let rgb4Byte = Self(AV_PIX_FMT_RGB4_BYTE)
    /// planar YUV 4:2:0, 12bpp, 1 plane for Y and 1 plane for the UV components, which are interleaved (first byte U and the following byte V)
    public static let nv12 = Self(AV_PIX_FMT_NV12)
    /// as above, but U and V bytes are swapped
    public static let nv21 = Self(AV_PIX_FMT_NV21)
    /// packed ARGB 8:8:8:8, 32bpp, ARGBARGB...
    public static let argb = Self(AV_PIX_FMT_ARGB)
    /// packed RGBA 8:8:8:8, 32bpp, RGBARGBA...
    public static let rgba = Self(AV_PIX_FMT_RGBA)
    /// packed ABGR 8:8:8:8, 32bpp, ABGRABGR...
    public static let abgr = Self(AV_PIX_FMT_ABGR)
    /// packed BGRA 8:8:8:8, 32bpp, BGRABGRA...
    public static let bgra = Self(AV_PIX_FMT_BGRA)
    /// Y, 16bpp, big-endian
    public static let gray16be = Self(AV_PIX_FMT_GRAY16BE)
    /// Y, 16bpp, little-endian
    public static let gray16le = Self(AV_PIX_FMT_GRAY16LE)
    /// planar YUV 4:4:0 (1 Cr & Cb sample per 1x2 Y samples)
    public static let yuv440p = Self(AV_PIX_FMT_YUV440P)
    /// planar YUV 4:4:0 full scale (JPEG), deprecated in favor of AV_PIX_FMT_YUV440P and setting color_range
    public static let yuvj440p = Self(AV_PIX_FMT_YUVJ440P)
    /// planar YUV 4:2:0, 20bpp, (1 Cr & Cb sample per 2x2 Y & A samples)
    public static let yuva420p = Self(AV_PIX_FMT_YUVA420P)
    /// packed RGB 16:16:16, 48bpp, 16R, 16G, 16B, the 2-byte value for each R/G/B component is stored as big-endian
    public static let rgb48be = Self(AV_PIX_FMT_RGB48BE)
    /// packed RGB 16:16:16, 48bpp, 16R, 16G, 16B, the 2-byte value for each R/G/B component is stored as little-endian
    public static let rgb48le = Self(AV_PIX_FMT_RGB48LE)
    /// packed RGB 5:6:5, 16bpp, (msb)   5R 6G 5B(lsb), big-endian
    public static let rgb565be = Self(AV_PIX_FMT_RGB565BE)
    /// packed RGB 5:6:5, 16bpp, (msb)   5R 6G 5B(lsb), little-endian
    public static let rgb565le = Self(AV_PIX_FMT_RGB565LE)
    /// packed RGB 5:5:5, 16bpp, (msb)1X 5R 5G 5B(lsb), big-endian   , X=unused/undefined
    public static let rgb555be = Self(AV_PIX_FMT_RGB555BE)
    /// packed RGB 5:5:5, 16bpp, (msb)1X 5R 5G 5B(lsb), little-endian, X=unused/undefined
    public static let rgb555le = Self(AV_PIX_FMT_RGB555LE)
    /// packed BGR 5:6:5, 16bpp, (msb)   5B 6G 5R(lsb), big-endian
    public static let bgr565be = Self(AV_PIX_FMT_BGR565BE)
    /// packed BGR 5:6:5, 16bpp, (msb)   5B 6G 5R(lsb), little-endian
    public static let bgr565le = Self(AV_PIX_FMT_BGR565LE)
    /// packed BGR 5:5:5, 16bpp, (msb)1X 5B 5G 5R(lsb), big-endian   , X=unused/undefined
    public static let bgr555be = Self(AV_PIX_FMT_BGR555BE)
    /// packed BGR 5:5:5, 16bpp, (msb)1X 5B 5G 5R(lsb), little-endian, X=unused/undefined
    public static let bgr555le = Self(AV_PIX_FMT_BGR555LE)
    /// Hardware acceleration through VA-API, data[3] contains a VASurfaceID.
    public static let vaapi = Self(AV_PIX_FMT_VAAPI)
    /// planar YUV 4:2:0, 24bpp, (1 Cr & Cb sample per 2x2 Y samples), little-endian
    public static let yuv420p16le = Self(AV_PIX_FMT_YUV420P16LE)
    /// planar YUV 4:2:0, 24bpp, (1 Cr & Cb sample per 2x2 Y samples), big-endian
    public static let yuv420p16be = Self(AV_PIX_FMT_YUV420P16BE)
    /// planar YUV 4:2:2, 32bpp, (1 Cr & Cb sample per 2x1 Y samples), little-endian
    public static let yuv422p16le = Self(AV_PIX_FMT_YUV422P16LE)
    /// planar YUV 4:2:2, 32bpp, (1 Cr & Cb sample per 2x1 Y samples), big-endian
    public static let yuv422p16be = Self(AV_PIX_FMT_YUV422P16BE)
    /// planar YUV 4:4:4, 48bpp, (1 Cr & Cb sample per 1x1 Y samples), little-endian
    public static let yuv444p16le = Self(AV_PIX_FMT_YUV444P16LE)
    /// planar YUV 4:4:4, 48bpp, (1 Cr & Cb sample per 1x1 Y samples), big-endian
    public static let yuv444p16be = Self(AV_PIX_FMT_YUV444P16BE)
    /// HW decoding through DXVA2, Picture.data[3] contains a LPDIRECT3DSURFACE9 pointer
    public static let dxva2Vld = Self(AV_PIX_FMT_DXVA2_VLD)
    /// packed RGB 4:4:4, 16bpp, (msb)4X 4R 4G 4B(lsb), little-endian, X=unused/undefined
    public static let rgb444le = Self(AV_PIX_FMT_RGB444LE)
    /// packed RGB 4:4:4, 16bpp, (msb)4X 4R 4G 4B(lsb), big-endian,    X=unused/undefined
    public static let rgb444be = Self(AV_PIX_FMT_RGB444BE)
    /// packed BGR 4:4:4, 16bpp, (msb)4X 4B 4G 4R(lsb), little-endian, X=unused/undefined
    public static let bgr444le = Self(AV_PIX_FMT_BGR444LE)
    /// packed BGR 4:4:4, 16bpp, (msb)4X 4B 4G 4R(lsb), big-endian,    X=unused/undefined
    public static let bgr444be = Self(AV_PIX_FMT_BGR444BE)
    /// 8 bits gray, 8 bits alpha
    public static let ya8 = Self(AV_PIX_FMT_YA8)
    /// Alias for ``ya8``.
    public static let y400a = ya8
    /// Alias for ``ya8``.
    public static let gray8a = ya8
    /// packed RGB 16:16:16, 48bpp, 16B, 16G, 16R, the 2-byte value for each R/G/B component is stored as big-endian
    public static let bgr48be = Self(AV_PIX_FMT_BGR48BE)
    /// packed RGB 16:16:16, 48bpp, 16B, 16G, 16R, the 2-byte value for each R/G/B component is stored as little-endian
    public static let bgr48le = Self(AV_PIX_FMT_BGR48LE)
    /// planar YUV 4:2:0, 13.5bpp, (1 Cr & Cb sample per 2x2 Y samples), big-endian
    public static let yuv420p9be = Self(AV_PIX_FMT_YUV420P9BE)
    /// planar YUV 4:2:0, 13.5bpp, (1 Cr & Cb sample per 2x2 Y samples), little-endian
    public static let yuv420p9le = Self(AV_PIX_FMT_YUV420P9LE)
    /// planar YUV 4:2:0, 15bpp, (1 Cr & Cb sample per 2x2 Y samples), big-endian
    public static let yuv420p10be = Self(AV_PIX_FMT_YUV420P10BE)
    /// planar YUV 4:2:0, 15bpp, (1 Cr & Cb sample per 2x2 Y samples), little-endian
    public static let yuv420p10le = Self(AV_PIX_FMT_YUV420P10LE)
    /// planar YUV 4:2:2, 20bpp, (1 Cr & Cb sample per 2x1 Y samples), big-endian
    public static let yuv422p10be = Self(AV_PIX_FMT_YUV422P10BE)
    /// planar YUV 4:2:2, 20bpp, (1 Cr & Cb sample per 2x1 Y samples), little-endian
    public static let yuv422p10le = Self(AV_PIX_FMT_YUV422P10LE)
    /// planar YUV 4:4:4, 27bpp, (1 Cr & Cb sample per 1x1 Y samples), big-endian
    public static let yuv444p9be = Self(AV_PIX_FMT_YUV444P9BE)
    /// planar YUV 4:4:4, 27bpp, (1 Cr & Cb sample per 1x1 Y samples), little-endian
    public static let yuv444p9le = Self(AV_PIX_FMT_YUV444P9LE)
    /// planar YUV 4:4:4, 30bpp, (1 Cr & Cb sample per 1x1 Y samples), big-endian
    public static let yuv444p10be = Self(AV_PIX_FMT_YUV444P10BE)
    /// planar YUV 4:4:4, 30bpp, (1 Cr & Cb sample per 1x1 Y samples), little-endian
    public static let yuv444p10le = Self(AV_PIX_FMT_YUV444P10LE)
    /// planar YUV 4:2:2, 18bpp, (1 Cr & Cb sample per 2x1 Y samples), big-endian
    public static let yuv422p9be = Self(AV_PIX_FMT_YUV422P9BE)
    /// planar YUV 4:2:2, 18bpp, (1 Cr & Cb sample per 2x1 Y samples), little-endian
    public static let yuv422p9le = Self(AV_PIX_FMT_YUV422P9LE)
    /// planar GBR 4:4:4 24bpp
    public static let gbrp = Self(AV_PIX_FMT_GBRP)
    /// planar GBR 4:4:4 27bpp, big-endian
    public static let gbrp9be = Self(AV_PIX_FMT_GBRP9BE)
    /// planar GBR 4:4:4 27bpp, little-endian
    public static let gbrp9le = Self(AV_PIX_FMT_GBRP9LE)
    /// planar GBR 4:4:4 30bpp, big-endian
    public static let gbrp10be = Self(AV_PIX_FMT_GBRP10BE)
    /// planar GBR 4:4:4 30bpp, little-endian
    public static let gbrp10le = Self(AV_PIX_FMT_GBRP10LE)
    /// planar GBR 4:4:4 48bpp, big-endian
    public static let gbrp16be = Self(AV_PIX_FMT_GBRP16BE)
    /// planar GBR 4:4:4 48bpp, little-endian
    public static let gbrp16le = Self(AV_PIX_FMT_GBRP16LE)
    /// planar YUV 4:2:2 24bpp, (1 Cr & Cb sample per 2x1 Y & A samples)
    public static let yuva422p = Self(AV_PIX_FMT_YUVA422P)
    /// planar YUV 4:4:4 32bpp, (1 Cr & Cb sample per 1x1 Y & A samples)
    public static let yuva444p = Self(AV_PIX_FMT_YUVA444P)
    /// planar YUV 4:2:0 22.5bpp, (1 Cr & Cb sample per 2x2 Y & A samples), big-endian
    public static let yuva420p9be = Self(AV_PIX_FMT_YUVA420P9BE)
    /// planar YUV 4:2:0 22.5bpp, (1 Cr & Cb sample per 2x2 Y & A samples), little-endian
    public static let yuva420p9le = Self(AV_PIX_FMT_YUVA420P9LE)
    /// planar YUV 4:2:2 27bpp, (1 Cr & Cb sample per 2x1 Y & A samples), big-endian
    public static let yuva422p9be = Self(AV_PIX_FMT_YUVA422P9BE)
    /// planar YUV 4:2:2 27bpp, (1 Cr & Cb sample per 2x1 Y & A samples), little-endian
    public static let yuva422p9le = Self(AV_PIX_FMT_YUVA422P9LE)
    /// planar YUV 4:4:4 36bpp, (1 Cr & Cb sample per 1x1 Y & A samples), big-endian
    public static let yuva444p9be = Self(AV_PIX_FMT_YUVA444P9BE)
    /// planar YUV 4:4:4 36bpp, (1 Cr & Cb sample per 1x1 Y & A samples), little-endian
    public static let yuva444p9le = Self(AV_PIX_FMT_YUVA444P9LE)
    /// planar YUV 4:2:0 25bpp, (1 Cr & Cb sample per 2x2 Y & A samples, big-endian)
    public static let yuva420p10be = Self(AV_PIX_FMT_YUVA420P10BE)
    /// planar YUV 4:2:0 25bpp, (1 Cr & Cb sample per 2x2 Y & A samples, little-endian)
    public static let yuva420p10le = Self(AV_PIX_FMT_YUVA420P10LE)
    /// planar YUV 4:2:2 30bpp, (1 Cr & Cb sample per 2x1 Y & A samples, big-endian)
    public static let yuva422p10be = Self(AV_PIX_FMT_YUVA422P10BE)
    /// planar YUV 4:2:2 30bpp, (1 Cr & Cb sample per 2x1 Y & A samples, little-endian)
    public static let yuva422p10le = Self(AV_PIX_FMT_YUVA422P10LE)
    /// planar YUV 4:4:4 40bpp, (1 Cr & Cb sample per 1x1 Y & A samples, big-endian)
    public static let yuva444p10be = Self(AV_PIX_FMT_YUVA444P10BE)
    /// planar YUV 4:4:4 40bpp, (1 Cr & Cb sample per 1x1 Y & A samples, little-endian)
    public static let yuva444p10le = Self(AV_PIX_FMT_YUVA444P10LE)
    /// planar YUV 4:2:0 40bpp, (1 Cr & Cb sample per 2x2 Y & A samples, big-endian)
    public static let yuva420p16be = Self(AV_PIX_FMT_YUVA420P16BE)
    /// planar YUV 4:2:0 40bpp, (1 Cr & Cb sample per 2x2 Y & A samples, little-endian)
    public static let yuva420p16le = Self(AV_PIX_FMT_YUVA420P16LE)
    /// planar YUV 4:2:2 48bpp, (1 Cr & Cb sample per 2x1 Y & A samples, big-endian)
    public static let yuva422p16be = Self(AV_PIX_FMT_YUVA422P16BE)
    /// planar YUV 4:2:2 48bpp, (1 Cr & Cb sample per 2x1 Y & A samples, little-endian)
    public static let yuva422p16le = Self(AV_PIX_FMT_YUVA422P16LE)
    /// planar YUV 4:4:4 64bpp, (1 Cr & Cb sample per 1x1 Y & A samples, big-endian)
    public static let yuva444p16be = Self(AV_PIX_FMT_YUVA444P16BE)
    /// planar YUV 4:4:4 64bpp, (1 Cr & Cb sample per 1x1 Y & A samples, little-endian)
    public static let yuva444p16le = Self(AV_PIX_FMT_YUVA444P16LE)
    /// HW acceleration through VDPAU, Picture.data[3] contains a VdpVideoSurface
    public static let vdpau = Self(AV_PIX_FMT_VDPAU)
    /// packed XYZ 4:4:4, 36 bpp, (msb) 12X, 12Y, 12Z (lsb), the 2-byte value for each X/Y/Z is stored as little-endian, the 4 lower bits are set to 0
    public static let xyz12le = Self(AV_PIX_FMT_XYZ12LE)
    /// packed XYZ 4:4:4, 36 bpp, (msb) 12X, 12Y, 12Z (lsb), the 2-byte value for each X/Y/Z is stored as big-endian, the 4 lower bits are set to 0
    public static let xyz12be = Self(AV_PIX_FMT_XYZ12BE)
    /// interleaved chroma YUV 4:2:2, 16bpp, (1 Cr & Cb sample per 2x1 Y samples)
    public static let nv16 = Self(AV_PIX_FMT_NV16)
    /// interleaved chroma YUV 4:2:2, 20bpp, (1 Cr & Cb sample per 2x1 Y samples), little-endian
    public static let nv20le = Self(AV_PIX_FMT_NV20LE)
    /// interleaved chroma YUV 4:2:2, 20bpp, (1 Cr & Cb sample per 2x1 Y samples), big-endian
    public static let nv20be = Self(AV_PIX_FMT_NV20BE)
    /// packed RGBA 16:16:16:16, 64bpp, 16R, 16G, 16B, 16A, the 2-byte value for each R/G/B/A component is stored as big-endian
    public static let rgba64be = Self(AV_PIX_FMT_RGBA64BE)
    /// packed RGBA 16:16:16:16, 64bpp, 16R, 16G, 16B, 16A, the 2-byte value for each R/G/B/A component is stored as little-endian
    public static let rgba64le = Self(AV_PIX_FMT_RGBA64LE)
    /// packed RGBA 16:16:16:16, 64bpp, 16B, 16G, 16R, 16A, the 2-byte value for each R/G/B/A component is stored as big-endian
    public static let bgra64be = Self(AV_PIX_FMT_BGRA64BE)
    /// packed RGBA 16:16:16:16, 64bpp, 16B, 16G, 16R, 16A, the 2-byte value for each R/G/B/A component is stored as little-endian
    public static let bgra64le = Self(AV_PIX_FMT_BGRA64LE)
    /// packed YUV 4:2:2, 16bpp, Y0 Cr Y1 Cb
    public static let yvyu422 = Self(AV_PIX_FMT_YVYU422)
    /// 16 bits gray, 16 bits alpha (big-endian)
    public static let ya16be = Self(AV_PIX_FMT_YA16BE)
    /// 16 bits gray, 16 bits alpha (little-endian)
    public static let ya16le = Self(AV_PIX_FMT_YA16LE)
    /// planar GBRA 4:4:4:4 32bpp
    public static let gbrap = Self(AV_PIX_FMT_GBRAP)
    /// planar GBRA 4:4:4:4 64bpp, big-endian
    public static let gbrap16be = Self(AV_PIX_FMT_GBRAP16BE)
    /// planar GBRA 4:4:4:4 64bpp, little-endian
    public static let gbrap16le = Self(AV_PIX_FMT_GBRAP16LE)
    /// HW acceleration through QSV, data[3] contains a pointer to the mfxFrameSurface1 structure.
    public static let qsv = Self(AV_PIX_FMT_QSV)
    /// HW acceleration though MMAL, data[3] contains a pointer to the MMAL_BUFFER_HEADER_T structure.
    public static let mmal = Self(AV_PIX_FMT_MMAL)
    /// HW decoding through Direct3D11 via old API, Picture.data[3] contains a ID3D11VideoDecoderOutputView pointer
    public static let d3d11vaVld = Self(AV_PIX_FMT_D3D11VA_VLD)
    /// HW acceleration through CUDA. data[i] contain CUdeviceptr pointers exactly as for system memory frames.
    public static let cuda = Self(AV_PIX_FMT_CUDA)
    /// packed RGB 8:8:8, 32bpp, XRGBXRGB.. X=unused/undefined
    public static let format0rgb = Self(AV_PIX_FMT_0RGB)
    /// packed RGB 8:8:8, 32bpp, RGBXRGBX.. X=unused/undefined
    public static let rgb0 = Self(AV_PIX_FMT_RGB0)
    /// packed BGR 8:8:8, 32bpp, XBGRXBGR.. X=unused/undefined
    public static let format0bgr = Self(AV_PIX_FMT_0BGR)
    /// packed BGR 8:8:8, 32bpp, BGRXBGRX.. X=unused/undefined
    public static let bgr0 = Self(AV_PIX_FMT_BGR0)
    /// planar YUV 4:2:0,18bpp, (1 Cr & Cb sample per 2x2 Y samples), big-endian
    public static let yuv420p12be = Self(AV_PIX_FMT_YUV420P12BE)
    /// planar YUV 4:2:0,18bpp, (1 Cr & Cb sample per 2x2 Y samples), little-endian
    public static let yuv420p12le = Self(AV_PIX_FMT_YUV420P12LE)
    /// planar YUV 4:2:0,21bpp, (1 Cr & Cb sample per 2x2 Y samples), big-endian
    public static let yuv420p14be = Self(AV_PIX_FMT_YUV420P14BE)
    /// planar YUV 4:2:0,21bpp, (1 Cr & Cb sample per 2x2 Y samples), little-endian
    public static let yuv420p14le = Self(AV_PIX_FMT_YUV420P14LE)
    /// planar YUV 4:2:2,24bpp, (1 Cr & Cb sample per 2x1 Y samples), big-endian
    public static let yuv422p12be = Self(AV_PIX_FMT_YUV422P12BE)
    /// planar YUV 4:2:2,24bpp, (1 Cr & Cb sample per 2x1 Y samples), little-endian
    public static let yuv422p12le = Self(AV_PIX_FMT_YUV422P12LE)
    /// planar YUV 4:2:2,28bpp, (1 Cr & Cb sample per 2x1 Y samples), big-endian
    public static let yuv422p14be = Self(AV_PIX_FMT_YUV422P14BE)
    /// planar YUV 4:2:2,28bpp, (1 Cr & Cb sample per 2x1 Y samples), little-endian
    public static let yuv422p14le = Self(AV_PIX_FMT_YUV422P14LE)
    /// planar YUV 4:4:4,36bpp, (1 Cr & Cb sample per 1x1 Y samples), big-endian
    public static let yuv444p12be = Self(AV_PIX_FMT_YUV444P12BE)
    /// planar YUV 4:4:4,36bpp, (1 Cr & Cb sample per 1x1 Y samples), little-endian
    public static let yuv444p12le = Self(AV_PIX_FMT_YUV444P12LE)
    /// planar YUV 4:4:4,42bpp, (1 Cr & Cb sample per 1x1 Y samples), big-endian
    public static let yuv444p14be = Self(AV_PIX_FMT_YUV444P14BE)
    /// planar YUV 4:4:4,42bpp, (1 Cr & Cb sample per 1x1 Y samples), little-endian
    public static let yuv444p14le = Self(AV_PIX_FMT_YUV444P14LE)
    /// planar GBR 4:4:4 36bpp, big-endian
    public static let gbrp12be = Self(AV_PIX_FMT_GBRP12BE)
    /// planar GBR 4:4:4 36bpp, little-endian
    public static let gbrp12le = Self(AV_PIX_FMT_GBRP12LE)
    /// planar GBR 4:4:4 42bpp, big-endian
    public static let gbrp14be = Self(AV_PIX_FMT_GBRP14BE)
    /// planar GBR 4:4:4 42bpp, little-endian
    public static let gbrp14le = Self(AV_PIX_FMT_GBRP14LE)
    /// planar YUV 4:1:1, 12bpp, (1 Cr & Cb sample per 4x1 Y samples) full scale (JPEG), deprecated in favor of AV_PIX_FMT_YUV411P and setting color_range
    public static let yuvj411p = Self(AV_PIX_FMT_YUVJ411P)
    /// bayer, BGBG..(odd line), GRGR..(even line), 8-bit samples
    public static let bayerBggr8 = Self(AV_PIX_FMT_BAYER_BGGR8)
    /// bayer, RGRG..(odd line), GBGB..(even line), 8-bit samples
    public static let bayerRggb8 = Self(AV_PIX_FMT_BAYER_RGGB8)
    /// bayer, GBGB..(odd line), RGRG..(even line), 8-bit samples
    public static let bayerGbrg8 = Self(AV_PIX_FMT_BAYER_GBRG8)
    /// bayer, GRGR..(odd line), BGBG..(even line), 8-bit samples
    public static let bayerGrbg8 = Self(AV_PIX_FMT_BAYER_GRBG8)
    /// bayer, BGBG..(odd line), GRGR..(even line), 16-bit samples, little-endian
    public static let bayerBggr16le = Self(AV_PIX_FMT_BAYER_BGGR16LE)
    /// bayer, BGBG..(odd line), GRGR..(even line), 16-bit samples, big-endian
    public static let bayerBggr16be = Self(AV_PIX_FMT_BAYER_BGGR16BE)
    /// bayer, RGRG..(odd line), GBGB..(even line), 16-bit samples, little-endian
    public static let bayerRggb16le = Self(AV_PIX_FMT_BAYER_RGGB16LE)
    /// bayer, RGRG..(odd line), GBGB..(even line), 16-bit samples, big-endian
    public static let bayerRggb16be = Self(AV_PIX_FMT_BAYER_RGGB16BE)
    /// bayer, GBGB..(odd line), RGRG..(even line), 16-bit samples, little-endian
    public static let bayerGbrg16le = Self(AV_PIX_FMT_BAYER_GBRG16LE)
    /// bayer, GBGB..(odd line), RGRG..(even line), 16-bit samples, big-endian
    public static let bayerGbrg16be = Self(AV_PIX_FMT_BAYER_GBRG16BE)
    /// bayer, GRGR..(odd line), BGBG..(even line), 16-bit samples, little-endian
    public static let bayerGrbg16le = Self(AV_PIX_FMT_BAYER_GRBG16LE)
    /// bayer, GRGR..(odd line), BGBG..(even line), 16-bit samples, big-endian
    public static let bayerGrbg16be = Self(AV_PIX_FMT_BAYER_GRBG16BE)
    /// planar YUV 4:4:0,20bpp, (1 Cr & Cb sample per 1x2 Y samples), little-endian
    public static let yuv440p10le = Self(AV_PIX_FMT_YUV440P10LE)
    /// planar YUV 4:4:0,20bpp, (1 Cr & Cb sample per 1x2 Y samples), big-endian
    public static let yuv440p10be = Self(AV_PIX_FMT_YUV440P10BE)
    /// planar YUV 4:4:0,24bpp, (1 Cr & Cb sample per 1x2 Y samples), little-endian
    public static let yuv440p12le = Self(AV_PIX_FMT_YUV440P12LE)
    /// planar YUV 4:4:0,24bpp, (1 Cr & Cb sample per 1x2 Y samples), big-endian
    public static let yuv440p12be = Self(AV_PIX_FMT_YUV440P12BE)
    /// packed AYUV 4:4:4,64bpp (1 Cr & Cb sample per 1x1 Y & A samples), little-endian
    public static let ayuv64le = Self(AV_PIX_FMT_AYUV64LE)
    /// packed AYUV 4:4:4,64bpp (1 Cr & Cb sample per 1x1 Y & A samples), big-endian
    public static let ayuv64be = Self(AV_PIX_FMT_AYUV64BE)
    /// hardware decoding through Videotoolbox
    public static let videotoolbox = Self(AV_PIX_FMT_VIDEOTOOLBOX)
    /// like NV12, with 10bpp per component, data in the high bits, zeros in the low bits, little-endian
    public static let p010le = Self(AV_PIX_FMT_P010LE)
    /// like NV12, with 10bpp per component, data in the high bits, zeros in the low bits, big-endian
    public static let p010be = Self(AV_PIX_FMT_P010BE)
    /// planar GBR 4:4:4:4 48bpp, big-endian
    public static let gbrap12be = Self(AV_PIX_FMT_GBRAP12BE)
    /// planar GBR 4:4:4:4 48bpp, little-endian
    public static let gbrap12le = Self(AV_PIX_FMT_GBRAP12LE)
    /// planar GBR 4:4:4:4 40bpp, big-endian
    public static let gbrap10be = Self(AV_PIX_FMT_GBRAP10BE)
    /// planar GBR 4:4:4:4 40bpp, little-endian
    public static let gbrap10le = Self(AV_PIX_FMT_GBRAP10LE)
    /// hardware decoding through MediaCodec
    public static let mediacodec = Self(AV_PIX_FMT_MEDIACODEC)
    /// Y, 12bpp, big-endian
    public static let gray12be = Self(AV_PIX_FMT_GRAY12BE)
    /// Y, 12bpp, little-endian
    public static let gray12le = Self(AV_PIX_FMT_GRAY12LE)
    /// Y, 10bpp, big-endian
    public static let gray10be = Self(AV_PIX_FMT_GRAY10BE)
    /// Y , 10bpp, little-endian
    public static let gray10le = Self(AV_PIX_FMT_GRAY10LE)
    /// like NV12, with 16bpp per component, little-endian
    public static let p016le = Self(AV_PIX_FMT_P016LE)
    /// like NV12, with 16bpp per component, big-endian
    public static let p016be = Self(AV_PIX_FMT_P016BE)
    /**
     Hardware surfaces for Direct3D11.

     This is preferred over the legacy ``d3d11vaVld``. The new D3D11 hwaccel API and filtering support `d3d11` only.

     data[0] contains a ID3D11Texture2D pointer, and data[1] contains the texture array index of the frame as intptr_t if the ID3D11Texture2D is an array texture (or always 0 if it's a normal texture).
     */
    public static let d3d11 = Self(AV_PIX_FMT_D3D11)
    /// Y, 9bpp, big-endian
    public static let gray9be = Self(AV_PIX_FMT_GRAY9BE)
    /// Y, 9bpp, little-endian
    public static let gray9le = Self(AV_PIX_FMT_GRAY9LE)
    /// IEEE-754 single precision planar GBR 4:4:4,     96bpp, big-endian
    public static let gbrpf32be = Self(AV_PIX_FMT_GBRPF32BE)
    /// IEEE-754 single precision planar GBR 4:4:4,     96bpp, little-endian
    public static let gbrpf32le = Self(AV_PIX_FMT_GBRPF32LE)
    /// IEEE-754 single precision planar GBRA 4:4:4:4, 128bpp, big-endian
    public static let gbrapf32be = Self(AV_PIX_FMT_GBRAPF32BE)
    /// IEEE-754 single precision planar GBRA 4:4:4:4, 128bpp, little-endian
    public static let gbrapf32le = Self(AV_PIX_FMT_GBRAPF32LE)
    /**
     DRM-managed buffers exposed through PRIME buffer sharing.
     
     data[0] points to an AVDRMFrameDescriptor.
     */
    public static let drmPRIME = Self(AV_PIX_FMT_DRM_PRIME)
    /**
     Hardware surfaces for OpenCL.
     
     data[i] contain 2D image objects (typed in C as cl_mem, used in OpenCL as image2d_t) for each plane of the surface.
     */
    public static let opencl = Self(AV_PIX_FMT_OPENCL)
    /// Y        , 14bpp, big-endian
    public static let gray14be = Self(AV_PIX_FMT_GRAY14BE)
    /// Y        , 14bpp, little-endian
    public static let gray14le = Self(AV_PIX_FMT_GRAY14LE)
    /// IEEE-754 single precision Y, 32bpp, big-endian
    public static let grayf32be = Self(AV_PIX_FMT_GRAYF32BE)
    /// IEEE-754 single precision Y, 32bpp, little-endian
    public static let grayf32le = Self(AV_PIX_FMT_GRAYF32LE)
    /// planar YUV 4:2:2,24bpp, (1 Cr & Cb sample per 2x1 Y samples), 12b alpha, big-endian
    public static let yuva422p12be = Self(AV_PIX_FMT_YUVA422P12BE)
    /// planar YUV 4:2:2,24bpp, (1 Cr & Cb sample per 2x1 Y samples), 12b alpha, little-endian
    public static let yuva422p12le = Self(AV_PIX_FMT_YUVA422P12LE)
    /// planar YUV 4:4:4,36bpp, (1 Cr & Cb sample per 1x1 Y samples), 12b alpha, big-endian
    public static let yuva444p12be = Self(AV_PIX_FMT_YUVA444P12BE)
    /// planar YUV 4:4:4,36bpp, (1 Cr & Cb sample per 1x1 Y samples), 12b alpha, little-endian
    public static let yuva444p12le = Self(AV_PIX_FMT_YUVA444P12LE)
    /// planar YUV 4:4:4, 24bpp, 1 plane for Y and 1 plane for the UV components, which are interleaved (first byte U and the following byte V)
    public static let nv24 = Self(AV_PIX_FMT_NV24)
    /// as above, but U and V bytes are swapped
    public static let nv42 = Self(AV_PIX_FMT_NV42)
    /**
     Vulkan hardware images.
     
     data[0] points to an AVVkFrame
     */
    public static let vulkan = Self(AV_PIX_FMT_VULKAN)
    /// packed YUV 4:2:2 like YUYV422, 20bpp, data in the high bits, big-endian
    public static let y210be = Self(AV_PIX_FMT_Y210BE)
    /// packed YUV 4:2:2 like YUYV422, 20bpp, data in the high bits, little-endian
    public static let y210le = Self(AV_PIX_FMT_Y210LE)
    /// packed RGB 10:10:10, 30bpp, (msb)2X 10R 10G 10B(lsb), little-endian, X=unused/undefined
    public static let x2rgb10le = Self(AV_PIX_FMT_X2RGB10LE)
    /// packed RGB 10:10:10, 30bpp, (msb)2X 10R 10G 10B(lsb), big-endian, X=unused/undefined
    public static let x2rgb10be = Self(AV_PIX_FMT_X2RGB10BE)
    /// packed BGR 10:10:10, 30bpp, (msb)2X 10B 10G 10R(lsb), little-endian, X=unused/undefined
    public static let x2bgr10le = Self(AV_PIX_FMT_X2BGR10LE)
    /// packed BGR 10:10:10, 30bpp, (msb)2X 10B 10G 10R(lsb), big-endian, X=unused/undefined
    public static let x2bgr10be = Self(AV_PIX_FMT_X2BGR10BE)
    /// interleaved chroma YUV 4:2:2, 20bpp, data in the high bits, big-endian
    public static let p210be = Self(AV_PIX_FMT_P210BE)
    /// interleaved chroma YUV 4:2:2, 20bpp, data in the high bits, little-endian
    public static let p210le = Self(AV_PIX_FMT_P210LE)
    /// interleaved chroma YUV 4:4:4, 30bpp, data in the high bits, big-endian
    public static let p410be = Self(AV_PIX_FMT_P410BE)
    /// interleaved chroma YUV 4:4:4, 30bpp, data in the high bits, little-endian
    public static let p410le = Self(AV_PIX_FMT_P410LE)
    /// interleaved chroma YUV 4:2:2, 32bpp, big-endian
    public static let p216be = Self(AV_PIX_FMT_P216BE)
    /// interleaved chroma YUV 4:2:2, 32bpp, little-endian
    public static let p216le = Self(AV_PIX_FMT_P216LE)
    /// interleaved chroma YUV 4:4:4, 48bpp, big-endian
    public static let p416be = Self(AV_PIX_FMT_P416BE)
    /// interleaved chroma YUV 4:4:4, 48bpp, little-endian
    public static let p416le = Self(AV_PIX_FMT_P416LE)
    /// packed VUYA 4:4:4:4, 32bpp (1 Cr & Cb sample per 1x1 Y & A samples), VUYAVUYA...
    public static let vuya = Self(AV_PIX_FMT_VUYA)
    /// IEEE-754 half precision packed RGBA 16:16:16:16, 64bpp, RGBARGBA..., big-endian
    public static let rgbaf16be = Self(AV_PIX_FMT_RGBAF16BE)
    /// IEEE-754 half precision packed RGBA 16:16:16:16, 64bpp, RGBARGBA..., little-endian
    public static let rgbaf16le = Self(AV_PIX_FMT_RGBAF16LE)
    /// packed VUYX 4:4:4:4, 32bpp, Variant of VUYA where alpha channel is left undefined
    public static let vuyx = Self(AV_PIX_FMT_VUYX)
    /// like NV12, with 12bpp per component, data in the high bits, zeros in the low bits, little-endian
    public static let p012le = Self(AV_PIX_FMT_P012LE)
    /// like NV12, with 12bpp per component, data in the high bits, zeros in the low bits, big-endian
    public static let p012be = Self(AV_PIX_FMT_P012BE)
    /// packed YUV 4:2:2 like YUYV422, 24bpp, data in the high bits, zeros in the low bits, big-endian
    public static let y212be = Self(AV_PIX_FMT_Y212BE)
    /// packed YUV 4:2:2 like YUYV422, 24bpp, data in the high bits, zeros in the low bits, little-endian
    public static let y212le = Self(AV_PIX_FMT_Y212LE)
    /// packed XVYU 4:4:4, 32bpp, (msb)2X 10V 10Y 10U(lsb), big-endian, variant of Y410 where alpha channel is left undefined
    public static let xv30be = Self(AV_PIX_FMT_XV30BE)
    /// packed XVYU 4:4:4, 32bpp, (msb)2X 10V 10Y 10U(lsb), little-endian, variant of Y410 where alpha channel is left undefined
    public static let xv30le = Self(AV_PIX_FMT_XV30LE)
    /// packed XVYU 4:4:4, 48bpp, data in the high bits, zeros in the low bits, big-endian, variant of Y412 where alpha channel is left undefined
    public static let xv36be = Self(AV_PIX_FMT_XV36BE)
    /// packed XVYU 4:4:4, 48bpp, data in the high bits, zeros in the low bits, little-endian, variant of Y412 where alpha channel is left undefined
    public static let xv36le = Self(AV_PIX_FMT_XV36LE)
    /// IEEE-754 single precision packed RGB 32:32:32, 96bpp, RGBRGB..., big-endian
    public static let rgbf32be = Self(AV_PIX_FMT_RGBF32BE)
    /// IEEE-754 single precision packed RGB 32:32:32, 96bpp, RGBRGB..., little-endian
    public static let rgbf32le = Self(AV_PIX_FMT_RGBF32LE)
    /// IEEE-754 single precision packed RGBA 32:32:32:32, 128bpp, RGBARGBA..., big-endian
    public static let rgbaf32be = Self(AV_PIX_FMT_RGBAF32BE)
    /// IEEE-754 single precision packed RGBA 32:32:32:32, 128bpp, RGBARGBA..., little-endian
    public static let rgbaf32le = Self(AV_PIX_FMT_RGBAF32LE)
    /// interleaved chroma YUV 4:2:2, 24bpp, data in the high bits, big-endian
    public static let p212be = Self(AV_PIX_FMT_P212BE)
    /// interleaved chroma YUV 4:2:2, 24bpp, data in the high bits, little-endian
    public static let p212le = Self(AV_PIX_FMT_P212LE)
    /// interleaved chroma YUV 4:4:4, 36bpp, data in the high bits, big-endian
    public static let p412be = Self(AV_PIX_FMT_P412BE)
    /// interleaved chroma YUV 4:4:4, 36bpp, data in the high bits, little-endian
    public static let p412le = Self(AV_PIX_FMT_P412LE)
    /// planar GBR 4:4:4:4 56bpp, big-endian
    public static let gbrap14be = Self(AV_PIX_FMT_GBRAP14BE)
    /// planar GBR 4:4:4:4 56bpp, little-endian
    public static let gbrap14le = Self(AV_PIX_FMT_GBRAP14LE)
    /**
     Hardware surfaces for Direct3D 12.
     
     data[0] points to an AVD3D12VAFrame
     */
    public static let d3d12 = Self(AV_PIX_FMT_D3D12)
    /// packed AYUV 4:4:4:4, 32bpp (1 Cr & Cb sample per 1x1 Y & A samples), AYUVAYUV...
    public static let ayuv = Self(AV_PIX_FMT_AYUV)
    /// packed UYVA 4:4:4:4, 32bpp (1 Cr & Cb sample per 1x1 Y & A samples), UYVAUYVA...
    public static let uyva = Self(AV_PIX_FMT_UYVA)
    /// packed VYU 4:4:4, 24bpp (1 Cr & Cb sample per 1x1 Y), VYUVYU...
    public static let vyu444 = Self(AV_PIX_FMT_VYU444)
    /// packed VYUX 4:4:4 like XV30, 32bpp, (msb)10V 10Y 10U 2X(lsb), big-endian
    public static let v30xbe = Self(AV_PIX_FMT_V30XBE)
    /// packed VYUX 4:4:4 like XV30, 32bpp, (msb)10V 10Y 10U 2X(lsb), little-endian
    public static let v30xle = Self(AV_PIX_FMT_V30XLE)
    /// IEEE-754 half precision packed RGB 16:16:16, 48bpp, RGBRGB..., big-endian
    public static let rgbf16be = Self(AV_PIX_FMT_RGBF16BE)
    /// IEEE-754 half precision packed RGB 16:16:16, 48bpp, RGBRGB..., little-endian
    public static let rgbf16le = Self(AV_PIX_FMT_RGBF16LE)
    /// packed RGBA 32:32:32:32, 128bpp, RGBARGBA..., big-endian
    public static let rgba128be = Self(AV_PIX_FMT_RGBA128BE)
    /// packed RGBA 32:32:32:32, 128bpp, RGBARGBA..., little-endian
    public static let rgba128le = Self(AV_PIX_FMT_RGBA128LE)
    /// packed RGBA 32:32:32, 96bpp, RGBRGB..., big-endian
    public static let rgb96be = Self(AV_PIX_FMT_RGB96BE)
    /// packed RGBA 32:32:32, 96bpp, RGBRGB..., little-endian
    public static let rgb96le = Self(AV_PIX_FMT_RGB96LE)
    /// packed YUV 4:2:2 like YUYV422, 32bpp, big-endian
    public static let y216be = Self(AV_PIX_FMT_Y216BE)
    /// packed YUV 4:2:2 like YUYV422, 32bpp, little-endian
    public static let y216le = Self(AV_PIX_FMT_Y216LE)
    /// packed XVYU 4:4:4, 64bpp, big-endian, variant of Y416 where alpha channel is left undefined
    public static let xv48be = Self(AV_PIX_FMT_XV48BE)
    /// packed XVYU 4:4:4, 64bpp, little-endian, variant of Y416 where alpha channel is left undefined
    public static let xv48le = Self(AV_PIX_FMT_XV48LE)
    /// IEEE-754 half precision planer GBR 4:4:4, 48bpp, big-endian
    public static let gbrpf16be = Self(AV_PIX_FMT_GBRPF16BE)
    /// IEEE-754 half precision planer GBR 4:4:4, 48bpp, little-endian
    public static let gbrpf16le = Self(AV_PIX_FMT_GBRPF16LE)
    /// IEEE-754 half precision planar GBRA 4:4:4:4, 64bpp, big-endian
    public static let gbrapf16be = Self(AV_PIX_FMT_GBRAPF16BE)
    /// IEEE-754 half precision planar GBRA 4:4:4:4, 64bpp, little-endian
    public static let gbrapf16le = Self(AV_PIX_FMT_GBRAPF16LE)
    /// IEEE-754 half precision Y, 16bpp, big-endian
    public static let grayf16be = Self(AV_PIX_FMT_GRAYF16BE)
    /// IEEE-754 half precision Y, 16bpp, little-endian
    public static let grayf16le = Self(AV_PIX_FMT_GRAYF16LE)
    /// HW acceleration through AMF. data[0] contain AMFSurface pointer
    public static let amfSurface = Self(AV_PIX_FMT_AMF_SURFACE)
    /// Y, 32bpp, big-endian
    public static let gray32be = Self(AV_PIX_FMT_GRAY32BE)
    /// Y, 32bpp, little-endian
    public static let gray32le = Self(AV_PIX_FMT_GRAY32LE)
    /// IEEE-754 single precision packed YA, 32 bits gray, 32 bits alpha, 64bpp, big-endian
    public static let yaf32be = Self(AV_PIX_FMT_YAF32BE)
    /// IEEE-754 single precision packed YA, 32 bits gray, 32 bits alpha, 64bpp, little-endian
    public static let yaf32le = Self(AV_PIX_FMT_YAF32LE)
    /// IEEE-754 half precision packed YA, 16 bits gray, 16 bits alpha, 32bpp, big-endian
    public static let yaf16be = Self(AV_PIX_FMT_YAF16BE)
    /// IEEE-754 half precision packed YA, 16 bits gray, 16 bits alpha, 32bpp, little-endian
    public static let yaf16le = Self(AV_PIX_FMT_YAF16LE)
    /// planar GBRA 4:4:4:4 128bpp, big-endian
    public static let gbrap32be = Self(AV_PIX_FMT_GBRAP32BE)
    /// planar GBRA 4:4:4:4 128bpp, little-endian
    public static let gbrap32le = Self(AV_PIX_FMT_GBRAP32LE)
    /// planar YUV 4:4:4, 30bpp, (1 Cr & Cb sample per 1x1 Y samples), lowest bits zero, big-endian
    public static let yuv444p10msbbe = Self(AV_PIX_FMT_YUV444P10MSBBE)
    /// planar YUV 4:4:4, 30bpp, (1 Cr & Cb sample per 1x1 Y samples), lowest bits zero, little-endian
    public static let yuv444p10msble = Self(AV_PIX_FMT_YUV444P10MSBLE)
    /// planar YUV 4:4:4, 30bpp, (1 Cr & Cb sample per 1x1 Y samples), lowest bits zero, big-endian
    public static let yuv444p12msbbe = Self(AV_PIX_FMT_YUV444P12MSBBE)
    /// planar YUV 4:4:4, 30bpp, (1 Cr & Cb sample per 1x1 Y samples), lowest bits zero, little-endian
    public static let yuv444p12msble = Self(AV_PIX_FMT_YUV444P12MSBLE)
    /// planar GBR 4:4:4 30bpp, lowest bits zero, big-endian
    public static let gbrp10msbbe = Self(AV_PIX_FMT_GBRP10MSBBE)
    /// planar GBR 4:4:4 30bpp, lowest bits zero, little-endian
    public static let gbrp10msble = Self(AV_PIX_FMT_GBRP10MSBLE)
    /// planar GBR 4:4:4 36bpp, lowest bits zero, big-endian
    public static let gbrp12msbbe = Self(AV_PIX_FMT_GBRP12MSBBE)
    /// planar GBR 4:4:4 36bpp, lowest bits zero, little-endian
    public static let gbrp12msble = Self(AV_PIX_FMT_GBRP12MSBLE)

    public let rawValue: Int32
    public init(rawValue: Int32) {
        self.rawValue = rawValue
    }

    init(_ native: CFFmpeg.AVPixelFormat) {
        self.rawValue = native.rawValue
    }
    
    var native: CFFmpeg.AVPixelFormat {
        .init(rawValue: rawValue)
    }
}
