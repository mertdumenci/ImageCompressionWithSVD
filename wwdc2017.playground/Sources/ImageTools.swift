//
//  ImageTools.swift
//  SVDCompressionKit
//
//  Created by Mert Dümenci on 3/30/17.
//  Copyright © 2017 Mert Dümenci. All rights reserved.
//

import UIKit
import CoreGraphics

private func createImageContext(data: UnsafeMutableRawPointer, size: Size) -> CGContext {
    let width = size.width
    let height = size.height
    
    let colorspace = CGColorSpaceCreateDeviceRGB()
    let context = CGContext(data: data, width: width, height: height,
                            bitsPerComponent: 8, bytesPerRow: width * 4,
                            space: colorspace,
                            bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue)
    
    return context!
}

// Swift bug? typealiasing the return type maximizes SourceKit CPU usage, gets
// Xcode in an endless indexing loop
public func extractMatrices(image: UIImage) -> (Matrix<UInt8>, Matrix<UInt8>, Matrix<UInt8>) {
    let width = Int(image.size.width)
    let height = Int(image.size.height)
    
    var bitmapData = Vector<UInt8>(repeating: 0,
                                   count: width * height * 4)
    let context = createImageContext(data: &bitmapData,
                                     size: Size(height: height, width: width))

    context.draw(image.cgImage!, in: CGRect(x: 0, y: 0,
                                             width: width, height: height))
    
    var redVector: Vector<UInt8> = []
    var greenVector: Vector<UInt8> = []
    var blueVector: Vector<UInt8> = []
    
    for i in stride(from: 0, to: bitmapData.count, by: 4) {
        let red = bitmapData[i]
        let green = bitmapData[i + 1]
        let blue = bitmapData[i + 2]
        
        redVector.append(red)
        greenVector.append(green)
        blueVector.append(blue)
    }

    let size = Size(height: height, width: width)
    let redMatrix = Matrix(vec: redVector, size: size)
    let greenMatrix = Matrix(vec: greenVector, size: size)
    let blueMatrix = Matrix(vec: blueVector, size: size)
    
    return (redMatrix, greenMatrix, blueMatrix)
}

public func compileImage(red: Matrix<UInt8>, green: Matrix<UInt8>,
                         blue: Matrix<UInt8>) -> UIImage {
    return compileImage(redVector: red.underlyingVector,
                        greenVector: green.underlyingVector,
                        blueVector: blue.underlyingVector,
                        size: Size(height: Int(red.size.height),
                                   width: Int(red.size.width)))
}

public func compileImage(redVector: Vector<UInt8>,
                         greenVector: Vector<UInt8>,
                         blueVector: Vector<UInt8>,
                         size: Size) -> UIImage {
    let width = size.width
    let height = size.height
    
    var bitmapData = Vector<UInt8>(repeating: 0,
                                   count: width * height * 4)
    
    for i in 0..<redVector.count {
        let red = redVector[i]
        let green = greenVector[i]
        let blue = blueVector[i]
        
        bitmapData[4 * i] = red
        bitmapData[4 * i + 1] = green
        bitmapData[4 * i + 2] = blue
        bitmapData[4 * i + 3] = UInt8.max
    }
    
    let context = createImageContext(data: &bitmapData, size: size)
    let image = context.makeImage()
    
    return UIImage(cgImage: image!)
}

public func downsizeImage(image: UIImage, width: Int) -> UIImage {
    if (width > Int(image.size.height)) {
        return image
    }
    
    let computedHeight = CGFloat(width) * image.size.height / image.size.width
    let computedSize = CGSize(width: CGFloat(width),
                              height: computedHeight)
    
    UIGraphicsBeginImageContextWithOptions(computedSize, false, image.scale);
    image.draw(in: CGRect(x: 0, y: 0, width: computedSize.width,
                          height: computedSize.height))
    let resizedImage = UIGraphicsGetImageFromCurrentImageContext()!
    UIGraphicsEndImageContext()
    
    return resizedImage
}
