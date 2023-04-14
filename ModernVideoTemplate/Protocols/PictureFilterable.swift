//
//  PictureFilterable.swift
//  ModernVideoTemplate
//
//  Created by Alexander Litvinov on 14.4.2023.
//

import UIKit

protocol PictureFilterable {
    
    var strategy: PictureStrategable { get set }
    
    func getProcessedImages(current: UIImage, next: UIImage, mask: CIImage) -> [UIImage]
}
