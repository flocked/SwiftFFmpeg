//
//  AVImageTests.swift
//  Tests
//
//  Created by sunlubo on 2018/8/5.
//

import XCTest

@testable import SwiftFFmpeg

final class AVImageTests: XCTestCase {

  static var allTests = [
    ("testBuf", testBuf),
    ("testLinesizes", testLinesizes),
    ("testTotalSize", testTotalSize),
  ]

  let width = 1080
  let height = 1920
  let pixelFormat = AVPixelFormat.yuv422p
  var image: AVImage!

  override func setUp() {
    super.setUp()

    image = AVImage(width: width, height: height, pixelFormat: pixelFormat, align: 1)
  }

  func testBuf() {
    XCTAssertNotNil(image.data[0])
    XCTAssertNotNil(image.data[1])
    XCTAssertNotNil(image.data[2])
    XCTAssertNil(image.data[3])

    var data = [UnsafeMutablePointer<UInt8>?](repeating: nil, count: 4)
    let linesizes = image.linesizes.map({ Int32($0) })
    try! AVImage.fillPointers(
        &data, pixelFormat: pixelFormat, height: height, buffer: image.data[0], lineSizes: linesizes)
    XCTAssertEqual(image.data[0], data.first)
  }

  func testLinesizes() {
    XCTAssertEqual(Array(image.linesizes), [1080, 540, 540, 0])

    let linesizes1 = (0..<4).map({
      try! AVImage.lineSize(for: pixelFormat, width: width, plane: $0)
    })
    XCTAssertEqual(Array(image.linesizes), linesizes1.map({ Int32($0) }))

    let linesizes2 = try! AVImage.lineSizes(for: pixelFormat, width: width)
      XCTAssertEqual(image.linesizes.map({ Int($0) }), linesizes2)
  }

  func testTotalSize() {
    let size = try! AVImage.bufferSize(for: pixelFormat, width: width, height: height)
    XCTAssertEqual(image.size, size)
  }
}
