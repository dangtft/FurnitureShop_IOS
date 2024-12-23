    import Firebase
    import SwiftUI
    import UIKit
    import Darwin
    import FirebaseFirestore
    import FirebaseAuth

    class FirestoreService {
        
        private let db = Firestore.firestore()
        
        @Published var products: [ProductModel] = []
        
        // MARK: - Update user data
        func updateUser(user: UserModel, completion: @escaping (Bool, Error?) -> Void) {
            // Cập nhật dữ liệu trên Firestore
            let userRef = db.collection("users").document(user.id!)
            
            // Cập nhật dữ liệu người dùng trong Firestore
            userRef.updateData([
                "name": user.name,
                "image": user.image as Any,
                "email": user.email,
                "address": user.address as Any,
                "phoneNumber": user.phoneNumber as Any
            ]) { error in
                if let error = error {
                    completion(false, error)
                    return
                }
                
                // Cập nhật thông tin người dùng trong Firebase Authentication
                self.updateAuthUser(user: user, completion: completion)
            }
        }
        
        // MARK: Cập nhật người dùng trong Firebase Authentication
        private func updateAuthUser(user: UserModel, completion: @escaping (Bool, Error?) -> Void) {
            guard let currentUser = Auth.auth().currentUser else {
                completion(false, NSError(domain: "UserNotLoggedIn", code: 0, userInfo: nil))
                return
            }

            // Cập nhật email nếu thay đổi
            if currentUser.email != user.email {
                currentUser.updateEmail(to: user.email) { error in
                    if let error = error {
                        completion(false, error)
                        return
                    }

                    // Cập nhật mật khẩu nếu người dùng cung cấp mật khẩu mới và mật khẩu không rỗng
                    if !user.password!.isEmpty {
                        self.updatePassword(currentUser: currentUser, newPassword: user.password!, completion: completion)
                    } else {
                        completion(true, nil)  // Chỉ cập nhật email nếu không thay đổi mật khẩu
                    }
                }
            } else {
                // Nếu email không thay đổi, kiểm tra mật khẩu nếu có sự thay đổi
                if !user.password!.isEmpty {
                    self.updatePassword(currentUser: currentUser, newPassword: user.password!, completion: completion)
                } else {
                    completion(true, nil)  
                }
            }
        }

        
        // MARK: Cập nhật mật khẩu trong Firebase Authentication
        private func updatePassword(currentUser: User, newPassword: String, completion: @escaping (Bool, Error?) -> Void) {
            currentUser.updatePassword(to: newPassword) { error in
                if let error = error {
                    completion(false, error)
                } else {
                    completion(true, nil)
                }
            }
        }
        
        // MARK: Delete user
        func deleteUser(user: UserModel, completion: @escaping (Bool, Error?) -> Void) {
            guard let userId = user.id else {
                completion(false, NSError(domain: "InvalidUserId", code: 0, userInfo: nil))
                return
            }
            
            // Xóa dữ liệu người dùng từ Firestore
            db.collection("users").document(userId).delete { error in
                if let error = error {
                    completion(false, error)
                    return
                }
                
                // Xóa người dùng từ Firebase Authentication
                guard let currentUser = Auth.auth().currentUser else {
                    completion(false, NSError(domain: "UserNotLoggedIn", code: 0, userInfo: nil))
                    return
                }
                
                currentUser.delete { error in
                    if let error = error {
                        completion(false, error)
                    } else {
                        completion(true, nil)
                    }
                }
            }
        }
        
        // MARK: fetchUsers
        func fetchUsers(completion: @escaping ([UserModel]?) -> Void) {
            db.collection("users")
                .getDocuments { snapshot, error in
                    if let error = error {
                        print("Error fetching users: \(error.localizedDescription)")
                        completion(nil)
                        return
                    }

                    var users: [UserModel] = []
                    for document in snapshot!.documents {
                        do {
                            var user = try document.data(as: UserModel.self)

                            // Kiểm tra nếu "image" là một chuỗi rỗng và gán giá trị mặc định nếu cần
                            if ((user.image?.isEmpty) != nil) {
                                user.image = "https://i.pinimg.com/736x/d9/7b/bb/d97bbb08017ac2309307f0822e63d082.jpg"
                            }

                            users.append(user)
                        } catch {
                            print("Error decoding user: \(error)")
                        }
                    }
                    completion(users)
                }
        }



        
        // MARK: - Add new category to Firestore
        func addCategory(category: CategoryModel, completion: @escaping (Bool, Error?) -> Void) {
            do {
                // Add the new category to Firestore, including image URL
                _ = try db.collection("categories").addDocument(from: category) { error in
                    completion(error == nil, error)
                }
            } catch {
                completion(false, error)
            }
        }
        
        //Update category in Firestore
        func updateCategory(category: CategoryModel, completion: @escaping (Bool, Error?) -> Void) {
            guard let categoryId = category.id else {
                completion(false, NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Category ID is missing"]))
                return
            }
            
            db.collection("categories").document(categoryId).setData([
                "name": category.name,
                "image": category.image
            ]) { error in
                completion(error == nil, error)
            }
        }
        
        //Delete Category
        func deleteCategory(_ category: CategoryModel, completion: @escaping (Bool, Error?) -> Void) {
            guard let categoryId = category.id else {
                completion(false, NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Category ID is missing"]))
                return
            }
            
            db.collection("categories").document(categoryId).delete { error in
                if let error = error {
                    print("Error deleting category: \(error)")
                    completion(false, error)
                } else {
                    print("Category deleted successfully")
                    completion(true, nil)
                }
            }
        }
        
        // fetchCategories
        func fetchCategories(completion: @escaping ([CategoryModel], Error?) -> Void) {
            db.collection("categories").getDocuments { snapshot, error in
                if let error = error {
                    completion([], error)
                    return
                }
                
                var categories: [CategoryModel] = []
                for document in snapshot?.documents ?? [] {
                    let data = document.data()
                    let id = document.documentID
                    
                    if let name = data["name"] as? String {
                      
                        let image = data["image"] as? String ?? ""
                        let category = CategoryModel(id: id, name: name, image: image)
                        categories.append(category)
                    }
                }
                completion(categories, nil)
            }
        }

        
        // MARK: - Add News
        func addNews(news: NewsModel, completion: @escaping (Result<Void, Error>) -> Void) {
            let newsData: [String: Any] = [
                "title": news.title,
                "author": news.author,
                "detail": news.detail,
                "postTime": news.postTime,
                "image": news.image,
                "comments": []
            ]
            
            db.collection("news").addDocument(data: newsData) { error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(()))
                }
            }
        }
        
        // Add Comment
        func addComment(to newsId: String, comment: CommentModel, completion: @escaping (Result<Void, Error>) -> Void) {
            let commentData: [String: Any] = [
                "userId": comment.userId,
                "userName": comment.userName,
                "comment": comment.comment,
                "timestamp": comment.timestamp
            ]
            
            db.collection("news").document(newsId).updateData([
                "comments": FieldValue.arrayUnion([commentData])
            ]) { error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(()))
                }
            }
        }
        
        // Delete Comment
        func deleteComment(from newsId: String, commentId: String, completion: @escaping (Result<Void, Error>) -> Void) {
            db.collection("news").document(newsId).updateData([
                "comments": FieldValue.arrayRemove([["id": commentId]])
            ]) { error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(()))
                }
            }
        }
        
        
        // MARK: - Fetch all products from Firestore
        func fetchProducts() {
            db.collection("products").getDocuments { (snapshot, error) in
                if let error = error {
                    print("Error getting documents: \(error)")
                    return
                }
                
                self.products = snapshot?.documents.compactMap { doc in
                    try? doc.data(as: ProductModel.self)
                } ?? []
            }
        }
        
        // MARK: Add a new product to Firestore
        func addProduct(_ product: ProductModel, completion: @escaping (Error?) -> Void) {
                do {
                    let productData = try Firestore.Encoder().encode(product)
                    _ = db.collection("products").addDocument(data: productData) { error in
                        completion(error)
                    }
                } catch {
                    completion(error)
                }
            }
        
        // MARK: Update an existing product in Firestore
        func updateProduct(_ productId: String, updatedProduct: ProductModel, completion: @escaping (Error?) -> Void) {
            do {
                let updatedProductData = try Firestore.Encoder().encode(updatedProduct)
                db.collection("products").document(productId).setData(updatedProductData) { error in
                    completion(error)
                }
            } catch {
                completion(error)
            }
        }
        
        // MARK: Delete a product from Firestore
        func deleteProduct(_ productId: String, completion: @escaping (Error?) -> Void) {
            db.collection("products").document(productId).delete { error in
                completion(error)
            }
        }
        
        
        
        // MARK: - Fetch all Orders from Firestore


        // MARK:  Thêm đơn hàng vào Firestore
        func addOrder(order: OrderModel, completion: @escaping (Bool) -> Void) {
            let orderData: [String: Any] = [
                "id": order.id as Any,
                "orderDate": order.orderDate,
                "totalAmount": order.totalAmount,
                "status": order.status,
                "products": order.products.map { product in
                    [
                        "productId": product.productId,
                        "productName": product.productName,
                        "quantity": product.quantity,
                        "price": product.price,
                        "productImage": product.productImage ?? ""
                    ]
                },
                "userId": order.userId,
                "userName": order.userName,
                "address": order.address,
                "paymentMethod": order.paymentMethod
            ]

            db.collection("orders").document(order.id!).setData(orderData) { error in
                completion(error == nil)
            }
        }

        // MARK:  Cập nhật đơn hàng trong Firestore
        func updateOrder(order: OrderModel, completion: @escaping (Bool) -> Void) {
            let orderData: [String: Any] = [
                "id": order.id as Any,
                "orderDate": order.orderDate,
                "totalAmount": order.totalAmount,
                "status": order.status,
                "products": order.products.map { product in
                    [
                        "productId": product.productId,
                        "productName": product.productName,
                        "quantity": product.quantity,
                        "price": product.price,
                        "productImage": product.productImage ?? ""
                    ]
                },
                "userId": order.userId,
                "userName": order.userName,
                "address": order.address,
                "paymentMethod": order.paymentMethod
            ]

            db.collection("orders").document(order.id!).updateData(orderData) { error in
                completion(error == nil)
            }
        }
        // MARK: fetchOrders
        func fetchOrders(completion: @escaping ([OrderModel]?, Error?) -> Void) {
                db.collection("orders")
                    .getDocuments { snapshot, error in
                        if let error = error {
                            completion(nil, error)
                            return
                        }

                        let orders = snapshot?.documents.compactMap { document in
                            try? document.data(as: OrderModel.self)
                        }
                        completion(orders, nil)
                    }
            }
        
        // MARK: Cập nhật trạng thái đơn hàng
        func acceptOrder(orderId: String, completion: @escaping (Error?) -> Void) {
            let orderRef = db.collection("orders").document(orderId)
            orderRef.updateData([
                "status": "Accepted"
            ]) { error in
                completion(error)
            }
        }
        
        //MARK: Delete order
        func deleteOrder(orderId: String, completion: @escaping (Error?) -> Void) {
            db.collection("orders").document(orderId).delete { error in
                completion(error)
            }
        }
        
        //MARK: Lấy 5 đơn hàng gần nhất
        func fetchRecentOrders(completion: @escaping ([OrderModel]?, Error?) -> Void) {
            db.collection("orders")
                .order(by: "orderDate", descending: true)
                .limit(to: 5)
                .getDocuments { snapshot, error in
                    if let error = error {
                        completion(nil, error)
                        return
                    }
                    var orders: [OrderModel] = []
                    for document in snapshot!.documents {
                        do {
                            let order = try document.data(as: OrderModel.self)
                            orders.append(order)
                        } catch {
                            print("Error decoding order: \(error)")
                        }
                    }
                    completion(orders, nil)
                }
        }
    }

