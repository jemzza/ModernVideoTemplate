//
//  CutStrategyCopySpam.swift
//  ModernVideoTemplate
//
//  Created by Alexander Litvinov on 13.4.2023.
//

import UIKit

final class CutStrategyCopySpam: PictureStrategable {
    
    func processImages(current firstImage: UIImage, next secondImage: UIImage, mask: CIImage) -> [UIImage] {
        let nextImage = secondImage.resize(size: firstImage.size)
        let removedBackground = nextImage.removeBackground(mask: mask)
        let removedBackgroundSmaller = removedBackground.resizedImage(scale: 0.9)
        
        let topRightPoint = CGPoint(x: firstImage.size.width / 4, y: -firstImage.size.height * 2 / 5)
        let bottomleftPoint = CGPoint(x: -firstImage.size.width / 3, y: 0)
        let bottomRightPoint = CGPoint(x: firstImage.size.width / 3, y: 0)
        let topleftPoint = CGPoint(x: -firstImage.size.width / 5, y: -firstImage.size.height * 7 / 10)
        let leftPoint = CGPoint(x: -firstImage.size.width / 3, y: -firstImage.size.height * 1 / 2)
        
        let topRightImage = removedBackground.drawIn(firstImage, position: topRightPoint)
        
        let bottomLeftImage = removedBackgroundSmaller.drawIn(topRightImage, position: topleftPoint)
        
        let topLeftImage = removedBackgroundSmaller
            .resizedImage(scale: 0.8)
            .drawIn(bottomLeftImage, position: bottomleftPoint)
        
        let bottomRightImage = removedBackgroundSmaller.drawIn(topLeftImage, position: bottomRightPoint)
        
        let topImage = removedBackground.drawIn(bottomRightImage, position: leftPoint)
        let bottomImage = removedBackground.drawIn(topImage)
        
        
        return [topRightImage, bottomLeftImage, topLeftImage, bottomRightImage, topImage, bottomImage]
    }
}
