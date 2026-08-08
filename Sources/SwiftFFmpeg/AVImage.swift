//
//  AVImage.swift
//  SwiftFFmpeg
//
//  Created by sunlubo on 2018/7/12.
//

import CFFmpeg

/// An allocated image buffer with FFmpeg-compatible data pointers and line sizes.
public final class AVImage {
    /// The image data pointers for each plane.
    public let data: UnsafeMutableBufferPointer<UnsafeMutablePointer<UInt8>?>
    /// The number of bytes per row for each image plane.
    public let linesizes: UnsafeMutableBufferPointer<Int32>
    /// The total allocated image buffer size in bytes.
    public let size: Int
    /// The image width in pixels.
    public let width: Int
    /// The image height in pixels.
    public let height: Int
    /// The pixel format of the image data.
    public let pixelFormat: AVPixelFormat
    var owned: Bool = false

    /**
     The chroma sample size for the image dimensions, or `nil` if the pixel format has no descriptor.

     This describes chroma sample dimensions only; use image linesizes and data pointers for memory layout.
     */
    public var chromaSize: (width: Int, height: Int)? {
        pixelFormat.descriptor?.chromaSize(forLumaSize: (width, height))
    }
    
    /**
     Allocate an image with the specified size and pixel format.
     
     - Parameters:
        - width: The width of the image.
        - height: The height of the image.
        - pixelFormat: The pixel format of the image.
        - align: the value to use for buffer size alignment, e.g. 1(no alignment), 16, 32, 64
     */
    public init(width: Int, height: Int, pixelFormat: AVPixelFormat, align: Int = 1) {
        let data = UnsafeMutablePointer<UnsafeMutablePointer<UInt8>?>.allocate(capacity: 4)
        data.initialize(to: nil)

        let linesizes = UnsafeMutablePointer<Int32>.allocate(capacity: 4)
        linesizes.initialize(to: 0)

        let ret = av_image_alloc(
            data, linesizes, Int32(width), Int32(height), pixelFormat, Int32(align)
        )
        guard ret >= 0 else {
            abort("av_image_alloc: \(AVError(code: ret))")
        }

        self.data = UnsafeMutableBufferPointer(start: data, count: 4)
        self.linesizes = UnsafeMutableBufferPointer(start: linesizes, count: 4)
        self.size = Int(ret)
        self.width = width
        self.height = height
        self.pixelFormat = pixelFormat
        self.owned = true
    }

    /// Create an image from the given frame.
    public init(frame: AVFrame) {
        precondition(frame.pixelFormat != .none)

        let data = UnsafeMutablePointer<UnsafeMutablePointer<UInt8>?>.allocate(capacity: 4)
        data.initialize(to: nil)
        data.update(from: frame.data.baseAddress!, count: 4)

        let linesizes = UnsafeMutablePointer<Int32>.allocate(capacity: 4)
        linesizes.initialize(to: 0)
        linesizes.update(from: frame.linesize.baseAddress!, count: 4)

        self.data = UnsafeMutableBufferPointer(start: data, count: 4)
        self.size = frame.buffer.reduce(0) { $0 + ($1?.size ?? 0) }
        self.linesizes = UnsafeMutableBufferPointer(start: linesizes, count: 4)
        self.width = frame.width
        self.height = frame.height
        self.pixelFormat = frame.pixelFormat
        self.owned = false
    }

    deinit {
        if owned {
            av_freep(data.baseAddress)
        }
        data.deallocate()
        linesizes.deallocate()
    }

    /// Copy image from the given pixel buffer.
    public func copy(from buffer: UnsafeMutablePointer<UnsafePointer<UInt8>?>, linesizes: UnsafePointer<Int32>) {
        av_image_copy(
            data.baseAddress,
            self.linesizes.baseAddress,
            buffer,
            linesizes,
            pixelFormat,
            Int32(width),
            Int32(height)
        )
    }

    /// Copy image from the given frame.
    public func copy(from frame: AVFrame) {
        frame.data.withMemoryRebound(to: UnsafePointer<UInt8>?.self) { ptr in
            copy(from: ptr.baseAddress!, linesizes: frame.linesize.baseAddress!)
        }
    }
    
    /**
     Reformat image using the given `SwsContext`.
     
     - Returns: The height of the output slice.
     */
    @discardableResult
    public func reformat(using context: SwsContext, to image: AVImage) throws -> Int {
        try data.withMemoryRebound(to: UnsafePointer<UInt8>?.self) { ptr in
            try context.scale(
                src: ptr.baseAddress!,
                srcStride: linesizes.baseAddress!,
                srcSliceY: 0,
                srcSliceHeight: height,
                dst: image.data.baseAddress!,
                dstStride: image.linesizes.baseAddress!
            )
        }
    }
}

public extension AVImage {
    /// Compute the size in bytes of an image line with the specified format and width for the plane.
    static func lineSize(for pixelFormat: AVPixelFormat, width: Int, plane: Int) throws -> Int {
        try throwIfFail(av_image_get_linesize(pixelFormat, Int32(width), Int32(plane)))
    }

    /// Returns the line sizes for the image planes with the specified pixel format and width.
    static func lineSizes(for pixelFormat: AVPixelFormat, width: Int) throws -> [Int] {
        var lineSizes = [Int32](repeating: 0, count: 4)
        try lineSizes.withUnsafeMutableBufferPointer { buffer in
            try throwIfFail(av_image_fill_linesizes(buffer.baseAddress!, pixelFormat, Int32(width)))
        }
        return lineSizes.map(Int.init)
    }

    /// Fill plane data pointers for an image with pixel format and height.
    ///
    /// - Parameters:
    ///   - data: pointers array to be filled with the pointer for each image plane
    ///   - pixelFormat: the pixel format of the image
    ///   - height: the height of the image
    ///   - buffer: the pointer to a buffer which will contain the image
    ///   - linesizes: the array containing the linesize for each plane, should be filled by
    ///     `fillLinesizes(_:pixelFormat:width:)`
    /// - Returns: the size in bytes required for the image buffer
    /// - Throws: AVError
    @discardableResult
    static func fillPointers(
        _ data: UnsafeMutablePointer<UnsafeMutablePointer<UInt8>?>,
        pixelFormat: AVPixelFormat,
        height: Int,
        buffer: UnsafeMutablePointer<UInt8>?,
        lineSizes: UnsafePointer<Int32>?
    ) throws -> Int {
        try throwIfFail(av_image_fill_pointers(data, pixelFormat, Int32(height), buffer, lineSizes))
    }

    /// Return the size in bytes of the amount of data required to store an image with the given parameters.
    ///
    /// - Parameters:
    ///   - pixelFormat: the pixel format of the image
    ///   - width: the width of the image in pixels
    ///   - height: the height of the image in pixels
    ///   - align: the assumed linesize alignment
    /// - Returns: the buffer size in bytes
    /// - Throws: AVError
    static func bufferSize(for pixelFormat: AVPixelFormat, width: Int, height: Int, align: Int = 1) throws -> Int {
        try throwIfFail(av_image_get_buffer_size(pixelFormat, Int32(width), Int32(height), Int32(align)))
    }
}

public extension AVFrame {
    /**
     Creates a pixel buffer containing a contiguous copy of the frame image data.

     - Parameter align: The assumed line-size alignment for the destination buffer.
     - Returns: A newly allocated buffer containing the copied image data.
     */
    func makePixelBuffer(align: Int = 1) throws -> UnsafeMutableBufferPointer<UInt8> {
        let size = try bufferSize(align: align)
        let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: size)
        do {
            let written = try copyImageData(to: buffer, size: size, align: align)
            return UnsafeMutableBufferPointer(start: buffer, count: written)
        } catch {
            buffer.deallocate()
            throw error
        }
    }

    /**
     Copies the frame image data into a contiguous destination buffer.

     - Parameters:
       - buffer: The destination buffer.
       - size: The destination buffer size in bytes.
       - align: The assumed line-size alignment for the destination buffer.
     - Returns: The number of bytes written to the destination buffer.
     */
    @discardableResult
    func copyImageData(to buffer: UnsafeMutablePointer<UInt8>, size: Int, align: Int = 1) throws -> Int {
        try data.withMemoryRebound(to: UnsafePointer<UInt8>?.self) { ptr -> Int in
            try throwIfFail(av_image_copy_to_buffer(
                buffer,
                Int32(size),
                ptr.baseAddress,
                linesize.baseAddress!,
                pixelFormat,
                Int32(width),
                Int32(height),
                Int32(align)
            ))
        }
    }
    
    /**
     Returns the required contiguous image buffer size for the frame dimensions and pixel format.
     
     - Parameter align: The assumed line-size alignment for the destination buffer.
     */
    func bufferSize(align: Int = 1) throws -> Int {
        try av_image_get_buffer_size(pixelFormat, Int32(width),  Int32(height), Int32(align)).throwIfFail()
    }
}
