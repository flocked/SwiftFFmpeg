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
    AVLog.log(level: .warning, message: "Option '\(String(cString: tag.pointee.key) ?? "unknown")' not found.")
    prev = tag
  }
}

extension Array {
    init?(_ ptr: UnsafePointer<Element>?, until end: Element) where Element: Equatable {
        self.init(ptr, until: { $0 == end })
    }
    
    init?(_ ptr: UnsafePointer<Element>?, until predicate: (Element) -> Bool) {
        guard let start = ptr else {
          return nil
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
