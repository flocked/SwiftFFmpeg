//
//  AVStreamDisposition.swift
//  SwiftFFmpeg
//
//  Created by Florian Zand on 01.08.26.
//

import CFFmpeg

/// Options that describe the disposition and intended use of a media stream.
public struct AVStreamDisposition: OptionSet, Sendable, CustomStringConvertible, CustomDebugStringConvertible {
    /// The raw disposition value.
    public let rawValue: Int32
    /// Creates a new stream disposition from the specified raw value.
    public init(rawValue: Int32) {
        self.rawValue = rawValue
    }
    /// Indicates that the stream is the default choice for its media type.
    public static let `default` = Self(rawValue: AV_DISPOSITION_DEFAULT)
    /// Indicates that the stream contains dubbed audio.
    public static let dub = Self(rawValue: AV_DISPOSITION_DUB)
    /// Indicates that the stream contains the original version of the content.
    public static let original = Self(rawValue: AV_DISPOSITION_ORIGINAL)
    /// Indicates that the stream contains commentary.
    public static let comment = Self(rawValue: AV_DISPOSITION_COMMENT)
    /// Indicates that the stream contains song lyrics.
    public static let lyrics = Self(rawValue: AV_DISPOSITION_LYRICS)
    /// Indicates that the stream is intended for karaoke.
    public static let karaoke = Self(rawValue: AV_DISPOSITION_KARAOKE)
    /// Indicates that the stream is forced and should be displayed regardless of subtitle preferences.
    public static let forced = Self(rawValue: AV_DISPOSITION_FORCED)
    /// Indicates that the stream is intended for users with hearing impairments.
    public static let hearingImpaired = Self(rawValue: AV_DISPOSITION_HEARING_IMPAIRED)
    /// Indicates that the stream is intended for users with visual impairments.
    public static let visualImpaired = Self(rawValue: AV_DISPOSITION_VISUAL_IMPAIRED)
    /// Indicates that the stream contains audio with dialogue removed.
    public static let cleanEffects = Self(rawValue: AV_DISPOSITION_CLEAN_EFFECTS)
    /// Indicates that the stream contains an attached picture, such as cover art.
    public static let attachedPicture = Self(rawValue: AV_DISPOSITION_ATTACHED_PIC)
    /// Indicates that the stream contains timed thumbnail images.
    public static let timedThumbnails = Self(rawValue: AV_DISPOSITION_TIMED_THUMBNAILS)
    /// Indicates that the stream contains non-diegetic audio intended only for the audience.
    public static let nonDiegetic = Self(rawValue: AV_DISPOSITION_NON_DIEGETIC)
    /// Indicates that the stream contains captions.
    public static let captions = Self(rawValue: AV_DISPOSITION_CAPTIONS)
    /// Indicates that the stream contains audio descriptions.
    public static let descriptions = Self(rawValue: AV_DISPOSITION_DESCRIPTIONS)
    /// Indicates that the stream contains metadata.
    public static let metadata = Self(rawValue: AV_DISPOSITION_METADATA)
    /// Indicates that the stream depends on another stream for decoding or presentation.
    public static let dependent = Self(rawValue: AV_DISPOSITION_DEPENDENT)
    /// Indicates that the stream contains a still image.
    public static let stillImage = Self(rawValue: AV_DISPOSITION_STILL_IMAGE)
    /// Indicates that the stream is part of a multilayer presentation.
    public static let multilayer = Self(rawValue: AV_DISPOSITION_MULTILAYER)
    
    public var description: String {
        "[\( elements().map(\.string).joined(separator: ", "))]"
    }
    
    public var debugDescription: String {
        "[\( elements().map(\.ffmpegName).joined(separator: ", "))]"
    }
    
    private var ffmpegName: String {
        String(cString: av_disposition_to_string(rawValue)) ?? "\(rawValue)"
    }
    
    private var string: String {
        switch self {
        case .default: "default"
        case .dub: "dub"
        case .original: "original"
        case .comment: "comment"
        case .lyrics: "lyrics"
        case .karaoke: "karaoke"
        case .forced: "forced"
        case .hearingImpaired: "hearingImpaired"
        case .visualImpaired: "visualImpaired"
        case .cleanEffects: "cleanEffects"
        case .attachedPicture: "attachedPicture"
        case .timedThumbnails: "timedThumbnails"
        case .nonDiegetic: "nonDiegetic"
        case .captions: "captions"
        case .descriptions: "descriptions"
        case .metadata: "metadata"
        case .dependent: "dependent"
        case .stillImage: "stillImage"
        case .multilayer: "multilayer"
        default: ffmpegName
        }
    }
}
