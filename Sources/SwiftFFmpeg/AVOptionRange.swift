//
//  AVOptionRange.swift
//  SwiftFFmpeg
//
//  Created by Florian Zand on 08.08.26.
//

import CFFmpeg

public struct AVOptionRange {
    /// The associated string value, if any.
    public let string: String?
    /// The minimum allowed value.
    public let minimum: Double
    /// The maximum allowed value.
    public let maximum: Double
    /// The minimum allowed component value.
    public let componentMinimum: Double
    /// The maximum allowed component value.
    public let componentMaximum: Double
    /// A Boolean value indicating whether this represents a range.
    public let isRange: Bool
    
    init(native: CFFmpeg.AVOptionRange) {
        self.string = native.str.map(String.init(cString:))
        self.minimum = native.value_min
        self.maximum = native.value_max
        self.componentMinimum = native.component_min
        self.componentMaximum = native.component_max
        self.isRange = native.is_range != 0
    }
}

/*
public struct AVOptionRanges {
    /// The allowed ranges.
    public let ranges: [AVOptionRange]
    /// The number of components described by each range.
    public let componentCount: Int
    
    init(native: CFFmpeg.AVOptionRanges) {
        self.componentCount = Int(native.nb_components)
        self.ranges = (0..<Int(native.nb_ranges)).compactMap { index in
            native.range[index].map { AVOptionRange(native: $0.pointee) }
        }
    }
}
*/
