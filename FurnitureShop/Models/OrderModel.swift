import FirebaseFirestore
import Foundation

struct OrderModel: Identifiable, Decodable {
    @DocumentID var id: String?
    var orderDate: Date
    var totalAmount: Double
    var status: String
    var products: [OrderProduct]
}

struct OrderProduct: Decodable {
    var productId: Int
    var productName: String
    var quantity: Int
    var price: Double
    var productImage: String?
}

