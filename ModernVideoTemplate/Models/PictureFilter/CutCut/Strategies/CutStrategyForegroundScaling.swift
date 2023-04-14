//
//  CutStrategyForegroundScaling.swift
//  ModernVideoTemplate
//
//  Created by Alexander Litvinov on 13.4.2023.
//

import UIKit

final class CutStrategyForegroundScaling: PictureStrategable {
    
    func processImages(current firstImage: UIImage, next secondImage: UIImage, mask: CIImage) -> [UIImage] {
        let removedBackground = secondImage.removeBackground(mask: mask)
        let removedBackgroundResized = removedBackground.resizedImage(scale: 1.2)
        
        let first = removedBackgroundResized.drawIn(firstImage)
        let second = removedBackgroundResized.drawIn(secondImage)
        
        return [first, second]
    }
}

    

