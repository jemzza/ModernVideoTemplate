//
//  CutCutFilter.swift
//  ModernVideoTemplate
//
//  Created by Alexander Litvinov on 14.4.2023.
//

import UIKit

final class CutCutFilter: PictureFilterable {
    
    var strategy: PictureStrategable
    
    init(strategy: PictureStrategable) {
        self.strategy = strategy
    }
    
    func getProcessedImages(current: UIImage, next: UIImage, mask: CIImage) -> [UIImage] {
        return strategy.processImages(current: current, next: next, mask: mask)
    }
}
