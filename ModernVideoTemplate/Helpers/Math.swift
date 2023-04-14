//
//  Math.swift
//  ModernVideoTemplate
//
//  Created by Alexander Litvinov on 2.4.2023.
//

import Foundation

/** Ensures that `x` is in the range `[min, max]`. */
public func clamp<T: Comparable>(_ x: T, min: T, max: T) -> T {
    if x < min { return min }
    if x > max { return max }
    return x
}
