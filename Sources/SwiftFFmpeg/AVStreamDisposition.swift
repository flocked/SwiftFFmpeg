//
//  AVStreamDisposition.swift
//  SwiftFFmpeg
//
//  Created by Florian Zand on 01.08.26.
//

import Foundation

/// Options that describe the disposition and intended use of a media stream.
public struct AVStreamDisposition: OptionSet, Sendable {
    /// The raw disposition value.
    public let rawValue: Int32
    /// Creates a new stream disposition from the specified raw value.
    public init(rawValue: Int32) {
        self.rawValue = rawValue
    }
    /// Indicates that the stream is the default choice for its media type.
    public static let `default` = Self(rawValue: 1 << 0)
    /// Indicates that the stream contains dubbed audio.
    public static let dub = Self(rawValue: 1 << 1)
    /// Indicates that the stream contains the original version of the content.
    public static let original = Self(rawValue: 1 << 2)
    /// Indicates that the stream contains commentary.
    public static let comment = Self(rawValue: 1 << 3)
    /// Indicates that the stream contains song lyrics.
    public static let lyrics = Self(rawValue: 1 << 4)
    /// Indicates that the stream is intended for karaoke.
    public static let karaoke = Self(rawValue: 1 << 5)
    /// Indicates that the stream is forced and should be displayed regardless of subtitle preferences.
    public static let forced = Self(rawValue: 1 << 6)
    /// Indicates that the stream is intended for users with hearing impairments.
    public static let hearingImpaired = Self(rawValue: 1 << 7)
    /// Indicates that the stream is intended for users with visual impairments.
    public static let visualImpaired = Self(rawValue: 1 << 8)
    /// Indicates that the stream contains audio with dialogue removed.
    public static let cleanEffects = Self(rawValue: 1 << 9)
    /// Indicates that the stream contains an attached picture, such as cover art.
    public static let attachedPicture = Self(rawValue: 1 << 10)
    /// Indicates that the stream contains timed thumbnail images.
    public static let timedThumbnails = Self(rawValue: 1 << 11)
    /// Indicates that the stream contains non-diegetic audio intended only for the audience.
    public static let nonDiegetic = Self(rawValue: 1 << 12)
    /// Indicates that the stream contains captions.
    public static let captions = Self(rawValue: 1 << 16)
    /// Indicates that the stream contains audio descriptions.
    public static let descriptions = Self(rawValue: 1 << 17)
    /// Indicates that the stream contains metadata.
    public static let metadata = Self(rawValue: 1 << 18)
    /// Indicates that the stream depends on another stream for decoding or presentation.
    public static let dependent = Self(rawValue: 1 << 19)
    /// Indicates that the stream contains a still image.
    public static let stillImage = Self(rawValue: 1 << 20)
    /// Indicates that the stream is part of a multilayer presentation.
    public static let multilayer = Self(rawValue: 1 << 21)
}
