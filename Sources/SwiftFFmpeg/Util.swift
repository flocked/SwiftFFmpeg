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

