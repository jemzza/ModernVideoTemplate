//
//  TemplatePresenter.swift
//  ModernVideoTemplate
//
//  Created by Alexander Litvinov on 3.4.2023.
//

import Combine
import UIKit

protocol TemplatePresentable: AnyObject {
    
    var processedImage: UIImage? { get set }
    var processedImagePublished: Published<UIImage?> { get }
    var processedImagePublisher: Published<UIImage?>.Publisher { get }
    
    var convertVideoResultSubject: CurrentValueSubject<Bool, MediaError> { get }
}

final class TemplatePresenter: ObservableObject, TemplatePresentable {
    
    @Published var processedImage: UIImage? = nil
    var processedImagePublished: Published<UIImage?> { _processedImage }
    var processedImagePublisher: Published<UIImage?>.Publisher { $processedImage }
    
    var convertVideoResultSubject: CurrentValueSubject<Bool, MediaError> = .init(false)
}
