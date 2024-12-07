import SwiftUI

struct ProductModel : Identifiable, Decodable{
    var id: Int
    var name: String
    var description: String
    var price: Double
    var imageName: String
    var size: ProductSize
    var quantity : Int
    var material: String
    var availableColors: [String]
    var category: String
}

struct ProductSize: Decodable {
    var height: Double
    var width: Double
    var diameter: Double
}

