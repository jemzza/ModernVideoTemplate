//
//  CutStrategyStrokeAppearing.swift
//  ModernVideoTemplate
//
//  Created by Alexander Litvinov on 13.4.2023.
//

import UIKit

final class CutStrategyStrokeAppearing: PictureStrategable {
    
    private enum Constants {
        
        static let strokesThickness: [CGFloat] = [60, 80, 120]
    }
        
    func processImages(current firstImage: UIImage, next secondImage: UIImage, mask: CIImage) -> [UIImage] {
        let ciImagesWithStroke = getCIImagesWithStrokes(nextImage: secondImage, mask: mask)
        
        var resultImages: [UIImage] = []
        
        for index in 0...ciImagesWithStroke.count {
            if index == 0 {
                resultImages.append(secondImage.changeBackground(for: firstImage, mask: mask))
                continue
            }
            
            resultImages.append(secondImage.changeBackground(for: firstImage, mask: ciImagesWithStroke[index - 1]))
        }
                
        return resultImages
    }
    
    private func getCIImagesWithStrokes(nextImage: UIImage, mask: CIImage) -> [CIImage] {
        var images: [UIImage] = []
        let imageWithoutBackground = nextImage.removeBackground(mask: mask)
        
        for index in 0..<Constants.strokesThickness.count {
            let image = index == 0 ? imageWithoutBackground : images[index - 1]
            
            images.append(
                image
                    .imageByApplyingStroke(strokeColor: .black, strokeThickness: Constants.strokesThickness[index])
                    .imageByApplyingStroke(strokeColor: .white, strokeThickness: Constants.strokesThickness[index])
            )
        }
        
        return images
            .map { $0.cgImage?.ciImage }
            .compactMap { $0 }
            .map { $0.removeForeground(mask: mask).addToMask(mask) ?? CIImage() }
    }
}
