/*:
## WWDC 2017 Submission: Image Compression using SVD
Mert Dumenci, [mdumenci@gatech.edu](mailto:mdumenci@gatech.edu)
 
*Singular Value Decomposition* is a powerful way to compress images. In this Playground, we will show, step by step, how SVD can be used to compress images in a relatively simple way, and utilize the interactivity provided by Swift Playgrounds to its full extent.
 */
import UIKit

/*:
Let's choose an image to compress. It can be any image, but note that it'll be rendered in grayscale (no colors!) before the compression step. This is done for simplicity--although it certainly is possible to compress color images using the same method.
 */
let image = #imageLiteral(resourceName: "diddy.jpg")
/*:
A digital image is a two-dimensional array of pixels. In a color image, each one of these pixels have multiple components (red, green, blue, etc.), but since we're omitting those for simplicity, every pixel is an integer `[0, 255]` that denotes *blackness*. 0 is white, and 255 is black.
 
Note that a Matrix is a two-dimensional array of integers. Here, we convert our image to the matrix format (and grayscale it.)
 */
let matrix = Matrix<UInt8>(image: image)
/*:
Now that we have a matrix of integers that denotes our image in grayscale--we can apply some clever mathematics on it!
 
Here, we will utilize a Linear Algebra (the branch of Mathematics that deals with matrices) concept called *Singular Value Decomposition*. A *Singular Value Decomposition* of a matrix A is as the following:
 
 `A = U * Σ * V^T`
*/
let SVD = matrix.svd()

let U = SVD.U
let sigma = SVD.Σ
let VT = SVD.VT

let trimmedSigma = trimZeroes(vector: sigma.underlyingVector).reversed()
let rank = trimmedSigma.count

for singularValue in trimmedSigma {
    singularValue
}

let rankFactor = 0.01
let newRank = Int(round(Double(rank) * rankFactor))

let newSigma = Vector<Double>(trimmedSigma.prefix(newRank))
let newSigmaMatrix = Matrix<Double>(diagonal: newSigma, size: sigma.size)

for singularValue in newSigma {
    singularValue
}

let newImageMatrix = (U * newSigmaMatrix * VT)
let newImage = newImageMatrix.integerRepresentation().imageRepresentation()
