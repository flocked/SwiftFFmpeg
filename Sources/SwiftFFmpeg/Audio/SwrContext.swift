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
    /// `dst` and `dstCount` can be set to 0 to flush the last few samples out at the end.
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
    public func convert(dst: UnsafeMutablePointer<UnsafeMutablePointer<UInt8>?>, dstCount: Int, src: UnsafePointer<UnsafePointer<UInt8>?>, srcCount: Int) throws -> Int {
        try swr_convert(native, dst, Int32(dstCount), src, Int32(srcCount)).throwIfFail()
    }
}

extension SwrContext {
    public func convert(_ frame: AVFrame) throws -> AVFrame {
        guard let sampleRate = outputSampleRate, let channelLayout = outputChannelLayout, let sampleFormat = outputSampleFormat, let inputSampleRate = inputSampleRate else {
            throw AVError.invalidData
        }
        return try convert(frame, to: sampleFormat, sampleRate: sampleRate, channelLayout: channelLayout, inputSampleRate: inputSampleRate)
    }
    

    private func convert(_ frame: AVFrame, to sampleFormat: AVSampleFormat, sampleRate: Int, channelLayout: AVChannelLayout, inputSampleRate: Int) throws -> AVFrame {
        let dst = AVFrame()
        dst.sampleFormat = sampleFormat
        dst.sampleRate = sampleRate
        dst.channelLayout = channelLayout

        let dstCount = Int(
            AVMath.rescale(
                swr_get_delay(native, Int64(inputSampleRate)) + Int64(frame.sampleCount),
                Int64(sampleRate),
                Int64(inputSampleRate),
                rounding: .up))
        dst.sampleCount = dstCount
        try dst.allocBuffer()
        let srcData: [UnsafePointer<UInt8>?] = frame.extendedData.map { pointer in
            pointer.map { UnsafePointer<UInt8>($0) }
        }
        let converted = try srcData.withUnsafeBufferPointer { srcData in
            guard let dstData = dst.extendedData.baseAddress,
                  let srcData = srcData.baseAddress
            else { throw AVError.invalidData }
            return try convert(dst: dstData, dstCount: dstCount, src: srcData, srcCount: frame.sampleCount)
        }
        dst.sampleCount = converted
        return dst
    }
}

extension SwrContext: AVClassSupport {
    public static let `class` = AVClass(native: swr_get_class())

    public func withUnsafeObjectPointer<T>(_ body: (UnsafeMutableRawPointer) throws -> T) rethrows -> T {
        try body(UnsafeMutableRawPointer(native))
    }
}
