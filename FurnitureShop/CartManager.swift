import SwiftUI
import FirebaseFirestore
import FirebaseAuth

class CartManager: ObservableObject {
    @Published var cart: CartModel?
    @Published var availableProducts: [ProductModel] = []
    
    private let db = Firestore.firestore()
    
    var total: Int {
        return cart?.totalPrice ?? 0
    }

    var cartItemCount: Int {
        return cart?.totalQuantity ?? 0
    }

    // Hàm tải giỏ hàng từ Firebase
    func loadCartFromFirebase(userId: String) {
        db.collection("carts").document(userId).getDocument { [weak self] document, error in
            if let document = document, document.exists {
                do {
                    let cartData = try document.data(as: CartModel.self)
                    self?.cart = cartData
                } catch {
                    print("Lỗi khi tải giỏ hàng: \(error.localizedDescription)")
                }
            } else {
                print("Giỏ hàng không tồn tại.")
            }
        }
    }
    
    // Hàm thêm sản phẩm vào giỏ hàng
    func addToCart(product: CartProduct, userId: String) {
        // Tải giỏ hàng từ Firebase trước khi thêm sản phẩm mới
        loadCartFromFirebase(userId: userId) { [weak self] in
            guard let self = self else { return }
            
            if self.cart == nil {
                // Nếu giỏ hàng chưa được tạo, tạo mới giỏ hàng với sản phẩm hiện tại
                self.cart = CartModel(id: Int(userId) ?? 0, products: [product])
            } else {
                // Kiểm tra nếu sản phẩm đã có trong giỏ hàng
                if let index = self.cart?.products.firstIndex(where: { $0.productId == product.productId }) {
                    // Nếu sản phẩm đã có trong giỏ hàng, cập nhật số lượng
                    self.cart?.products[index].quantity += product.quantity
                } else {
                    // Nếu sản phẩm chưa có trong giỏ hàng, thêm vào giỏ
                    self.cart?.products.append(product)
                }
            }

            // Lưu giỏ hàng vào Firebase sau khi thay đổi
            self.saveCartToFirebase(userId: userId)
            loadCartFromFirebase(userId: userId)
        }
    }

    // Hàm tải giỏ hàng từ Firebase
    func loadCartFromFirebase(userId: String, completion: @escaping () -> Void) {
        db.collection("carts").document(userId).getDocument { [weak self] document, error in
            if let document = document, document.exists {
                do {
                    let cartData = try document.data(as: CartModel.self)
                    self?.cart = cartData
                } catch {
                    print("Lỗi khi tải giỏ hàng: \(error.localizedDescription)")
                }
            } else {
                print("Giỏ hàng không tồn tại.")
            }
            
            // Sau khi tải xong giỏ hàng, gọi completion
            completion()
        }
    }


    func generateNewProductId() -> String {
        return "\(cart?.products.count ?? 0 + 1)"
    }

    // Lưu giỏ hàng vào Firebase
    func saveCartToFirebase(userId: String) {
        guard let cart = cart else { return }

        let cartData: [String: Any] = [
            "id": cart.id,
            "products": cart.products.map { product in
                return [
                    "id": product.id,
                    "productId": product.productId,
                    "name": product.name,
                    "category": product.category,
                    "price": product.price,
                    "quantity": product.quantity,
                    "image": product.image
                ]
            },
            "totalPrice": total,
            "totalQuantity": cartItemCount
        ]

//        db.collection("carts").document(userId).setData(cartData) { error in
//            if let error = error {
//                print("Lỗi khi lưu giỏ hàng: \(error.localizedDescription)")
//            } else {
//                print("Giỏ hàng đã được lưu thành công.")
//            }
//        }
        db.collection("carts").document(userId).setData(cartData) { error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Lỗi khi lưu giỏ hàng: \(error.localizedDescription)")
                } else {
                    print("Giỏ hàng đã được lưu thành công.")
                }
            }
        }

    }

    // Xóa một sản phẩm khỏi giỏ hàng
    func removeFromCart(product: CartProduct, userId: String) {
        guard let currentCart = cart else {
            print("Giỏ hàng chưa được khởi tạo.")
            return
        }

        // Tìm sản phẩm trong giỏ hàng
        if let index = currentCart.products.firstIndex(where: { $0.productId == product.productId }) {
            if currentCart.products[index].quantity > 1 {
                // Giảm số lượng sản phẩm
                cart?.products[index].quantity -= 1
            } else {
                // Xóa sản phẩm khi số lượng bằng 1
                cart?.products.remove(at: index)
            }

            // Kiểm tra nếu giỏ hàng trống sau khi xóa
            if cart?.products.isEmpty == true {
                cart = nil // Đặt giỏ hàng thành nil nếu trống
            }

            // Lưu giỏ hàng vào Firebase
            saveCartToFirebase(userId: userId)
        } else {
            print("Sản phẩm không tồn tại trong giỏ hàng.")
        }
    }





    // Xóa toàn bộ một sản phẩm khỏi giỏ hàng
    func removeAllFromCart(productId: Int, userId: String) {
        // Kiểm tra xem giỏ hàng đã khởi tạo chưa
        guard cart != nil else {
            print("Giỏ hàng chưa được khởi tạo.")
            return
        }

        // Xóa tất cả sản phẩm có productId tương ứng
        cart?.products.removeAll { $0.productId == productId }

        // Kiểm tra nếu giỏ hàng trống sau khi xóa
        if cart?.products.isEmpty == true {
            cart = nil // Đặt giỏ hàng thành nil nếu trống
        }

        // Lưu giỏ hàng sau khi thay đổi
        saveCartToFirebase(userId: userId)
    }


    // Xóa tất cả sản phẩm trong giỏ hàng
    func clearCart() {
        cart = nil
        if let userId = getCurrentUserId() {
            db.collection("carts").document(userId).delete { error in
                if let error = error {
                    print("Lỗi khi xóa giỏ hàng: \(error.localizedDescription)")
                } else {
                    print("Giỏ hàng đã được xóa.")
                }
            }
        }
    }

    // Giả lập hàm lấy userId hiện tại
    func getCurrentUserId() -> String? {
        return Auth.auth().currentUser?.uid
    }
}


