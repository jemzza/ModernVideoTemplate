//
//  FileManager+Extension.swift
//  ModernVideoTemplate
//
//  Created by Alexander Litvinov on 8.4.2023.
//

import Foundation

extension FileManager {
    
    static func createUrlWithPath(_ component: String) -> URL {
        guard
            let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
                .first?
                .appendingPathComponent(component)
        else {
            fatalError("Create temporary video url error")
        }
        
        return url
    }
    
    
    static func removeItem(at url: URL) {
        do {
            try FileManager.default.removeItem(at: url)
        } catch {
            print("Could not remove file \(error.localizedDescription)")
        }
    }
}
