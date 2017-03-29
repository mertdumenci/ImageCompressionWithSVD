//: Playground - noun: a place where people can play

import UIKit
import SVDCompressionKit

let image = #imageLiteral(resourceName: "diddy.jpg")

let matrix = Matrix<Int8>(image: UIImage(named: "diddy.jpg")!)
let preVSD = matrix.imageRepresentation()

let vsd = matrix.svd()

let imaj = (vsd.U * vsd.Σ * vsd.VT).integerRepresentation().imageRepresentation()
