//
//  AVAudioFifo.swift
//  SwiftFFmpeg
//
//  Created by Florian Zand on 09.08.26.
//

import CFFmpeg

/**
 A first-in, first-out buffer for audio samples.

 The FIFO stores audio samples using a fixed sample format and channel count
 and automatically grows as needed when samples are written.
 */
public final class AVAudioFifo {
    let native: OpaquePointer

    /// The sample format of the audio stored in the FIFO.
    public let sampleFormat: AVSampleFormat

    /// The number of audio channels stored in the FIFO.
    public let channelCount: Int

    /**
     Creates a new audio FIFO.

     - Parameters:
       - sampleFormat: The sample format of the audio stored in the FIFO.
       - channelCount: The number of audio channels.
       - capacity: The initial capacity of the FIFO, in samples.
     - Throws: An `AVError` if the FIFO couldn't be allocated.
     */
    public init(
        sampleFormat: AVSampleFormat,
        channelCount: Int,
        capacity: Int = 1
    ) throws {
        guard let native = av_audio_fifo_alloc(
            sampleFormat.native,
            Int32(channelCount),
            Int32(capacity)
        ) else {
            throw AVError.unknown
        }

        self.native = native
        self.sampleFormat = sampleFormat
        self.channelCount = channelCount
    }

    deinit {
        av_audio_fifo_free(native)
    }

    /// The number of samples currently stored in the FIFO.
    public var sampleCount: Int {
        Int(av_audio_fifo_size(native))
    }

    /// The number of samples that can be written without reallocating the FIFO.
    public var space: Int {
        Int(av_audio_fifo_space(native))
    }

    /// Removes all samples from the FIFO.
    public func reset() {
        av_audio_fifo_reset(native)
    }

    /**
     Removes the specified number of samples from the FIFO.

     - Parameter sampleCount: The number of samples to remove.
     - Throws: An `AVError` if the samples couldn't be removed.
     */
    public func drain(_ sampleCount: Int) throws {
        try av_audio_fifo_drain(native, Int32(sampleCount)).throwIfFail()
    }

    /**
     Reserves capacity for the specified number of samples.

     - Parameter sampleCount: The number of samples the FIFO should be able to store.
     - Throws: An `AVError` if the FIFO couldn't be reallocated.
     */
    public func reserveCapacity(_ sampleCount: Int) throws {
        try av_audio_fifo_realloc(native, Int32(sampleCount)).throwIfFail()
    }

    /**
     Writes the audio samples of a frame to the FIFO.

     The frame must use the sample format and channel count of the FIFO.

     - Parameter frame: The audio frame containing the samples to write.
     - Returns: The number of samples written.
     - Throws: An `AVError` if the samples couldn't be written.
     */
    @discardableResult
    public func write(_ frame: AVFrame) throws -> Int {
        var data = try dataPointers(for: frame)

        let written = data.withUnsafeMutableBufferPointer { data in
            av_audio_fifo_write(
                native,
                data.baseAddress,
                Int32(frame.sampleCount)
            )
        }

        try written.throwIfFail()

        guard written == frame.sampleCount else {
            throw AVError.invalidData
        }

        return Int(written)
    }

    /**
     Reads audio samples from the FIFO into a new audio frame.

     If the FIFO contains fewer samples than requested, the returned frame contains the available samples.

     - Parameters:
       - sampleCount: The number of samples to read.
       - sampleRate: The sample rate to assign to the returned frame.
       - channelLayout: The channel layout to assign to the returned frame.
     - Returns: An audio frame containing the samples read from the FIFO.
     - Throws: An `AVError` if the frame couldn't be allocated or the samples couldn't be read.
     */
    public func read(
        sampleCount: Int,
        sampleRate: Int,
        channelLayout: AVChannelLayout
    ) throws -> AVFrame {
        let frame = AVFrame()
        try read(
            sampleCount: sampleCount,
            sampleRate: sampleRate,
            channelLayout: channelLayout,
            into: frame
        )
        return frame
    }

    /**
     Reads audio samples from the FIFO into an audio frame.

     If the frame already has compatible writable buffers, they are reused.
     If the FIFO contains fewer samples than requested, the frame contains the available samples.

     - Parameters:
       - sampleCount: The number of samples to read.
       - sampleRate: The sample rate to assign to the frame.
       - channelLayout: The channel layout to assign to the frame.
       - frame: The audio frame that receives the samples.
     - Returns: The number of samples read from the FIFO.
     - Throws: An `AVError` if the frame couldn't be allocated or the samples couldn't be read.
     */
    @discardableResult
    public func read(
        sampleCount: Int,
        sampleRate: Int,
        channelLayout: AVChannelLayout,
        into frame: AVFrame
    ) throws -> Int {
        try prepareFrame(
            frame,
            sampleCount: sampleCount,
            sampleRate: sampleRate,
            channelLayout: channelLayout
        )

        var data = try dataPointers(for: frame)

        let read = data.withUnsafeMutableBufferPointer { data in
            av_audio_fifo_read(
                native,
                data.baseAddress,
                Int32(sampleCount)
            )
        }

        try read.throwIfFail()
        frame.sampleCount = Int(read)

        return Int(read)
    }

    /**
     Reads exactly the requested number of audio samples from the FIFO into a new audio frame.

     - Parameters:
       - sampleCount: The number of samples to read.
       - sampleRate: The sample rate to assign to the returned frame.
       - channelLayout: The channel layout to assign to the returned frame.
     - Returns: An audio frame containing the samples read from the FIFO.
     - Throws: An `AVError` if the FIFO contains fewer than the requested number of samples.
     */
    public func readExactly(
        sampleCount: Int,
        sampleRate: Int,
        channelLayout: AVChannelLayout
    ) throws -> AVFrame {
        let frame = AVFrame()
        try readExactly(
            sampleCount: sampleCount,
            sampleRate: sampleRate,
            channelLayout: channelLayout,
            into: frame
        )
        return frame
    }

    /**
     Reads exactly the requested number of audio samples from the FIFO into an audio frame.

     - Parameters:
       - sampleCount: The number of samples to read.
       - sampleRate: The sample rate to assign to the frame.
       - channelLayout: The channel layout to assign to the frame.
       - frame: The audio frame that receives the samples.
     - Throws: An `AVError` if the FIFO contains fewer than the requested number of samples.
     */
    public func readExactly(
        sampleCount: Int,
        sampleRate: Int,
        channelLayout: AVChannelLayout,
        into frame: AVFrame
    ) throws {
        guard self.sampleCount >= sampleCount else {
            throw AVError.invalidData
        }

        try read(
            sampleCount: sampleCount,
            sampleRate: sampleRate,
            channelLayout: channelLayout,
            into: frame
        )
    }

    /**
     Peeks audio samples from the FIFO into a new audio frame without removing them.

     If the FIFO contains fewer samples than requested, the returned frame contains the available samples.

     - Parameters:
       - sampleCount: The number of samples to peek.
       - sampleRate: The sample rate to assign to the returned frame.
       - channelLayout: The channel layout to assign to the returned frame.
     - Returns: An audio frame containing the samples peeked from the FIFO.
     - Throws: An `AVError` if the frame couldn't be allocated or the samples couldn't be peeked.
     */
    public func peek(
        sampleCount: Int,
        sampleRate: Int,
        channelLayout: AVChannelLayout
    ) throws -> AVFrame {
        try peek(
            sampleCount: sampleCount,
            offset: 0,
            sampleRate: sampleRate,
            channelLayout: channelLayout
        )
    }

    /**
     Peeks audio samples from the FIFO at the given offset without removing them.

     If the FIFO contains fewer samples than requested after the offset, the returned frame contains the available samples.

     - Parameters:
       - sampleCount: The number of samples to peek.
       - offset: The sample offset from the current read position.
       - sampleRate: The sample rate to assign to the returned frame.
       - channelLayout: The channel layout to assign to the returned frame.
     - Returns: An audio frame containing the samples peeked from the FIFO.
     - Throws: An `AVError` if the frame couldn't be allocated or the samples couldn't be peeked.
     */
    public func peek(
        sampleCount: Int,
        offset: Int,
        sampleRate: Int,
        channelLayout: AVChannelLayout
    ) throws -> AVFrame {
        let frame = try makeFrame(
            sampleCount: sampleCount,
            sampleRate: sampleRate,
            channelLayout: channelLayout
        )

        var data = try dataPointers(for: frame)

        let read = data.withUnsafeMutableBufferPointer { data in
            av_audio_fifo_peek_at(
                native,
                data.baseAddress,
                Int32(sampleCount),
                Int32(offset)
            )
        }

        try read.throwIfFail()
        frame.sampleCount = Int(read)

        return frame
    }

    /**
     Peeks exactly the requested number of audio samples from the FIFO without removing them.

     - Parameters:
       - sampleCount: The number of samples to peek.
       - sampleRate: The sample rate to assign to the returned frame.
       - channelLayout: The channel layout to assign to the returned frame.
     - Returns: An audio frame containing the samples peeked from the FIFO.
     - Throws: An `AVError` if the FIFO contains fewer than the requested number of samples.
     */
    public func peekExactly(
        sampleCount: Int,
        sampleRate: Int,
        channelLayout: AVChannelLayout
    ) throws -> AVFrame {
        guard self.sampleCount >= sampleCount else {
            throw AVError.invalidData
        }

        return try peek(
            sampleCount: sampleCount,
            sampleRate: sampleRate,
            channelLayout: channelLayout
        )
    }

    private func makeFrame(
        sampleCount: Int,
        sampleRate: Int,
        channelLayout: AVChannelLayout
    ) throws -> AVFrame {
        guard channelLayout.channelCount == channelCount else {
            throw AVError.invalidData
        }

        let frame = AVFrame()
        frame.sampleFormat = sampleFormat
        frame.sampleRate = sampleRate
        frame.channelLayout = channelLayout
        frame.sampleCount = sampleCount

        try frame.allocBuffer()
        return frame
    }

    private func prepareFrame(
        _ frame: AVFrame,
        sampleCount: Int,
        sampleRate: Int,
        channelLayout: AVChannelLayout
    ) throws {
        guard channelLayout.channelCount == channelCount else {
            throw AVError.invalidData
        }

        if frame.native.pointee.data.0 != nil &&
            frame.sampleFormat == sampleFormat &&
            frame.sampleRate == sampleRate &&
            frame.channelLayout.channelCount == channelCount &&
            frame.sampleCount == sampleCount {
            try frame.makeWritable()
            return
        }

        frame.unref()
        frame.sampleFormat = sampleFormat
        frame.sampleRate = sampleRate
        frame.channelLayout = channelLayout
        frame.sampleCount = sampleCount
        try frame.allocBuffer()
    }

    private func dataPointers(for frame: AVFrame) throws -> [UnsafeMutableRawPointer?] {
        guard frame.sampleFormat == sampleFormat,
              frame.channelLayout.channelCount == channelCount else {
            throw AVError.invalidData
        }

        return frame.audioExtendedData.map { pointer in
            pointer.map { UnsafeMutableRawPointer($0) }
        }
    }
}
