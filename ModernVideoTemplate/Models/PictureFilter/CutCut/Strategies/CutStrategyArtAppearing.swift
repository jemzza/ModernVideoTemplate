//
//  CutStrategySlowAppearing.swift
//  ModernVideoTemplate
//
//  Created by Alexander Litvinov on 13.4.2023.
//

import UIKit

final class CutStrategyArtAppearing: PictureStrategable {
    
    func processImages(current firstImage: UIImage, next secondImage: UIImage, mask: CIImage) -> [UIImage] {
        guard let secondCGImage = secondImage.cgImage else {
            return []
        }
        
        guard
            let compositeOutputCIImage = CIImage(cgImage: secondCGImage).edgeFilter()?.createMask()?.addToMask(mask)
        else {
            return []
        }
        
        let first = secondImage.changeBackground(for: firstImage, mask: mask)
        
        let twoMaskResult = secondImage.changeBackground(for: firstImage, mask: compositeOutputCIImage)
        let removedBackround = secondImage.removeBackground(mask: mask)
        
        let second = removedBackround.drawIn(twoMaskResult)
        
        return [first, second]
    }
}
