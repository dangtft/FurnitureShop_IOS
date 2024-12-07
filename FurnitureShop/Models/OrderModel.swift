import Foundation

struct OrderModel: Identifiable, Codable {
    var id: String
    var userId: String
    var orderDate: Date
    var products: [OrderProduct]
    var totalAmount: Double
    var status: String
}

struct OrderProduct: Codable {
    var productId: Int
    var productName : String
    var quantity: Int
    var price: Double
}
