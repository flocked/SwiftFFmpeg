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
    private let isRandom: Bool
    
    public var description: String {
        if let name = name {
            return "\(name) (\(red), \(green), \(blue), \(alpha))"
        }
        return "(\(red), \(green), \(blue), \(alpha))"
    }

    var rgbaBytes: [UInt8] {
        [red, green, blue, alpha]
    }
    
    init(_ values: [UInt8], isRandom: Bool = false) {
        red = values[safe: 0] ?? 0
        green = values[safe: 1] ?? 0
        blue = values[safe: 2] ?? 0
        alpha = values[safe: 3] ?? .max
        self.isRandom = isRandom
    }
    
    public init?(name: String) {
        var rgba = [UInt8](repeating: 0, count: 4)
        let result = name.withCString { av_parse_color(&rgba, $0, -1, nil) }
        guard result >= 0 else { return nil }
        self.init(rgba, isRandom: name == "random")
    }

    /// Creates a color with the given red, green, blue, and alpha components.
    public init(red: UInt8, green: UInt8, blue: UInt8, alpha: UInt8 = 255) {
        self.red = red
        self.green = green
        self.blue = blue
        self.alpha = alpha
        self.isRandom = false
    }

    /// The color components as a tuple of red, green, blue, and alpha values.
    public var components: (red: UInt8, green: UInt8, blue: UInt8, alpha: UInt8) {
        get { (red, green, blue, alpha) }
        set { (red, green, blue, alpha) = newValue }
    }
    
    public var name: String? {
        if isRandom { return "random" }
        guard alpha == 255 else { return nil }
        var index: Int32 = 0
        while true {
            var rgb: UnsafePointer<UInt8>?
            guard let cName = av_get_known_color_name(index, &rgb) else { return nil }
            if let rgb, rgb[0] == red, rgb[1] == green, rgb[2] == blue {
                return String(cString: cName)
            }
            index += 1
        }
    }
    
    /// The names of all colors recognized by FFmpeg.
    public static let knownNames: [String] = {
        var names: [String] = []
        var index: Int32 = 0
        while let name = av_get_known_color_name(index, nil) {
            names.append(String(cString: name))
            index += 1
        }
        return names
    }()
}

