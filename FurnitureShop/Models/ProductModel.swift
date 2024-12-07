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

//var products = [
//    ProductModel(id: 0, name: "Luxury Swedish Chair", description: "A luxurious chair for modern homes", price: 1299, imageName: "chair_1", size: ProductSize(height: 100, width: 80, diameter: 0), material: "Wood", availableColors: [.red, .blue], category: "Chair"),
//    ProductModel(id: 1, name: "Modern Sofa", description: "Comfortable sofa for living room", price: 999, imageName: "chair_2", size: ProductSize(height: 90, width: 220, diameter: 0),material: "Fabric", availableColors: [.gray, .black], category: "Sofa"),
//    ProductModel(id: 2, name: "Elegant Lamp", description: "Stylish lamp for lighting", price: 199, imageName: "chair_3", size: ProductSize(height: 150, width: 20, diameter: 15),  material: "Metal", availableColors: [.yellow, .white], category: "Lamp"),
//    ProductModel(id: 3, name: "Stylish Table", description: "Perfect dining table", price: 499, imageName: "chair_4", size: ProductSize(height: 75, width: 200, diameter: 0),  material: "Wood", availableColors: [.brown, .black], category: "Table")
//]
