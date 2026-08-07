//
//  AVStreamDisposition.swift
//  SwiftFFmpeg
//
//  Created by Florian Zand on 01.08.26.
//

import CFFmpeg

/// Options that describe the disposition and intended use of a media stream.
public struct AVStreamDisposition: OptionSet, Hashable, Sendable, CustomStringConvertible, CustomDebugStringConvertible {
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
        "[\(elements().map { Self.names[$0]?.swift ?? "\($0.rawValue)" }.joined(separator: ", "))]"
    }
    
    public var debugDescription: String {
        "[\(elements().map { Self.names[$0]?.native ?? "\($0.rawValue)" }.joined(separator: ", "))]"
    }

    private static let names: [Self: (swift: String, native: String)] = [
        .default: ("default", "AV_DISPOSITION_DEFAULT"),
        .dub: ("dub", "AV_DISPOSITION_DUB"),
        .original: ("original", "AV_DISPOSITION_ORIGINAL"),
        .comment: ("comment", "AV_DISPOSITION_COMMENT"),
        .lyrics: ("lyrics", "AV_DISPOSITION_LYRICS"),
        .karaoke: ("karaoke", "AV_DISPOSITION_KARAOKE"),
        .forced: ("forced", "AV_DISPOSITION_FORCED"),
        .hearingImpaired: ("hearingImpaired", "AV_DISPOSITION_HEARING_IMPAIRED"),
        .visualImpaired: ("visualImpaired", "AV_DISPOSITION_VISUAL_IMPAIRED"),
        .cleanEffects: ("cleanEffects", "AV_DISPOSITION_CLEAN_EFFECTS"),
        .attachedPicture: ("attachedPicture", "AV_DISPOSITION_ATTACHED_PIC"),
        .timedThumbnails: ("timedThumbnails", "AV_DISPOSITION_TIMED_THUMBNAILS"),
        .nonDiegetic: ("nonDiegetic", "AV_DISPOSITION_NON_DIEGETIC"),
        .captions: ("captions", "AV_DISPOSITION_CAPTIONS"),
        .descriptions: ("descriptions", "AV_DISPOSITION_DESCRIPTIONS"),
        .metadata: ("metadata", "AV_DISPOSITION_METADATA"),
        .dependent: ("dependent", "AV_DISPOSITION_DEPENDENT"),
        .stillImage: ("stillImage", "AV_DISPOSITION_STILL_IMAGE"),
        .multilayer: ("multilayer", "AV_DISPOSITION_MULTILAYER"),
    ]
}
