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
}
