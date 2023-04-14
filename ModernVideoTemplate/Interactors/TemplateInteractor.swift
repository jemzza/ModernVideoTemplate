//
//  TemplateInteractor.swift
//  ModernVideoTemplate
//
//  Created by Alexander Litvinov on 3.4.2023.
//
import UIKit
import Vision
import Combine
import CoreImage.CIFilterBuiltins

typealias MatrixPosition = SafeDictionary<Int, UIImage>

final class TemplateInteractor: TemplateMakable  {
    
    var presenter: TemplatePresentable?
    
    var selectedImages: [UIImage] = [
        UIImage(imageLiteralResourceName: "1"),
        UIImage(imageLiteralResourceName: "2"),
        UIImage(imageLiteralResourceName: "3"),
        UIImage(imageLiteralResourceName: "4"),
        UIImage(imageLiteralResourceName: "5"),
        UIImage(imageLiteralResourceName: "6"),
        UIImage(imageLiteralResourceName: "7"),
        UIImage(imageLiteralResourceName: "8"),
        UIImage(imageLiteralResourceName: "9")
    ]
    
    var requests: [VNCoreMLRequest] = []
    
    private var pictureFilter: PictureFilterable
    private let videoService: VideoMakable
    
    private var segmentationModel: segmentation_8bit!
    private var visionModel: VNCoreMLModel!
    
    private let dispatchGroup = DispatchGroup()
    
    private let safeDictionary = SafeDictionary<Int, MatrixPosition>()
    
    init(pictureFilter: PictureFilterable, videoService: VideoMakable) {
        self.pictureFilter = pictureFilter
        self.videoService = videoService
        
        do {
            segmentationModel = try segmentation_8bit()
            visionModel = try VNCoreMLModel(for: segmentationModel.model)
        } catch let error {
            fatalError(error.localizedDescription)
        }
    }
    
    func makeTemplate() {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let images = self?.getProcessedImages() else {
                return
            }
            
            self?.videoService.makeVideo(ciImages: images) { [weak self] result in
                self?.handleMakeVideoResult(result)
            }
        }
    }
}

private extension TemplateInteractor {
    
    func getProcessedImages() -> [CIImage]? {
        requests = createCoreMLRequests()
        
        for index in 1..<selectedImages.count {
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                guard
                    let cgImage = self?.selectedImages[index].cgImage,
                    let request = self?.requests[index - 1]
                else {
                    return
                }
                
                let handler = VNImageRequestHandler(cgImage: cgImage)
                try? handler.perform([request])
            }
        }
        
        dispatchGroup.wait()
        
        var array = [CIImage]()
        
        for filterIndex in 0..<selectedImages.count - 1 {
            var isElementExist = true
            var elementIndex = 0
            
            while isElementExist {
                if let row = safeDictionary[filterIndex], let element = row[elementIndex], let ciImage = CIImage(image: element) {
                    sendImageToPresenter(image: element, afterSeconds: array.count)
                    array.append(ciImage)
                    elementIndex += 1
                } else {
                    isElementExist = false
                }
            }
        }
        
        safeDictionary.removeAll()
        
        return array
    }
    
    func createCoreMLRequests() -> [VNCoreMLRequest] {
        var coreMLRequests: [VNCoreMLRequest] = []
        
        for index in 0..<selectedImages.count {
            safeDictionary[index] = SafeDictionary<Int, UIImage>()
            
            guard index < selectedImages.count - 1 else {
                continue
            }
            
            dispatchGroup.enter()
            let request = VNCoreMLRequest(model: visionModel) { [weak self] request, error in
                self?.handleCoreMLRequest(withIndex: index, request: request, error: error)
            }
            request.imageCropAndScaleOption = .scaleFill
            
            coreMLRequests.append(request)
        }
        
        return coreMLRequests
    }
    
    func sendImageToPresenter(image: UIImage, afterSeconds seconds: Int) {
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(seconds)) { [weak self] in
            self?.presenter?.processedImage = image
        }
    }
    
    func handleCoreMLRequest(withIndex index: Int, request: VNRequest, error: Error?) {
        if let error = error {
            fatalError(error.localizedDescription)
        }
        
        guard
            let results = request.results,
            let pixelBufferObservation = results.first as? VNPixelBufferObservation
        else {
            return
        }
        
        let maskBuffer = pixelBufferObservation.pixelBuffer
        let maskImage = CIImage(cvPixelBuffer: maskBuffer)
        
        switch index {
            case 0:
                pictureFilter.strategy = CutStrategyInvertedBackgroundAndRotatedForeground()
            case 1:
                pictureFilter.strategy = CutStrategySlowAppearing()
            case 2:
                pictureFilter.strategy = CutStrategyStrokeAppearing()
            case 3:
                pictureFilter.strategy = CutStrategyInvertRotateScale()
            case 4:
                pictureFilter.strategy = CutStrategySlowAppearing()
            case 5:
                pictureFilter.strategy = CutStrategyForegroundScaling()
            case 6:
                pictureFilter.strategy = CutStrategyCopySpam()
            case 7:
                pictureFilter.strategy = CutStrategyInvertedBackgroundScaling()
            default:
                pictureFilter.strategy = DefaultFilterStrategy()
        }
        
        let processedImages =  pictureFilter.getProcessedImages(
            current: selectedImages[index],
            next: selectedImages[index + 1],
            mask: maskImage
        )
        
        setProcessedIImagesToDictionary(index: index, images: processedImages)
        pictureFilter.strategy = DefaultFilterStrategy()
        
        dispatchGroup.leave()
    }
    
    func handleMakeVideoResult(_ result: Result<Bool, MediaError>) {
        switch result {
            case .success(let isSuccess):
                presenter?.convertVideoResultSubject.send(isSuccess)
            case .failure(let error):
                presenter?.convertVideoResultSubject.send(completion: .failure(error))
        }
    }
    
    func setProcessedIImagesToDictionary(index: Int, images: [UIImage]) {
        
        guard let row = safeDictionary[index] else {
            return
        }
        
        for processedIndex in 1...images.count {
            row[processedIndex] = images[processedIndex - 1]
        }
        
        row[0] = selectedImages[index]
        
        // Set last image to Dictionary
        if index == selectedImages.count - 2 {
            var count = 0
            var isImageExist = true
            
            while isImageExist {
                if let _ = row[count] {
                    count += 1
                } else {
                    row[count] = selectedImages[index + 1]
                    isImageExist = false
                }
            }
        }
    }
}
