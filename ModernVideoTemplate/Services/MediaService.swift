//
//  VideoService.swift
//  ModernVideoTemplate
//
//  Created by Alexander Litvinov on 3.4.2023.
//

import Foundation
import CoreImage
import AVFoundation

enum MediaError: Error {
    
    case audio(message: String)
    case video(message: String)
    case createAssetWriter(message: String)
    case export(message: String)
}

final class MediaService: VideoMakable {
    
    private enum Constants {
        
        static let videoQueueName = "videoConvertingQueue"
    }
    
    private let videoQueue = DispatchQueue(label: Constants.videoQueueName, attributes: .concurrent)
    private let timeValue: Int64 = 3
    private let timeScale: Int32 = 10
    
    init() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Setting category to AVAudioSessionCategoryPlayback failed.")
        }
    }
    
    func makeVideo(ciImages: [CIImage], completion: @escaping (Result<Bool, MediaError>) -> Void) {
        
        let temporaryMovieURL = Resources.temporaryMovieURL
        let outputMovieUrl = Resources.outputMovieUrl
        
        FileManager.removeItem(at: temporaryMovieURL)
        FileManager.removeItem(at: outputMovieUrl)
        
        guard let audioUrl = Bundle.main.url(forResource: "music", withExtension: "aac") else {
            return
        }
        
        guard
            let assetWriter = createAssetWriter(url: temporaryMovieURL),
            let assetWriterInput = assetWriter.inputs.first(where: { $0.mediaType == .video })
        else {
            print(MediaError.createAssetWriter(message: "Error ouccur when creating assetWriter"))
            return
        }

        let pixelBufferAdaptor = AVAssetWriterInputPixelBufferAdaptor(
            assetWriterInput: assetWriterInput, sourcePixelBufferAttributes: nil
        )
        
        assetWriter.startWriting()
        assetWriter.startSession(atSourceTime: CMTime.zero)
        
        if (pixelBufferAdaptor.pixelBufferPool == nil) {
            print(MediaError.video(message: "Error converting images to video: pixelBufferPool nil"))
        }
        
        let frameDuration = CMTimeMake(value: timeValue, timescale: timeScale)
        var frameCount = 0

        assetWriterInput.requestMediaDataWhenReady(on: videoQueue) { [weak self] in
            while assetWriterInput.isReadyForMoreMediaData == true, frameCount < ciImages.count {
                let lastFrameTime = CMTimeMake(
                    value: Int64(frameCount) * (self?.timeValue ?? 0), timescale: self?.timeScale ?? 0
                )
                let presentationTime = frameCount == 0 ? lastFrameTime : CMTimeAdd(lastFrameTime, frameDuration)

                self?.appendImageToPixelBuffer(
                    ciImage: ciImages[frameCount],
                    pixelBufferAdaptor: pixelBufferAdaptor,
                    presentationTime: presentationTime
                )

                frameCount += 1
            }

            assetWriterInput.markAsFinished()

            assetWriter.finishWriting { [weak self] in
                let avUrlAssetVideo = AVURLAsset(url: temporaryMovieURL)
                let avUrlAssetAudio = AVURLAsset(url: audioUrl)
                
                self?.addAudioToVideo(
                    avUrlAudioAsset: avUrlAssetAudio,
                    avUrlVideoAsset: avUrlAssetVideo,
                    quality: AVAssetExportPresetHighestQuality,
                    outputUrl: outputMovieUrl,
                    completion: completion
                )
            }
        }
    }
}

extension MediaService {
    
    private func createAssetWriter(url: URL) -> AVAssetWriter? {
        //delete any old file
        FileManager.removeItem(at: url)
        
        //create an assetwriter instance
        guard let assetwriter = try? AVAssetWriter(outputURL: url, fileType: .mov) else {
            abort()
        }
        //generate 1080p settings
        let settingsAssistant = AVOutputSettingsAssistant(preset: .preset1920x1080)?.videoSettings
        //create a single video input
        let assetWriterInput = AVAssetWriterInput(mediaType: .video, outputSettings: settingsAssistant)
        
        //add the input to the asset writer
        assetwriter.add(assetWriterInput)
        
        return assetwriter
    }
    
    private func appendImageToPixelBuffer(
        ciImage: CIImage,
        pixelBufferAdaptor: AVAssetWriterInputPixelBufferAdaptor,
        presentationTime: CMTime
    ) {
        var pixelBuffer: CVPixelBuffer?
        
        let attributes = [
            kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue,
            kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue
        ] as CFDictionary
        
        let width = Int(ciImage.extent.size.width)
        let height = Int(ciImage.extent.size.height)
        
        CVPixelBufferCreate(
            kCFAllocatorDefault,
            width,
            height,
            kCVPixelFormatType_32BGRA,
            attributes,
            &pixelBuffer
        )
        
        guard let pixelBuffer = pixelBuffer else {
            return
        }
        
        let context = CIContext()
        context.render(ciImage, to: pixelBuffer)
        
        pixelBufferAdaptor.append(pixelBuffer, withPresentationTime: presentationTime)
    }
    
    private func addAudioToVideo(
        avUrlAudioAsset audioUrl: AVURLAsset,
        avUrlVideoAsset videoUrl: AVURLAsset,
        quality: String,
        outputUrl: URL,
        completion: @escaping (Result<Bool, MediaError>) -> Void
    ) {
        let composition = AVMutableComposition()
        
        guard let videoAssetTrack = videoUrl.tracks(withMediaType: .video).first else {
            return
        }
        
        let compositionVideoTrack = composition.addMutableTrack(
            withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid
        )
        
        try? compositionVideoTrack?.insertTimeRange(
            CMTimeRangeMake(start: .zero, duration: videoUrl.duration), of: videoAssetTrack, at: .zero
        )
        
        guard let audioAssetTrack = audioUrl.tracks(withMediaType: .audio).first else {
            return
        }
        
        let compositionAudioTrack = composition.addMutableTrack(
            withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid
        )
        try? compositionAudioTrack?.insertTimeRange(
            CMTimeRangeMake(start: CMTime(value: 5, timescale: 10), duration: videoUrl.duration),
            of: audioAssetTrack,
            at: .zero
        )
        
        guard let assetExportSession = createAssetExportSesssion(
            composition: composition,
            quality: quality,
            outputUrl: outputUrl
        ) else {
            return
        }
        
        assetExportSession.exportAsynchronously {
            FileManager.removeItem(at: videoUrl.url)
            completion(.success(true))
        }
    }
    
    private func createAssetExportSesssion(
        composition: AVMutableComposition,
        quality: String,
        outputUrl: URL
    ) -> AVAssetExportSession? {
        let assetExportSession = AVAssetExportSession(asset: composition, presetName: quality)
        assetExportSession?.outputFileType = .mov
        assetExportSession?.outputURL = outputUrl
        
        return assetExportSession
    }
}
