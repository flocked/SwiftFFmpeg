//
//  AVSideData.swift
//  SwiftFFmpeg
//
//  Created by Greg Cotten on 3/31/20.
//
//

import CFFmpeg

public struct AVFrameSideDataType: RawRepresentable, CustomStringConvertible {
    public let rawValue: UInt32

    /// The data is the AVPanScan struct defined in libavcodec.
    public static let panScan = Self(native: AV_FRAME_DATA_PANSCAN)

    /**
     ATSC A53 Part 4 Closed Captions.

     The data is stored as a `UInt8` buffer.
     */
    public static let a53ClosedCaptions = Self(native: AV_FRAME_DATA_A53_CC)

    /// The data is the `AVStereo3D` structure defined in `libavutil/stereo3d.h`.
    public static let stereo3D = Self(native: AV_FRAME_DATA_STEREO3D)

    /// The data is the `AVMatrixEncoding` value defined in `libavutil/channel_layout.h`.
    public static let matrixEncoding = Self(native: AV_FRAME_DATA_MATRIXENCODING)

    /// The data is the `AVDownmixInfo` structure describing downmix metadata.
    public static let downmixInfo = Self(native: AV_FRAME_DATA_DOWNMIX_INFO)

    /// The data is the `AVReplayGain` structure containing ReplayGain information.
    public static let replayGain = Self(native: AV_FRAME_DATA_REPLAYGAIN)

    /// The data contains a 3×3 affine transformation matrix for correct frame presentation.
    public static let displayMatrix = Self(native: AV_FRAME_DATA_DISPLAYMATRIX)

    /// The data contains an Active Format Description (`AVActiveFormatDescription`) value.
    public static let activeFormatDescription = Self(native: AV_FRAME_DATA_AFD)

    /**
     Motion vectors exported by codecs when the `export_mvs` codec option is enabled.

     The data is an array of `AVMotionVector` structures.
     */
    public static let motionVectors = Self(native: AV_FRAME_DATA_MOTION_VECTORS)

    /**
     Recommends skipping a number of audio samples at the beginning or end of a frame.

     The data uses the same format as `AV_PKT_DATA_SKIP_SAMPLES`.
     */
    public static let skipSamples = Self(native: AV_FRAME_DATA_SKIP_SAMPLES)

    /// The data contains an `AVAudioServiceType` value associated with an audio frame.
    public static let audioServiceType = Self(native: AV_FRAME_DATA_AUDIO_SERVICE_TYPE)

    /// The data contains `AVMasteringDisplayMetadata` describing the mastering display color volume.
    public static let masteringDisplayMetadata = Self(native: AV_FRAME_DATA_MASTERING_DISPLAY_METADATA)

    /// The data contains a 25-bit GOP timecode stored as a 64-bit integer.
    public static let gopTimecode = Self(native: AV_FRAME_DATA_GOP_TIMECODE)

    /// The data contains an `AVSphericalMapping` structure.
    public static let sphericalMapping = Self(native: AV_FRAME_DATA_SPHERICAL)

    /// The data contains `AVContentLightMetadata` describing HDR content light levels.
    public static let contentLightLevel = Self(native: AV_FRAME_DATA_CONTENT_LIGHT_LEVEL)

    /**
     The data contains an ICC profile following ISO 15076-1.

     An optional profile name may be stored in the `"name"` metadata entry.
     */
    public static let iccProfile = Self(native: AV_FRAME_DATA_ICC_PROFILE)

    /**
     The data contains one to three SMPTE ST 12-1 timecodes.

     The payload is an array of four `UInt32` values.
     */
    public static let s12MTimecode = Self(native: AV_FRAME_DATA_S12M_TIMECODE)

    /// The data contains `AVDynamicHDRPlus` metadata for SMPTE 2094-40 HDR dynamic metadata.
    public static let dynamicHDRPlus = Self(native: AV_FRAME_DATA_DYNAMIC_HDR_PLUS)

    /**
     The data contains an array of `AVRegionOfInterest` structures.

     The number of elements is determined by the side data size.
     */
    public static let regionsOfInterest = Self(native: AV_FRAME_DATA_REGIONS_OF_INTEREST)

    /// The data contains `AVVideoEncParams` describing video encoding parameters.
    public static let videoEncodingParameters = Self(native: AV_FRAME_DATA_VIDEO_ENC_PARAMS)

    /**
     The data contains H.264/H.265 unregistered user data (SEI).

     The payload begins with a 16-byte UUID followed by the user data.
     */
    public static let seiUnregistered = Self(native: AV_FRAME_DATA_SEI_UNREGISTERED)

    /**
     The data contains `AVFilmGrainParams` describing film grain parameters.

     Multiple parameter sets may be present.
     */
    public static let filmGrainParameters = Self(native: AV_FRAME_DATA_FILM_GRAIN_PARAMS)

    /// The data contains `AVDetectionBBoxHeader` object detection bounding boxes.
    public static let detectionBoundingBoxes = Self(native: AV_FRAME_DATA_DETECTION_BBOXES)

    /**
     The data contains raw Dolby Vision RPU data.

     The payload is a `UInt8` buffer with NAL emulation bytes intact.
     */
    public static let dolbyVisionRPUBuffer = Self(native: AV_FRAME_DATA_DOVI_RPU_BUFFER)

    /// The data contains parsed Dolby Vision metadata as an `AVDOVIMetadata` structure.
    public static let dolbyVisionMetadata = Self(native: AV_FRAME_DATA_DOVI_METADATA)

    /// The data contains `AVDynamicHDRVivid` metadata for HDR Vivid dynamic metadata.
    public static let dynamicHDRVivid = Self(native: AV_FRAME_DATA_DYNAMIC_HDR_VIVID)

    /// The data contains ambient viewing environment metadata defined by H.274.
    public static let ambientViewingEnvironment = Self(native: AV_FRAME_DATA_AMBIENT_VIEWING_ENVIRONMENT)

    /**
     The data provides encoder-specific hints about changed and unchanged regions of a frame.

     It can be used to optimize video encoding.
     */
    public static let videoHint = Self(native: AV_FRAME_DATA_VIDEO_HINT)

    /**
     The data contains raw LCEVC payload data.

     The payload is a `UInt8` buffer with NAL emulation bytes intact.
     */
    public static let lcevc = Self(native: AV_FRAME_DATA_LCEVC)

    /// The data contains the view identifier for a multi-view video frame.
    public static let viewID = Self(native: AV_FRAME_DATA_VIEW_ID)

    /// The data contains an `AV3DReferenceDisplaysInfo` structure describing reference displays for multi-view video.
    public static let referenceDisplays3D = Self(native: AV_FRAME_DATA_3D_REFERENCE_DISPLAYS)

    /**
     The data contains EXIF metadata.

     The payload begins with a TIFF header indicating the byte order.
     */
    public static let exif = Self(native: AV_FRAME_DATA_EXIF)

    /// The data contains `AVDynamicHDRSmpte2094App5` metadata for SMPTE 2094-50 HDR dynamic metadata.
    public static let dynamicHDRSMPTE2094App5 = Self(native: AV_FRAME_DATA_DYNAMIC_HDR_SMPTE_2094_APP5)

    /// The data contains an `AVIAMFParamDefinition` describing IAMF mix gain parameters.
    public static let iamfMixGainParameter = Self(native: AV_FRAME_DATA_IAMF_MIX_GAIN_PARAM)

    /// The data contains an `AVIAMFParamDefinition` describing IAMF demixing information parameters.
    public static let iamfDemixingInfoParameter = Self(native: AV_FRAME_DATA_IAMF_DEMIXING_INFO_PARAM)

    /// The data contains an `AVIAMFParamDefinition` describing IAMF reconstruction gain parameters.
    public static let iamfReconstructionGainParameter = Self(native: AV_FRAME_DATA_IAMF_RECON_GAIN_INFO_PARAM)

    /// The data contains an `AVRawColorParams` structure describing RAW camera color information.
    public static let rawColorParameters = Self(native: AV_FRAME_DATA_RAW_COLOR_PARAMS)

    #if FF_API_FRAME_QP

    /// Implementation-specific description of the format of AV_FRAME_QP_TABLE_DATA.
    /// The contents of this side data are undocumented and internal; use
    /// av_frame_set_qp_table() and av_frame_get_qp_table() to access this in a
    /// meaningful way instead.
    public static let qpTableProperties = Self(native: AV_FRAME_DATA_QP_TABLE_PROPERTIES)

    /// Raw QP table data. Its format is described by
    /// AV_FRAME_DATA_QP_TABLE_PROPERTIES. Use av_frame_set_qp_table() and
    /// av_frame_get_qp_table() to access this instead.
    public static let qpTableData = Self(native: AV_FRAME_DATA_QP_TABLE_DATA)
    #endif

    public init(rawValue: UInt32) {
        self.rawValue = rawValue
    }

    var native: CFFmpeg.AVFrameSideDataType {
        .init(rawValue: rawValue)
    }

    init(native: CFFmpeg.AVFrameSideDataType) {
        self.rawValue = native.rawValue
    }
    
    /// The name of the type.
    public var name: String {
        String(cString: av_frame_side_data_name(native))
    }
    
    public var description: String {
        name
    }

    /// Side data property flags.
    public var properties: Properties {
        Properties(rawValue: av_frame_side_data_desc(native)?.pointee.props ?? 0)
    }

    public struct Properties: OptionSet, Hashable, CustomStringConvertible, CustomDebugStringConvertible {
        /**
         The side data type can be used in stream-global structures.

         Side data types without this property are only meaningful on per-frame basis.
         */
        public static let global = Self(rawValue: 1 << 0)

        /// Multiple instances of this side data type can be meaningfully present in a single side data array.
        public static let multi = Self(rawValue: 1 << 1)

        /**
         Side data depends on the video dimensions.

         Side data with this property loses its meaning when rescaling or cropping the image, unless either recomputed or adjusted to the new resolution.
         */
        public static let sizeDependent = Self(rawValue: 1 << 2)

        /**
         Side data depends on the video color space.

         Side data with this property loses its meaning when changing the video color encoding, e.g. by adapting to a different set of primaries or transfer characteristics.
         */
        public static let colorDependent = Self(rawValue: 1 << 3)

        /**
         Side data depends on the channel layout.

         Side data with this property loses its meaning when downmixing or upmixing, unless either recomputed or adjusted to the new layout.
         */
        public static let channelDependent = Self(rawValue: 1 << 4)

        public let rawValue: UInt32

        public init(rawValue: UInt32) {
            self.rawValue = rawValue
        }
        
        public var description: String {
            "[\(elements().map { Self.names[$0]?.swift ?? "\($0.rawValue)" }.joined(separator: ", "))]"
        }

        public var debugDescription: String {
            "[\(elements().map { Self.names[$0]?.native ?? "\($0.rawValue)" }.joined(separator: ", "))]"
        }
        
        private static let names: [Self: (swift: String, native: String)] = [
            .global: ("global", "AV_SIDE_DATA_PROP_GLOBAL"),
            .multi: ("multi", "AV_SIDE_DATA_PROP_MULTI"),
            .sizeDependent: ("sizeDependent", "AV_SIDE_DATA_PROP_SIZE_DEPENDENT"),
            .colorDependent: ("colorDependent", "AV_SIDE_DATA_PROP_COLOR_DEPENDENT"),
            .channelDependent: ("channelDependent", "AV_SIDE_DATA_PROP_CHANNEL_DEPENDENT"),
        ]
    }
}

/*
public typealias AVFrameSideDataType = CFFmpeg.AVFrameSideDataType

public extension AVFrameSideDataType {
    /// The data is the AVPanScan struct defined in libavcodec.
    static let panScan = AV_FRAME_DATA_PANSCAN

    /// ATSC A53 Part 4 Closed Captions.
    /// A53 CC bitstream is stored as uint8_t in AVFrameSideData.data.
    /// The number of bytes of CC data is AVFrameSideData.size.
    static let a53CC = AV_FRAME_DATA_A53_CC

    /// Stereoscopic 3d metadata.
    /// The data is the AVStereo3D struct defined in libavutil/stereo3d.h.
    static let stereo3D = AV_FRAME_DATA_STEREO3D

    /// The data is the AVMatrixEncoding enum defined in libavutil/channel_layout.h.
    static let matrixEncoding = AV_FRAME_DATA_MATRIXENCODING

    /// Metadata relevant to a downmix procedure.
    /// The data is the AVDownmixInfo struct defined in libavutil/downmix_info.h.
    static let downMixInfo = AV_FRAME_DATA_DOWNMIX_INFO

    /// ReplayGain information in the form of the AVReplayGain struct.
    static let replayGain = AV_FRAME_DATA_REPLAYGAIN

    /// This side data contains a 3x3 transformation matrix describing an affine
    /// transformation that needs to be applied to the frame for correct
    /// presentation.
    /// See libavutil/display.h for a detailed description of the data.
    static let displayMatrix = AV_FRAME_DATA_DISPLAYMATRIX

    /// Active Format Description data consisting of a single byte as specified
    /// in ETSI TS 101 154 using AVActiveFormatDescription enum.
    static let afd = AV_FRAME_DATA_AFD

    /// Motion vectors exported by some codecs (on demand through the export_mvs
    /// flag set in the libavcodec AVCodecContext flags2 option).
    /// The data is the AVMotionVector struct defined in
    /// libavutil/motion_vector.h.
    static let motionVectors = AV_FRAME_DATA_MOTION_VECTORS

    /// Recommmends skipping the specified number of samples. This is exported
    /// only if the "skip_manual" AVOption is set in libavcodec.
    /// This has the same format as AV_PKT_DATA_SKIP_SAMPLES.
    /// @code
    /// u32le number of samples to skip from start of this packet
    /// u32le number of samples to skip from end of this packet
    /// u8    reason for start skip
    /// u8    reason for end   skip (0=padding silence, 1=convergence)
    /// @endcode
    static let skipSamples = AV_FRAME_DATA_SKIP_SAMPLES

    /// This side data must be associated with an audio frame and corresponds to
    /// enum AVAudioServiceType defined in avcodec.h.
    static let audioServiceType = AV_FRAME_DATA_AUDIO_SERVICE_TYPE

    /// Mastering display metadata associated with a video frame. The payload is
    /// an AVMasteringDisplayMetadata type and contains information about the
    /// mastering display color volume.
    static let masteringDisplayMetadata = AV_FRAME_DATA_MASTERING_DISPLAY_METADATA

    /// The GOP timecode in 25 bit timecode format. Data format is 64-bit integer.
    /// This is set on the first frame of a GOP that has a temporal reference of 0.
    static let gopTimecode = AV_FRAME_DATA_GOP_TIMECODE

    /// The data represents the AVSphericalMapping structure defined in
    /// libavutil/spherical.h.
    static let spherical = AV_FRAME_DATA_SPHERICAL

    /// Content light level (based on CTA-861.3). This payload contains data in
    /// the form of the AVContentLightMetadata struct.
    static let contentLightLevel = AV_FRAME_DATA_CONTENT_LIGHT_LEVEL

    /// The data contains an ICC profile as an opaque octet buffer following the
    /// format described by ISO 15076-1 with an optional name defined in the
    /// metadata key entry "name".
    static let iccProfile = AV_FRAME_DATA_ICC_PROFILE

    #if FF_API_FRAME_QP

    /// Implementation-specific description of the format of AV_FRAME_QP_TABLE_DATA.
    /// The contents of this side data are undocumented and internal; use
    /// av_frame_set_qp_table() and av_frame_get_qp_table() to access this in a
    /// meaningful way instead.
    static let qpTableProperties = AV_FRAME_DATA_QP_TABLE_PROPERTIES

    /// Raw QP table data. Its format is described by
    /// AV_FRAME_DATA_QP_TABLE_PROPERTIES. Use av_frame_set_qp_table() and
    /// av_frame_get_qp_table() to access this instead.
    static let qpTableData = AV_FRAME_DATA_QP_TABLE_DATA
    #endif

    /// Timecode which conforms to SMPTE ST 12-1. The data is an array of 4 uint32_t
    /// where the first uint32_t describes how many (1-3) of the other timecodes are used.
    /// The timecode format is described in the av_timecode_get_smpte_from_framenum()
    /// function in libavutil/timecode.c.
    static let S12MTimecode = AV_FRAME_DATA_S12M_TIMECODE

    /// HDR dynamic metadata associated with a video frame. The payload is
    /// an AVDynamicHDRPlus type and contains information for color
    /// volume transform - application 4 of SMPTE 2094-40:2016 standard.
    static let dynamicHDRPlus = AV_FRAME_DATA_DYNAMIC_HDR_PLUS

    /// Regions Of Interest, the data is an array of AVRegionOfInterest type, the number of
    /// array element is implied by AVFrameSideData.size / AVRegionOfInterest.self_size.
    static let regionsOfInterest = AV_FRAME_DATA_REGIONS_OF_INTEREST

    /// Encoding parameters for a video frame, as described by AVVideoEncParams.
    static let videoEncodingParams = AV_FRAME_DATA_VIDEO_ENC_PARAMS

    /// User data unregistered metadata associated with a video frame.
    /// This is the H.26[45] UDU SEI message, and shouldn't be used for any other purpose
    /// The data is stored as uint8_t in AVFrameSideData.data which is 16 bytes of
    /// uuid_iso_iec_11578 followed by AVFrameSideData.size - 16 bytes of user_data_payload_byte.
    static let seiUnregistered = AV_FRAME_DATA_SEI_UNREGISTERED

    /// Film grain parameters for a frame, described by AVFilmGrainParams.
    /// Must be present for every frame which should have film grain applied.
    ///
    /// May be present multiple times, for example when there are multiple
    /// alternative parameter sets for different video signal characteristics.
    /// The user should select the most appropriate set for the application.
    static let filmGrainParams = AV_FRAME_DATA_FILM_GRAIN_PARAMS

    /// Bounding boxes for object detection and classification,
    /// as described by AVDetectionBBoxHeader.
    static let detectionBBoxes = AV_FRAME_DATA_DETECTION_BBOXES

    /// Dolby Vision RPU raw data, suitable for passing to x265
    /// or other libraries. Array of uint8_t, with NAL emulation
    /// bytes intact.
    static let dolbyVisionRPU = AV_FRAME_DATA_DOVI_RPU_BUFFER

    /// Parsed Dolby Vision metadata, suitable for passing to a software
    /// implementation. The payload is the AVDOVIMetadata struct defined in
    /// libavutil/dovi_meta.h.
    static let dolbyVisionMetadata = AV_FRAME_DATA_DOVI_METADATA

    /// HDR Vivid dynamic metadata associated with a video frame. The payload is
    /// an AVDynamicHDRVivid type and contains information for color
    /// volume transform - CUVA 005.1-2021.
    static let dynamicHDRVivid = AV_FRAME_DATA_DYNAMIC_HDR_VIVID

    /// Ambient viewing environment metadata, as defined by H.274.
    static let ambientViewingEnvironment = AV_FRAME_DATA_AMBIENT_VIEWING_ENVIRONMENT

    /// Provide encoder-specific hinting information about changed/unchanged
    /// portions of a frame.  It can be used to pass information about which
    /// macroblocks can be skipped because they didn't change from the
    /// corresponding ones in the previous frame. This could be useful for
    /// applications which know this information in advance to speed up
    /// encoding.
    static let videoHint = AV_FRAME_DATA_VIDEO_HINT

    /// Raw LCEVC payload data, as a uint8_t array, with NAL emulation
    /// bytes intact.
    static let lcevc = AV_FRAME_DATA_LCEVC

    /// This side data must be associated with a video frame.
    /// The presence of this side data indicates that the video stream is
    /// composed of multiple views (e.g. stereoscopic 3D content,
    /// cf. H.264 Annex H or H.265 Annex G).
    /// The data is an int storing the view ID.
    static let viewId = AV_FRAME_DATA_VIEW_ID

    /// The name of the type.
    var name: String {
        String(cString: av_frame_side_data_name(self))
    }
}
 */

typealias CAVFrameSideData = CFFmpeg.AVFrameSideData

/// Structure to hold side data for an AVFrame.
///
/// sizeof(AVFrameSideData) is not a part of the public ABI, so new fields may be added
/// o the end with a minor bump.
public final class AVFrameSideData {
    let native: UnsafeMutablePointer<CAVFrameSideData>

    init(native: UnsafeMutablePointer<CAVFrameSideData>) {
        self.native = native
    }

    public var type: AVFrameSideDataType {
        AVFrameSideDataType(native: native.pointee.type)
    }

    public var data: UnsafeMutablePointer<UInt8> {
        native.pointee.data
    }

    public var size: Int {
        Int(native.pointee.size)
    }

    public var metadata: [String: String] {
        var dict = [String: String]()
        var tag: UnsafeMutablePointer<AVDictionaryEntry>?
        while let next = av_dict_get(native.pointee.metadata, "", tag, AV_DICT_IGNORE_SUFFIX) {
            dict[String(cString: next.pointee.key)] = String(cString: next.pointee.value)
            tag = next
        }
        return dict
    }

    public var buffer: AVBuffer {
        AVBuffer(native: native.pointee.buf)
    }
}
