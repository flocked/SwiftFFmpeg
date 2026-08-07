//
//  AVImageSize.swift
//  SwiftFFmpeg
//
//  Created by Florian Zand on 07.08.26.
//

import Foundation

/// A two-dimensional image size in pixels.
public struct AVImageSize {
    /// The image width in pixels.
    public var width: Int

    /// The image height in pixels.
    public var height: Int
    
    var nativeValues: [Int32] {
        [Int32(width), Int32(height)]
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
}
