/*:
 ## WWDC 2017 Submission: Image Compression with SVD
 Mert Dumenci [(mdumenci@gatech.edu)](mailto:mdumenci@gatech.edu)

 I took Linear Algebra in my first semester in college (I'm a freshman in Computer Science),
 and I found the *Singular Value Decomposition (SVD)* to be fascinating. I decided to make this
 playground about image compression using SVD--I believe it's a wonderful showcase of the powers
 of the interactive playground environment, the Swift language and the Accelerate framework.

 Let's compress an image!
*/
import UIKit
import SVDCompressionKit
/*:
 To compress an image, we need to have an image. I've observed that Playgrounds can be a bit
 slow when executing complex programs. (Probably because of the interactive value logging it does.)
 
 Because we're going to apply a multitude of complex arithmetic operations on the image,
 and we don't want this to be slow, we fetch and downsize the image first.
 
 Please note that downsizing is not compression--we are simply scaling the image down. This
 program would work equally fine with a bigger image (in fact, it's almost instant when ran in
 a non-Playground environment, because we use Accelerate).
 
 You can play around with the image and import your own if you want!
 */
let workingWidth = 200
let image = downsizeImage(image: #imageLiteral(resourceName: "flower.jpg"), width: workingWidth)
/*:
 Our image compression algorithm is defined on matrices, which are simply two-dimensional arrays
 of numbers. If there were some way to represent our image as a matrix, we would be able to use
 our algorithm to compress the image!
 
 Every digital image can be represented as a *bitmap*: a two-dimensional array of *pixels*. A single
 pixel in this instance is simply 4 numbers put together: red, green, blue and alpha.
 
 ![pixel format](pixelformat.png)
 
 If we were to pick out a color component from each pixel, and assemble them in a matrix, we would
 get the same image in the color that we picked. Thus, we can assemble 3 different matrices of colors
 red, green and blue from a single image. Here, using a helper function we do just that.
 
 ![color matrices](colormatrices.png)
 */
let singleColorMatrices = extractMatrices(image: image)
/*:
 Now that we have three matrices representing our image, we can treat them as any other matrix and
 apply *Linear Algebra* (the branch of Mathematics that deal with matrices*) concepts to them!
 
 Our aim is to compress the image. Well, what does compression mean? Essentially approximating the initial 
 data by only using less amount of data. The better our approximation is and the less data we use, the
 better our compression is.
 
 Right now what we have is a simple matrix, recalling our definition, a two-dimensional array of 
 integers. How can we compute a 'good' approximation of this matrix? *Linear Algebra* gives us an 
 indispensable tool called the *Singular Value Decomposition* that we can use to do precisely this.
 
 The *Singular Value Decomposition* is a way of *decomposing* any matrix `A` into three special matrices
 `U`, `Σ` and `V^T` such that
 
 `A = U * Σ * V^T`
 */
func rankReduction(matrix: Matrix<UInt8>, byFactor factor: Double) -> Matrix<UInt8> {
    let SVD = matrix.svd()
    
    let U = SVD.U
    let sigma = SVD.Σ
    let VT = SVD.VT
/*:
 The *SVD* is a special type of decomposition that can be applied to *any* matrix *A* regardless of shape
 and contents. The matrix `Σ` is a special matrix called a *diagonal matrix*, which means it only has
 non-zero values in its diagonal. This implies that there's only one non-zero value in every column or row,
 and for `Σ` we call each of these values the *singular values* of `A`.
     
 By the properties of the matrix multiplication and matrices `U`, `Σ` and `VT`, we can rewrite
 the previous equation as
     
 `A = s_1 * σ_1 * vt_1 + ... + s_n * σ_n * vt_n`
     
 where `s_k` is the `k`th column of `S`, `σ_k` is the `k`th singular value, and `vt_k` is the `k`th column of `V^T`.
     
 I know this looks scary, but we don't have to worry about what all of this means right now. All we have to care
 is that every term in this equation has the `k`th singular value as a coefficient.
     
 As it happens, the singular values `σ_1` through `σ_n` are ordered in a descending order. The amount of detail they
 carry in the final image is directly correlated to their value--the bigger `σ_k` is, the more detail it describes. 
 So, technically, if we replace some singular values with zeroes, we would be able to reduce the detail in the image and
 reduce data size. This process is called *rank reduction*, and as it turns out, the result we get when we replace a
 singular value with zero in the *SVD* form is the *best* approximation of the original image we can have with the remaining
 data.
     
 Here we get the diagonal vector of the matrix `Σ` and plot them. (If you can't see the plot, click on "Show value" for 
     `singularValue`)
*/
    let trimmedSigma = trimZeroes(vector: sigma.underlyingVector).reversed()
    let rank = trimmedSigma.count
    
    for singularValue in trimmedSigma {
        singularValue
    }
/*:
 We calculate the new rank (i.e. the number of singular values we will take) by multiplying
 the existing rank by a factor.
*/
    let newRank = Int(round(Double(rank) * factor))
/*:
 We take the first `n` singular values where `n` is the new rank we calculated (note that
 the singular values are ordered in a descending order, hence the retaining of the most
 detail signifying values), and assemble them back into a diagonal matrix. (A matrix 
 such that the new singular values are on the diagonal, and the rest is filled with zeroes.)
     
 We then plot the new singular values.
*/
    let newSigma = Vector<Double>(trimmedSigma.prefix(newRank))
    let newSigmaMatrix = Matrix<Double>(diagonal: newSigma, size: sigma.size)
    
    for singularValue in newSigma {
        singularValue
    }
/*:
 Remember the *SVD* equation `A = U * Σ * V^T`? Now that we computed a new `Σ` that has a less
 amount of singular values, we can just replace the original `Σ` in the equation with our new
 `Σ` and compute the new, compressed `A` by multiplying all three matrices together.
*/
    let newImageMatrix = (U * newSigmaMatrix * VT)
    return newImageMatrix.integerRepresentation()
}
/*:
 We define the rank factor--this describes the new rank our compressed matrix `A` will have.
 Essentially the ratio of how many singular values we will retain from the original matrix.
*/
let factor = 0.2
/*:
 We extract the red, green and blue image matrices that we computed at the beginning, and
 run our rank reduction algorithm on them.
*/
let newRed = rankReduction(matrix: singleColorMatrices.0, byFactor: factor)
let newGreen = rankReduction(matrix: singleColorMatrices.1, byFactor: factor)
let newBlue = rankReduction(matrix: singleColorMatrices.2, byFactor: factor)
/*:
 We now have compressed red, green and blue matrices. We can put them back together in an image
 using the same principles of digital images that we used to extract them from the original image.
 */
let compressedImage = compileImage(red: newRed, green: newGreen, blue: newBlue)

/*:
 We now have a final compressed image! Play around with the factor and image to see how the compression
 changes--Mathematics is a lot of fun!
 */
compressedImage













