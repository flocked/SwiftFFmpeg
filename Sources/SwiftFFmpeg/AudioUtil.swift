//
//  AudioUtil.swift
//  SwiftFFmpeg
//
//  Created by sunlubo on 2018/8/2.
//

import CFFmpeg.AVUtil

public typealias AVChannelLayout = CFFmpeg.AVChannelLayout

public extension AVChannelLayout {
    /// Initialize a channel layout from a given string description.
    ///
    /// The input string can be represented by:
    ///  - the formal channel layout name (returned by av_channel_layout_describe())
    ///  - single or multiple channel names (returned by av_channel_name(), eg. "FL",
    ///    or concatenated with "+", each optionally containing a custom name after
    ///    a "@", eg. "FL@Left+FR@Right+LFE")
    ///  - a decimal or hexadecimal value of a native channel layout (eg. "4" or "0x4")
    ///  - the number of channels with default layout (eg. "4c")
    ///  - the number of unordered channels (eg. "4C" or "4 channels")
    ///  - the ambisonic order followed by optional non-diegetic channels (eg.
    ///    "ambisonic 2+stereo")
    ///
    /// - Parameter name: string describing the channel layout
    init?(name: String) {
        var channelLayout = AVChannelLayout()
        guard av_channel_layout_from_string(&channelLayout, name) != 0 else { return nil }
        self = channelLayout
    }

    /// The number of channels in the channel layout.
    var channelCount: Int {
        Int(nb_channels)
    }
    
    func sdsds() {
        
    }

    /// Get the index of a given channel in a channel layout.
    /// In case multiple channels are found, only the first match will be returned.
    func index(for channel: AVChannel) -> Int? {
        let i = withUnsafePointer(to: self) { ptr in
            av_channel_layout_index_from_channel(ptr, channel)
        }
        return i >= 0 ? Int(i) : nil
    }

    /// Get the channel with the given index in a channel layout.
    func channel(at index: Int) -> AVChannel? {
        let c = withUnsafePointer(to: self) { ptr in
            av_channel_layout_channel_from_index(ptr, UInt32(index))
        }
        return c != AV_CHAN_NONE ? c : nil
    }

    /// Get the default channel layout for a given number of channels.
    static func `default`(for channelCount: Int) -> AVChannelLayout {
        var cl = AVChannelLayout()
        av_channel_layout_default(&cl, Int32(channelCount))
        return cl
    }
}

extension AVChannelLayout: @retroactive Equatable, @retroactive CustomStringConvertible {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.u.mask == rhs.u.mask
    }
    
    public var description: String {
        let buf = UnsafeMutablePointer<Int8>.allocate(capacity: 256)
        buf.initialize(to: 0)
        defer { buf.deallocate() }
        let r = withUnsafePointer(to: self) { p in
            av_channel_layout_describe(p, buf, 256)
        }
        return r >= 0 ? String(cString: buf) : "Invalid"
    }
}

public extension AVChannelLayout {
    /// A mono channel layout.
    static let mono = AVChannelLayoutMono
    /// A stereo channel layout.
    static let stereo = AVChannelLayoutStereo
    /// A 2.1 channel layout.
    static let twoPointOne = AVChannelLayout2Point1
    /// A 2-1 channel layout.
    static let twoOne = AVChannelLayout2_1
    /// A 3.0 surround channel layout.
    static let surround = AVChannelLayoutSurround
    /// A 3.1 channel layout.
    static let threePointOne = AVChannelLayout3Point1
    /// A 4.0 channel layout.
    static let fourPointZero = AVChannelLayout4Point0
    /// A 4.1 channel layout.
    static let fourPointOne = AVChannelLayout4Point1
    /// A 2-2 channel layout.
    static let twoTwo = AVChannelLayout2_2
    /// A quadraphonic channel layout.
    static let quad = AVChannelLayoutQuad
    /// A 5.0 channel layout.
    static let fivePointZero = AVChannelLayout5Point0
    /// A 5.1 channel layout.
    static let fivePointOne = AVChannelLayout5Point1
    /// A 5.0 channel layout with back channels.
    static let fivePointZeroBack = AVChannelLayout5Point0Back
    /// A 5.1 channel layout with back channels.
    static let fivePointOneBack = AVChannelLayout5Point1Back
    /// A 6.0 channel layout.
    static let sixPointZero = AVChannelLayout6Point0
    /// A 6.0 channel layout with front channels.
    static let sixPointZeroFront = AVChannelLayout6Point0Front
    /// A hexagonal channel layout.
    static let hexagonal = AVChannelLayoutHexagonal
    /// A 6.1 channel layout.
    static let sixPointOne = AVChannelLayout6Point1
    /// A 6.1 channel layout with back channels.
    static let sixPointOneBack = AVChannelLayout6Point1Back
    /// A 6.1 channel layout with front channels.
    static let sixPointOneFront = AVChannelLayout6Point1Front
    /// A 7.0 channel layout.
    static let sevenPointZero = AVChannelLayout7Point0
    /// A 7.0 channel layout with front channels.
    static let sevenPointZeroFront = AVChannelLayout7Point0Front
    /// A 7.1 channel layout.
    static let sevenPointOne = AVChannelLayout7Point1
    /// A wide 7.1 channel layout.
    static let sevenPointOneWide = AVChannelLayout7Point1Wide
    /// A wide 7.1 channel layout with back channels.
    static let sevenPointOneWideBack = AVChannelLayout7Point1WideBack
    /// An octagonal channel layout.
    static let octagonal = AVChannelLayoutOctagonal
    /// A hexadecagonal channel layout.
    static let hexadecagonal = AVChannelLayoutHexadecagonal
    /// A stereo downmix channel layout.
    static let stereoDownmix = AVChannelLayoutStereoDownmix
    /// A 22.2 channel layout.
    static let twentyTwoPointTwo = AVChannelLayout22Point2
}
