//
//  VideoMakable.swift
//  ModernVideoTemplate
//
//  Created by Alexander Litvinov on 14.4.2023.
//

import CoreImage

protocol VideoMakable {
    
    func makeVideo(ciImages: [CIImage], completion: @escaping (Result<Bool, MediaError>) -> Void)
}
