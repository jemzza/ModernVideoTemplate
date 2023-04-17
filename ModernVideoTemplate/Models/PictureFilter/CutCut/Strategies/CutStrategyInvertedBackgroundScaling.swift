//
//  CutStrategyInvertedBackgroundScaling.swift
//  ModernVideoTemplate
//
//  Created by Alexander Litvinov on 13.4.2023.
//

import UIKit

final class CutStrategyInvertedBackgroundScaling: PictureStrategable {
    
    func processImages(current firstImage: UIImage, next secondImage: UIImage, mask: CIImage) -> [UIImage] {
        let koefHeight = firstImage.size.height / secondImage.size.height

        let removedForeground = secondImage.removeForeground(mask: mask).resizedImage(scale: koefHeight)
        let removedForegroundResized = removedForeground.resizedImage(scale: 1.3)
        
        let first = removedForegroundResized.drawIn(firstImage)
        let second = removedForeground.drawIn(firstImage)

        return [first, second]
    }
}
