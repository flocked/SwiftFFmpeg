//
//  AVColor.swift
//  SwiftFFmpeg
//
//  Created by Florian Zand on 07.08.26.
//

import Foundation

/// A color represented by red, green, blue, and alpha components.
public struct AVColor: Hashable, Sendable {
    /// The red component.
    public var red: UInt8
    /// The green component.
    public var green: UInt8
    /// The blue component.
    public var blue: UInt8
    /// The alpha component.
    public var alpha: UInt8

    var rgbaBytes: [UInt8] {
        [red, green, blue, alpha]
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
