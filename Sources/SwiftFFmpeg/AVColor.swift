//
//  AVColor.swift
//  SwiftFFmpeg
//
//  Created by Florian Zand on 07.08.26.
//

import Foundation
import CFFmpeg

/// A color represented by red, green, blue, and alpha components.
public struct AVColor: Hashable, Sendable, CustomStringConvertible {
    /// The red component.
    public var red: UInt8
    /// The green component.
    public var green: UInt8
    /// The blue component.
    public var blue: UInt8
    /// The alpha component.
    public var alpha: UInt8
    
    public var description: String {
        "(red: \(red), green: \(green), blue: \(blue), alpha: \(alpha))"
    }

    var rgbaBytes: [UInt8] {
        [red, green, blue, alpha]
    }
    
    init(_ values: [UInt8]) {
        red = values[safe: 0] ?? 0
        green = values[safe: 1] ?? 0
        blue = values[safe: 2] ?? 0
        alpha = values[safe: 3] ?? .max
    }
    
    public init?(name: String) {
        var rgba = [UInt8](repeating: 0, count: 4)
        let result = name.withCString { av_parse_color(&rgba, $0, -1, nil) }
        guard result >= 0 else { return nil }
        self.init(red: rgba[0], green: rgba[1], blue: rgba[2], alpha: rgba[3])
    }

    /// Creates a color with the given red, green, blue, and alpha components.
    public init(red: UInt8, green: UInt8, blue: UInt8, alpha: UInt8 = 255) {
        self.red = red
        self.green = green
        self.blue = blue
        self.alpha = alpha
    }

    /// The color components as a tuple of red, green, blue, and alpha values.
    public var components: (red: UInt8, green: UInt8, blue: UInt8, alpha: UInt8) {
        get { (red, green, blue, alpha) }
        set { (red, green, blue, alpha) = newValue }
    }
}
