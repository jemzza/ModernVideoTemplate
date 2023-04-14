//
//  CutStrategyInvertedBackgroundScaling.swift
//  ModernVideoTemplate
//
//  Created by Alexander Litvinov on 13.4.2023.
//

import UIKit

final class CutStrategyInvertedBackgroundScaling: PictureStrategable {
    
    func processImages(current firstImage: UIImage, next secondImage: UIImage, mask: CIImage) -> [UIImage] {
        let removedForeground = secondImage.removeForeground(mask: mask)
        let first = removedForeground.resizedImage(scale: 1.3).drawIn(firstImage)

        let second = secondImage.invertedBackground(for: firstImage, mask: mask)


        return [first, second]
    }
}
