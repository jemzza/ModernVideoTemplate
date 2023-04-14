//
//  TemplatePresenter.swift
//  ModernVideoTemplate
//
//  Created by Alexander Litvinov on 3.4.2023.
//

import Combine
import UIKit

final class TemplatePresenter: ObservableObject {
    
    @Published var processedImage: UIImage? = nil
    @Published var resultSubject = CurrentValueSubject<Bool, MediaError>(false)
}
