//
//  CutStrategyInvertedBackgroundAndRotatedForeground.swift
//  ModernVideoTemplate
//
//  Created by Alexander Litvinov on 8.4.2023.
//

import UIKit

final class CutStrategyInvertedBackgroundAndRotatedForeground: PictureStrategable {
    
    private enum Constants {
        
        static let angle: CGFloat = -5
        static let humanPostition = CGPoint(x: 80, y: -220)
    }
    
    func processImages(current firstImage: UIImage, next secondImage: UIImage, mask: CIImage) -> [UIImage] {
        let removedBackround = secondImage.removeBackground(mask: mask)
        let imageInverted = secondImage.invertedBackground(for: firstImage, mask: mask)
        let first = removedBackround.drawIn(firstImage, position: Constants.humanPostition, angle: Constants.angle)
        let second = removedBackround.drawIn(imageInverted, position: Constants.humanPostition, angle: Constants.angle)
        
        return [first, second]
    }
}
