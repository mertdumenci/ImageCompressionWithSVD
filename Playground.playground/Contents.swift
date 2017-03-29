//: Playground - noun: a place where people can play

import UIKit
import SVDCompressionKit

let image = #imageLiteral(resourceName: "diddy.jpg")

var matrix = Matrix<Int8>(image: image)
var roundTrip = matrix.imageRepresentation()