//
//  AVCodecID.swift
//  SwiftFFmpeg
//
//  Created by Florian Zand on 07.08.26.
//

import Foundation
import CFFmpeg

/// Identifies a codec.
public struct AVCodecID: RawRepresentable, CustomStringConvertible, Hashable {
    public let rawValue: UInt32
    
    public init(rawValue: UInt32) {
        self.rawValue = rawValue
    }
    
    public init?(name: String) {
        guard let codecID = avcodec_descriptor_get_by_name(name)?.pointee.id else { return nil }
        self.init(native: codecID)
    }
    
    init(native: CFFmpeg.AVCodecID) {
        self.init(rawValue: native.rawValue)
    }
    
    var native: CFFmpeg.AVCodecID {
        .init(rawValue: rawValue)
    }
    
    /// The name of the codec.
    public var name: String {
      String(cString: avcodec_get_name(native))
    }

    /// The media type of the codec.
    public var mediaType: AVMediaType {
      AVMediaType(native: avcodec_get_type(native))
    }
    
    public var description: String {
        name
    }
    
    /// The decoder registered for this codec ID, or `nil` if none is available.
    public var decoder: AVCodec? {
        avcodec_find_decoder(native).map({ AVCodec(native: $0) })
    }

    /// The encoder registered for this codec ID, or `nil` if none is available.
    public var encoder: AVCodec? {
        avcodec_find_encoder(native).map({ AVCodec(native: $0) })
    }
    
    public func profileName(for profile: AVProfile) -> String? {
        String(cString: avcodec_profile_name(native, profile.rawValue))
    }

    /**
     The approximate number of bits per sample for this codec.

     Use ``exactBitsPerSample`` when you need an exact value.
     */
    public var bitsPerSample: Int32? {
        let bits = av_get_bits_per_sample(native)
        return bits > 0 ? bits : nil
    }

    /**
     The exact number of bits per sample for this codec.

     Unlike ``bitsPerSample``, this returns a nonzero value only when the exact number is known.
     */
    public var exactBitsPerSample: Int32? {
        let bits = av_get_exact_bits_per_sample(native)
        return bits > 0 ? bits : nil
    }

    private var descriptor: UnsafePointer<CFFmpeg.AVCodecDescriptor>? {
        avcodec_descriptor_get(native)
    }
    
    /// A more descriptive name of the codec.
    public var longName: String? {
        String(cString: descriptor?.pointee.long_name)
    }
    
    /// The MIME types associated with this codec.
    public var mimeTypes: [String] {
        guard let mimeTypes = descriptor?.pointee.mime_types else { return [] }
        var result: [String] = []
        var current = mimeTypes
        while let mimeType = current.pointee {
            result.append(String(cString: mimeType))
            current = current.advanced(by: 1)
        }

        return result
    }
    
    /// The recognized profiles for this codec.
    public var profiles: [AVNamedProfile] {
        guard let profiles = descriptor?.pointee.profiles else { return [] }
        var result: [AVNamedProfile] = []
        var current = profiles

        while current.pointee.profile != AV_PROFILE_UNKNOWN {
            result.append(AVNamedProfile(native: current.pointee))
            current = current.advanced(by: 1)
        }

        return result
    }
    
    /// The properties of this codec.
    public var properties: Properties {
        Properties(rawValue: descriptor?.pointee.props ?? 0)
    }
    
    /// The properties of a codec.
    public struct Properties: OptionSet {
        /// Codec uses only intra compression.
        public static let intraOnly = Self.init(rawValue: 1 << 0)
        /**
         Codec supports lossy compression.

         A codec may support both ``lossy`` and ``lossless``.
         */
        public static let lossy = Self.init(rawValue: 1 << 1)
        /**
         Codec supports lossless compression.
         
         A codec may support both ``lossy`` and ``lossless``.
         */
        public static let lossless = Self.init(rawValue: 1 << 2)
        /**
         Codec supports frame reordering.
         
         That is, the coded order (the order in which the encoded packets are output by the encoders / stored / input to the decoders) may be different from the presentation order of the corresponding frames.
         For codecs that do not have this property set, PTS and DTS should always be equal.
         */
        public static let reorder = Self.init(rawValue: 1 << 3)
        /// Video codec supports separate coding of fields in interlaced frames.
        public static let fields = Self.init(rawValue: 1 << 4)
        /**
         Video codec contains enhancement information meant to be applied to other existing frames, and can't generate usable image data on its own.
         
         A standalone decoder is unlikely to be available for it and should not be expected.
         */
        public static let enhancement = Self.init(rawValue: 1 << 5)
        /// Subtitle codec is bitmap based.
        public static let bitmapSubtitle = Self.init(rawValue: 1 << 16)
        /// Subtitle codec is text based.
        public static let textSubtitle = Self.init(rawValue: 1 << 17)
        
        public let rawValue: Int32

        public init(rawValue: Int32) {
            self.rawValue = rawValue
        }
    }
    
    /// All codec IDs known to libavcodec.
    public static var all: [AVCodecID] {
        var result: [AVCodecID] = []
        var previous: UnsafePointer<CFFmpeg.AVCodecDescriptor>?
        while let descriptor = avcodec_descriptor_next(previous) {
            result.append(AVCodecID(native: descriptor.pointee.id))
            previous = descriptor
        }
        return result
    }
}

extension AVCodecID {
    // MARK: - General

    public static let none = Self(native: AV_CODEC_ID_NONE)

    // MARK: - Video Codecs

    /// The MPEG-1 video codec.
    public static let mpeg1video = Self(native: AV_CODEC_ID_MPEG1VIDEO)
    /// The MPEG-2 video codec.
    public static let mpeg2video = Self(native: AV_CODEC_ID_MPEG2VIDEO)
    /// The H.261 video codec.
    public static let h261 = Self(native: AV_CODEC_ID_H261)
    /// The H.263 video codec.
    public static let h263 = Self(native: AV_CODEC_ID_H263)
    /// The RealVideo 1.0 video codec.
    public static let rv10 = Self(native: AV_CODEC_ID_RV10)
    /// The RealVideo 2.0 video codec.
    public static let rv20 = Self(native: AV_CODEC_ID_RV20)
    /// The Motion JPEG (MJPEG) video codec.
    public static let mjpeg = Self(native: AV_CODEC_ID_MJPEG)
    /// The Motion JPEG B (MJPEG-B) video codec.
    public static let mjpegb = Self(native: AV_CODEC_ID_MJPEGB)
    /// The lossless JPEG video codec.
    public static let ljpeg = Self(native: AV_CODEC_ID_LJPEG)
    /// The SP5X video codec.
    public static let sp5x = Self(native: AV_CODEC_ID_SP5X)
    /// The JPEG-LS lossless image codec.
    public static let jpegls = Self(native: AV_CODEC_ID_JPEGLS)
    /// The MPEG-4 Part 2 video codec.
    public static let mpeg4 = Self(native: AV_CODEC_ID_MPEG4)
    /// The uncompressed raw video codec.
    public static let rawvideo = Self(native: AV_CODEC_ID_RAWVIDEO)
    /// The Microsoft MPEG-4 version 1 video codec.
    public static let msmpeg4v1 = Self(native: AV_CODEC_ID_MSMPEG4V1)
    /// The Microsoft MPEG-4 version 2 video codec.
    public static let msmpeg4v2 = Self(native: AV_CODEC_ID_MSMPEG4V2)
    /// The Microsoft MPEG-4 version 3 video codec.
    public static let msmpeg4v3 = Self(native: AV_CODEC_ID_MSMPEG4V3)
    /// The Windows Media Video 7 (WMV7) video codec.
    public static let wmv1 = Self(native: AV_CODEC_ID_WMV1)
    /// The Windows Media Video 8 (WMV8) video codec.
    public static let wmv2 = Self(native: AV_CODEC_ID_WMV2)
    /// The H263P video codec.
    public static let h263p = Self(native: AV_CODEC_ID_H263P)
    /// The H263I video codec.
    public static let h263i = Self(native: AV_CODEC_ID_H263I)
    /// The FLV1 video codec.
    public static let flv1 = Self(native: AV_CODEC_ID_FLV1)
    /// The SVQ1 video codec.
    public static let svq1 = Self(native: AV_CODEC_ID_SVQ1)
    /// The SVQ3 video codec.
    public static let svq3 = Self(native: AV_CODEC_ID_SVQ3)
    /// The DVVIDEO video codec.
    public static let dvvideo = Self(native: AV_CODEC_ID_DVVIDEO)
    /// The HUFFYUV video codec.
    public static let huffyuv = Self(native: AV_CODEC_ID_HUFFYUV)
    /// The CYUV video codec.
    public static let cyuv = Self(native: AV_CODEC_ID_CYUV)
    /// The H.264 / Advanced Video Coding (AVC) video codec.
    public static let h264 = Self(native: AV_CODEC_ID_H264)
    /// The INDEO3 video codec.
    public static let indeo3 = Self(native: AV_CODEC_ID_INDEO3)
    /// The VP3 video codec.
    public static let vp3 = Self(native: AV_CODEC_ID_VP3)
    /// The THEORA video codec.
    public static let theora = Self(native: AV_CODEC_ID_THEORA)
    /// The ASV1 video codec.
    public static let asv1 = Self(native: AV_CODEC_ID_ASV1)
    /// The ASV2 video codec.
    public static let asv2 = Self(native: AV_CODEC_ID_ASV2)
    /// The FFV1 video codec.
    public static let ffv1 = Self(native: AV_CODEC_ID_FFV1)
    /// The 4XM video codec.
    public static let c4xm = Self(native: AV_CODEC_ID_4XM)
    /// The VCR1 video codec.
    public static let vcr1 = Self(native: AV_CODEC_ID_VCR1)
    /// The CLJR video codec.
    public static let cljr = Self(native: AV_CODEC_ID_CLJR)
    /// The MDEC video codec.
    public static let mdec = Self(native: AV_CODEC_ID_MDEC)
    /// The ROQ video codec.
    public static let roq = Self(native: AV_CODEC_ID_ROQ)
    /// The INTERPLAY_VIDEO video codec.
    public static let interplayVideo = Self(native: AV_CODEC_ID_INTERPLAY_VIDEO)
    /// The XAN_WC3 video codec.
    public static let xanWc3 = Self(native: AV_CODEC_ID_XAN_WC3)
    /// The XAN_WC4 video codec.
    public static let xanWc4 = Self(native: AV_CODEC_ID_XAN_WC4)
    /// The RPZA video codec.
    public static let rpza = Self(native: AV_CODEC_ID_RPZA)
    /// The CINEPAK video codec.
    public static let cinepak = Self(native: AV_CODEC_ID_CINEPAK)
    /// The WS_VQA video codec.
    public static let wsVqa = Self(native: AV_CODEC_ID_WS_VQA)
    /// The MSRLE video codec.
    public static let msrle = Self(native: AV_CODEC_ID_MSRLE)
    /// The MSVIDEO1 video codec.
    public static let msvideo1 = Self(native: AV_CODEC_ID_MSVIDEO1)
    /// The IDCIN video codec.
    public static let idcin = Self(native: AV_CODEC_ID_IDCIN)
    /// The 8BPS video codec.
    public static let c8bps = Self(native: AV_CODEC_ID_8BPS)
    /// The SMC video codec.
    public static let smc = Self(native: AV_CODEC_ID_SMC)
    /// The FLIC video codec.
    public static let flic = Self(native: AV_CODEC_ID_FLIC)
    /// The TRUEMOTION1 video codec.
    public static let truemotion1 = Self(native: AV_CODEC_ID_TRUEMOTION1)
    /// The VMDVIDEO video codec.
    public static let vmdvideo = Self(native: AV_CODEC_ID_VMDVIDEO)
    /// The MSZH video codec.
    public static let mszh = Self(native: AV_CODEC_ID_MSZH)
    /// The ZLIB video codec.
    public static let zlib = Self(native: AV_CODEC_ID_ZLIB)
    /// The QTRLE video codec.
    public static let qtrle = Self(native: AV_CODEC_ID_QTRLE)
    /// The TSCC video codec.
    public static let tscc = Self(native: AV_CODEC_ID_TSCC)
    /// The ULTI video codec.
    public static let ulti = Self(native: AV_CODEC_ID_ULTI)
    /// The QDRAW video codec.
    public static let qdraw = Self(native: AV_CODEC_ID_QDRAW)
    /// The VIXL video codec.
    public static let vixl = Self(native: AV_CODEC_ID_VIXL)
    /// The QPEG video codec.
    public static let qpeg = Self(native: AV_CODEC_ID_QPEG)
    /// The PNG video codec.
    public static let png = Self(native: AV_CODEC_ID_PNG)
    /// The PPM video codec.
    public static let ppm = Self(native: AV_CODEC_ID_PPM)
    /// The PBM video codec.
    public static let pbm = Self(native: AV_CODEC_ID_PBM)
    /// The PGM video codec.
    public static let pgm = Self(native: AV_CODEC_ID_PGM)
    /// The PGMYUV video codec.
    public static let pgmyuv = Self(native: AV_CODEC_ID_PGMYUV)
    /// The PAM video codec.
    public static let pam = Self(native: AV_CODEC_ID_PAM)
    /// The FFVHUFF video codec.
    public static let ffvhuff = Self(native: AV_CODEC_ID_FFVHUFF)
    /// The RV30 video codec.
    public static let rv30 = Self(native: AV_CODEC_ID_RV30)
    /// The RV40 video codec.
    public static let rv40 = Self(native: AV_CODEC_ID_RV40)
    /// The VC1 video codec.
    public static let vc1 = Self(native: AV_CODEC_ID_VC1)
    /// The WMV3 video codec.
    public static let wmv3 = Self(native: AV_CODEC_ID_WMV3)
    /// The LOCO video codec.
    public static let loco = Self(native: AV_CODEC_ID_LOCO)
    /// The WNV1 video codec.
    public static let wnv1 = Self(native: AV_CODEC_ID_WNV1)
    /// The AASC video codec.
    public static let aasc = Self(native: AV_CODEC_ID_AASC)
    /// The INDEO2 video codec.
    public static let indeo2 = Self(native: AV_CODEC_ID_INDEO2)
    /// The FRAPS video codec.
    public static let fraps = Self(native: AV_CODEC_ID_FRAPS)
    /// The TRUEMOTION2 video codec.
    public static let truemotion2 = Self(native: AV_CODEC_ID_TRUEMOTION2)
    /// The BMP video codec.
    public static let bmp = Self(native: AV_CODEC_ID_BMP)
    /// The CSCD video codec.
    public static let cscd = Self(native: AV_CODEC_ID_CSCD)
    /// The MMVIDEO video codec.
    public static let mmvideo = Self(native: AV_CODEC_ID_MMVIDEO)
    /// The ZMBV video codec.
    public static let zmbv = Self(native: AV_CODEC_ID_ZMBV)
    /// The AVS video codec.
    public static let avs = Self(native: AV_CODEC_ID_AVS)
    /// The SMACKVIDEO video codec.
    public static let smackvideo = Self(native: AV_CODEC_ID_SMACKVIDEO)
    /// The NUV video codec.
    public static let nuv = Self(native: AV_CODEC_ID_NUV)
    /// The KMVC video codec.
    public static let kmvc = Self(native: AV_CODEC_ID_KMVC)
    /// The FLASHSV video codec.
    public static let flashsv = Self(native: AV_CODEC_ID_FLASHSV)
    /// The CAVS video codec.
    public static let cavs = Self(native: AV_CODEC_ID_CAVS)
    /// The JPEG2000 video codec.
    public static let jpeg2000 = Self(native: AV_CODEC_ID_JPEG2000)
    /// The VMNC video codec.
    public static let vmnc = Self(native: AV_CODEC_ID_VMNC)
    /// The VP5 video codec.
    public static let vp5 = Self(native: AV_CODEC_ID_VP5)
    /// The VP6 video codec.
    public static let vp6 = Self(native: AV_CODEC_ID_VP6)
    /// The VP6F video codec.
    public static let vp6f = Self(native: AV_CODEC_ID_VP6F)
    /// The TARGA video codec.
    public static let targa = Self(native: AV_CODEC_ID_TARGA)
    /// The DSICINVIDEO video codec.
    public static let dsicinvideo = Self(native: AV_CODEC_ID_DSICINVIDEO)
    /// The TIERTEXSEQVIDEO video codec.
    public static let tiertexseqvideo = Self(native: AV_CODEC_ID_TIERTEXSEQVIDEO)
    /// The TIFF video codec.
    public static let tiff = Self(native: AV_CODEC_ID_TIFF)
    /// The GIF video codec.
    public static let gif = Self(native: AV_CODEC_ID_GIF)
    /// The DXA video codec.
    public static let dxa = Self(native: AV_CODEC_ID_DXA)
    /// The DNXHD video codec.
    public static let dnxhd = Self(native: AV_CODEC_ID_DNXHD)
    /// The THP video codec.
    public static let thp = Self(native: AV_CODEC_ID_THP)
    /// The SGI video codec.
    public static let sgi = Self(native: AV_CODEC_ID_SGI)
    /// The C93 video codec.
    public static let c93 = Self(native: AV_CODEC_ID_C93)
    /// The BETHSOFTVID video codec.
    public static let bethsoftvid = Self(native: AV_CODEC_ID_BETHSOFTVID)
    /// The PTX video codec.
    public static let ptx = Self(native: AV_CODEC_ID_PTX)
    /// The TXD video codec.
    public static let txd = Self(native: AV_CODEC_ID_TXD)
    /// The VP6A video codec.
    public static let vp6a = Self(native: AV_CODEC_ID_VP6A)
    /// The AMV video codec.
    public static let amv = Self(native: AV_CODEC_ID_AMV)
    /// The VB video codec.
    public static let vb = Self(native: AV_CODEC_ID_VB)
    /// The PCX video codec.
    public static let pcx = Self(native: AV_CODEC_ID_PCX)
    /// The SUNRAST video codec.
    public static let sunrast = Self(native: AV_CODEC_ID_SUNRAST)
    /// The INDEO4 video codec.
    public static let indeo4 = Self(native: AV_CODEC_ID_INDEO4)
    /// The INDEO5 video codec.
    public static let indeo5 = Self(native: AV_CODEC_ID_INDEO5)
    /// The MIMIC video codec.
    public static let mimic = Self(native: AV_CODEC_ID_MIMIC)
    /// The RL2 video codec.
    public static let rl2 = Self(native: AV_CODEC_ID_RL2)
    /// The ESCAPE124 video codec.
    public static let escape124 = Self(native: AV_CODEC_ID_ESCAPE124)
    /// The DIRAC video codec.
    public static let dirac = Self(native: AV_CODEC_ID_DIRAC)
    /// The BFI video codec.
    public static let bfi = Self(native: AV_CODEC_ID_BFI)
    /// The CMV video codec.
    public static let cmv = Self(native: AV_CODEC_ID_CMV)
    /// The MOTIONPIXELS video codec.
    public static let motionpixels = Self(native: AV_CODEC_ID_MOTIONPIXELS)
    /// The TGV video codec.
    public static let tgv = Self(native: AV_CODEC_ID_TGV)
    /// The TGQ video codec.
    public static let tgq = Self(native: AV_CODEC_ID_TGQ)
    /// The TQI video codec.
    public static let tqi = Self(native: AV_CODEC_ID_TQI)
    /// The AURA video codec.
    public static let aura = Self(native: AV_CODEC_ID_AURA)
    /// The AURA2 video codec.
    public static let aura2 = Self(native: AV_CODEC_ID_AURA2)
    /// The V210X video codec.
    public static let v210x = Self(native: AV_CODEC_ID_V210X)
    /// The TMV video codec.
    public static let tmv = Self(native: AV_CODEC_ID_TMV)
    /// The V210 video codec.
    public static let v210 = Self(native: AV_CODEC_ID_V210)
    /// The DPX video codec.
    public static let dpx = Self(native: AV_CODEC_ID_DPX)
    /// The MAD video codec.
    public static let mad = Self(native: AV_CODEC_ID_MAD)
    /// The FRWU video codec.
    public static let frwu = Self(native: AV_CODEC_ID_FRWU)
    /// The FLASHSV2 video codec.
    public static let flashsv2 = Self(native: AV_CODEC_ID_FLASHSV2)
    /// The CDGRAPHICS video codec.
    public static let cdgraphics = Self(native: AV_CODEC_ID_CDGRAPHICS)
    /// The R210 video codec.
    public static let r210 = Self(native: AV_CODEC_ID_R210)
    /// The ANM video codec.
    public static let anm = Self(native: AV_CODEC_ID_ANM)
    /// The BINKVIDEO video codec.
    public static let binkvideo = Self(native: AV_CODEC_ID_BINKVIDEO)
    /// The IFF_ILBM video codec.
    public static let iffIlbm = Self(native: AV_CODEC_ID_IFF_ILBM)
    /// The KGV1 video codec.
    public static let kgv1 = Self(native: AV_CODEC_ID_KGV1)
    /// The YOP video codec.
    public static let yop = Self(native: AV_CODEC_ID_YOP)
    /// The VP8 video codec.
    public static let vp8 = Self(native: AV_CODEC_ID_VP8)
    /// The PICTOR video codec.
    public static let pictor = Self(native: AV_CODEC_ID_PICTOR)
    /// The ANSI video codec.
    public static let ansi = Self(native: AV_CODEC_ID_ANSI)
    /// The A64_MULTI video codec.
    public static let a64Multi = Self(native: AV_CODEC_ID_A64_MULTI)
    /// The A64_MULTI5 video codec.
    public static let a64Multi5 = Self(native: AV_CODEC_ID_A64_MULTI5)
    /// The R10K video codec.
    public static let r10k = Self(native: AV_CODEC_ID_R10K)
    /// The MXPEG video codec.
    public static let mxpeg = Self(native: AV_CODEC_ID_MXPEG)
    /// The LAGARITH video codec.
    public static let lagarith = Self(native: AV_CODEC_ID_LAGARITH)
    /// The PRORES video codec.
    public static let prores = Self(native: AV_CODEC_ID_PRORES)
    /// The JV video codec.
    public static let jv = Self(native: AV_CODEC_ID_JV)
    /// The DFA video codec.
    public static let dfa = Self(native: AV_CODEC_ID_DFA)
    /// The WMV3IMAGE video codec.
    public static let wmv3image = Self(native: AV_CODEC_ID_WMV3IMAGE)
    /// The VC1IMAGE video codec.
    public static let vc1image = Self(native: AV_CODEC_ID_VC1IMAGE)
    /// The UTVIDEO video codec.
    public static let utvideo = Self(native: AV_CODEC_ID_UTVIDEO)
    /// The BMV_VIDEO video codec.
    public static let bmvVideo = Self(native: AV_CODEC_ID_BMV_VIDEO)
    /// The VBLE video codec.
    public static let vble = Self(native: AV_CODEC_ID_VBLE)
    /// The DXTORY video codec.
    public static let dxtory = Self(native: AV_CODEC_ID_DXTORY)
    /// The XWD video codec.
    public static let xwd = Self(native: AV_CODEC_ID_XWD)
    /// The CDXL video codec.
    public static let cdxl = Self(native: AV_CODEC_ID_CDXL)
    /// The XBM video codec.
    public static let xbm = Self(native: AV_CODEC_ID_XBM)
    /// The ZEROCODEC video codec.
    public static let zerocodec = Self(native: AV_CODEC_ID_ZEROCODEC)
    /// The MSS1 video codec.
    public static let mss1 = Self(native: AV_CODEC_ID_MSS1)
    /// The MSA1 video codec.
    public static let msa1 = Self(native: AV_CODEC_ID_MSA1)
    /// The TSCC2 video codec.
    public static let tscc2 = Self(native: AV_CODEC_ID_TSCC2)
    /// The MTS2 video codec.
    public static let mts2 = Self(native: AV_CODEC_ID_MTS2)
    /// The CLLC video codec.
    public static let cllc = Self(native: AV_CODEC_ID_CLLC)
    /// The MSS2 video codec.
    public static let mss2 = Self(native: AV_CODEC_ID_MSS2)
    /// The VP9 video codec.
    public static let vp9 = Self(native: AV_CODEC_ID_VP9)
    /// The AIC video codec.
    public static let aic = Self(native: AV_CODEC_ID_AIC)
    /// The ESCAPE130 video codec.
    public static let escape130 = Self(native: AV_CODEC_ID_ESCAPE130)
    /// The G2M video codec.
    public static let g2m = Self(native: AV_CODEC_ID_G2M)
    /// The WEBP video codec.
    public static let webp = Self(native: AV_CODEC_ID_WEBP)
    /// The HNM4_VIDEO video codec.
    public static let hnm4Video = Self(native: AV_CODEC_ID_HNM4_VIDEO)
    /// The H.265 / High Efficiency Video Coding (HEVC) video codec.
    public static let hevc = Self(native: AV_CODEC_ID_HEVC)
    /// The FIC video codec.
    public static let fic = Self(native: AV_CODEC_ID_FIC)
    /// The ALIAS_PIX video codec.
    public static let aliasPix = Self(native: AV_CODEC_ID_ALIAS_PIX)
    /// The BRENDER_PIX video codec.
    public static let brenderPix = Self(native: AV_CODEC_ID_BRENDER_PIX)
    /// The PAF_VIDEO video codec.
    public static let pafVideo = Self(native: AV_CODEC_ID_PAF_VIDEO)
    /// The EXR video codec.
    public static let exr = Self(native: AV_CODEC_ID_EXR)
    /// The VP7 video codec.
    public static let vp7 = Self(native: AV_CODEC_ID_VP7)
    /// The SANM video codec.
    public static let sanm = Self(native: AV_CODEC_ID_SANM)
    /// The SGIRLE video codec.
    public static let sgirle = Self(native: AV_CODEC_ID_SGIRLE)
    /// The MVC1 video codec.
    public static let mvc1 = Self(native: AV_CODEC_ID_MVC1)
    /// The MVC2 video codec.
    public static let mvc2 = Self(native: AV_CODEC_ID_MVC2)
    /// The HQX video codec.
    public static let hqx = Self(native: AV_CODEC_ID_HQX)
    /// The TDSC video codec.
    public static let tdsc = Self(native: AV_CODEC_ID_TDSC)
    /// The HQ_HQA video codec.
    public static let hqHqa = Self(native: AV_CODEC_ID_HQ_HQA)
    /// The HAP video codec.
    public static let hap = Self(native: AV_CODEC_ID_HAP)
    /// The DDS video codec.
    public static let dds = Self(native: AV_CODEC_ID_DDS)
    /// The DXV video codec.
    public static let dxv = Self(native: AV_CODEC_ID_DXV)
    /// The SCREENPRESSO video codec.
    public static let screenpresso = Self(native: AV_CODEC_ID_SCREENPRESSO)
    /// The RSCC video codec.
    public static let rscc = Self(native: AV_CODEC_ID_RSCC)
    /// The AVS2 video codec.
    public static let avs2 = Self(native: AV_CODEC_ID_AVS2)
    /// The PGX video codec.
    public static let pgx = Self(native: AV_CODEC_ID_PGX)
    /// The AVS3 video codec.
    public static let avs3 = Self(native: AV_CODEC_ID_AVS3)
    /// The MSP2 video codec.
    public static let msp2 = Self(native: AV_CODEC_ID_MSP2)
    /// The H.266 / Versatile Video Coding (VVC) video codec.
    public static let vvc = Self(native: AV_CODEC_ID_VVC)
    /// The Y41P video codec.
    public static let y41p = Self(native: AV_CODEC_ID_Y41P)
    /// The AVRP video codec.
    public static let avrp = Self(native: AV_CODEC_ID_AVRP)
    /// The 012V video codec.
    public static let c012v = Self(native: AV_CODEC_ID_012V)
    /// The AVUI video codec.
    public static let avui = Self(native: AV_CODEC_ID_AVUI)
    /// The TARGA_Y216 video codec.
    public static let targaY216 = Self(native: AV_CODEC_ID_TARGA_Y216)
    /// The YUV4 video codec.
    public static let yuv4 = Self(native: AV_CODEC_ID_YUV4)
    /// The AVRN video codec.
    public static let avrn = Self(native: AV_CODEC_ID_AVRN)
    /// The CPIA video codec.
    public static let cpia = Self(native: AV_CODEC_ID_CPIA)
    /// The XFACE video codec.
    public static let xface = Self(native: AV_CODEC_ID_XFACE)
    /// The SNOW video codec.
    public static let snow = Self(native: AV_CODEC_ID_SNOW)
    /// The SMVJPEG video codec.
    public static let smvjpeg = Self(native: AV_CODEC_ID_SMVJPEG)
    /// The APNG video codec.
    public static let apng = Self(native: AV_CODEC_ID_APNG)
    /// The DAALA video codec.
    public static let daala = Self(native: AV_CODEC_ID_DAALA)
    /// The CFHD video codec.
    public static let cfhd = Self(native: AV_CODEC_ID_CFHD)
    /// The TRUEMOTION2RT video codec.
    public static let truemotion2rt = Self(native: AV_CODEC_ID_TRUEMOTION2RT)
    /// The M101 video codec.
    public static let m101 = Self(native: AV_CODEC_ID_M101)
    /// The MAGICYUV video codec.
    public static let magicyuv = Self(native: AV_CODEC_ID_MAGICYUV)
    /// The SHEERVIDEO video codec.
    public static let sheervideo = Self(native: AV_CODEC_ID_SHEERVIDEO)
    /// The YLC video codec.
    public static let ylc = Self(native: AV_CODEC_ID_YLC)
    /// The PSD video codec.
    public static let psd = Self(native: AV_CODEC_ID_PSD)
    /// The PIXLET video codec.
    public static let pixlet = Self(native: AV_CODEC_ID_PIXLET)
    /// The SPEEDHQ video codec.
    public static let speedhq = Self(native: AV_CODEC_ID_SPEEDHQ)
    /// The FMVC video codec.
    public static let fmvc = Self(native: AV_CODEC_ID_FMVC)
    /// The SCPR video codec.
    public static let scpr = Self(native: AV_CODEC_ID_SCPR)
    /// The CLEARVIDEO video codec.
    public static let clearvideo = Self(native: AV_CODEC_ID_CLEARVIDEO)
    /// The XPM video codec.
    public static let xpm = Self(native: AV_CODEC_ID_XPM)
    /// The AOMedia Video 1 (AV1) video codec.
    public static let av1 = Self(native: AV_CODEC_ID_AV1)
    /// The BITPACKED video codec.
    public static let bitpacked = Self(native: AV_CODEC_ID_BITPACKED)
    /// The MSCC video codec.
    public static let mscc = Self(native: AV_CODEC_ID_MSCC)
    /// The SRGC video codec.
    public static let srgc = Self(native: AV_CODEC_ID_SRGC)
    /// The SVG video codec.
    public static let svg = Self(native: AV_CODEC_ID_SVG)
    /// The GDV video codec.
    public static let gdv = Self(native: AV_CODEC_ID_GDV)
    /// The FITS video codec.
    public static let fits = Self(native: AV_CODEC_ID_FITS)
    /// The IMM4 video codec.
    public static let imm4 = Self(native: AV_CODEC_ID_IMM4)
    /// The PROSUMER video codec.
    public static let prosumer = Self(native: AV_CODEC_ID_PROSUMER)
    /// The MWSC video codec.
    public static let mwsc = Self(native: AV_CODEC_ID_MWSC)
    /// The WCMV video codec.
    public static let wcmv = Self(native: AV_CODEC_ID_WCMV)
    /// The RASC video codec.
    public static let rasc = Self(native: AV_CODEC_ID_RASC)
    /// The HYMT video codec.
    public static let hymt = Self(native: AV_CODEC_ID_HYMT)
    /// The ARBC video codec.
    public static let arbc = Self(native: AV_CODEC_ID_ARBC)
    /// The AGM video codec.
    public static let agm = Self(native: AV_CODEC_ID_AGM)
    /// The LSCR video codec.
    public static let lscr = Self(native: AV_CODEC_ID_LSCR)
    /// The VP4 video codec.
    public static let vp4 = Self(native: AV_CODEC_ID_VP4)
    /// The IMM5 video codec.
    public static let imm5 = Self(native: AV_CODEC_ID_IMM5)
    /// The MVDV video codec.
    public static let mvdv = Self(native: AV_CODEC_ID_MVDV)
    /// The MVHA video codec.
    public static let mvha = Self(native: AV_CODEC_ID_MVHA)
    /// The CDTOONS video codec.
    public static let cdtoons = Self(native: AV_CODEC_ID_CDTOONS)
    /// The MV30 video codec.
    public static let mv30 = Self(native: AV_CODEC_ID_MV30)
    /// The NOTCHLC video codec.
    public static let notchlc = Self(native: AV_CODEC_ID_NOTCHLC)
    /// The PFM video codec.
    public static let pfm = Self(native: AV_CODEC_ID_PFM)
    /// The MOBICLIP video codec.
    public static let mobiclip = Self(native: AV_CODEC_ID_MOBICLIP)
    /// The PHOTOCD video codec.
    public static let photocd = Self(native: AV_CODEC_ID_PHOTOCD)
    /// The IPU video codec.
    public static let ipu = Self(native: AV_CODEC_ID_IPU)
    /// The ARGO video codec.
    public static let argo = Self(native: AV_CODEC_ID_ARGO)
    /// The CRI video codec.
    public static let cri = Self(native: AV_CODEC_ID_CRI)
    /// The SIMBIOSIS_IMX video codec.
    public static let simbiosisImx = Self(native: AV_CODEC_ID_SIMBIOSIS_IMX)
    /// The SGA_VIDEO video codec.
    public static let sgaVideo = Self(native: AV_CODEC_ID_SGA_VIDEO)
    /// The GEM video codec.
    public static let gem = Self(native: AV_CODEC_ID_GEM)
    /// The VBN video codec.
    public static let vbn = Self(native: AV_CODEC_ID_VBN)
    /// The JPEGXL video codec.
    public static let jpegxl = Self(native: AV_CODEC_ID_JPEGXL)
    /// The QOI video codec.
    public static let qoi = Self(native: AV_CODEC_ID_QOI)
    /// The PHM video codec.
    public static let phm = Self(native: AV_CODEC_ID_PHM)
    /// The RADIANCE_HDR video codec.
    public static let radianceHdr = Self(native: AV_CODEC_ID_RADIANCE_HDR)
    /// The WBMP video codec.
    public static let wbmp = Self(native: AV_CODEC_ID_WBMP)
    /// The MEDIA100 video codec.
    public static let media100 = Self(native: AV_CODEC_ID_MEDIA100)
    /// The VQC video codec.
    public static let vqc = Self(native: AV_CODEC_ID_VQC)
    /// The PDV video codec.
    public static let pdv = Self(native: AV_CODEC_ID_PDV)
    /// The EVC video codec.
    public static let evc = Self(native: AV_CODEC_ID_EVC)
    /// The RTV1 video codec.
    public static let rtv1 = Self(native: AV_CODEC_ID_RTV1)
    /// The VMIX video codec.
    public static let vmix = Self(native: AV_CODEC_ID_VMIX)
    /// The LEAD video codec.
    public static let lead = Self(native: AV_CODEC_ID_LEAD)
    /// The DNXUC video codec.
    public static let dnxuc = Self(native: AV_CODEC_ID_DNXUC)
    /// The RV60 video codec.
    public static let rv60 = Self(native: AV_CODEC_ID_RV60)
    /// The JPEGXL_ANIM video codec.
    public static let jpegxlAnim = Self(native: AV_CODEC_ID_JPEGXL_ANIM)
    /// The APV video codec.
    public static let apv = Self(native: AV_CODEC_ID_APV)
    /// The PRORES_RAW video codec.
    public static let proresRaw = Self(native: AV_CODEC_ID_PRORES_RAW)
    /// The JPEGXS video codec.
    public static let jpegxs = Self(native: AV_CODEC_ID_JPEGXS)
    /// The WEBP_ANIM video codec.
    public static let webpAnim = Self(native: AV_CODEC_ID_WEBP_ANIM)

    // MARK: - PCM Audio Codecs

    /// The PCM_S16LE audio codec.
    public static let pcmS16le = Self(native: AV_CODEC_ID_PCM_S16LE)
    /// The PCM_S16BE audio codec.
    public static let pcmS16be = Self(native: AV_CODEC_ID_PCM_S16BE)
    /// The PCM_U16LE audio codec.
    public static let pcmU16le = Self(native: AV_CODEC_ID_PCM_U16LE)
    /// The PCM_U16BE audio codec.
    public static let pcmU16be = Self(native: AV_CODEC_ID_PCM_U16BE)
    /// The PCM_S8 audio codec.
    public static let pcmS8 = Self(native: AV_CODEC_ID_PCM_S8)
    /// The PCM_U8 audio codec.
    public static let pcmU8 = Self(native: AV_CODEC_ID_PCM_U8)
    /// The PCM_MULAW audio codec.
    public static let pcmMulaw = Self(native: AV_CODEC_ID_PCM_MULAW)
    /// The PCM_ALAW audio codec.
    public static let pcmAlaw = Self(native: AV_CODEC_ID_PCM_ALAW)
    /// The PCM_S32LE audio codec.
    public static let pcmS32le = Self(native: AV_CODEC_ID_PCM_S32LE)
    /// The PCM_S32BE audio codec.
    public static let pcmS32be = Self(native: AV_CODEC_ID_PCM_S32BE)
    /// The PCM_U32LE audio codec.
    public static let pcmU32le = Self(native: AV_CODEC_ID_PCM_U32LE)
    /// The PCM_U32BE audio codec.
    public static let pcmU32be = Self(native: AV_CODEC_ID_PCM_U32BE)
    /// The PCM_S24LE audio codec.
    public static let pcmS24le = Self(native: AV_CODEC_ID_PCM_S24LE)
    /// The PCM_S24BE audio codec.
    public static let pcmS24be = Self(native: AV_CODEC_ID_PCM_S24BE)
    /// The PCM_U24LE audio codec.
    public static let pcmU24le = Self(native: AV_CODEC_ID_PCM_U24LE)
    /// The PCM_U24BE audio codec.
    public static let pcmU24be = Self(native: AV_CODEC_ID_PCM_U24BE)
    /// The PCM_S24DAUD audio codec.
    public static let pcmS24daud = Self(native: AV_CODEC_ID_PCM_S24DAUD)
    /// The PCM_ZORK audio codec.
    public static let pcmZork = Self(native: AV_CODEC_ID_PCM_ZORK)
    /// The PCM_S16LE_PLANAR audio codec.
    public static let pcmS16lePlanar = Self(native: AV_CODEC_ID_PCM_S16LE_PLANAR)
    /// The PCM_DVD audio codec.
    public static let pcmDvd = Self(native: AV_CODEC_ID_PCM_DVD)
    /// The PCM_F32BE audio codec.
    public static let pcmF32be = Self(native: AV_CODEC_ID_PCM_F32BE)
    /// The PCM_F32LE audio codec.
    public static let pcmF32le = Self(native: AV_CODEC_ID_PCM_F32LE)
    /// The PCM_F64BE audio codec.
    public static let pcmF64be = Self(native: AV_CODEC_ID_PCM_F64BE)
    /// The PCM_F64LE audio codec.
    public static let pcmF64le = Self(native: AV_CODEC_ID_PCM_F64LE)
    /// The PCM_BLURAY audio codec.
    public static let pcmBluray = Self(native: AV_CODEC_ID_PCM_BLURAY)
    /// The PCM_LXF audio codec.
    public static let pcmLxf = Self(native: AV_CODEC_ID_PCM_LXF)
    /// The S302M audio codec.
    public static let s302m = Self(native: AV_CODEC_ID_S302M)
    /// The PCM_S8_PLANAR audio codec.
    public static let pcmS8Planar = Self(native: AV_CODEC_ID_PCM_S8_PLANAR)
    /// The PCM_S24LE_PLANAR audio codec.
    public static let pcmS24lePlanar = Self(native: AV_CODEC_ID_PCM_S24LE_PLANAR)
    /// The PCM_S32LE_PLANAR audio codec.
    public static let pcmS32lePlanar = Self(native: AV_CODEC_ID_PCM_S32LE_PLANAR)
    /// The PCM_S16BE_PLANAR audio codec.
    public static let pcmS16bePlanar = Self(native: AV_CODEC_ID_PCM_S16BE_PLANAR)
    /// The PCM_S64LE audio codec.
    public static let pcmS64le = Self(native: AV_CODEC_ID_PCM_S64LE)
    /// The PCM_S64BE audio codec.
    public static let pcmS64be = Self(native: AV_CODEC_ID_PCM_S64BE)
    /// The PCM_F16LE audio codec.
    public static let pcmF16le = Self(native: AV_CODEC_ID_PCM_F16LE)
    /// The PCM_F24LE audio codec.
    public static let pcmF24le = Self(native: AV_CODEC_ID_PCM_F24LE)
    /// The PCM_VIDC audio codec.
    public static let pcmVidc = Self(native: AV_CODEC_ID_PCM_VIDC)
    /// The PCM_SGA audio codec.
    public static let pcmSga = Self(native: AV_CODEC_ID_PCM_SGA)

    // MARK: - ADPCM Audio Codecs

    /// The ADPCM_IMA_QT audio codec.
    public static let adpcmImaQt = Self(native: AV_CODEC_ID_ADPCM_IMA_QT)
    /// The ADPCM_IMA_WAV audio codec.
    public static let adpcmImaWav = Self(native: AV_CODEC_ID_ADPCM_IMA_WAV)
    /// The ADPCM_IMA_DK3 audio codec.
    public static let adpcmImaDk3 = Self(native: AV_CODEC_ID_ADPCM_IMA_DK3)
    /// The ADPCM_IMA_DK4 audio codec.
    public static let adpcmImaDk4 = Self(native: AV_CODEC_ID_ADPCM_IMA_DK4)
    /// The ADPCM_IMA_WS audio codec.
    public static let adpcmImaWs = Self(native: AV_CODEC_ID_ADPCM_IMA_WS)
    /// The ADPCM_IMA_SMJPEG audio codec.
    public static let adpcmImaSmjpeg = Self(native: AV_CODEC_ID_ADPCM_IMA_SMJPEG)
    /// The ADPCM_MS audio codec.
    public static let adpcmMs = Self(native: AV_CODEC_ID_ADPCM_MS)
    /// The ADPCM_4XM audio codec.
    public static let adpcm4xm = Self(native: AV_CODEC_ID_ADPCM_4XM)
    /// The ADPCM_XA audio codec.
    public static let adpcmXa = Self(native: AV_CODEC_ID_ADPCM_XA)
    /// The ADPCM_ADX audio codec.
    public static let adpcmAdx = Self(native: AV_CODEC_ID_ADPCM_ADX)
    /// The ADPCM_EA audio codec.
    public static let adpcmEa = Self(native: AV_CODEC_ID_ADPCM_EA)
    /// The ADPCM_G726 audio codec.
    public static let adpcmG726 = Self(native: AV_CODEC_ID_ADPCM_G726)
    /// The ADPCM_CT audio codec.
    public static let adpcmCt = Self(native: AV_CODEC_ID_ADPCM_CT)
    /// The ADPCM_SWF audio codec.
    public static let adpcmSwf = Self(native: AV_CODEC_ID_ADPCM_SWF)
    /// The ADPCM_YAMAHA audio codec.
    public static let adpcmYamaha = Self(native: AV_CODEC_ID_ADPCM_YAMAHA)
    /// The ADPCM_SBPRO_4 audio codec.
    public static let adpcmSbpro4 = Self(native: AV_CODEC_ID_ADPCM_SBPRO_4)
    /// The ADPCM_SBPRO_3 audio codec.
    public static let adpcmSbpro3 = Self(native: AV_CODEC_ID_ADPCM_SBPRO_3)
    /// The ADPCM_SBPRO_2 audio codec.
    public static let adpcmSbpro2 = Self(native: AV_CODEC_ID_ADPCM_SBPRO_2)
    /// The ADPCM_THP audio codec.
    public static let adpcmThp = Self(native: AV_CODEC_ID_ADPCM_THP)
    /// The ADPCM_IMA_AMV audio codec.
    public static let adpcmImaAmv = Self(native: AV_CODEC_ID_ADPCM_IMA_AMV)
    /// The ADPCM_EA_R1 audio codec.
    public static let adpcmEaR1 = Self(native: AV_CODEC_ID_ADPCM_EA_R1)
    /// The ADPCM_EA_R3 audio codec.
    public static let adpcmEaR3 = Self(native: AV_CODEC_ID_ADPCM_EA_R3)
    /// The ADPCM_EA_R2 audio codec.
    public static let adpcmEaR2 = Self(native: AV_CODEC_ID_ADPCM_EA_R2)
    /// The ADPCM_IMA_EA_SEAD audio codec.
    public static let adpcmImaEaSead = Self(native: AV_CODEC_ID_ADPCM_IMA_EA_SEAD)
    /// The ADPCM_IMA_EA_EACS audio codec.
    public static let adpcmImaEaEacs = Self(native: AV_CODEC_ID_ADPCM_IMA_EA_EACS)
    /// The ADPCM_EA_XAS audio codec.
    public static let adpcmEaXas = Self(native: AV_CODEC_ID_ADPCM_EA_XAS)
    /// The ADPCM_EA_MAXIS_XA audio codec.
    public static let adpcmEaMaxisXa = Self(native: AV_CODEC_ID_ADPCM_EA_MAXIS_XA)
    /// The ADPCM_IMA_ISS audio codec.
    public static let adpcmImaIss = Self(native: AV_CODEC_ID_ADPCM_IMA_ISS)
    /// The ADPCM_G722 audio codec.
    public static let adpcmG722 = Self(native: AV_CODEC_ID_ADPCM_G722)
    /// The ADPCM_IMA_APC audio codec.
    public static let adpcmImaApc = Self(native: AV_CODEC_ID_ADPCM_IMA_APC)
    /// The ADPCM_VIMA audio codec.
    public static let adpcmVima = Self(native: AV_CODEC_ID_ADPCM_VIMA)
    /// The ADPCM_AFC audio codec.
    public static let adpcmAfc = Self(native: AV_CODEC_ID_ADPCM_AFC)
    /// The ADPCM_IMA_OKI audio codec.
    public static let adpcmImaOki = Self(native: AV_CODEC_ID_ADPCM_IMA_OKI)
    /// The ADPCM_DTK audio codec.
    public static let adpcmDtk = Self(native: AV_CODEC_ID_ADPCM_DTK)
    /// The ADPCM_IMA_RAD audio codec.
    public static let adpcmImaRad = Self(native: AV_CODEC_ID_ADPCM_IMA_RAD)
    /// The ADPCM_G726LE audio codec.
    public static let adpcmG726le = Self(native: AV_CODEC_ID_ADPCM_G726LE)
    /// The ADPCM_THP_LE audio codec.
    public static let adpcmThpLe = Self(native: AV_CODEC_ID_ADPCM_THP_LE)
    /// The ADPCM_PSX audio codec.
    public static let adpcmPsx = Self(native: AV_CODEC_ID_ADPCM_PSX)
    /// The ADPCM_AICA audio codec.
    public static let adpcmAica = Self(native: AV_CODEC_ID_ADPCM_AICA)
    /// The ADPCM_IMA_DAT4 audio codec.
    public static let adpcmImaDat4 = Self(native: AV_CODEC_ID_ADPCM_IMA_DAT4)
    /// The ADPCM_MTAF audio codec.
    public static let adpcmMtaf = Self(native: AV_CODEC_ID_ADPCM_MTAF)
    /// The ADPCM_AGM audio codec.
    public static let adpcmAgm = Self(native: AV_CODEC_ID_ADPCM_AGM)
    /// The ADPCM_ARGO audio codec.
    public static let adpcmArgo = Self(native: AV_CODEC_ID_ADPCM_ARGO)
    /// The ADPCM_IMA_SSI audio codec.
    public static let adpcmImaSsi = Self(native: AV_CODEC_ID_ADPCM_IMA_SSI)
    /// The ADPCM_ZORK audio codec.
    public static let adpcmZork = Self(native: AV_CODEC_ID_ADPCM_ZORK)
    /// The ADPCM_IMA_APM audio codec.
    public static let adpcmImaApm = Self(native: AV_CODEC_ID_ADPCM_IMA_APM)
    /// The ADPCM_IMA_ALP audio codec.
    public static let adpcmImaAlp = Self(native: AV_CODEC_ID_ADPCM_IMA_ALP)
    /// The ADPCM_IMA_MTF audio codec.
    public static let adpcmImaMtf = Self(native: AV_CODEC_ID_ADPCM_IMA_MTF)
    /// The ADPCM_IMA_CUNNING audio codec.
    public static let adpcmImaCunning = Self(native: AV_CODEC_ID_ADPCM_IMA_CUNNING)
    /// The ADPCM_IMA_MOFLEX audio codec.
    public static let adpcmImaMoflex = Self(native: AV_CODEC_ID_ADPCM_IMA_MOFLEX)
    /// The ADPCM_IMA_ACORN audio codec.
    public static let adpcmImaAcorn = Self(native: AV_CODEC_ID_ADPCM_IMA_ACORN)
    /// The ADPCM_XMD audio codec.
    public static let adpcmXmd = Self(native: AV_CODEC_ID_ADPCM_XMD)
    /// The ADPCM_IMA_XBOX audio codec.
    public static let adpcmImaXbox = Self(native: AV_CODEC_ID_ADPCM_IMA_XBOX)
    /// The ADPCM_SANYO audio codec.
    public static let adpcmSanyo = Self(native: AV_CODEC_ID_ADPCM_SANYO)
    /// The ADPCM_IMA_HVQM4 audio codec.
    public static let adpcmImaHvqm4 = Self(native: AV_CODEC_ID_ADPCM_IMA_HVQM4)
    /// The ADPCM_IMA_PDA audio codec.
    public static let adpcmImaPda = Self(native: AV_CODEC_ID_ADPCM_IMA_PDA)
    /// The ADPCM_N64 audio codec.
    public static let adpcmN64 = Self(native: AV_CODEC_ID_ADPCM_N64)
    /// The ADPCM_IMA_HVQM2 audio codec.
    public static let adpcmImaHvqm2 = Self(native: AV_CODEC_ID_ADPCM_IMA_HVQM2)
    /// The ADPCM_IMA_MAGIX audio codec.
    public static let adpcmImaMagix = Self(native: AV_CODEC_ID_ADPCM_IMA_MAGIX)
    /// The ADPCM_PSXC audio codec.
    public static let adpcmPsxc = Self(native: AV_CODEC_ID_ADPCM_PSXC)
    /// The ADPCM_CIRCUS audio codec.
    public static let adpcmCircus = Self(native: AV_CODEC_ID_ADPCM_CIRCUS)
    /// The ADPCM_IMA_ESCAPE audio codec.
    public static let adpcmImaEscape = Self(native: AV_CODEC_ID_ADPCM_IMA_ESCAPE)

    // MARK: - AMR Audio Codecs

    /// The AMR_NB audio codec.
    public static let amrNb = Self(native: AV_CODEC_ID_AMR_NB)
    /// The AMR_WB audio codec.
    public static let amrWb = Self(native: AV_CODEC_ID_AMR_WB)

    // MARK: - RealAudio Codecs

    /// The RA_144 audio codec.
    public static let ra144 = Self(native: AV_CODEC_ID_RA_144)
    /// The RA_288 audio codec.
    public static let ra288 = Self(native: AV_CODEC_ID_RA_288)

    // MARK: - DPCM Audio Codecs

    /// The ROQ_DPCM audio codec.
    public static let roqDpcm = Self(native: AV_CODEC_ID_ROQ_DPCM)
    /// The INTERPLAY_DPCM audio codec.
    public static let interplayDpcm = Self(native: AV_CODEC_ID_INTERPLAY_DPCM)
    /// The XAN_DPCM audio codec.
    public static let xanDpcm = Self(native: AV_CODEC_ID_XAN_DPCM)
    /// The SOL_DPCM audio codec.
    public static let solDpcm = Self(native: AV_CODEC_ID_SOL_DPCM)
    /// The SDX2_DPCM audio codec.
    public static let sdx2Dpcm = Self(native: AV_CODEC_ID_SDX2_DPCM)
    /// The GREMLIN_DPCM audio codec.
    public static let gremlinDpcm = Self(native: AV_CODEC_ID_GREMLIN_DPCM)
    /// The DERF_DPCM audio codec.
    public static let derfDpcm = Self(native: AV_CODEC_ID_DERF_DPCM)
    /// The WADY_DPCM audio codec.
    public static let wadyDpcm = Self(native: AV_CODEC_ID_WADY_DPCM)
    /// The CBD2_DPCM audio codec.
    public static let cbd2Dpcm = Self(native: AV_CODEC_ID_CBD2_DPCM)

    // MARK: - Audio Codecs

    /// The MP2 audio codec.
    public static let mp2 = Self(native: AV_CODEC_ID_MP2)
    /// The MP3 audio codec.
    public static let mp3 = Self(native: AV_CODEC_ID_MP3)
    /// The AAC audio codec.
    public static let aac = Self(native: AV_CODEC_ID_AAC)
    /// The AC3 audio codec.
    public static let ac3 = Self(native: AV_CODEC_ID_AC3)
    /// The DTS audio codec.
    public static let dts = Self(native: AV_CODEC_ID_DTS)
    /// The VORBIS audio codec.
    public static let vorbis = Self(native: AV_CODEC_ID_VORBIS)
    /// The DVAUDIO audio codec.
    public static let dvaudio = Self(native: AV_CODEC_ID_DVAUDIO)
    /// The WMAV1 audio codec.
    public static let wmav1 = Self(native: AV_CODEC_ID_WMAV1)
    /// The WMAV2 audio codec.
    public static let wmav2 = Self(native: AV_CODEC_ID_WMAV2)
    /// The MACE3 audio codec.
    public static let mace3 = Self(native: AV_CODEC_ID_MACE3)
    /// The MACE6 audio codec.
    public static let mace6 = Self(native: AV_CODEC_ID_MACE6)
    /// The VMDAUDIO audio codec.
    public static let vmdaudio = Self(native: AV_CODEC_ID_VMDAUDIO)
    /// The FLAC audio codec.
    public static let flac = Self(native: AV_CODEC_ID_FLAC)
    /// The MP3ADU audio codec.
    public static let mp3adu = Self(native: AV_CODEC_ID_MP3ADU)
    /// The MP3ON4 audio codec.
    public static let mp3on4 = Self(native: AV_CODEC_ID_MP3ON4)
    /// The SHORTEN audio codec.
    public static let shorten = Self(native: AV_CODEC_ID_SHORTEN)
    /// The ALAC audio codec.
    public static let alac = Self(native: AV_CODEC_ID_ALAC)
    /// The WESTWOOD_SND1 audio codec.
    public static let westwoodSnd1 = Self(native: AV_CODEC_ID_WESTWOOD_SND1)
    /// The GSM audio codec.
    public static let gsm = Self(native: AV_CODEC_ID_GSM)
    /// The QDM2 audio codec.
    public static let qdm2 = Self(native: AV_CODEC_ID_QDM2)
    /// The COOK audio codec.
    public static let cook = Self(native: AV_CODEC_ID_COOK)
    /// The TRUESPEECH audio codec.
    public static let truespeech = Self(native: AV_CODEC_ID_TRUESPEECH)
    /// The TTA audio codec.
    public static let tta = Self(native: AV_CODEC_ID_TTA)
    /// The SMACKAUDIO audio codec.
    public static let smackaudio = Self(native: AV_CODEC_ID_SMACKAUDIO)
    /// The QCELP audio codec.
    public static let qcelp = Self(native: AV_CODEC_ID_QCELP)
    /// The WAVPACK audio codec.
    public static let wavpack = Self(native: AV_CODEC_ID_WAVPACK)
    /// The DSICINAUDIO audio codec.
    public static let dsicinaudio = Self(native: AV_CODEC_ID_DSICINAUDIO)
    /// The IMC audio codec.
    public static let imc = Self(native: AV_CODEC_ID_IMC)
    /// The MUSEPACK7 audio codec.
    public static let musepack7 = Self(native: AV_CODEC_ID_MUSEPACK7)
    /// The MLP audio codec.
    public static let mlp = Self(native: AV_CODEC_ID_MLP)
    /// The GSM_MS audio codec.
    public static let gsmMs = Self(native: AV_CODEC_ID_GSM_MS)
    /// The ATRAC3 audio codec.
    public static let atrac3 = Self(native: AV_CODEC_ID_ATRAC3)
    /// The APE audio codec.
    public static let ape = Self(native: AV_CODEC_ID_APE)
    /// The NELLYMOSER audio codec.
    public static let nellymoser = Self(native: AV_CODEC_ID_NELLYMOSER)
    /// The MUSEPACK8 audio codec.
    public static let musepack8 = Self(native: AV_CODEC_ID_MUSEPACK8)
    /// The SPEEX audio codec.
    public static let speex = Self(native: AV_CODEC_ID_SPEEX)
    /// The WMAVOICE audio codec.
    public static let wmavoice = Self(native: AV_CODEC_ID_WMAVOICE)
    /// The WMAPRO audio codec.
    public static let wmapro = Self(native: AV_CODEC_ID_WMAPRO)
    /// The WMALOSSLESS audio codec.
    public static let wmalossless = Self(native: AV_CODEC_ID_WMALOSSLESS)
    /// The ATRAC3P audio codec.
    public static let atrac3p = Self(native: AV_CODEC_ID_ATRAC3P)
    /// The EAC3 audio codec.
    public static let eac3 = Self(native: AV_CODEC_ID_EAC3)
    /// The SIPR audio codec.
    public static let sipr = Self(native: AV_CODEC_ID_SIPR)
    /// The MP1 audio codec.
    public static let mp1 = Self(native: AV_CODEC_ID_MP1)
    /// The TWINVQ audio codec.
    public static let twinvq = Self(native: AV_CODEC_ID_TWINVQ)
    /// The TRUEHD audio codec.
    public static let truehd = Self(native: AV_CODEC_ID_TRUEHD)
    /// The MP4ALS audio codec.
    public static let mp4als = Self(native: AV_CODEC_ID_MP4ALS)
    /// The ATRAC1 audio codec.
    public static let atrac1 = Self(native: AV_CODEC_ID_ATRAC1)
    /// The BINKAUDIO_RDFT audio codec.
    public static let binkaudioRdft = Self(native: AV_CODEC_ID_BINKAUDIO_RDFT)
    /// The BINKAUDIO_DCT audio codec.
    public static let binkaudioDct = Self(native: AV_CODEC_ID_BINKAUDIO_DCT)
    /// The AAC_LATM audio codec.
    public static let aacLatm = Self(native: AV_CODEC_ID_AAC_LATM)
    /// The QDMC audio codec.
    public static let qdmc = Self(native: AV_CODEC_ID_QDMC)
    /// The CELT audio codec.
    public static let celt = Self(native: AV_CODEC_ID_CELT)
    /// The G723_1 audio codec.
    public static let g7231 = Self(native: AV_CODEC_ID_G723_1)
    /// The G729 audio codec.
    public static let g729 = Self(native: AV_CODEC_ID_G729)
    /// The 8SVX_EXP audio codec.
    public static let c8svxExp = Self(native: AV_CODEC_ID_8SVX_EXP)
    /// The 8SVX_FIB audio codec.
    public static let c8svxFib = Self(native: AV_CODEC_ID_8SVX_FIB)
    /// The BMV_AUDIO audio codec.
    public static let bmvAudio = Self(native: AV_CODEC_ID_BMV_AUDIO)
    /// The RALF audio codec.
    public static let ralf = Self(native: AV_CODEC_ID_RALF)
    /// The IAC audio codec.
    public static let iac = Self(native: AV_CODEC_ID_IAC)
    /// The ILBC audio codec.
    public static let ilbc = Self(native: AV_CODEC_ID_ILBC)
    /// The OPUS audio codec.
    public static let opus = Self(native: AV_CODEC_ID_OPUS)
    /// The COMFORT_NOISE audio codec.
    public static let comfortNoise = Self(native: AV_CODEC_ID_COMFORT_NOISE)
    /// The TAK audio codec.
    public static let tak = Self(native: AV_CODEC_ID_TAK)
    /// The METASOUND audio codec.
    public static let metasound = Self(native: AV_CODEC_ID_METASOUND)
    /// The PAF_AUDIO audio codec.
    public static let pafAudio = Self(native: AV_CODEC_ID_PAF_AUDIO)
    /// The ON2AVC audio codec.
    public static let on2avc = Self(native: AV_CODEC_ID_ON2AVC)
    /// The DSS_SP audio codec.
    public static let dssSp = Self(native: AV_CODEC_ID_DSS_SP)
    /// The CODEC2 audio codec.
    public static let codec2 = Self(native: AV_CODEC_ID_CODEC2)
    /// The FFWAVESYNTH audio codec.
    public static let ffwavesynth = Self(native: AV_CODEC_ID_FFWAVESYNTH)
    /// The SONIC audio codec.
    public static let sonic = Self(native: AV_CODEC_ID_SONIC)
    /// The SONIC_LS audio codec.
    public static let sonicLs = Self(native: AV_CODEC_ID_SONIC_LS)
    /// The EVRC audio codec.
    public static let evrc = Self(native: AV_CODEC_ID_EVRC)
    /// The SMV audio codec.
    public static let smv = Self(native: AV_CODEC_ID_SMV)
    /// The DSD_LSBF audio codec.
    public static let dsdLsbf = Self(native: AV_CODEC_ID_DSD_LSBF)
    /// The DSD_MSBF audio codec.
    public static let dsdMsbf = Self(native: AV_CODEC_ID_DSD_MSBF)
    /// The DSD_LSBF_PLANAR audio codec.
    public static let dsdLsbfPlanar = Self(native: AV_CODEC_ID_DSD_LSBF_PLANAR)
    /// The DSD_MSBF_PLANAR audio codec.
    public static let dsdMsbfPlanar = Self(native: AV_CODEC_ID_DSD_MSBF_PLANAR)
    /// The 4GV audio codec.
    public static let c4gv = Self(native: AV_CODEC_ID_4GV)
    /// The INTERPLAY_ACM audio codec.
    public static let interplayAcm = Self(native: AV_CODEC_ID_INTERPLAY_ACM)
    /// The XMA1 audio codec.
    public static let xma1 = Self(native: AV_CODEC_ID_XMA1)
    /// The XMA2 audio codec.
    public static let xma2 = Self(native: AV_CODEC_ID_XMA2)
    /// The DST audio codec.
    public static let dst = Self(native: AV_CODEC_ID_DST)
    /// The ATRAC3AL audio codec.
    public static let atrac3al = Self(native: AV_CODEC_ID_ATRAC3AL)
    /// The ATRAC3PAL audio codec.
    public static let atrac3pal = Self(native: AV_CODEC_ID_ATRAC3PAL)
    /// The DOLBY_E audio codec.
    public static let dolbyE = Self(native: AV_CODEC_ID_DOLBY_E)
    /// The APTX audio codec.
    public static let aptx = Self(native: AV_CODEC_ID_APTX)
    /// The APTX_HD audio codec.
    public static let aptxHd = Self(native: AV_CODEC_ID_APTX_HD)
    /// The SBC audio codec.
    public static let sbc = Self(native: AV_CODEC_ID_SBC)
    /// The ATRAC9 audio codec.
    public static let atrac9 = Self(native: AV_CODEC_ID_ATRAC9)
    /// The HCOM audio codec.
    public static let hcom = Self(native: AV_CODEC_ID_HCOM)
    /// The ACELP_KELVIN audio codec.
    public static let acelpKelvin = Self(native: AV_CODEC_ID_ACELP_KELVIN)
    /// The MPEGH_3D_AUDIO audio codec.
    public static let mpegh3dAudio = Self(native: AV_CODEC_ID_MPEGH_3D_AUDIO)
    /// The SIREN audio codec.
    public static let siren = Self(native: AV_CODEC_ID_SIREN)
    /// The HCA audio codec.
    public static let hca = Self(native: AV_CODEC_ID_HCA)
    /// The FASTAUDIO audio codec.
    public static let fastaudio = Self(native: AV_CODEC_ID_FASTAUDIO)
    /// The MSNSIREN audio codec.
    public static let msnsiren = Self(native: AV_CODEC_ID_MSNSIREN)
    /// The DFPWM audio codec.
    public static let dfpwm = Self(native: AV_CODEC_ID_DFPWM)
    /// The BONK audio codec.
    public static let bonk = Self(native: AV_CODEC_ID_BONK)
    /// The MISC4 audio codec.
    public static let misc4 = Self(native: AV_CODEC_ID_MISC4)
    /// The APAC audio codec.
    public static let apac = Self(native: AV_CODEC_ID_APAC)
    /// The FTR audio codec.
    public static let ftr = Self(native: AV_CODEC_ID_FTR)
    /// The WAVARC audio codec.
    public static let wavarc = Self(native: AV_CODEC_ID_WAVARC)
    /// The RKA audio codec.
    public static let rka = Self(native: AV_CODEC_ID_RKA)
    /// The AC4 audio codec.
    public static let ac4 = Self(native: AV_CODEC_ID_AC4)
    /// The OSQ audio codec.
    public static let osq = Self(native: AV_CODEC_ID_OSQ)
    /// The QOA audio codec.
    public static let qoa = Self(native: AV_CODEC_ID_QOA)
    /// The LC3 audio codec.
    public static let lc3 = Self(native: AV_CODEC_ID_LC3)
    /// The G728 audio codec.
    public static let g728 = Self(native: AV_CODEC_ID_G728)
    /// The AHX audio codec.
    public static let ahx = Self(native: AV_CODEC_ID_AHX)
    /// The APPLE_APAC audio codec.
    public static let appleApac = Self(native: AV_CODEC_ID_APPLE_APAC)

    // MARK: - Subtitle Codecs

    /// The DVD_SUBTITLE subtitle codec.
    public static let dvdSubtitle = Self(native: AV_CODEC_ID_DVD_SUBTITLE)
    /// The DVB_SUBTITLE subtitle codec.
    public static let dvbSubtitle = Self(native: AV_CODEC_ID_DVB_SUBTITLE)
    /// The TEXT subtitle codec.
    public static let text = Self(native: AV_CODEC_ID_TEXT)
    /// The XSUB subtitle codec.
    public static let xsub = Self(native: AV_CODEC_ID_XSUB)
    /// The SSA subtitle codec.
    public static let ssa = Self(native: AV_CODEC_ID_SSA)
    /// The MOV_TEXT subtitle codec.
    public static let movText = Self(native: AV_CODEC_ID_MOV_TEXT)
    /// The HDMV_PGS_SUBTITLE subtitle codec.
    public static let hdmvPgsSubtitle = Self(native: AV_CODEC_ID_HDMV_PGS_SUBTITLE)
    /// The DVB_TELETEXT subtitle codec.
    public static let dvbTeletext = Self(native: AV_CODEC_ID_DVB_TELETEXT)
    /// The SRT subtitle codec.
    public static let srt = Self(native: AV_CODEC_ID_SRT)
    /// The MICRODVD subtitle codec.
    public static let microdvd = Self(native: AV_CODEC_ID_MICRODVD)
    /// The EIA_608 subtitle codec.
    public static let eia608 = Self(native: AV_CODEC_ID_EIA_608)
    /// The JACOSUB subtitle codec.
    public static let jacosub = Self(native: AV_CODEC_ID_JACOSUB)
    /// The SAMI subtitle codec.
    public static let sami = Self(native: AV_CODEC_ID_SAMI)
    /// The REALTEXT subtitle codec.
    public static let realtext = Self(native: AV_CODEC_ID_REALTEXT)
    /// The STL subtitle codec.
    public static let stl = Self(native: AV_CODEC_ID_STL)
    /// The SUBVIEWER1 subtitle codec.
    public static let subviewer1 = Self(native: AV_CODEC_ID_SUBVIEWER1)
    /// The SUBVIEWER subtitle codec.
    public static let subviewer = Self(native: AV_CODEC_ID_SUBVIEWER)
    /// The SUBRIP subtitle codec.
    public static let subrip = Self(native: AV_CODEC_ID_SUBRIP)
    /// The WEBVTT subtitle codec.
    public static let webvtt = Self(native: AV_CODEC_ID_WEBVTT)
    /// The MPL2 subtitle codec.
    public static let mpl2 = Self(native: AV_CODEC_ID_MPL2)
    /// The VPLAYER subtitle codec.
    public static let vplayer = Self(native: AV_CODEC_ID_VPLAYER)
    /// The PJS subtitle codec.
    public static let pjs = Self(native: AV_CODEC_ID_PJS)
    /// The ASS subtitle codec.
    public static let ass = Self(native: AV_CODEC_ID_ASS)
    /// The HDMV_TEXT_SUBTITLE subtitle codec.
    public static let hdmvTextSubtitle = Self(native: AV_CODEC_ID_HDMV_TEXT_SUBTITLE)
    /// The TTML subtitle codec.
    public static let ttml = Self(native: AV_CODEC_ID_TTML)
    /// The ARIB_CAPTION subtitle codec.
    public static let aribCaption = Self(native: AV_CODEC_ID_ARIB_CAPTION)
    /// The IVTV_VBI subtitle codec.
    public static let ivtvVbi = Self(native: AV_CODEC_ID_IVTV_VBI)

    // MARK: - Data and Attachment Codecs

    /// The TTF data codec.
    public static let ttf = Self(native: AV_CODEC_ID_TTF)
    /// The SCTE_35 data codec.
    public static let scte35 = Self(native: AV_CODEC_ID_SCTE_35)
    /// The EPG data codec.
    public static let epg = Self(native: AV_CODEC_ID_EPG)
    /// The BINTEXT data codec.
    public static let bintext = Self(native: AV_CODEC_ID_BINTEXT)
    /// The XBIN data codec.
    public static let xbin = Self(native: AV_CODEC_ID_XBIN)
    /// The IDF data codec.
    public static let idf = Self(native: AV_CODEC_ID_IDF)
    /// The OTF data codec.
    public static let otf = Self(native: AV_CODEC_ID_OTF)
    /// The SMPTE_KLV data codec.
    public static let smpteKlv = Self(native: AV_CODEC_ID_SMPTE_KLV)
    /// The DVD_NAV data codec.
    public static let dvdNav = Self(native: AV_CODEC_ID_DVD_NAV)
    /// The TIMED_ID3 data codec.
    public static let timedId3 = Self(native: AV_CODEC_ID_TIMED_ID3)
    /// The BIN_DATA data codec.
    public static let binData = Self(native: AV_CODEC_ID_BIN_DATA)
    /// The SMPTE_2038 data codec.
    public static let smpte2038 = Self(native: AV_CODEC_ID_SMPTE_2038)
    /// The LCEVC data codec.
    public static let lcevc = Self(native: AV_CODEC_ID_LCEVC)
    /// The SMPTE_436M_ANC data codec.
    public static let smpte436mAnc = Self(native: AV_CODEC_ID_SMPTE_436M_ANC)

    // MARK: - Special and Pseudo Codecs

    /// The PROBE codec.
    public static let probe = Self(native: AV_CODEC_ID_PROBE)
    /// The MPEG2TS codec.
    public static let mpeg2ts = Self(native: AV_CODEC_ID_MPEG2TS)
    /// The MPEG4SYSTEMS codec.
    public static let mpeg4systems = Self(native: AV_CODEC_ID_MPEG4SYSTEMS)
    /// The FFMETADATA codec.
    public static let ffmetadata = Self(native: AV_CODEC_ID_FFMETADATA)
    /// The WRAPPED_AVFRAME codec.
    public static let wrappedAvframe = Self(native: AV_CODEC_ID_WRAPPED_AVFRAME)
    /// The VNULL codec.
    public static let vnull = Self(native: AV_CODEC_ID_VNULL)
    /// The ANULL codec.
    public static let anull = Self(native: AV_CODEC_ID_ANULL)
}
