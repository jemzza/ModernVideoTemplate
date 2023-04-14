//
//  CutStrategyStrokeAppearing.swift
//  ModernVideoTemplate
//
//  Created by Alexander Litvinov on 13.4.2023.
//

import UIKit

final class CutStrategyStrokeAppearing: PictureStrategable {
    
    private let dispatchGroup = DispatchGroup()
    private let cIImagesafeDictionary = SafeDictionary<Int, CIImage>()
    
    func processImages(current firstImage: UIImage, next secondImage: UIImage, mask: CIImage) -> [UIImage] {
        
        var imagesWithStroke = getImagesWithStrokes(nextImage: secondImage, mask: mask)
                
        for index in 0..<imagesWithStroke.count {
            dispatchGroup.enter()
            
            DispatchQueue.global().async { [weak self] in
                let outputImageFirstWithoutHuman = imagesWithStroke[index].cgImage?.ciImage
                    .removeForeground(mask: mask)
                    .addToMask(mask)
                self?.cIImagesafeDictionary[index] = outputImageFirstWithoutHuman
                self?.dispatchGroup.leave()
            }
        }
        
        dispatchGroup.wait()
        imagesWithStroke = []
        
        imagesWithStroke.append(secondImage.changeBackground(for: firstImage, mask: mask))
        
        for index in 0..<cIImagesafeDictionary.count {
            guard let cIImage = cIImagesafeDictionary[index] else {
                continue
            }
            
            imagesWithStroke.append(secondImage.changeBackground(for: firstImage, mask: cIImage))
        }
        
        return imagesWithStroke
    }
    
    private func getImagesWithStrokes(nextImage: UIImage, mask: CIImage) -> [UIImage] {
        var array: [UIImage] = []
        
        let imageWithoutBackground = nextImage.removeBackground(mask: mask)
        
        array.append(
            imageWithoutBackground
                .imageByApplyingStroke(strokeColor: .black, strokeThickness: 60.0)
                .imageByApplyingStroke(strokeColor: .white, strokeThickness: 60.0)
        )
        
        array.append(
            array[0]
                .imageByApplyingStroke(strokeColor: .black, strokeThickness: 80.0)
                .imageByApplyingStroke(strokeColor: .white, strokeThickness: 80.0)
        )
        
        array.append(
            array[1]
                .imageByApplyingStroke(strokeColor: .black, strokeThickness: 120.0)
                .imageByApplyingStroke(strokeColor: .white, strokeThickness: 120.0)
        )
        
        return array
    }
}
