//
//  CGFloat+Extensions.swift
//  ModernVideoTemplate
//
//  Created by Alexander Litvinov on 12.4.2023.
//

import Foundation

extension CGFloat {
    
    func radians() -> CGFloat {
        return CGFloat(self / 180.0 * .pi)
    }
}
