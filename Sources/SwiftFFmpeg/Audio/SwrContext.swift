//
//  SwrContext.swift
//  SwiftFFmpeg
//
//  Created by sunlubo on 2018/7/6.
//

import CFFmpeg

public final class SwrContext {
    var native: OpaquePointer!
    public private(set) var inputChannelLayout: AVChannelLayout?
    public private(set) var inputSampleFormat: AVSampleFormat?
    public private(set) var inputSampleRate: Int?

    public private(set) var outputChannelLayout: AVChannelLayout?
    public private(set) var outputSampleFormat: AVSampleFormat?
    public private(set) var outputSampleRate: Int?

    /// Create `SwrContext`.
    ///
    /// If you use this function you will need to set the parameters before calling `initialize()`.
    public init() {
        self.native = swr_alloc()
    }

    /// Creates a resample context from the given parameters.
    public init(
        inputChannelLayout: AVChannelLayout,
        inputSampleFormat: AVSampleFormat,
        inputSampleRate: Int,
        outputChannelLayout: AVChannelLayout,
        outputSampleFormat: AVSampleFormat,
        outputSampleRate: Int
    ) throws {
        var ptr: OpaquePointer?
        var icl = inputChannelLayout
        var ocl = outputChannelLayout
        try swr_alloc_set_opts2(
            &ptr,
            &ocl,
            outputSampleFormat.native,
            Int32(outputSampleRate),
            &icl,
            inputSampleFormat.native,
            Int32(inputSampleRate),
            0,
            nil
        ).throwIfFail()
        self.native = ptr
        self.outputSampleRate = outputSampleRate
        self.outputSampleFormat = outputSampleFormat
        self.outputChannelLayout = outputChannelLayout
        self.inputSampleRate = inputSampleRate
        self.inputSampleFormat = inputSampleFormat
        self.inputChannelLayout = inputChannelLayout
    }
    
    /// Creates a resampler configured from the input and output frame settings.
    public convenience init(from input: AVFrame, to output: AVFrame) throws {
        self.init()
        try configure(from: input, to: output)
    }
    
    
    /**
     Configures or reconfigures the resampler from the input and output frame settings.

     This resets the resampler context even if configuration fails. Flush delayed samples before calling this on a context that has already converted audio.
     */
    public func configure(from input: AVFrame, to output: AVFrame) throws {
        try swr_config_frame(native, output.native, input.native).throwIfFail()

        inputSampleRate = input.sampleRate
        inputSampleFormat = input.sampleFormat
        inputChannelLayout = input.channelLayout

        outputSampleRate = output.sampleRate
        outputSampleFormat = output.sampleFormat
        outputChannelLayout = output.channelLayout
    }

    deinit {
        swr_free(&native)
    }

    /// A Boolean value indicating whether the context has been initialized or not.
    public var isInitialized: Bool {
        swr_is_initialized(native) > 0
    }

    /// Set/reset common parameters.
    ///
    /// - Parameters:
    ///   - dstChannelLayout: output channel layout
    ///   - dstSampleFormat: output sample format
    ///   - dstSampleRate: output sample rate (frequency in Hz)
    ///   - srcChannelLayout: input channel layout
    ///   - srcSampleFormat: input sample format
    ///   - srcSampleRate: input sample rate (frequency in Hz)
    ///
    /// - Throws: AVError
    public func setOptions(
        outputChannelLayout: AVChannelLayout,
        outputSampleFormat: AVSampleFormat,
        outputSampleRate: Int,
        inputChannelLayout: AVChannelLayout,
        inputSampleFormat: AVSampleFormat,
        inputSampleRate: Int
    ) throws {
        var icl = inputChannelLayout
        var ocl = outputChannelLayout
        try swr_alloc_set_opts2(
            &native,
            &ocl,
            outputSampleFormat.native,
            Int32(outputSampleRate),
            &icl,
            inputSampleFormat.native,
            Int32(inputSampleRate),
            0,
            nil
        ).throwIfFail()
        self.outputSampleRate = outputSampleRate
        self.outputSampleFormat = outputSampleFormat
        self.outputChannelLayout = outputChannelLayout
        self.inputSampleRate = inputSampleRate
        self.inputSampleFormat = inputSampleFormat
        self.inputChannelLayout = inputChannelLayout
    }

    /// Initialize context after user parameters have been set.
    ///
    /// - Throws: AVError
    public func initialize() throws {
        try swr_init(native).throwIfFail()
    }

    /// Closes the context so that `isInitialized` returns `false`.
    ///
    /// The context can be brought back to life by running `initialize()`,
    /// `initialize()` can also be used without `close()`.
    /// This function is mainly provided for simplifying the usecase
    /// where one tries to support libavresample and libswresample.
    public func close() {
        swr_close(native)
    }

    /// Gets the delay the next input sample will experience relative to the next output sample.
    ///
    /// - Parameter timebase: timebase in which the returned delay will be
    ///   - if it's set to 1 the returned delay is in seconds
    ///   - if it's set to 1000 the returned delay is in milliseconds
    ///   - if it's set to the input sample rate then the returned delay is in input samples
    ///   - if it's set to the output sample rate then the returned delay is in output samples
    ///   - if it's the least common multiple of `in_sample_rate` and
    ///     `out_sample_rate` then an exact rounding-free delay will be returned
    /// - Returns: the delay in 1 / base units.
    public func getDelay(_ timebase: Int64) -> Int {
        Int(swr_get_delay(native, timebase))
    }

    /// Find an upper bound on the number of samples that the next `convert(dst:dstCount:src:srcCount:)`
    /// call will output, if called with `sampleCount` of input samples.
    /// This depends on the internal state, and anything changing the internal state
    /// (like further `convert(dst:dstCount:src:srcCount:)` calls) will may change the number of samples
    /// `getOutSamples(_:)` returns for the same number of input samples.
    ///
    /// - Note: any call to swr_inject_silence(), swr_convert(), swr_next_pts()
    ///   or swr_set_compensation() invalidates this limit
    ///
    /// - Note: it is recommended to pass the correct available buffer size to all functions like
    ///   `convert(dst:dstCount:src:srcCount:)` even if `getOutSamples(_:)` indicates that less  would be used.
    ///
    /// - Parameter sampleCount: number of input samples
    /// - Returns: an upper bound on the number of samples that the next `convert(dst:dstCount:src:srcCount:)`
    ///   will output
    /// - Throws: AVError
    public func getOutSamples(_ sampleCount: Int64) throws -> Int {
        try swr_get_out_samples(native, Int32(sampleCount)).throwIfFail()
    }

    /// Convert audio.
    ///
    /// Pass `nil` input and an input sample count of `0` to flush delayed samples.
    ///
    /// If more input is provided than output space, then the input will be buffered.
    /// You can avoid this buffering by using `getOutSamples(_:)` to retrieve an upper bound
    /// on the required number of output samples for the given number of input samples.
    /// Conversion will run directly without copying whenever possible.
    ///
    /// - Parameters:
    ///   - dst: output buffers, only the first one need be set in case of packed audio
    ///   - dstCount: amount of space available for output in samples per channel
    ///   - src: input buffers, only the first one need to be set in case of packed audio
    ///   - srcCount: number of input samples available in one channel
    /// - Returns: number of samples output per channel
    /// - Throws: AVError
    @discardableResult
    public func convert(dst: UnsafeMutablePointer<UnsafeMutablePointer<UInt8>?>, dstCount: Int, src: UnsafePointer<UnsafePointer<UInt8>?>?, srcCount: Int) throws -> Int {
        try swr_convert(native, dst, Int32(dstCount), src, Int32(srcCount)).throwIfFail()
    }
}

extension SwrContext {
    /// Converts an audio frame and returns a newly allocated output frame.
    public func convert(_ frame: AVFrame) throws -> AVFrame {
        guard let inputSampleRate,
              let outputSampleRate else {
            throw AVError.invalidData
        }

        let sampleCount = Int(
            AVMath.rescale(
                swr_get_delay(native, Int64(inputSampleRate)) + Int64(frame.sampleCount),
                Int64(outputSampleRate),
                Int64(inputSampleRate),
                rounding: .up
            )
        )

        let destination = try makeOutputFrame(sampleCount: sampleCount)
        try convert(frame, to: destination)
        return destination
    }

    /**
     Converts an audio frame into an existing output frame.

     The output frame must use the destination sample format, sample rate and channel layout, and its
     `sampleCount` is used as the available output capacity before being updated to the converted sample count.
     */
    public func convert(_ frame: AVFrame, to outputFrame: AVFrame) throws {
        guard let outputSampleRate,
              let outputChannelLayout,
              let outputSampleFormat,
              outputFrame.sampleRate == outputSampleRate,
              outputFrame.sampleFormat == outputSampleFormat,
              outputFrame.channelLayout == outputChannelLayout,
              outputFrame.sampleCount > 0 else {
            throw AVError.invalidData
        }

        let sourceData: [UnsafePointer<UInt8>?] = frame.audioExtendedData.map { pointer in
            pointer.map { UnsafePointer<UInt8>($0) }
        }

        outputFrame.sampleCount = try sourceData.withUnsafeBufferPointer { sourceData in
            guard let dst = outputFrame.audioExtendedData.baseAddress,
                  let src = sourceData.baseAddress else {
                throw AVError.invalidData
            }

            return try convert(
                dst: dst,
                dstCount: outputFrame.sampleCount,
                src: src,
                srcCount: frame.sampleCount
            )
        }
    }
    
    public func flush() throws -> AVFrame? {
        let sampleCount: Int = try swr_get_out_samples(native, 0).throwIfFail()

        guard sampleCount > 0 else {
            return nil
        }

        let frame = try makeOutputFrame(sampleCount: sampleCount)

        guard let dst = frame.audioExtendedData.baseAddress else {
            throw AVError.invalidData
        }

        let converted: Int = try swr_convert(
            native,
            dst,
            Int32(sampleCount),
            nil,
            0
        ).throwIfFail()

        guard converted > 0 else {
            return nil
        }

        frame.sampleCount = Int(converted)
        return frame
    }
    
    private func makeOutputFrame(sampleCount: Int) throws -> AVFrame {
        guard let outputSampleRate,
              let outputChannelLayout,
              let outputSampleFormat else {
            throw AVError.invalidData
        }

        let frame = AVFrame()
        frame.sampleRate = outputSampleRate
        frame.sampleFormat = outputSampleFormat
        frame.channelLayout = outputChannelLayout
        frame.sampleCount = sampleCount

        try frame.allocBuffer()
        return frame
    }
}

extension SwrContext: AVClassSupport {
    public static let `class` = AVClass(native: swr_get_class())

    public func withUnsafeObjectPointer<T>(_ body: (UnsafeMutableRawPointer) throws -> T) rethrows -> T {
        try body(UnsafeMutableRawPointer(native))
    }
}
