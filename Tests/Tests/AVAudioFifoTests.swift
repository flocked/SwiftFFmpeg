//
//  AVAudioFifoTests.swift
//  Tests
//
//  Created by Florian Zand on 10.08.26.
//

import XCTest

@testable import SwiftFFmpeg

final class AVAudioFifoTests: XCTestCase {

  static var allTests = [
    ("testPartialReadAndStrictRead", testPartialReadAndStrictRead)
  ]

  func testPartialReadAndStrictRead() throws {
    let channelLayout = AVChannelLayout.stereo
    let fifo = try AVAudioFifo(
      sampleFormat: .int16,
      channelCount: channelLayout.channelCount
    )

    let frame = AVFrame()
    frame.sampleFormat = .int16
    frame.sampleRate = 48_000
    frame.channelLayout = channelLayout
    frame.sampleCount = 4
    try frame.allocBuffer()

    XCTAssertEqual(try fifo.write(frame), 4)
    XCTAssertEqual(fifo.sampleCount, 4)

    let peeked = try fifo.peek(
      sampleCount: 10,
      sampleRate: 48_000,
      channelLayout: channelLayout
    )
    XCTAssertEqual(peeked.sampleCount, 4)
    XCTAssertEqual(fifo.sampleCount, 4)

    XCTAssertThrowsError(
      try fifo.readExactly(
        sampleCount: 5,
        sampleRate: 48_000,
        channelLayout: channelLayout
      )
    )

    let read = try fifo.read(
      sampleCount: 10,
      sampleRate: 48_000,
      channelLayout: channelLayout
    )
    XCTAssertEqual(read.sampleCount, 4)
    XCTAssertEqual(fifo.sampleCount, 0)
  }

  func testReadIntoExistingFrame() throws {
    let channelLayout = AVChannelLayout.stereo
    let fifo = try AVAudioFifo(
      sampleFormat: .int16,
      channelCount: channelLayout.channelCount
    )

    let input = AVFrame()
    input.sampleFormat = .int16
    input.sampleRate = 48_000
    input.channelLayout = channelLayout
    input.sampleCount = 4
    try input.allocBuffer()

    let output = AVFrame()

    XCTAssertEqual(try fifo.write(input), 4)
    XCTAssertEqual(
      try fifo.read(
        sampleCount: 4,
        sampleRate: 48_000,
        channelLayout: channelLayout,
        into: output
      ),
      4
    )
    XCTAssertEqual(output.sampleCount, 4)
    XCTAssertEqual(output.sampleRate, 48_000)
    XCTAssertEqual(output.sampleFormat, .int16)
    XCTAssertEqual(output.channelLayout.channelCount, channelLayout.channelCount)
    XCTAssertEqual(fifo.sampleCount, 0)
  }
}
