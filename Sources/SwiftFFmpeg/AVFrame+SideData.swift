//
//  AVSideData.swift
//  SwiftFFmpeg
//
//  Created by Greg Cotten on 3/31/20.
//
//

import CFFmpeg

public extension AVFrame {
    /// Side data associated with a frame.
    final class SideData {
        let native: UnsafeMutablePointer<CFFmpeg.AVFrameSideData>

        init(native: UnsafeMutablePointer<CFFmpeg.AVFrameSideData>) {
            self.native = native
        }

        /// The type of the side data.
        public var type: DataType {
            .init(native: native.pointee.type)
        }

        /// A pointer to the side data bytes.
        public var data: UnsafeMutablePointer<UInt8> {
            native.pointee.data
        }

        /// The size of the side data, in bytes.
        public var size: Int {
            Int(native.pointee.size)
        }

        /// The metadata associated with the side data.
        public var metadata: [String: String] {
            native.pointee.metadata?.avDict ?? [:]
        }

        /// The buffer containing the side data.
        public var buffer: AVBuffer {
            AVBuffer(native: native.pointee.buf)
        }
    }
}

extension AVFrame.SideData {
    /// A type of side data associated with a frame.
    public struct DataType: RawRepresentable, CustomStringConvertible {
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
        
        /// The name of side data.
        public var name: String {
            av_frame_side_data_name(native).string
        }
        
        public var description: String {
            name
        }
        
        /// The properties of the side data.
        public var properties: Properties {
            Properties(rawValue: av_frame_side_data_desc(native)?.pointee.props ?? 0)
        }
    }
}

extension AVFrame.SideData.DataType {
    /// Properties describing how a side data type can be used and what media characteristics it depends on.
    public struct Properties: OptionSet, Hashable, CustomStringConvertible, CustomDebugStringConvertible {
        /**
         The side data type can be used in stream-global structures.

         Side data types without this property are meaningful only on a per-frame basis.
         */
        public static let global = Self(rawValue: 1 << 0)

        /// Multiple instances of the side data type may be present in a single side data array.
        public static let multi = Self(rawValue: 1 << 1)

        /**
         The side data depends on the video dimensions.

         Side data with this property loses its meaning when the image is resized or cropped unless it is recomputed or adjusted for the new dimensions.
         */
        public static let sizeDependent = Self(rawValue: 1 << 2)

        /**
         The side data depends on the video color space.

         Side data with this property loses its meaning when the video color encoding changes unless it is recomputed or adjusted for the new color space.
         */
        public static let colorDependent = Self(rawValue: 1 << 3)

        /**
         The side data depends on the channel layout.

         Side data with this property loses its meaning when audio is downmixed or upmixed unless it is recomputed or adjusted for the new channel layout.
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
