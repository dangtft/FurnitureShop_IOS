import SwiftUI
import FirebaseFirestore

struct ProductModel: Identifiable, Decodable, Encodable {
    @DocumentID var id: String?
    var name: String
    var description: String
    var price: Double
    var imageName: String
    var size: ProductSize
    var quantity: Int
    var material: String
    var availableColors: [String]
    var category: String
}

struct ProductSize: Decodable, Encodable {
    var height: Double
    var width: Double
    var diameter: Double
}
