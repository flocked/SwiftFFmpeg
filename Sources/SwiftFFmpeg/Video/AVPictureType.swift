//
//  AVPictureType.swift
//  SwiftFFmpeg
//
//  Created by sunlubo on 2018/8/2.
//

import CFFmpeg

public enum AVPictureType: UInt32, CustomStringConvertible {
    /// Undefined
    case none = 0
    /// Intra
    case I
    /// Predicted
    case P
    /// Bi-dir predicted
    case B
    /// S(GMC)-VOP MPEG-4
    case S
    /// Switching Intra
    case SI
    /// Switching Predicted
    case SP
    /// BI type
    case BI

    var native: CFFmpeg.AVPictureType {
        CFFmpeg.AVPictureType(rawValue)
    }
    
    var nonNil: Self? {
        self != .none ? self : nil
    }
    
    var isNil: Bool {
        self == .none
    }

    init(native: CFFmpeg.AVPictureType) {
        guard let type = AVPictureType(rawValue: native.rawValue) else {
            fatalError("Unknown picture type: \(native)")
        }
        self = type
    }

    public var description: String {
        let char = av_get_picture_type_char(native)
        let scalar = Unicode.Scalar(Int(char))!
        return String(Character(scalar))
    }
}
