//
//  DefaultFilterStrategy.swift
//  ModernVideoTemplate
//
//  Created by Alexander Litvinov on 13.4.2023.
//

import UIKit

final class DefaultFilterStrategy: PictureStrategable {
    
    func processImages(current firstImage: UIImage, next secondImage: UIImage, mask: CIImage) -> [UIImage] {
        let imageWithoutBackground = secondImage.changeBackground(for: firstImage, mask: mask)
        
        return [imageWithoutBackground]
    }
}
