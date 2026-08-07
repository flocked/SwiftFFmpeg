//
//  AVMetadataKey.swift
//
//
//  Created by Florian Zand on 02.08.26.
//

/// A typed key for accessing FFmpeg metadata dictionary values.
public struct AVMetadataKey: RawRepresentable, Hashable, ExpressibleByStringLiteral {
    /// The title of the media item or stream.
    public static let title: Self = "title"
    /// The primary artist or performer.
    public static let artist: Self = "artist"
    /// The album or collection title.
    public static let album: Self = "album"
    /// The album artist metadata key used by many containers.
    public static let albumArtist: Self = "album_artist"
    /// The alternate album artist metadata key used by some containers.
    public static let albumArtistAlternative: Self = "albumartist"
    /// The composer of the media item.
    public static let composer: Self = "composer"
    /// The genre or category of the media item.
    public static let genre: Self = "genre"
    /// The recording, release, or creation date.
    public static let date: Self = "date"
    /// The recording, release, or creation year.
    public static let year: Self = "year"
    /// A free-form comment.
    public static let comment: Self = "comment"
    /// A description of the media item.
    public static let description: Self = "description"
    /// A synopsis or summary of the media item.
    public static let synopsis: Self = "synopsis"
    /// The encoder or muxer that wrote the file.
    public static let encoder: Self = "encoder"
    /// The creation timestamp stored by the container.
    public static let creationTime: Self = "creation_time"
    /// The copyright notice.
    public static let copyright: Self = "copyright"
    /// The language code, commonly an ISO 639 code such as `eng`.
    public static let language: Self = "language"
    /// The container handler name for a stream, such as `VideoHandler` or `SoundHandler`.
    public static let handlerName: Self = "handler_name"
    /// The MP4/MOV major brand identifier.
    public static let majorBrand: Self = "major_brand"
    /// The MP4/MOV minor version value.
    public static let minorVersion: Self = "minor_version"
    /// The MP4/MOV compatible brand identifiers.
    public static let compatibleBrands: Self = "compatible_brands"
    
    public let rawValue: String
    
    public init(rawValue: String) {
        self.rawValue = rawValue
    }
    
    public init(stringLiteral value: String) {
        self.rawValue = value
    }
}
