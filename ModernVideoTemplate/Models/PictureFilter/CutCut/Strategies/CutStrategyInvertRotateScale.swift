//
//  CutStrategyInvertRotateScale.swift
//  ModernVideoTemplate
//
//  Created by Alexander Litvinov on 13.4.2023.
//

import UIKit

final class CutStrategyInvertRotateScale: PictureStrategable {
    
    func processImages(current firstImage: UIImage, next secondImage: UIImage, mask: CIImage) -> [UIImage] {
        let invertedRemove = secondImage.removeForeground(mask: mask)
        
        let x = (invertedRemove.size.width - invertedRemove.size.width * 1.2) / 2
        let y = (invertedRemove.size.height - invertedRemove.size.height * 1.2) / 2
        
        let resizedImage = invertedRemove.resizedImage(scale: 1.2)
            .croppedInRect(rect: CGRect(origin: CGPoint(x: -x, y: -y), size: invertedRemove.size))
        
        let first = resizedImage.drawIn(firstImage, angle: -4)
        let second = invertedRemove.drawIn(firstImage, angle: -4)
        
        let removedBackground = secondImage.removeBackground(mask: mask).resizedImage(scale: 1.1, aspectRatio: 1)
        let third = removedBackground.drawIn(second)
        
        let lastImage = invertedRemove.drawIn(firstImage, position: .zero, angle: 0)
        let fourth = removedBackground.drawIn(lastImage)
        
        return [first, second, third, fourth]
    }
}
