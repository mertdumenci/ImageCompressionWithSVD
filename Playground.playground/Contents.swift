//: Playground - noun: a place where people can play

import UIKit
import SVDCompressionKit

let image = #imageLiteral(resourceName: "diddy.jpg")

let matrix = Matrix<Int8>(image: image)
let SVD = matrix.svd()

let U = SVD.U
let sigma = SVD.Σ
let VT = SVD.VT

print(sigma)

let trimmedSigma = trimZeroes(vector: sigma.underlyingVector).reversed()
let rank = trimmedSigma.count

for singularValue in trimmedSigma {
    singularValue
}

let rankFactor = 0.1
let newRank = Int(round(Double(rank) * rankFactor))

let newSigma = Vector<Double>(trimmedSigma.prefix(newRank))
let newSigmaMatrix = Matrix<Double>(diagonal: newSigma, size: sigma.size)

for singularValue in newSigma {
    singularValue
}

let newImageMatrix = (U * newSigmaMatrix * VT)

newImageMatrix.integerRepresentation().imageRepresentation()