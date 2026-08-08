//
//  Util.swift
//  SwiftFFmpeg
//
//  Created by sunlubo on 2018/7/9.
//

import CFFmpeg

/// Allows to "box" another value.
final class Box<T> {
  let value: T

  init(_ value: T) {
    self.value = value
  }
}

func dumpUnrecognizedOptions(_ dict: OpaquePointer?) {
  var prev: UnsafeMutablePointer<AVDictionaryEntry>?
  while let tag = av_dict_get(dict, "", prev, AV_DICT_IGNORE_SUFFIX) {
      AVLog.log("Option '\(String(cString: tag.pointee.key) ?? "unknown")' not found.", at: .warning)
    prev = tag
  }
}

extension Array {
    init(_ ptr: UnsafePointer<Element>?, until end: Element) where Element: Equatable {
        self.init(ptr, until: { $0 == end })
    }
    
    init(_ ptr: UnsafePointer<Element>?, until predicate: (Element) -> Bool) {
        guard let start = ptr else {
            self = []
          return
        }

        var end = start
        while !predicate(end.pointee) {
          end = end.advanced(by: 1)
        }
        self = end > start ? Array(UnsafeBufferPointer(start: start, count: end - start)) : []
    }
}

extension OpaquePointer {
    var avDict: [String: String] {
        var dict = [String: String]()
        var prev: UnsafeMutablePointer<AVDictionaryEntry>?
        while let tag = av_dict_get(self, "", prev, AV_DICT_IGNORE_SUFFIX) {
          dict[String(cString: tag.pointee.key)] = String(cString: tag.pointee.value)
          prev = tag
        }
        return dict
    }
}

extension UInt32 {
    /// The four-character code string represented by this value.
    var fourCC: String? {
        let bytes = [UInt8(self & 0xFF), UInt8((self >> 8) & 0xFF), UInt8((self >> 16) & 0xFF), UInt8((self >> 24) & 0xFF)]
        guard bytes.allSatisfy({ (0x20...0x7E).contains($0) }) else { return nil }
        return String(bytes: bytes, encoding: .ascii)
    }
}

extension String {
    /// The four-character code represented by this string.
    var fourCC: UInt32? {
        let bytes = Array(utf8)
        guard bytes.count == 4, bytes.allSatisfy({ (0x20...0x7E).contains($0) }) else {
            return nil
        }
        return bytes.enumerated().reduce(0) {
            $0 | UInt32($1.element) << ($1.offset * 8)
        }
    }
}
