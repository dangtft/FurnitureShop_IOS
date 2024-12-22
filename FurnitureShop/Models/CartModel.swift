import Foundation

struct CartModel: Identifiable, Codable {
    var id: String
    var products: [CartProduct]
    
    var totalPrice: Int {
        return products.reduce(0) { $0 + ($1.totalPrice) }
    }
    
    var totalQuantity: Int {
        return products.reduce(0) { $0 + $1.quantity }
    }

    init(id: String, products: [CartProduct]) {
        self.id = id
        self.products = products
    }
}

struct CartProduct: Identifiable, Codable {
    var id: String
    var productId: String
    var name: String
    var category: String
    var price: Int
    var quantity: Int
    var image: String
    
    var totalPrice: Int {
        return price * quantity
    }
    
    init(id: String, productId: String, name: String, category: String, price: Int, quantity: Int, image: String) {
        self.id = id
        self.productId = productId
        self.name = name
        self.category = category
        self.price = price
        self.quantity = quantity
        self.image = image
    }
}
