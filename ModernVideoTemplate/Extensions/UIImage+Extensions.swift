//
//  UIImage+Extensions.swift
//  ModernVideoTemplate
//
//  Created by Alexander Litvinov on 2.4.2023.
//

#if canImport(UIKit)

import UIKit

extension UIImage {
    /**
     Converts the image into an array of RGBA bytes.
     */
    @nonobjc public func toByteArrayRGBA() -> [UInt8]? {
        return cgImage?.toByteArrayRGBA()
    }
    
    /**
     Creates a new UIImage from an array of RGBA bytes.
     */
    @nonobjc public class func fromByteArrayRGBA(_ bytes: [UInt8],
                                                 width: Int,
                                                 height: Int,
                                                 scale: CGFloat = 0,
                                                 orientation: UIImage.Orientation = .up) -> UIImage? {
        if let cgImage = CGImage.fromByteArrayRGBA(bytes, width: width, height: height) {
            return UIImage(cgImage: cgImage, scale: scale, orientation: orientation)
        } else {
            return nil
        }
    }
    
    /**
     Creates a new UIImage from an array of grayscale bytes.
     */
    @nonobjc public class func fromByteArrayGray(_ bytes: [UInt8],
                                                 width: Int,
                                                 height: Int,
                                                 scale: CGFloat = 0,
                                                 orientation: UIImage.Orientation = .up) -> UIImage? {
        if let cgImage = CGImage.fromByteArrayGray(bytes, width: width, height: height) {
            return UIImage(cgImage: cgImage, scale: scale, orientation: orientation)
        } else {
            return nil
        }
    }
}

#endif

import CoreML

extension UIImage {
    
    func mlMultiArray(
        scale preprocessScale: Double = 255,
        rBias preprocessRBias: Double = 0,
        gBias preprocessGBias: Double = 0,
        bBias preprocessBBias: Double = 0
    ) -> MLMultiArray {
        let imagePixel = self.getPixelRgb(
            scale: preprocessScale, rBias: preprocessRBias, gBias: preprocessGBias, bBias: preprocessBBias
        )
        let size = self.size
        let imagePointer: UnsafePointer<Double> = UnsafePointer(imagePixel)
        let mlArray = try! MLMultiArray(
            shape: [3,  NSNumber(value: Float(size.width)), NSNumber(value: Float(size.height))],
            dataType: MLMultiArrayDataType.double
        )
        mlArray.dataPointer.initializeMemory(as: Double.self, from: imagePointer, count: imagePixel.count)
        return mlArray
    }
    
    func mlMultiArrayGrayScale(scale preprocessScale:Double=255,bias preprocessBias:Double=0) -> MLMultiArray {
        let imagePixel = self.getPixelGrayScale(scale: preprocessScale, bias: preprocessBias)
        let size = self.size
        let imagePointer: UnsafePointer<Double> = UnsafePointer(imagePixel)
        let mlArray = try! MLMultiArray(
            shape: [1,  NSNumber(value: Float(size.width)), NSNumber(value: Float(size.height))],
            dataType: MLMultiArrayDataType.double
        )
        mlArray.dataPointer.initializeMemory(as: Double.self, from: imagePointer, count: imagePixel.count)
        return mlArray
    }
    
    func getPixelRgb(
        scale preprocessScale: Double = 255,
        rBias preprocessRBias: Double = 0,
        gBias preprocessGBias: Double = 0,
        bBias preprocessBBias: Double = 0
    ) -> [Double]  {
        guard let cgImage = self.cgImage else {
            return []
        }
        let bytesPerRow = cgImage.bytesPerRow
        let width = cgImage.width
        let height = cgImage.height
        let bytesPerPixel = 4
        let pixelData = cgImage.dataProvider!.data! as Data
        
        var r_buf : [Double] = []
        var g_buf : [Double] = []
        var b_buf : [Double] = []
        
        for j in 0..<height {
            for i in 0..<width {
                let pixelInfo = bytesPerRow * j + i * bytesPerPixel
                let r = Double(pixelData[pixelInfo])
                let g = Double(pixelData[pixelInfo+1])
                let b = Double(pixelData[pixelInfo+2])
                r_buf.append(Double(r/preprocessScale)+preprocessRBias)
                g_buf.append(Double(g/preprocessScale)+preprocessGBias)
                b_buf.append(Double(b/preprocessScale)+preprocessBBias)
            }
        }
        return ((b_buf + g_buf) + r_buf)
    }
    
    func getPixelGrayScale(scale preprocessScale:Double=255, bias preprocessBias:Double=0) -> [Double] {
        guard let cgImage = self.cgImage else {
            return []
        }
        
        let bytesPerRow = cgImage.bytesPerRow
        let width = cgImage.width
        let height = cgImage.height
        let bytesPerPixel = 2
        let pixelData = cgImage.dataProvider!.data! as Data
        
        var buf : [Double] = []
        
        for j in 0..<height {
            for i in 0..<width {
                let pixelInfo = bytesPerRow * j + i * bytesPerPixel
                let v = Double(pixelData[pixelInfo])
                buf.append(Double(v/preprocessScale)+preprocessBias)
            }
        }
        
        return buf
    }
}

//MARK: - Scale transformation
extension UIImage {
    
    func resize(size: CGSize? = nil, insets: UIEdgeInsets = .zero, fill: UIColor = .white) -> UIImage {
        var size = size ?? self.size
        let widthRatio = size.width / self.size.width
        let heightRatio = size.height / self.size.height
        
        if widthRatio > heightRatio {
            size = CGSize(width: floor(self.size.width * heightRatio), height: floor(self.size.height * heightRatio))
        } else if heightRatio > widthRatio {
            size = CGSize(width: floor(self.size.width * widthRatio), height: floor(self.size.height * widthRatio))
        }
        
        let rect = CGRect(
            x: 0,
            y: 0,
            width: size.width + insets.left + insets.right,
            height: size.height + insets.top + insets.bottom
        )
        
        UIGraphicsBeginImageContextWithOptions(rect.size, false, scale)
        fill.setFill()
        UIGraphicsGetCurrentContext()?.fill(rect)
        
        draw(in: CGRect(x: insets.left, y: insets.top, width: size.width, height: size.height))
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage ?? self
    }
    
    func resizedImage(scale: CGFloat, aspectRatio: CGFloat = 1) -> UIImage {
        guard let inputCIImage = CIImage(image: self) else {
            return self
        }
        
        let filter = CIFilter.lanczosScaleTransform()
        filter.inputImage = inputCIImage
        filter.scale = Float(scale)
        filter.aspectRatio = Float(aspectRatio)
        
        let context = CIContext()
        
        guard let outputCIImage = filter.outputImage,
              let outputCGImage = context.createCGImage(outputCIImage, from: outputCIImage.extent)
        else {
            return self
        }
        
        return UIImage(cgImage: outputCGImage)
    }
    
    func scalePreservingAspectRatio(targetSize: CGSize) -> UIImage {
        // Determine the scale factor that preserves aspect ratio
        let widthRatio = targetSize.width / size.width
        let heightRatio = targetSize.height / size.height
        
        let scaleFactor = min(widthRatio, heightRatio)
        
        // Compute the new image size that preserves aspect ratio
        let scaledImageSize = CGSize(
            width: size.width * scaleFactor,
            height: size.height * scaleFactor
        )
        
        // Draw and return the resized UIImage
        let renderer = UIGraphicsImageRenderer(
            size: scaledImageSize
        )
        
        let scaledImage = renderer.image { _ in
             draw(in: CGRect(
                origin: .zero,
                size: scaledImageSize
            ))
        }
        
        return scaledImage
    }
}

// MARK: - Draw stroke around UIImage
extension UIImage {
    
    /// Converts the image's color space to the specified color space
    /// - Parameter colorSpace: The color space to convert to
    /// - Returns: A CGImage in the specified color space
    func cgImageInColorSpace(_ colorSpace: CGColorSpace) -> CGImage? {
        guard let cgImage = self.cgImage else {
            return nil
        }
        
        guard cgImage.colorSpace != colorSpace else {
            return cgImage
        }
        
        let rect = CGRect(x: 0, y: 0, width: cgImage.width, height: cgImage.height)
        
        let ciImage = CIImage(cgImage: cgImage)
        guard let convertedImage = ciImage.matchedFromWorkingSpace(to: CGColorSpaceCreateDeviceRGB()) else {
            return nil
        }
        
        let ciContext = CIContext()
        let convertedCGImage = ciContext.createCGImage(convertedImage, from: rect)
        
        return convertedCGImage
    }
    
    /// Crops the image to the bounding box containing it's opaque pixels, trimming away fully transparent pixels
    /// - Parameter minimumAlpha: The minimum alpha value to crop out of the image
    /// - Parameter completion: A completion block to execute as the processing takes place on a background thread
    func imageByCroppingToOpaquePixels(
        withMinimumAlpha minimumAlpha: CGFloat = 0, _ completion: @escaping ((_ image: UIImage)->())
    ) {
        
        guard let originalImage = cgImage else {
            completion(self)
            return
        }
        
        // Move to a background thread for the heavy lifting
        DispatchQueue.global(qos: .background).async {
            
            // Ensure we have the correct colorspace so we can safely iterate over the pixel data
            let colorSpace = CGColorSpaceCreateDeviceRGB()
            guard let cgImage = self.cgImageInColorSpace(colorSpace) else {
                DispatchQueue.main.async {
                    completion(UIImage())
                }
                return
            }
            
            // Store some helper variables for iterating the pixel data
            let width: Int = cgImage.width
            let height: Int = cgImage.height
            let bytesPerPixel: Int = cgImage.bitsPerPixel / 8
            let bytesPerRow: Int = cgImage.bytesPerRow
            let bitsPerComponent: Int = cgImage.bitsPerComponent
            let bitmapInfo: UInt32 = CGImageAlphaInfo.premultipliedLast.rawValue | CGBitmapInfo.byteOrder32Big.rawValue
            
            // Attempt to access our pixel data
            guard
                let context = CGContext(
                    data: nil,
                    width: width,
                    height: height,
                    bitsPerComponent: bitsPerComponent,
                    bytesPerRow: bytesPerRow,
                    space: colorSpace,
                    bitmapInfo: bitmapInfo
                ),
                let ptr = context.data?.assumingMemoryBound(to: UInt8.self) else {
                DispatchQueue.main.async { completion(UIImage()) }
                return
            }
            
            context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
            
            var minX: Int = width
            var minY: Int = height
            var maxX: Int = 0
            var maxY: Int = 0
            
            for x in 0 ..< width {
                for y in 0 ..< height {
                    let pixelIndex = bytesPerRow * Int(y) + bytesPerPixel * Int(x)
                    let alphaAtPixel = CGFloat(ptr[pixelIndex + 3]) / 255.0
                    
                    if alphaAtPixel > minimumAlpha {
                        if x < minX { minX = x }
                        if x > maxX { maxX = x }
                        if y < minY { minY = y }
                        if y > maxY { maxY = y }
                    }
                }
            }
            
            let rectangleForOpaquePixels = CGRect(
                x: CGFloat(minX),
                y: CGFloat(minY),
                width: CGFloat( maxX - minX ),
                height: CGFloat( maxY - minY )
            )
            guard let croppedImage = originalImage.cropping(to: rectangleForOpaquePixels) else {
                DispatchQueue.main.async { completion(UIImage()) }
                return
            }
            
            DispatchQueue.main.async {
                let result = UIImage(cgImage: croppedImage, scale: self.scale, orientation: self.imageOrientation)
                completion(result)
            }
            
        }
        
    }
    
}

extension UIImage {
    
    /// Returns a version of this image any non-transparent pixels filled with the specified color
    /// - Parameter color: The color to fill
    /// - Returns: A re-colored version of this image with the specified color
    func imageByFillingWithColor(_ color: UIColor) -> UIImage {
        return UIGraphicsImageRenderer(size: size).image { context in
            color.setFill()
            context.fill(context.format.bounds)
            draw(in: context.format.bounds, blendMode: .destinationIn, alpha: 1.0)
        }
    }
    
}


extension UIImage {
    
    /// Applies a stroke around the image
    /// - Parameters:
    ///   - strokeColor: The color of the desired stroke
    ///   - inputThickness: The thickness, in pixels, of the desired stroke
    ///   - rotationSteps: The number of rotations to make when applying the stroke. Higher rotationSteps will result in a more precise stroke. Defaults to 8.
    ///   - extrusionSteps: The number of extrusions to make along a given rotation. Higher extrusions will make a more precise stroke, but aren't usually needed unless using a very thick stroke. Defaults to 1.
    func imageByApplyingStroke(
        strokeColor: UIColor = .white,
        strokeThickness inputThickness: CGFloat = 2,
        rotationSteps: Int = 8,
        extrusionSteps: Int = 1
    ) -> UIImage {
        let thickness: CGFloat = inputThickness > 0 ? inputThickness : 0
        
        // Create a "stamp" version of ourselves that we can stamp around our edges
        let strokeImage = imageByFillingWithColor(strokeColor)
        let koef = size.width / size.height
        
        let outputSize: CGSize = CGSize(
            width: size.width + (thickness * 2) * koef,
            height: size.height + (thickness * 2)
        )
        let renderer = UIGraphicsImageRenderer(size: outputSize)
        let stroked = renderer.image { ctx in
            
            // Compute the center of our image
            let center = CGPoint(x: outputSize.width / 2, y: outputSize.height / 2)
            
            let centerRect = CGRect(
                x: center.x - (outputSize.width / 2),
                y: center.y - (outputSize.height / 2),
                width: outputSize.width,
                height: outputSize.height
            )
            
            // Compute the increments for rotations / extrusions
            let rotationIncrement: CGFloat = rotationSteps > 0 ? 360 / CGFloat(rotationSteps) : 360
            let extrusionIncrement: CGFloat = extrusionSteps > 0 ? thickness / CGFloat(extrusionSteps) : thickness
            
            for rotation in 0..<rotationSteps {
                for extrusion in 1...extrusionSteps {
                    
                    // Compute the angle and distance for this stamp
                    let angleInDegrees: CGFloat = CGFloat(rotation) * rotationIncrement
                    let angleInRadians: CGFloat = angleInDegrees * .pi / 180.0
                    let extrusionDistance: CGFloat = CGFloat(extrusion) * extrusionIncrement
                    
                    // Compute the position for this stamp
                    let x = center.x + extrusionDistance * cos(angleInRadians)
                    let y = center.y + extrusionDistance * sin(angleInRadians)
                    let vector = CGPoint(x: x, y: y)
                    
                    // Draw our stamp at this position
                    let drawRect = CGRect(
                        x: vector.x - (outputSize.width / 2),
                        y: vector.y - (outputSize.height / 2),
                        width: outputSize.width,
                        height: outputSize.height
                    )
                    
                    strokeImage.draw(in: drawRect, blendMode: .destinationOver, alpha: 1.0)
                }
            }
            
            // Finally, re-draw ourselves centered within the context, so we appear in-front of all of the stamps we've drawn
            self.draw(in: centerRect, blendMode: .normal, alpha: 1.0)
        }
        
        return stroked
    }
}

extension UIImage {
    
    func changeBackground(for background: UIImage, mask: CIImage) -> UIImage {
        guard let cgImage = cgImage, let cgBackground = background.cgImage else {
            return self
        }
                
        var background = CIImage(cgImage: cgBackground)
        let originalImage = CIImage(cgImage: cgImage)
        
        let scaleX = originalImage.extent.width / mask.extent.width
        let scaleY = originalImage.extent.height / mask.extent.height
        let maskImage = mask.transformed(by: CGAffineTransform(scaleX: scaleX, y: scaleY), highQualityDownsample: true)
        
        let backgroundScaleX = originalImage.extent.width / background.extent.width
        let backgroundScaleY = originalImage.extent.height / background.extent.height
        
        let differenceX = abs(1.0 - backgroundScaleX)
        let differenceY = abs(1.0 - backgroundScaleY)
        
        let isDifferenceXCritical = (differenceX < 0.9 || differenceX > 1.1) && differenceX != 0
        let isDifferenceYCritical = (differenceY < 0.9 || differenceY > 1.1) && differenceX != 0
        
        if isDifferenceXCritical == true || isDifferenceYCritical == true {
            background = background.transformed(
                by: CGAffineTransform(scaleX: backgroundScaleX, y: backgroundScaleY),
                highQualityDownsample: false
            )
        }

        let blendFilter = CIFilter.blendWithRedMask()
        blendFilter.inputImage = originalImage
        blendFilter.maskImage = maskImage
        blendFilter.backgroundImage = background
        
        let context = CIContext()
        
        guard
            let outputCIImage = blendFilter.outputImage,
            let outputCGImage = context.createCGImage(outputCIImage, from: outputCIImage.extent)
        else {
            return self
        }
                
        return UIImage(cgImage: outputCGImage)
    }
}

extension UIImage {
    
    func removeBackground(mask: CIImage) -> UIImage {
        guard let cgImage = cgImage else {
            return self
        }
        
        var maskImage = mask
        let originalImage = CIImage(cgImage: cgImage)
        
        let scaleX = originalImage.extent.width / maskImage.extent.width
        let scaleY = originalImage.extent.height / maskImage.extent.height
        maskImage = maskImage.transformed(by: CGAffineTransform(scaleX: scaleX, y: scaleY), highQualityDownsample: true)
        
        let blendFilter = CIFilter.blendWithRedMask()
        blendFilter.inputImage = originalImage
        blendFilter.maskImage = maskImage
        
        let context = CIContext()
        
        guard
            let outputCIImage = blendFilter.outputImage,
            let outputCGImage = context.createCGImage(outputCIImage, from: outputCIImage.extent)
        else {
            return self
        }
        
        return UIImage(cgImage: outputCGImage)
    }
    
    func removeForeground(mask: CIImage) -> UIImage {
        guard let cgImage = cgImage else {
            return self
        }
        
        var maskImage = mask
        let originalImage = CIImage(cgImage: cgImage)
        
        let scaleX = originalImage.extent.width / maskImage.extent.width
        let scaleY = originalImage.extent.height / maskImage.extent.height
        maskImage = maskImage.transformed(by: CGAffineTransform(scaleX: scaleX, y: scaleY), highQualityDownsample: true)
        
        let context = CIContext()
        guard let inputCGImage = context.createCGImage(originalImage, from: originalImage.extent) else {
            return self
        }
        
        let blendFilter = CIFilter.blendWithRedMask()
        blendFilter.backgroundImage = CIImage(cgImage: inputCGImage)
        blendFilter.maskImage = maskImage
        
        guard
            let outputCIImage = blendFilter.outputImage,
            let outputCGImage = context.createCGImage(outputCIImage, from: outputCIImage.extent)
        else {
            return self
        }
        
        return UIImage(cgImage: outputCGImage)
    }
    
    func invertedBackground(for background: UIImage, mask: CIImage) -> UIImage {
        guard let cgBackground = background.cgImage else {
            return self
        }
        var background = CIImage(cgImage: cgBackground)
        
        guard let cgImage = cgImage else {
            return self
        }
        
        var maskImage = mask
        let originalImage = CIImage(cgImage: cgImage)
        
        let scaleX = originalImage.extent.width / maskImage.extent.width
        let scaleY = originalImage.extent.height / maskImage.extent.height
        maskImage = maskImage.transformed(by: CGAffineTransform(scaleX: scaleX, y: scaleY), highQualityDownsample: true)
        
        let backgroundScaleX = originalImage.extent.width / background.extent.width
        let backgroundScaleY = originalImage.extent.height / background.extent.height
        
        let differenceX = abs(1.0 - backgroundScaleX)
        let differenceY = abs(1.0 - backgroundScaleY)
        
        let isDifferenceXCritical = (differenceX < 0.9 || differenceX > 1.1) && differenceX != 0
        let isDifferenceYCritical = (differenceY < 0.9 || differenceY > 1.1) && differenceX != 0
        
        if isDifferenceXCritical == true || isDifferenceYCritical == true {
            background = background.transformed(
                by: CGAffineTransform(scaleX: backgroundScaleX, y: backgroundScaleY),
                highQualityDownsample: true
            )
        }
        
        let context = CIContext()
        guard let inputCGImage = context.createCGImage(originalImage, from: originalImage.extent) else {
            return self
        }
        
        let blendFilter = CIFilter.blendWithRedMask()
        blendFilter.inputImage = background
        blendFilter.maskImage = maskImage
        blendFilter.backgroundImage = CIImage(cgImage: inputCGImage)
        
        guard
            let outputCIImage = blendFilter.outputImage,
            let outputCGImage = context.createCGImage(outputCIImage, from: outputCIImage.extent)
        else {
            return self
        }
        
        return UIImage(cgImage: outputCGImage)
    }
    
    func croppedInRect(rect: CGRect) -> UIImage {
        
        var rectTransform: CGAffineTransform
        switch imageOrientation {
            case .left:
                rectTransform = CGAffineTransform(rotationAngle: CGFloat(90).radians())
                    .translatedBy(x: 0, y: -self.size.height)
            case .right:
                rectTransform = CGAffineTransform(rotationAngle: CGFloat(-90).radians())
                    .translatedBy(x: -self.size.width, y: 0)
            case .down:
                rectTransform = CGAffineTransform(rotationAngle: CGFloat(-180).radians())
                    .translatedBy(x: -self.size.width, y: -self.size.height)
            default:
                rectTransform = .identity
        }
        rectTransform = rectTransform.scaledBy(x: self.scale, y: self.scale)
        
        let imageRef = self.cgImage!.cropping(to: rect.applying(rectTransform))
        let result = UIImage(cgImage: imageRef!, scale: self.scale, orientation: self.imageOrientation)
        return result
    }
    
    func drawIn(
        _ backgpund: UIImage?,
        position: CGPoint = .zero,
        angle: CGFloat = 0
    ) -> UIImage {
        guard let backgpundCIImage = backgpund?.cgImage?.ciImage, var inputCIImage = CIImage(image: self) else {
            return self
        }
        
        let x = (inputCIImage.extent.size.width - backgpundCIImage.extent.size.width) / 2
        let y = (inputCIImage.extent.size.height - backgpundCIImage.extent.size.height) / 2
        let newPosition = CGPoint(x: -x, y: y) + position
        
        inputCIImage = inputCIImage
            .transformed(by: CGAffineTransform(rotationAngle: angle.radians()))
            .transformed(by: CGAffineTransform(translationX: newPosition.x, y: -newPosition.y))
        
        
        let blendFilter = CIFilter.sourceAtopCompositing()
        blendFilter.inputImage = inputCIImage
        blendFilter.backgroundImage = backgpundCIImage
        
        let context = CIContext()
        
        guard
            let outputCIImage = blendFilter.outputImage,
            let outputCGImage = context.createCGImage(outputCIImage, from: CGRect(origin: .zero, size: backgpundCIImage.extent.size))
        else {
            return self
        }
        
        return UIImage(cgImage: outputCGImage)
    }
}
