//
//  CIImage+Extensions.swift
//  ModernVideoTemplate
//
//  Created by Alexander Litvinov on 14.4.2023.
//

import CoreImage

//MARK: - Filters
extension CIImage {
    
    func edgeFilter() -> CIImage? {
        let blendFilter = CIFilter.edgeWork()
        blendFilter.inputImage = self
        blendFilter.radius = 8
        
        guard
            let outputCIImage = blendFilter.outputImage
        else {
            return nil
        }
        
        return outputCIImage
    }
    
    func createMask() -> CIImage? {
        let maskFilter = CIFilter.maskToAlpha()
        maskFilter.inputImage = self
        
        guard
            let outputCIImage = maskFilter.outputImage
        else {
            return nil
        }
        
        return outputCIImage
    }
    
    func addToMask(_ mask: CIImage) -> CIImage? {
        let scaleX = extent.width / mask.extent.width
        let scaleY = extent.height / mask.extent.height
        let maskImage = mask.transformed(by: CGAffineTransform(scaleX: scaleX, y: scaleY), highQualityDownsample: true)
        
        let compositeAdditionFilter = CIFilter.additionCompositing()
        compositeAdditionFilter.inputImage = maskImage
        compositeAdditionFilter.backgroundImage = self
        
        guard
            let compositeOutputCIImage = compositeAdditionFilter.outputImage
        else {
            return nil
        }
        
        return compositeOutputCIImage
    }
}

extension CIImage {
    
    func removeForeground(mask: CIImage) -> CIImage {
        
        var maskImage = mask
        
        let scaleX = extent.width / maskImage.extent.width
        let scaleY = extent.height / maskImage.extent.height
        maskImage = maskImage.transformed(by: CGAffineTransform(scaleX: scaleX, y: scaleY), highQualityDownsample: true)
                
        let blendFilter = CIFilter.blendWithRedMask()
        blendFilter.backgroundImage = self
        blendFilter.maskImage = maskImage
        
        guard
            let outputCIImage = blendFilter.outputImage
        else {
            return self
        }
        
        return outputCIImage
    }
}
