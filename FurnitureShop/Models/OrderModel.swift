import FirebaseFirestore
import Foundation

struct OrderModel: Identifiable, Decodable {
    @DocumentID var id: String?
    var orderDate: Date
    var totalAmount: Double
    var status: String
    var products: [OrderProduct]
    var userId: String
    var userName: String
    var address : String
    var paymentMethod : String
}

struct OrderProduct: Decodable {
    var productId: String
    var productName: String
    var quantity: Int
    var price: Double
    var productImage: String?
}

