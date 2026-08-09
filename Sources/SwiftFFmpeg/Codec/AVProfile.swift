//
//  AVProfile.swift
//  SwiftFFmpeg
//
//  Created by Florian Zand on 07.08.26.
//

import Foundation
import CFFmpeg

public struct AVProfile: RawRepresentable, Hashable, CustomStringConvertible, ExpressibleByIntegerLiteral {
    public let rawValue: Int32

    public init(rawValue: Int32) {
        self.rawValue = rawValue
    }
    
    public init(integerLiteral value: Int32) {
        self.rawValue = value
    }

    public var description: String {
        "\(rawValue)"
    }
}

public struct AVNamedProfile: Hashable, CustomStringConvertible {
    /// The profile value.
    public let profile: AVProfile

    /// The profile name.
    public let name: String

    init(native: CFFmpeg.AVProfile) {
        self.profile = AVProfile(rawValue: native.profile)
        self.name = native.name.string
    }
    
    init(name: String, profile: AVProfile) {
        self.name = name
        self.profile = profile
    }

    public var description: String {
        name
    }
}

public extension AVProfile {
    /// An unknown codec profile.
    static let unknown = Self(rawValue: AV_PROFILE_UNKNOWN)
    /// A reserved codec profile.
    static let reserved = Self(rawValue: AV_PROFILE_RESERVED)

    /// Advanced Audio Coding (AAC) profiles.
    enum AAC {
        /// The AAC Main profile.
        public static let main = AVProfile(rawValue: AV_PROFILE_AAC_MAIN)
        /// The AAC Low Complexity (LC) profile.
        public static let low = AVProfile(rawValue: AV_PROFILE_AAC_LOW)
        /// The AAC Scalable Sample Rate (SSR) profile.
        public static let ssr = AVProfile(rawValue: AV_PROFILE_AAC_SSR)
        /// The AAC Long Term Prediction (LTP) profile.
        public static let ltp = AVProfile(rawValue: AV_PROFILE_AAC_LTP)
        /// The AAC High Efficiency (HE-AAC) profile.
        public static let highEfficiency = AVProfile(rawValue: AV_PROFILE_AAC_HE)
        /// The AAC High Efficiency v2 (HE-AAC v2) profile.
        public static let highEfficiencyV2 = AVProfile(rawValue: AV_PROFILE_AAC_HE_V2)
        /// The AAC Low Delay (LD) profile.
        public static let lowDelay = AVProfile(rawValue: AV_PROFILE_AAC_LD)
        /// The AAC Enhanced Low Delay (ELD) profile.
        public static let enhancedLowDelay = AVProfile(rawValue: AV_PROFILE_AAC_ELD)
        /// The AAC Unified Speech and Audio Coding (USAC) profile.
        public static let usac = AVProfile(rawValue: AV_PROFILE_AAC_USAC)
    }

    /// MPEG-2 AAC profiles.
    enum MPEG2AAC {
        /// The MPEG-2 AAC Low Complexity profile.
        public static let low = AVProfile(rawValue: AV_PROFILE_MPEG2_AAC_LOW)
        /// The MPEG-2 AAC High Efficiency profile.
        public static let highEfficiency = AVProfile(rawValue: AV_PROFILE_MPEG2_AAC_HE)
    }

    /// DNxHD and DNxHR profiles.
    enum DNxHR {
        /// The DNxHR Low Bandwidth profile.
        public static let lowBandwidth = AVProfile(rawValue: AV_PROFILE_DNXHR_LB)
        /// The DNxHR Standard Quality profile.
        public static let standardQuality = AVProfile(rawValue: AV_PROFILE_DNXHR_SQ)
        /// The DNxHR High Quality profile.
        public static let highQuality = AVProfile(rawValue: AV_PROFILE_DNXHR_HQ)
        /// The DNxHR High Quality Extended profile.
        public static let highQualityExtended = AVProfile(rawValue: AV_PROFILE_DNXHR_HQX)
        /// The DNxHR 4:4:4 profile.
        public static let profile444 = AVProfile(rawValue: AV_PROFILE_DNXHR_444)
    }

    /// DNxHD profile.
    enum DNxHD {
        /// The DNxHD profile.
        public static let standard = AVProfile(rawValue: AV_PROFILE_DNXHD)
    }

    /// DTS audio profiles.
    enum DTS {
        /// The DTS profile.
        public static let standard = AVProfile(rawValue: AV_PROFILE_DTS)
        /// The DTS-ES profile.
        public static let extendedSurround = AVProfile(rawValue: AV_PROFILE_DTS_ES)
        /// The DTS 96/24 profile.
        public static let profile96_24 = AVProfile(rawValue: AV_PROFILE_DTS_96_24)
        /// The DTS-HD High Resolution Audio profile.
        public static let hdHighResolutionAudio = AVProfile(rawValue: AV_PROFILE_DTS_HD_HRA)
        /// The DTS-HD Master Audio profile.
        public static let hdMasterAudio = AVProfile(rawValue: AV_PROFILE_DTS_HD_MA)
        /// The DTS Express profile.
        public static let express = AVProfile(rawValue: AV_PROFILE_DTS_EXPRESS)
        /// The DTS-HD Master Audio X profile.
        public static let hdMasterAudioX = AVProfile(rawValue: AV_PROFILE_DTS_HD_MA_X)
        /// The DTS-HD Master Audio X IMAX profile.
        public static let hdMasterAudioXImax = AVProfile(rawValue: AV_PROFILE_DTS_HD_MA_X_IMAX)
    }

    /// Enhanced AC-3 profiles.
    enum EAC3 {
        /// The Dolby Digital Plus with Dolby Atmos profile.
        public static let dolbyDigitalPlusAtmos = AVProfile(rawValue: AV_PROFILE_EAC3_DDP_ATMOS)
    }

    /// Dolby TrueHD profiles.
    enum TrueHD {
        /// The Dolby TrueHD with Dolby Atmos profile.
        public static let atmos = AVProfile(rawValue: AV_PROFILE_TRUEHD_ATMOS)
    }

    /// MPEG-2 video profiles.
    enum MPEG2 {
        /// The MPEG-2 4:2:2 profile.
        public static let profile422 = AVProfile(rawValue: AV_PROFILE_MPEG2_422)
        /// The MPEG-2 High profile.
        public static let high = AVProfile(rawValue: AV_PROFILE_MPEG2_HIGH)
        /// The MPEG-2 Spatially Scalable profile.
        public static let spatiallyScalable = AVProfile(rawValue: AV_PROFILE_MPEG2_SS)
        /// The MPEG-2 SNR Scalable profile.
        public static let snrScalable = AVProfile(rawValue: AV_PROFILE_MPEG2_SNR_SCALABLE)
        /// The MPEG-2 Main profile.
        public static let main = AVProfile(rawValue: AV_PROFILE_MPEG2_MAIN)
        /// The MPEG-2 Simple profile.
        public static let simple = AVProfile(rawValue: AV_PROFILE_MPEG2_SIMPLE)
    }

    /// H.264/AVC video profiles.
    enum H264 {
        /// The H.264 Baseline profile.
        public static let baseline = AVProfile(rawValue: AV_PROFILE_H264_BASELINE)
        /// The H.264 Constrained Baseline profile.
        public static let constrainedBaseline = AVProfile(rawValue: AV_PROFILE_H264_CONSTRAINED_BASELINE)
        /// The H.264 Main profile.
        public static let main = AVProfile(rawValue: AV_PROFILE_H264_MAIN)
        /// The H.264 Extended profile.
        public static let extended = AVProfile(rawValue: AV_PROFILE_H264_EXTENDED)
        /// The H.264 High profile.
        public static let high = AVProfile(rawValue: AV_PROFILE_H264_HIGH)
        /// The H.264 High 10 profile.
        public static let high10 = AVProfile(rawValue: AV_PROFILE_H264_HIGH_10)
        /// The H.264 High 10 Intra profile.
        public static let high10Intra = AVProfile(rawValue: AV_PROFILE_H264_HIGH_10_INTRA)
        /// The H.264 Multiview High profile.
        public static let multiviewHigh = AVProfile(rawValue: AV_PROFILE_H264_MULTIVIEW_HIGH)
        /// The H.264 High 4:2:2 profile.
        public static let high422 = AVProfile(rawValue: AV_PROFILE_H264_HIGH_422)
        /// The H.264 High 4:2:2 Intra profile.
        public static let high422Intra = AVProfile(rawValue: AV_PROFILE_H264_HIGH_422_INTRA)
        /// The H.264 Stereo High profile.
        public static let stereoHigh = AVProfile(rawValue: AV_PROFILE_H264_STEREO_HIGH)
        /// The H.264 High 4:4:4 profile.
        public static let high444 = AVProfile(rawValue: AV_PROFILE_H264_HIGH_444)
        /// The H.264 High 4:4:4 Predictive profile.
        public static let high444Predictive = AVProfile(rawValue: AV_PROFILE_H264_HIGH_444_PREDICTIVE)
        /// The H.264 High 4:4:4 Intra profile.
        public static let high444Intra = AVProfile(rawValue: AV_PROFILE_H264_HIGH_444_INTRA)
        /// The H.264 CAVLC 4:4:4 profile.
        public static let cavlc444 = AVProfile(rawValue: AV_PROFILE_H264_CAVLC_444)
    }

    /// VC-1 video profiles.
    enum VC1 {
        /// The VC-1 Simple profile.
        public static let simple = AVProfile(rawValue: AV_PROFILE_VC1_SIMPLE)
        /// The VC-1 Main profile.
        public static let main = AVProfile(rawValue: AV_PROFILE_VC1_MAIN)
        /// The VC-1 Complex profile.
        public static let complex = AVProfile(rawValue: AV_PROFILE_VC1_COMPLEX)
        /// The VC-1 Advanced profile.
        public static let advanced = AVProfile(rawValue: AV_PROFILE_VC1_ADVANCED)
    }

    /// MPEG-4 Part 2 video profiles.
    enum MPEG4 {
        /// The MPEG-4 Simple profile.
        public static let simple = AVProfile(rawValue: AV_PROFILE_MPEG4_SIMPLE)
        /// The MPEG-4 Simple Scalable profile.
        public static let simpleScalable = AVProfile(rawValue: AV_PROFILE_MPEG4_SIMPLE_SCALABLE)
        /// The MPEG-4 Core profile.
        public static let core = AVProfile(rawValue: AV_PROFILE_MPEG4_CORE)
        /// The MPEG-4 Main profile.
        public static let main = AVProfile(rawValue: AV_PROFILE_MPEG4_MAIN)
        /// The MPEG-4 N-bit profile.
        public static let nBit = AVProfile(rawValue: AV_PROFILE_MPEG4_N_BIT)
        /// The MPEG-4 Scalable Texture profile.
        public static let scalableTexture = AVProfile(rawValue: AV_PROFILE_MPEG4_SCALABLE_TEXTURE)
        /// The MPEG-4 Simple Face Animation profile.
        public static let simpleFaceAnimation = AVProfile(rawValue: AV_PROFILE_MPEG4_SIMPLE_FACE_ANIMATION)
        /// The MPEG-4 Basic Animated Texture profile.
        public static let basicAnimatedTexture = AVProfile(rawValue: AV_PROFILE_MPEG4_BASIC_ANIMATED_TEXTURE)
        /// The MPEG-4 Hybrid profile.
        public static let hybrid = AVProfile(rawValue: AV_PROFILE_MPEG4_HYBRID)
        /// The MPEG-4 Advanced Real Time profile.
        public static let advancedRealTime = AVProfile(rawValue: AV_PROFILE_MPEG4_ADVANCED_REAL_TIME)
        /// The MPEG-4 Core Scalable profile.
        public static let coreScalable = AVProfile(rawValue: AV_PROFILE_MPEG4_CORE_SCALABLE)
        /// The MPEG-4 Advanced Coding profile.
        public static let advancedCoding = AVProfile(rawValue: AV_PROFILE_MPEG4_ADVANCED_CODING)
        /// The MPEG-4 Advanced Core profile.
        public static let advancedCore = AVProfile(rawValue: AV_PROFILE_MPEG4_ADVANCED_CORE)
        /// The MPEG-4 Advanced Scalable Texture profile.
        public static let advancedScalableTexture = AVProfile(rawValue: AV_PROFILE_MPEG4_ADVANCED_SCALABLE_TEXTURE)
        /// The MPEG-4 Simple Studio profile.
        public static let simpleStudio = AVProfile(rawValue: AV_PROFILE_MPEG4_SIMPLE_STUDIO)
        /// The MPEG-4 Advanced Simple profile.
        public static let advancedSimple = AVProfile(rawValue: AV_PROFILE_MPEG4_ADVANCED_SIMPLE)
    }

    /// JPEG 2000 profiles.
    enum JPEG2000 {
        /// The JPEG 2000 codestream restriction level 0 profile.
        public static let codestreamRestriction0 = AVProfile(rawValue: AV_PROFILE_JPEG2000_CSTREAM_RESTRICTION_0)
        /// The JPEG 2000 codestream restriction level 1 profile.
        public static let codestreamRestriction1 = AVProfile(rawValue: AV_PROFILE_JPEG2000_CSTREAM_RESTRICTION_1)
        /// The JPEG 2000 unrestricted codestream profile.
        public static let unrestrictedCodestream = AVProfile(rawValue: AV_PROFILE_JPEG2000_CSTREAM_NO_RESTRICTION)
        /// The JPEG 2000 Digital Cinema 2K profile.
        public static let digitalCinema2K = AVProfile(rawValue: AV_PROFILE_JPEG2000_DCINEMA_2K)
        /// The JPEG 2000 Digital Cinema 4K profile.
        public static let digitalCinema4K = AVProfile(rawValue: AV_PROFILE_JPEG2000_DCINEMA_4K)
    }

    /// VP9 video profiles.
    enum VP9 {
        /// The VP9 Profile 0.
        public static let profile0 = AVProfile(rawValue: AV_PROFILE_VP9_0)
        /// The VP9 Profile 1.
        public static let profile1 = AVProfile(rawValue: AV_PROFILE_VP9_1)
        /// The VP9 Profile 2.
        public static let profile2 = AVProfile(rawValue: AV_PROFILE_VP9_2)
        /// The VP9 Profile 3.
        public static let profile3 = AVProfile(rawValue: AV_PROFILE_VP9_3)
    }

    /// HEVC/H.265 video profiles.
    enum HEVC {
        /// The HEVC Main profile.
        public static let main = AVProfile(rawValue: AV_PROFILE_HEVC_MAIN)
        /// The HEVC Main 10 profile.
        public static let main10 = AVProfile(rawValue: AV_PROFILE_HEVC_MAIN_10)
        /// The HEVC Main Still Picture profile.
        public static let mainStillPicture = AVProfile(rawValue: AV_PROFILE_HEVC_MAIN_STILL_PICTURE)
        /// The HEVC Range Extensions profile.
        public static let rangeExtensions = AVProfile(rawValue: AV_PROFILE_HEVC_REXT)
        /// The HEVC Multiview Main profile.
        public static let multiviewMain = AVProfile(rawValue: AV_PROFILE_HEVC_MULTIVIEW_MAIN)
        /// The HEVC Screen Content Coding profile.
        public static let screenContentCoding = AVProfile(rawValue: AV_PROFILE_HEVC_SCC)
    }

    /// VVC/H.266 video profiles.
    enum VVC {
        /// The VVC Main 10 profile.
        public static let main10 = AVProfile(rawValue: AV_PROFILE_VVC_MAIN_10)
        /// The VVC Main 10 4:4:4 profile.
        public static let main10444 = AVProfile(rawValue: AV_PROFILE_VVC_MAIN_10_444)
    }

    /// AV1 video profiles.
    enum AV1 {
        /// The AV1 Main profile.
        public static let main = AVProfile(rawValue: AV_PROFILE_AV1_MAIN)
        /// The AV1 High profile.
        public static let high = AVProfile(rawValue: AV_PROFILE_AV1_HIGH)
        /// The AV1 Professional profile.
        public static let professional = AVProfile(rawValue: AV_PROFILE_AV1_PROFESSIONAL)
    }

    /// Motion JPEG profiles.
    enum MJPEG {
        /// The Huffman Baseline DCT profile.
        public static let huffmanBaselineDCT = AVProfile(rawValue: AV_PROFILE_MJPEG_HUFFMAN_BASELINE_DCT)
        /// The Huffman Extended Sequential DCT profile.
        public static let huffmanExtendedSequentialDCT = AVProfile(rawValue: AV_PROFILE_MJPEG_HUFFMAN_EXTENDED_SEQUENTIAL_DCT)
        /// The Huffman Progressive DCT profile.
        public static let huffmanProgressiveDCT = AVProfile(rawValue: AV_PROFILE_MJPEG_HUFFMAN_PROGRESSIVE_DCT)
        /// The Huffman Lossless profile.
        public static let huffmanLossless = AVProfile(rawValue: AV_PROFILE_MJPEG_HUFFMAN_LOSSLESS)
        /// The JPEG-LS profile.
        public static let jpegLS = AVProfile(rawValue: AV_PROFILE_MJPEG_JPEG_LS)
    }

    /// SBC audio profiles.
    enum SBC {
        /// The mSBC profile.
        public static let mSBC = AVProfile(rawValue: AV_PROFILE_SBC_MSBC)
    }

    /// Apple ProRes profiles.
    enum ProRes {
        /// The ProRes Proxy profile.
        public static let proxy = AVProfile(rawValue: AV_PROFILE_PRORES_PROXY)
        /// The ProRes LT profile.
        public static let lt = AVProfile(rawValue: AV_PROFILE_PRORES_LT)
        /// The ProRes Standard profile.
        public static let standard = AVProfile(rawValue: AV_PROFILE_PRORES_STANDARD)
        /// The ProRes HQ profile.
        public static let hq = AVProfile(rawValue: AV_PROFILE_PRORES_HQ)
        /// The ProRes 4444 profile.
        public static let profile4444 = AVProfile(rawValue: AV_PROFILE_PRORES_4444)
        /// The ProRes XQ profile.
        public static let xq = AVProfile(rawValue: AV_PROFILE_PRORES_XQ)
    }

    /// Apple ProRes RAW profiles.
    enum ProResRAW {
        /// The ProRes RAW profile.
        public static let raw = AVProfile(rawValue: AV_PROFILE_PRORES_RAW)
        /// The ProRes RAW HQ profile.
        public static let rawHQ = AVProfile(rawValue: AV_PROFILE_PRORES_RAW_HQ)
    }

    /// ARIB profiles.
    enum ARIB {
        /// The ARIB Profile A.
        public static let profileA = AVProfile(rawValue: AV_PROFILE_ARIB_PROFILE_A)
        /// The ARIB Profile C.
        public static let profileC = AVProfile(rawValue: AV_PROFILE_ARIB_PROFILE_C)
    }

    /// KLVA profiles.
    enum KLVA {
        /// The synchronous KLVA profile.
        public static let synchronous = AVProfile(rawValue: AV_PROFILE_KLVA_SYNC)
        /// The asynchronous KLVA profile.
        public static let asynchronous = AVProfile(rawValue: AV_PROFILE_KLVA_ASYNC)
    }

    /// Essential Video Coding (EVC) profiles.
    enum EVC {
        /// The EVC Baseline profile.
        public static let baseline = AVProfile(rawValue: AV_PROFILE_EVC_BASELINE)
        /// The EVC Main profile.
        public static let main = AVProfile(rawValue: AV_PROFILE_EVC_MAIN)
    }

    /// Advanced Professional Video (APV) profiles.
    enum APV {
        /// The APV 4:2:2 10-bit profile.
        public static let profile42210 = AVProfile(rawValue: AV_PROFILE_APV_422_10)
        /// The APV 4:2:2 12-bit profile.
        public static let profile42212 = AVProfile(rawValue: AV_PROFILE_APV_422_12)
        /// The APV 4:4:4 10-bit profile.
        public static let profile44410 = AVProfile(rawValue: AV_PROFILE_APV_444_10)
        /// The APV 4:4:4 12-bit profile.
        public static let profile44412 = AVProfile(rawValue: AV_PROFILE_APV_444_12)
        /// The APV 4:4:4:4 10-bit profile.
        public static let profile444410 = AVProfile(rawValue: AV_PROFILE_APV_4444_10)
        /// The APV 4:4:4:4 12-bit profile.
        public static let profile444412 = AVProfile(rawValue: AV_PROFILE_APV_4444_12)
        /// The APV 4:0:0 10-bit profile.
        public static let profile40010 = AVProfile(rawValue: AV_PROFILE_APV_400_10)
    }
}
