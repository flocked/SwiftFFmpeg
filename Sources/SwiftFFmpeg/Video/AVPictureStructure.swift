//
//  AVPictureStructure.swift
//  SwiftFFmpeg
//

import CFFmpeg

/// Describes whether a picture is coded as a frame or as one field.
public enum AVPictureStructure: UInt32 {
    /// The picture structure is unknown.
    case unknown
    /// The picture is coded as a top field.
    case topField
    /// The picture is coded as a bottom field.
    case bottomField
    /// The picture is coded as a frame.
    case frame

    init(native: CFFmpeg.AVPictureStructure) {
        guard let structure = Self(rawValue: native.rawValue) else {
            fatalError("Unknown picture structure: \(native)")
        }
        self = structure
    }

    var native: CFFmpeg.AVPictureStructure {
        CFFmpeg.AVPictureStructure(rawValue)
    }
}
