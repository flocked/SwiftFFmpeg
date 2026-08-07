//
//  Timestamp.swift
//  SwiftFFmpeg
//
//  Created by sunlubo on 2018/8/9.
//

import CFFmpeg
import Foundation

public enum AVTimestamp {
  /// Internal timebase represented as integer
  public static let timebase = AV_TIME_BASE
  /// Internal timebase represented as fractional value
  public static let timebaseQ = av_get_time_base_q()
  /// Undefined timestamp value.
  ///
  /// Usually reported by demuxer that work on containers that do not provide either pts or dts.
  public static let noPTS = swift_AV_NOPTS_VALUE // ((int64_t)UINT64_C(0x8000000000000000)) == Int64.min

    /**
     Compares two timestamps, each in its own timebase.

     - Warning: The result is undefined if either timestamp is outside the `Int64` range when represented in the other's timebase.
     
     - Returns: [.orderedAscending](https://developer.apple.com/documentation/foundation/comparisonresult/orderedascending) if `timestampA` is before `timestampB`, [.orderedDescending](https://developer.apple.com/documentation/foundation/comparisonresult/ordereddescending) if  after `timestampB`, or [.orderedSame](https://developer.apple.com/documentation/foundation/comparisonresult/orderedsame) if they represent the same position.
     */
    public static func compare(_ timestampA: Int64, timebase timebaseA: AVRational, to timestampB: Int64, timebase timebaseB: AVRational) -> ComparisonResult {
        let result = av_compare_ts(timestampA, timebaseA, timestampB, timebaseB)
        return result < 0 ? .orderedAscending : result > 0 ? .orderedDescending : .orderedSame
    }
}
