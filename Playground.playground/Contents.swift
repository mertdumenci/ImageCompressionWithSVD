//: Playground - noun: a place where people can play

import UIKit
import SVDCompressionKit

let image = #imageLiteral(resourceName: "diddy.jpg")

let imageSize = Size(height: Int(image.size.height), width: Int(image.size.width))
let vectorizedImage = vectorizeImage(image: image)

let redMatrix = Matrix<UInt8>(vec: vectorizedImage.0, size: imageSize)
let greenMatrix = Matrix<UInt8>(vec: vectorizedImage.1, size: imageSize)
let blueMatrix = Matrix<UInt8>(vec: vectorizedImage.2, size: imageSize)

func rankReduction(matrix: Matrix<UInt8>, rankFactor: Double) -> Matrix<UInt8> {
    let SVD = matrix.svd()
    
    let U = SVD.U
    let sigma = SVD.Σ
    let VT = SVD.VT
    
    let trimmedSigma = trimZeroes(vector: sigma.underlyingVector).reversed()
    let rank = trimmedSigma.count
    
    for singularValue in trimmedSigma {
        singularValue
    }
    
    let newRank = Int(round(Double(rank) * rankFactor))
    
    let newSigma = Vector<Double>(trimmedSigma.prefix(newRank))
    let newSigmaMatrix = Matrix<Double>(diagonal: newSigma, size: sigma.size)
    
    for singularValue in newSigma {
        singularValue
    }
    
    let newImageMatrix = (U * newSigmaMatrix * VT)
    
    return newImageMatrix.integerRepresentation()
}

let factor = 0.1
let newRed = rankReduction(matrix: redMatrix, rankFactor: factor)
let newGreen = rankReduction(matrix: greenMatrix, rankFactor: factor)
let newBlue = rankReduction(matrix: blueMatrix, rankFactor: factor)

let compressedImage = compileImage(redVector: newRed.underlyingVector,
                                   greenVector: newGreen.underlyingVector,
                                   blueVector: newBlue.underlyingVector,
                                   size: newRed.size)

compressedImage
















