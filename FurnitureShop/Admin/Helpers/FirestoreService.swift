import Firebase
import SwiftUI
import UIKit
import Darwin
import FirebaseFirestore
import FirebaseAuth

class FirestoreService {
    
    private let db = Firestore.firestore()
    
    func fetchUsers(completion: @escaping ([UserModel]?) -> Void) {
            db.collection("users").getDocuments { (snapshot, error) in
                if let error = error {
                    print("Error fetching users: \(error)")
                    completion(nil)
                    return
                }
                
                var users: [UserModel] = []
                for document in snapshot?.documents ?? [] {
                    let data = document.data()
                    // Lấy dữ liệu từ Firestore và ánh xạ vào UserModel
                    if let id = document.documentID as? String,
                       let name = data["name"] as? String,
                       let image = data["image"] as? String,
                       let email = data["email"] as? String,
                       let password = data["password"] as? String,
                       let address = data["address"] as? String,
                       let phoneNumber = data["phoneNumber"] as? String {
                        let user = UserModel(
                            id: id,
                            name: name,
                            image: image,
                            email: email,
                            password: password,
                            address: address,
                            phoneNumber: phoneNumber
                        )
                        users.append(user)
                    }
                }
                completion(users)
            }
        }
    
    // MARK: - Add a new user to Firestore
    func addUser(user: UserModel, completion: @escaping (Bool, Error?) -> Void) {
            do {
                let userData: [String: Any] = [
                    "name": user.name,
                    "image": user.image,
                    "email": user.email,
                    "password": user.password,
                    "address": user.address,
                    "phoneNumber": user.phoneNumber
                ]
                _ = try db.collection("users").addDocument(data: userData) { error in
                    completion(error == nil, error)
                }
            } catch {
                completion(false, error)
            }
        }
    // MARK: - Update user data
        
        func updateUser(user: UserModel, completion: @escaping (Bool, Error?) -> Void) {
            let userRef = db.collection("users").document(user.id!)
            
            userRef.updateData([
                "name": user.name,
                "image": user.image,
                "email": user.email,
                "password": user.password,
                "address": user.address,
                "phoneNumber": user.phoneNumber
            ]) { error in
                if let error = error {
                    completion(false, error)
                } else {
                    completion(true, nil)
                }
            }
        }

    
    // MARK: - Delete user
    func deleteUser(user: UserModel, completion: @escaping (Bool, Error?) -> Void) {
        db.collection("users").document(user.id!).delete { error in
            completion(error == nil, error)
        }
    }

    
    // MARK: - Fetch a single user by ID
       func fetchUser(byId id: String, completion: @escaping (UserModel?, Error?) -> Void) {
           db.collection("users").document(id).getDocument { (document, error) in
               if let error = error {
                   completion(nil, error)
                   return
               }
               
               guard let document = document, document.exists else {
                   completion(nil, nil)
                   return
               }
               
               let data = document.data()
               if let name = data?["name"] as? String,
                  let image = data?["image"] as? String,
                  let email = data?["email"] as? String,
                  let password = data?["password"] as? String,
                  let address = data?["address"] as? String,
                  let phoneNumber = data?["phoneNumber"] as? String {
                   let user = UserModel(
                       id: document.documentID,
                       name: name,
                       image: image,
                       email: email,
                       password: password,
                       address: address,
                       phoneNumber: phoneNumber
                   )
                   completion(user, nil)
               } else {
                   completion(nil, NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "User data is missing"]))
               }
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
    
    // MARK: - Update existing category in Firestore
    func updateCategory(category: CategoryModel, completion: @escaping (Bool, Error?) -> Void) {
        guard let categoryId = category.id else {
            completion(false, NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Category ID is missing"]))
            return
        }
        
        // Update category with image URL
        db.collection("categories").document(categoryId).setData([
            "name": category.name,
            "image": category.image
        ]) { error in
            completion(error == nil, error)
        }
    }
    
    // MARK: - Delete Category
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
    
    // MARK: - fetchCategories
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
                    let category = CategoryModel(id: id, name: name, image: "")
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
    
    // MARK: - Add Comment
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
    
    // MARK: - Delete Comment
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
    
    
    // MARK: Fetch all products from Firestore
    func fetchProducts(completion: @escaping ([ProductModel]?, Error?) -> Void) {
            db.collection("products").getDocuments { snapshot, error in
                if let error = error {
                    completion(nil, error)
                } else {
                    var products: [ProductModel] = []
                    for document in snapshot!.documents {
                        do {
                            let product = try document.data(as: ProductModel.self)
                            products.append(product)
                        } catch {
                            print("Error decoding product: \(error.localizedDescription)")
                        }
                    }
                    completion(products, nil)
                }
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
    func fetchOrders(completion: @escaping ([OrderModel]?, Error?) -> Void) {
        db.collection("orders").getDocuments { snapshot, error in
            if let error = error {
                completion(nil, error)
                return
            }
            
            var orders: [OrderModel] = []
            for document in snapshot?.documents ?? [] {
                let data = document.data()
                if let id = data["id"] as? String,
                   let orderDate = data["orderDate"] as? Timestamp,
                   let totalAmount = data["totalAmount"] as? Double,
                   let status = data["status"] as? String,
                   let userId = data["userId"] as? String,
                   let userName = data["userName"] as? String,
                   let address = data["address"] as? String,
                   let paymentMethod = data["paymentMethod"] as? String {
                    let order = OrderModel(
                        id: id,
                        orderDate: orderDate.dateValue(),
                        totalAmount: totalAmount,
                        status: status,
                        products: [], 
                        userId: userId,
                        userName: userName,
                        address: address,
                        paymentMethod: paymentMethod
                    )
                    orders.append(order)
                }
            }
            completion(orders, nil)
        }
    }

    // Thêm đơn hàng vào Firestore
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

    // Cập nhật đơn hàng trong Firestore
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
}

