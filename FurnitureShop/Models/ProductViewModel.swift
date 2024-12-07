import SwiftUI
import FirebaseFirestore

class ProductViewModel: ObservableObject {
    @Published var products: [ProductModel] = []
    
    private var db = Firestore.firestore()
    
    // Hàm tải dữ liệu từ Firebase
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
}
