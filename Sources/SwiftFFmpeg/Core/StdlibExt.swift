//
//  StdlibExt.swift
//  SwiftFFmpeg
//
//  Created by sunlubo on 2018/12/30.
//

import CFFmpeg

extension UnsafePointer {
    var mutable: UnsafeMutablePointer<Pointee> {
        UnsafeMutablePointer(mutating: self)
    }
    
    func buffer<I: BinaryInteger>(count: I) -> UnsafeBufferPointer<Pointee> {
        UnsafeBufferPointer(start: self, count: Int(count))
    }
}

extension UnsafeMutablePointer {
    func buffer<I: BinaryInteger>(count: I) -> UnsafeBufferPointer<Pointee> {
        UnsafeBufferPointer(start: self, count: Int(count))
    }
}

extension UnsafeBufferPointer {
    var mutable: UnsafeMutableBufferPointer<Element> {
        UnsafeMutableBufferPointer(mutating: self)
    }
}

public extension UnsafeBufferPointer where Element == UInt8 {
    var md5: String {
        let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: 16)
        defer {
            buffer.deinitialize(count: 16)
        }
        buffer.initialize(repeating: 0, count: 16)
        av_md5_sum(buffer, baseAddress, count)
        return (0 ..< 16).reduce("") { result, index in
            let hex = String(buffer[index], radix: 16, uppercase: true)
            return result + (hex.count > 1 ? hex : ("0" + hex))
        }
    }
}

extension UnsafePointer<CChar> {
    var string: String {
        String(cString: self)
    }
}

extension UnsafeMutablePointer<CChar> {
    var string: String {
        String(cString: self)
    }
}

extension Dictionary where Key == String, Value == String {
    var avDict: OpaquePointer? {
        var pm: OpaquePointer?
        for (k, v) in self {
            av_dict_set(&pm, k, v, 0)
        }
        return pm
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
    
    func dumpUnrecognizedOptions() {
        var prev: UnsafeMutablePointer<AVDictionaryEntry>?
        while let tag = av_dict_get(self, "", prev, AV_DICT_IGNORE_SUFFIX) {
            AVLog.log("Option '\(tag.pointee.key?.string ?? "unknown")' not found.", at: .warning)
          prev = tag
        }
    }
}

extension Optional where Wrapped == OpaquePointer {
    mutating func replace(with dictionary: [String: String]) {
        av_dict_free(&self)
        for (k, v) in dictionary {
            av_dict_set(&self, k, v, 0)
        }
    }
}

extension OptionSet where RawValue: FixedWidthInteger, Element == Self {
    func elements() -> [Element] {
        Array(_elements())
    }

    private func _elements() -> AnySequence<Element> {
        var remainingBits = rawValue
        return AnySequence {
            AnyIterator {
                guard remainingBits != 0 else { return nil }
                let lowestBit = remainingBits & ~(remainingBits - 1)
                remainingBits &= ~lowestBit
                return Self(rawValue: lowestBit)
            }
        }
    }
}

extension Collection {
    subscript(safe index: Index) -> Element? {
        guard !isEmpty, index >= startIndex, index < endIndex else { return nil }
        return self[index]
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

import Foundation

extension URL {
    var pathOrURLString: String {
        isFileURL ? path : absoluteString
    }
}

extension Sequence {
    func grouped<Key>(by keyForValue: (Element) throws -> Key) rethrows -> [Key: [Element]] {
        try Dictionary(grouping: self, by: keyForValue)
    }
}

extension Sequence {
    func sorted<Value>(by compare: (Element) throws -> Value, _ order: SortOrder = .forward) rethrows -> [Element] where Value: Comparable {
        try sorted { order == .forward ? (try compare($0)) < (try compare($1)) : (try compare($0)) > (try compare($1)) }
    }
    
    func sorted<Value>(by keyPath: KeyPath<Element, Value>, _ order: SortOrder = .forward) -> [Element] where Value: Comparable {
        sorted(by: { $0[keyPath: keyPath]}, order)
    }
}
