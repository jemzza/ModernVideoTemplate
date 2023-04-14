//
//  PictureStrategable.swift
//  ModernVideoTemplate
//
//  Created by Alexander Litvinov on 8.4.2023.
//

import UIKit

protocol PictureStrategable {
    
    func processImages(current: UIImage, next: UIImage, mask: CIImage) -> [UIImage]
}


