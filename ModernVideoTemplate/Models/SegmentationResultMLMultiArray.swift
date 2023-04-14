//
//  SegmentationResultMLMultiArray.swift
//  ModernVideoTemplate
//
//  Created by Alexander Litvinov on 1.4.2023.
//

import CoreML
import UIKit

struct SegmentationResultMLMultiArray {
    
    let mlMultiArray: MLMultiArray
    let segmentationMapWidthSize: Int
    let segmentationMapHeightSize: Int
    
    init(mlMultiArray: MLMultiArray) {
        self.mlMultiArray = mlMultiArray
        self.segmentationMapWidthSize = mlMultiArray.shape[0].intValue
        self.segmentationMapHeightSize = mlMultiArray.shape[1].intValue
    }
    
    subscript(columnIndex: Int, rowIndex: Int) -> NSNumber {
        let index = columnIndex * segmentationMapHeightSize + rowIndex
        return mlMultiArray[index]
    }
}
