//
//  Matrix.swift
//  SVDCompressionKit
//
//  Created by Mert Dümenci on 3/28/17.
//  Copyright © 2017 Mert Dümenci. All rights reserved.
//

import Foundation
import Accelerate

public typealias SVD = (U: Matrix<Double>,
                        Σ: Matrix<Double>,
                        VT: Matrix<Double>)
public typealias Vector<T> = [T]

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

private func multiplyDoubleMatrices(underlyingVectorA: Vector<Double>,
                                    underlyingVectorB: Vector<Double>,
                                    sizeA: Size,
                                    sizeB: Size) -> (Vector<Double>, Size)? {
    if sizeA.width != sizeB.height {
        return nil
    }
    
    let order = CblasRowMajor
    let transposeOpt = CblasNoTrans
    let height = Int32(sizeA.height)
    let width = Int32(sizeB.width)
    let overlappingDimension = Int32(sizeA.width)
    let scalingFactor: Double = 1
    
    let dimLeft = Int32(sizeA.width)
    let dimRight = Int32(sizeB.width)
    let dimResult = Int32(sizeB.width)
    
    let resultLength = Int(height) * Int(width)
    var result: [Double] = [Double](repeating: 0, count: resultLength)
    
    cblas_dgemm(order, transposeOpt, transposeOpt, height, width,
                overlappingDimension, scalingFactor, underlyingVectorA,
                dimLeft, underlyingVectorB, dimRight, scalingFactor, &result,
                dimResult)
    
    return (result, Size(height: Int(height), width: Int(width)))
}

private func singularValueDecomposition(underlyingVector: Vector<Double>,
                                        size: Size) -> SVD {
    // Return all columns of U and all rows of V^T
    var jobz = "A".utf8CString[0]
    var height = __CLPK_integer(size.height)
    var width = __CLPK_integer(size.width)
    var dimA = height
    var dimU = height
    var dimVT = width
    
    // Data
    var underlyingVector = underlyingVector
    var U = [Double](repeating: 0, count: Int(dimU) * Int(dimU))
    var Σ = [Double](repeating: 0, count: Int(dimU) * Int(dimVT))
    var VT = [Double](repeating: 0, count: Int(dimVT) * Int(dimVT))
    
    var info: __CLPK_integer = 0
    // I believe this is an internal array that `dgesdd` uses in its
    // internal algorithm--its minimum size is defined as 8 * min(m, n)
    var iwork = [__CLPK_integer](repeating: 0,
                                 count: 8 * min(size.height, size.width))
    var workopt: Double = 0
    var lwork: __CLPK_integer = -1
    
    // First run to get optimal lwork size
    dgesdd_(&jobz, &height, &width, &underlyingVector, &dimA, &Σ, &U,
            &dimU, &VT, &dimVT, &workopt, &lwork, &iwork, &info)
    
    // Second run to actually compute the SVD
    lwork = __CLPK_integer(workopt)
    var work = [Double](repeating: 0, count: Int(lwork))
    dgesdd_(&jobz, &height, &width, &underlyingVector, &dimA, &Σ, &U,
            &dimU, &VT, &dimVT, &work, &lwork, &iwork, &info)
    
    if info > 0 {
        fatalError("The SVD algorithm failed to converge.")
    }
    
    let sizeU = Size(height: size.height, width: size.height)
    let sizeΣ = Size(height: size.height, width: size.width)
    let sizeVT = Size(height: size.width, width: size.width)
    
    let rowMajorU = transpose(vector: U, size: sizeU.transpose())
    let rowMajorVT = transpose(vector: VT, size: sizeVT.transpose())
    
    let matrixU = Matrix(vec: rowMajorU, size: sizeU)
    let matrixΣ = Matrix(diagonal: Σ, size: sizeΣ)
    let matrixVT = Matrix(vec: rowMajorVT, size: sizeVT)
    
    return (U: matrixU, Σ: matrixΣ, VT: matrixVT)
}

private func transpose(vector: Vector<Double>, size: Size) -> Vector<Double> {
    let length = size.height * size.width
    var columnMajor = Vector<Double>(repeating: 0, count: length)
    
    for j in 0..<size.height {
        for i in 0..<size.width {
            let newIndex = i * size.height + j
            columnMajor[newIndex] = vector[j * size.width + i]
        }
    }
    
    return columnMajor
}

public struct Size {
    let height: Int
    let width: Int
    
    public init(height: Int, width: Int) {
        self.height = height
        self.width = width
    }
    
    public func transpose() -> Size {
        return Size(height: width, width: height)
    }
}

public protocol MatrixProtocol {
    associatedtype DT
    
    var underlyingVector: Vector<DT> { get set }
    var size: Size { get set }
    
    init()
}

public struct Matrix<T>: MatrixProtocol {
    public typealias DT = T
    
    // Stored row-major!
    public var underlyingVector: Vector<T>
    public var size: Size

    public var rows: [Vector<T>] {
        var rows: [Vector<T>] = []
        
        for (idx, el) in underlyingVector.enumerated() {
            let row = Int(idx / size.width)
            let col = idx % size.width
            
            if !rows.indices.contains(row) {
                rows.insert([], at: row)
            }
            
            rows[row].insert(el, at: col)
        }
        
        return rows
    }
    
    public init() {
        self.init(vec: [], size: Size(height: 0, width: 0))
    }
    
    public init(vec: Vector<T>, size: Size) {
        self.underlyingVector = vec
        self.size = size
    }
}

extension Matrix: CustomStringConvertible {
    public var description: String {
        var descriptionString = "\(size.height) * \(size.width)\n"
        for row in rows {
            let rowDescription = row.map() { String(describing: $0) }
                                .joined(separator: " ")
            
            descriptionString += "|" + rowDescription + "|\n"
        }
        
        return descriptionString
    }
}

/*
    Loading a `Matrix` with the grayscale representation of an `UIImage`, and
    creating a greyscale `UIImage` representation from a `Matrix`.
 */
public extension MatrixProtocol where DT == Int8 {
    init(image: UIImage) {
        self.init()
        
        let cgImage = image.cgImage!
        
        size = Size(height: Int(image.size.height),
                    width: Int(image.size.width))
        
        var data = Vector<Int8>(repeating: 0, count: size.height * size.width)
        
        let context = grayscale8BitContext(width: size.width,
                                           height: size.height,
                                           data: &data)
        
        context?.draw(cgImage, in: CGRect(x: 0, y: 0,
                                          width: size.width,
                                          height: size.height))
        
        self.underlyingVector = data
    }
    
    func imageRepresentation() -> UIImage? {
        var data = self.underlyingVector
        
        let context = grayscale8BitContext(width: size.width,
                                           height: size.height,
                                           data: &data)
        
        if let image = context?.makeImage() {
            return UIImage(cgImage: image)
        }
        
        return nil
    }
}

public extension MatrixProtocol where DT == Double {
    static func * (left: Self, right: Self) -> Matrix<Double> {
        let result =
            multiplyDoubleMatrices(underlyingVectorA: left.underlyingVector,
                                   underlyingVectorB: right.underlyingVector,
                                   sizeA: left.size, sizeB: right.size)
            
        if let result = result {
            return Matrix<DT>(vec: result.0, size: result.1)
        }
            
        #if DEBUG
            print("Size mismatch in Matrix multiplication, break in Matrix#*")
        #endif
        
        return Matrix<DT>(vec: [],
                              size: Size(height: 0, width: 0))
    }
    
    func svd() -> SVD {
        let colMajor = transpose(vector: underlyingVector, size: size)
        return singularValueDecomposition(underlyingVector: colMajor,
                                          size: size)
    }
    
    init(diagonal fromVector: Vector<DT>, size: Size) {
        self.init()
        
        let diagonalCount = min(size.height, size.width)
        var underlyingVector = [DT](repeating: DT(0),
                                    count: size.height * size.width)
        
        for (idx, el) in fromVector[0..<diagonalCount].enumerated() {
            underlyingVector[idx * size.width + idx] = el
        }

        self.underlyingVector = underlyingVector
        self.size = size
    }
    
    func integerRepresentation() -> Matrix<Int8> {
        let intVector = underlyingVector.map() { Int8(round($0)) }
        return Matrix<Int8>(vec: intVector, size: size)
    }
}

public extension MatrixProtocol where DT == Int8 {
    static func * (left: Self, right: Self) -> Matrix<Int8> {
            let leftDoubleVector = left.underlyingVector.map { Double($0) }
            let rightDoubleVector = right.underlyingVector.map { Double($0) }
            
            let result =
                multiplyDoubleMatrices(underlyingVectorA: leftDoubleVector,
                                       underlyingVectorB: rightDoubleVector,
                                       sizeA: left.size, sizeB: right.size)
            
            if let result = result {
                let integerVector = result.0.map() { Int8($0) }
                
                return Matrix<Int8>(vec: integerVector,
                                    size: result.1)
            }
            
            #if DEBUG
                print("Size mismatch in Matrix multiplication, break in Matrix#*")
            #endif
            
            return Matrix<Int8>(vec: [],
                                size: Size(height: 0, width: 0))
    }
    
    func svd() -> SVD {
        let doubleUnderlying = underlyingVector.map() { Double($0) }
        let colMajor = transpose(vector: doubleUnderlying, size: size)
        
        return singularValueDecomposition(underlyingVector: colMajor,
                                          size: size)
    }
}
