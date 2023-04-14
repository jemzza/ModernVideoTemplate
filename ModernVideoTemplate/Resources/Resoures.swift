//
//  Resoures.swift
//  ModernVideoTemplate
//
//  Created by Alexander Litvinov on 14.4.2023.
//

import Foundation

struct Resources {
    
    private enum Constants {
        
        static let temporaryVideoPath = "temporary_video.mov"
        static let outputMoviePath = "final_temporary_video.mov"
    }
    
    static let temporaryMovieURL = FileManager.createUrlWithPath(Constants.temporaryVideoPath)
    static let outputMovieUrl = FileManager.createUrlWithPath(Constants.outputMoviePath)
}
