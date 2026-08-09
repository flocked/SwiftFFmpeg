//
//  AVFieldOrder.swift
//  SwiftFFmpeg
//
//  Created by sunlubo on 2018/8/2.
//

import CFFmpeg

/// Describes the field order of interlaced video.
public enum AVFieldOrder: UInt32, CustomStringConvertible, CustomDebugStringConvertible {
    /// The field order is unknown.
    case unknown
    /// The video is progressive and has no field order.
    case progressive
    /// Top coded first, top displayed first.
    case tt
    /// Bottom coded first, bottom displayed first.
    case bb
    /// Top coded first, bottom displayed first.
    case tb
    /// Bottom coded first, top displayed first.
    case bt

    public var description: String {
        switch self {
        case .unknown: "unknown"
        case .progressive: "progressive"
        case .tt: "tt"
        case .bb: "bb"
        case .tb: "tb"
        case .bt: "bt"
        }
    }

    public var debugDescription: String {
        switch self {
        case .unknown: "AV_FIELD_UNKNOWN"
        case .progressive: "AV_FIELD_PROGRESSIVE"
        case .tt: "AV_FIELD_TT"
        case .bb: "AV_FIELD_BB"
        case .tb: "AV_FIELD_TB"
        case .bt: "AV_FIELD_BT"
        }
    }

    init(native: CFFmpeg.AVFieldOrder) {
        guard let value = Self(rawValue: native.rawValue) else {
            fatalError("Unknown field order: \(native)")
        }
        self = value
    }

    var native: CFFmpeg.AVFieldOrder {
        CFFmpeg.AVFieldOrder(rawValue)
    }
}
