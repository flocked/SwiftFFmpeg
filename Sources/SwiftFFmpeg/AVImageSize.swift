//
//  AVImageSize.swift
//  
//
//  Created by Florian Zand on 07.08.26.
//

import CFFmpeg

/// A two-dimensional image size in pixels.
public struct AVImageSize: CustomStringConvertible {
    /// The image width in pixels.
    public var width: Int

    /// The image height in pixels.
    public var height: Int
    
    var nativeValues: [Int32] {
        [Int32(width), Int32(height)]
    }
    
    public var description: String {
        "(\(width), \(height))"
    }
    
    /// Creates an image size with the specified width and height, in pixels.
    public init(width: Int, height: Int) {
        self.width = width
        self.height = height
    }

    /// Creates an image size with the specified width and height, in pixels.
    public init(_ width: Int, _ height: Int) {
        self.width = width
        self.height = height
    }
    
    /// Creates an image size with the specified name.
    public init?(name: String) {
        var width: Int32 = 0
        var height: Int32 = 0
        guard av_parse_video_size(&width, &height, name) >= 0 else { return nil }
        self.init(width: Int(width), height: Int(height))
    }
}
