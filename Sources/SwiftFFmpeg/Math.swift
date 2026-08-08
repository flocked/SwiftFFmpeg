//
//  Math.swift
//  SwiftFFmpeg
//
//  Created by sunlubo on 2018/8/9.
//

import CFFmpeg

// MARK: - AVRational

/// Rational number (pair of numerator and denominator).
public typealias AVRational = CFFmpeg.AVRational

extension AVRational: @retroactive @unchecked Sendable {
    /// Converts the rational to a Double value.
    public var toDouble: Double {
        av_q2d(self)
    }

    /**
     Creates a rational approximation of the specified floating-point value.

     - Parameters:
       - value: The floating-point value to convert.
       - maximum: The maximum allowed numerator and denominator.
     */
    public init(_ value: Double, maximum: Int32 = 1 << 26) {
        self = av_d2q(value, maximum)
    }

    /// Creates a rational from the specified values.
    public init(_ num: Int32, _ den: Int32) {
        self = Self(num: num, den: den)
    }

    /// Invert a rational. `1 / q`
    public var inverted: Self {
        av_inv_q(self)
    }

    /// Returns a reduced rational value.
    public func reduced(maximum: Int64 = Int64.max) -> Self {
        var numerator: Int32 = 0
        var denominator: Int32 = 0
        av_reduce(&numerator, &denominator, Int64(num), Int64(den), maximum)
        return Self(num: numerator, den: denominator)
    }

    public static func == (lhs: Self, rhs: Self) -> Bool {
        av_cmp_q(lhs, rhs) == 0
    }

    /// Add two rationals.
    public static func + (lhs: Self, rhs: Self) -> Self {
        av_add_q(lhs, rhs)
    }

    /// Subtract one rational from another.
    public static func - (lhs: Self, rhs: Self) -> Self {
        av_sub_q(lhs, rhs)
    }

    /// Multiply two rationals.
    public static func * (lhs: Self, rhs: Self) -> Self {
        av_mul_q(lhs, rhs)
    }

    /// Divide one rational by another.
    public static func / (lhs: Self, rhs: Self) -> Self {
        av_div_q(lhs, rhs)
    }
}

/*
extension AVRational: @retroactive Hashable {
    public func hash(into hasher: inout Hasher) {
        let reduced = reduced()
        hasher.combine(reduced.num)
        hasher.combine(reduced.den)
    }
    
    /*
    public func hash(into hasher: inout Hasher) {
        hasher.combine(den)
        hasher.combine(num)
    }
     */
}
*/

public enum AVMath {
    /// Rescale a integer with specified rounding.
    ///
    /// The operation is mathematically equivalent to `a * b / c`, but writing that
    /// directly can overflow, and does not support different rounding methods.
    public static func rescale<T: BinaryInteger>(_ a: T, _ b: T, _ c: T, rounding: AVRounding = .inf, passMinMax: Bool = false) -> Int64 {
        av_rescale_rnd(Int64(a), Int64(b), Int64(c), rounding.ffmpeg(passMinMax: passMinMax))
    }

    /// Rescale a integer by 2 rational numbers with specified rounding.
    ///
    /// The operation is mathematically equivalent to `a * bq / cq`.
    public static func rescale<T: BinaryInteger>(_ a: T, _ b: AVRational, _ c: AVRational, rounding: AVRounding = .inf, passMinMax: Bool = false) -> Int64 {
        av_rescale_q_rnd(Int64(a), b, c, rounding.ffmpeg(passMinMax: passMinMax))
    }

    public static func rescale<T: BinaryInteger>(_ a: T, _ b: AVRational, _ c: AVRational) -> Int64 {
        av_rescale_q(Int64(a), b, c)
    }

    /**
     Compute the greatest common divisor of two integer operands.

     GCD of `a` and `b` up to sign; if `a` >= 0 and `b` >= 0, return value is >= 0; if `a` == 0 and `b` == 0, returns 0.
     */
    public static func gcd<T: BinaryInteger>(_ a: T, _ b: T) -> Int64 {
        av_gcd(Int64(a), Int64(b))
    }

    public static func rescale_rnd<T: BinaryInteger>(_ a: T, _ b: T) -> Int64 {
        av_gcd(Int64(a), Int64(a))
    }
}

extension AVMath {
    /// Rounding methods.
    public enum AVRounding: UInt32 {
        /// Round toward zero.
        case zero = 0
        /// Round away from zero.
        case inf = 1
        /// Round toward -infinity.
        case down = 2
        /// Round toward +infinity.
        case up = 3
        /// Round to nearest and halfway cases away from zero.
        case nearInf = 5
        
        func ffmpeg(passMinMax: Bool) -> CFFmpeg.AVRounding {
            .init(rawValue: passMinMax ? rawValue | AV_ROUND_PASS_MINMAX.rawValue : rawValue)
        }
    }
}
