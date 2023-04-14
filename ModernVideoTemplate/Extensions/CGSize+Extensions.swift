//
//  CGSize+Extensions.swift
//  ModernVideoTemplate
//
//  Created by Alexander Litvinov on 12.4.2023.
//

import Foundation

extension CGSize {
    
    static func * (left: CGSize, _ value: CGFloat) -> CGSize{
        return CGSize(width: left.width * value, height: left.height * value)
    }
}
