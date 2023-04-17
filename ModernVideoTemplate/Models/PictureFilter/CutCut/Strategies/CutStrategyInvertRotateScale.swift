//
//  CutStrategyInvertRotateScale.swift
//  ModernVideoTemplate
//
//  Created by Alexander Litvinov on 13.4.2023.
//

import UIKit

final class CutStrategyInvertRotateScale: PictureStrategable {
    
    func processImages(current firstImage: UIImage, next secondImage: UIImage, mask: CIImage) -> [UIImage] {
        let removedForeground = secondImage.removeForeground(mask: mask)
        
        let resizedImage = removedForeground.resizedImage(scale: 1.2)
        
        let first = resizedImage.drawIn(firstImage, angle: -4)
        let second = removedForeground.drawIn(firstImage, angle: -4)
        
        let removedBackground = secondImage.removeBackground(mask: mask)
        let third = removedBackground.drawIn(second)
                
        return [first, second, third]
    }
}
