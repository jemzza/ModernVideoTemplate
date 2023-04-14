//
//  CGPoint+Extensions.swift
//  ModernVideoTemplate
//
//  Created by Alexander Litvinov on 12.4.2023.
//

import Foundation

extension CGPoint {
    
    static func + (lhs: Self, rhs: Self) -> Self {
        return CGPoint(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
    }
}
