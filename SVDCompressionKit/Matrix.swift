//
//  Matrix.swift
//  SVDCompressionKit
//
//  Created by Mert Dümenci on 3/28/17.
//  Copyright © 2017 Mert Dümenci. All rights reserved.
//

import Foundation

public typealias Vector8 = [Int8]

private func grayscale8BitContext(width: Int, height: Int,
                                        data: UnsafeMutableRawPointer)
    -> CGContext? {
    // Creates a 8-bit per pixel, grayscale image context
    let grayColorSpace = CGColorSpaceCreateDeviceGray()
    let context = CGContext(data: data, width: width,
                            height: height, bitsPerComponent: 8,
                            bytesPerRow: width, space: grayColorSpace,
                            bitmapInfo: CGImageAlphaInfo.none.rawValue)
    
    return context
}

public struct Matrix {
    var rows: [Vector8]
    
    var width: Int {
        return (rows.count > 0) ? rows[0].count : 0
    }

    var height: Int {
        return rows.count
    }
    
    init(rows: [Vector8]) {
        self.rows = rows
    }
}

/*
    Loading a `Matrix` with the grayscale representation of an `UIImage`, and
    creating a greyscale `UIImage` representation from a `Matrix`.
 */
public extension Matrix {
    init(image: UIImage) {
        let cgImage = image.cgImage!
        
        let width = Int(image.size.width)
        let height = Int(image.size.height)
        
        var data = Vector8(repeating: 0, count: width * height)
        
        let context = grayscale8BitContext(width: width,
                                           height: height,
                                           data: &data)

        context?.draw(cgImage, in: CGRect(x: 0, y: 0,
                                          width: width,
                                          height: height))
        
        var rows = [Vector8](repeating: Vector8(repeating: 0, count: width),
                             count: height)
        
        for (idx, el) in data.enumerated() {
            let row = Int(idx / width)
            let col = idx % width
            
            rows[row][col] = el
        }
        
        self.rows = rows
    }
    
    func imageRepresentation() -> UIImage? {
        var data = Vector8(repeating: 0, count: width * height)
        
        for (i, row) in rows.enumerated() {
            for (j, intensity) in row.enumerated() {
                data[i * width + j] = intensity
            }
        }
        
        let context = grayscale8BitContext(width: width,
                                           height: height,
                                           data: &data)
        
        if let image = context?.makeImage() {
            return UIImage(cgImage: image)
        }
        
        return nil
    }
}
