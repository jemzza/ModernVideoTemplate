//
//  TemplateMakable.swift
//  ModernVideoTemplate
//
//  Created by Alexander Litvinov on 14.4.2023.
//

import UIKit
import Vision

protocol TemplateMakable {
    
    var presenter: TemplatePresentable? { get set }
    var selectedImages: [UIImage] { get set }
    var requests: [VNCoreMLRequest] { get set }
    
    func makeTemplate()
}
