//
//  thumbnail.swift
//  SwiftFFmpeg
//
//  Created by Florian Zand on 09.08.26.
//

import Foundation
import SwiftFFmpeg
import CoreGraphics
import ImageIO
import UniformTypeIdentifiers

private struct ThumbnailOptions {
    let inputURL: URL
    let outputURL: URL?
    let count: Int
    let maxWidth: Int?
}

private func parseThumbnailOptions() -> ThumbnailOptions? {
    guard CommandLine.arguments.count >= 3 else {
        print(
            """
            Usage: \(CommandLine.arguments[0]) \(CommandLine.arguments[1]) video_path [output_path] [thumbnail_count] [max_width]
            """
        )
        return nil
    }

    let inputURL = URL(fileURLWithPath: CommandLine.arguments[2])
    var outputURL: URL?
    var count: Int?
    var maxWidth: Int?
    var index = 3

    if index < CommandLine.arguments.count, Int(CommandLine.arguments[index]) == nil {
        outputURL = URL(fileURLWithPath: CommandLine.arguments[index])
        index += 1
    }

    if index < CommandLine.arguments.count {
        count = Int(CommandLine.arguments[index])
        index += 1
    }

    if index < CommandLine.arguments.count {
        maxWidth = Int(CommandLine.arguments[index])
    }

    return ThumbnailOptions(
        inputURL: inputURL,
        outputURL: outputURL,
        count: max(count ?? 1, 1),
        maxWidth: maxWidth.map { max($0, 1) }
    )
}

private func openThumbnailDecoder(formatContext: AVFormatContext) throws -> (AVCodecContext, Int) {
    guard let streamIndex = formatContext.findBestStream(type: .video) else {
        throw AVError.streamNotFound
    }

    let stream = formatContext.streams[streamIndex]
    guard let decoder = AVCodec.decoder(for: stream.codecParameters.codecId) else {
        throw AVError.decoderNotFound
    }

    let codecContext = AVCodecContext(codec: decoder)
    codecContext.setParameters(stream.codecParameters)
    try codecContext.openCodec()
    return (codecContext, streamIndex)
}

private func thumbnailTimes(duration: Double, count: Int) -> [Double] {
    guard count > 1 else {
        return [duration / 2]
    }

    return (1 ... count).map { index in
        duration * Double(index) / Double(count + 1)
    }
}

private func outputURL(
    inputURL: URL,
    outputURL: URL?,
    index: Int,
    count: Int
) throws -> URL {
    let fileManager = FileManager.default
    let baseName = inputURL.deletingPathExtension().lastPathComponent
    let directory: URL

    if let outputURL, count == 1, !outputURL.pathExtension.isEmpty {
        try fileManager.createDirectory(
            at: outputURL.deletingLastPathComponent(),
            withIntermediateDirectories: true
        )
        return outputURL
    } else if let outputURL {
        directory = outputURL
    } else {
        directory = inputURL.deletingLastPathComponent()
    }

    try fileManager.createDirectory(at: directory, withIntermediateDirectories: true)

    let suffix = count == 1 ? "thumbnail" : String(format: "thumbnail-%03d", index + 1)
    return directory.appendingPathComponent("\(baseName)-\(suffix).png")
}

private func imageSize(for frame: AVFrame, maxWidth: Int?) -> (width: Int, height: Int) {
    guard let maxWidth, frame.width > maxWidth else {
        return (frame.width, frame.height)
    }

    let scale = Double(maxWidth) / Double(frame.width)
    return (maxWidth, max(Int(Double(frame.height) * scale), 1))
}

private func cgImage(from frame: AVFrame, maxWidth: Int?) throws -> CGImage {
    let size = imageSize(for: frame, maxWidth: maxWidth)
    let image = AVImage(width: size.width, height: size.height, pixelFormat: .rgba)

    guard let scaler = SwsContext(
        srcWidth: frame.width,
        srcHeight: frame.height,
        srcPixelFormat: frame.pixelFormat,
        dstWidth: size.width,
        dstHeight: size.height,
        dstPixelFormat: .rgba,
        flags: .bicubic
    ) else {
        throw AVError.invalidValue
    }

    try AVImage(frame: frame).reformat(using: scaler, to: image)

    let bytesPerRow = Int(image.linesizes[0])
    let byteCount = bytesPerRow * image.height
    let data = Data(bytes: image.data[0]!, count: byteCount)

    guard let provider = CGDataProvider(data: data as CFData),
          let cgImage = CGImage(
            width: image.width,
            height: image.height,
            bitsPerComponent: 8,
            bitsPerPixel: 32,
            bytesPerRow: bytesPerRow,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.last.rawValue | CGImageByteOrderInfo.order32Big.rawValue),
            provider: provider,
            decode: nil,
            shouldInterpolate: true,
            intent: .defaultIntent
          ) else {
        throw AVError.invalidValue
    }

    return cgImage
}

private func writePNG(_ image: CGImage, to url: URL) throws {
    guard let destination = CGImageDestinationCreateWithURL(url as CFURL, UTType.png.identifier as CFString, 1, nil) else {
        throw AVError.invalidValue
    }

    CGImageDestinationAddImage(destination, image, nil)

    guard CGImageDestinationFinalize(destination) else {
        throw AVError.invalidValue
    }
}

private func decodeFrame(
    formatContext: AVFormatContext,
    codecContext: AVCodecContext,
    streamIndex: Int,
    seconds: Double,
    body: (AVFrame) throws -> Void
) throws -> Bool {
    let stream = formatContext.streams[streamIndex]
    let targetTimestamp = Int64(seconds / stream.timebase.toDouble)
    try formatContext.seekFrame(toSeconds: seconds, streamIndex: streamIndex, flags: .backward)
    formatContext.flush()
    codecContext.flush()

    let packet = AVPacket()
    let frame = AVFrame()

    while true {
        do {
            try formatContext.readFrame(into: packet)
        } catch let error as AVError where error == .eof {
            break
        }

        defer { packet.unref() }
        guard packet.streamIndex == streamIndex else {
            continue
        }

        try codecContext.sendPacket(packet)

        while true {
            do {
                try codecContext.receiveFrame(frame)
            } catch let error as AVError where error == .tryAgain || error == .eof {
                break
            }

            let timestamp = frame.bestEffortTimestamp
            if timestamp == AVTimestamp.noPTS || timestamp >= targetTimestamp {
                try body(frame)
                frame.unref()
                return true
            }

            frame.unref()
        }
    }

    try codecContext.sendPacket(nil)

    while true {
        do {
            try codecContext.receiveFrame(frame)
        } catch let error as AVError where error == .tryAgain || error == .eof {
            return false
        }

        try body(frame)
        frame.unref()
        return true
    }
}

func thumbnail() throws {
    guard let options = parseThumbnailOptions() else {
        return
    }

    let formatContext = try AVFormatContext(url: options.inputURL)
    try formatContext.findStreamInfo()

    guard let duration = formatContext.durationSeconds, duration > 0 else {
        throw AVError.invalidValue
    }

    let (codecContext, streamIndex) = try openThumbnailDecoder(formatContext: formatContext)
    let times = thumbnailTimes(duration: duration, count: options.count)

    for (index, seconds) in times.enumerated() {
        let destination = try outputURL(
            inputURL: options.inputURL,
            outputURL: options.outputURL,
            index: index,
            count: times.count
        )

        let wroteImage = try decodeFrame(
            formatContext: formatContext,
            codecContext: codecContext,
            streamIndex: streamIndex,
            seconds: seconds
        ) { frame in
            let image = try cgImage(from: frame, maxWidth: options.maxWidth)
            try writePNG(image, to: destination)
        }

        if wroteImage {
            print("Wrote \(destination.path)")
        }
    }
}
