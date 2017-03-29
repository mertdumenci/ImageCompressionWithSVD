//: Playground - noun: a place where people can play

import UIKit
import SVDCompressionKit

let image = #imageLiteral(resourceName: "diddy.jpg")

let imageMatrix = Matrix(image: image)
let roundTrip = imageMatrix.imageRepresentation()
