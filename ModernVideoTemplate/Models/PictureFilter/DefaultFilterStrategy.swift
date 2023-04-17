//
//  DefaultFilterStrategy.swift
//  ModernVideoTemplate
//
//  Created by Alexander Litvinov on 13.4.2023.
//

import UIKit
import CoreML

final class DefaultFilterStrategy: PictureStrategable {
    
    func processImages(current firstImage: UIImage, next secondImage: UIImage, mask: CIImage) -> [UIImage] {
        print(Thread.current)
        let imageWithoutBackground = secondImage.changeBackground(for: firstImage, mask: mask)
        let ouputImage = imageWithoutBackground.drawIn(secondImage)
        
        /*
        let imageWithoutBackground = secondImage.changeBackground(for: firstImage, mask: mask)!.cgImage!
        
        let currentCGImage = firstImage.cgImage!
        let width = currentCGImage.width
        let height = currentCGImage.height
        
        let bytesPerPixel = 4
        let bytesPerRow = bytesPerPixel * width
        let bytsPerComponent = 8

        let rawData = UnsafeMutablePointer<UInt32>.allocate(capacity: width * height)
        
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
        
        let colorSpace: CGColorSpace = CGColorSpaceCreateDeviceRGB()
        let context = CGContext(
            data: rawData,
            width: width,
            height: height,
            bitsPerComponent: bytsPerComponent,
            bytesPerRow: bytesPerRow,
            space: colorSpace,
            bitmapInfo: bitmapInfo.rawValue
        )
                
        
        let nextCGImage = secondImage.cgImage!
        context?.draw(nextCGImage, in: CGRect(origin: .zero, size: CGSize(width: width, height: height)))
        context?.draw(imageWithoutBackground, in: CGRect(origin: .zero, size: CGSize(width: width / 2, height: height / 2)))
        let image = context!.makeImage()!
        rawData.deallocate()
        */
        
        return [ouputImage]
    }
}
