import SwiftUI
import FirebaseFirestore

struct AllProductView: View {
    @State private var products: [ProductModel] = []
    @State private var categories: [CategoryModel] = []
    @State private var filterCategory: String = "All"
    @State private var selectedProduct: ProductModel?
    @State private var showDetailView = false
    @State private var showAddProductView = false
    @State private var showEditProductView = false
    
    private let firebaseService = FirestoreService()

    func fetchProducts() {
        let db = Firestore.firestore()
        db.collection("products").getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching products: \(error)")
                return
            }
            
            if let snapshot = snapshot {
                self.products = snapshot.documents.compactMap { doc in
                    guard let name = doc.data()["name"] as? String,
                          let description = doc.data()["description"] as? String,
                          let price = doc.data()["price"] as? Double,
                          let imageName = doc.data()["imageName"] as? String,
                          let material = doc.data()["material"] as? String,
                          let category = doc.data()["category"] as? String,
                          let sizeData = doc.data()["size"] as? [String: Double] else { return nil }
                    
                    let height = sizeData["height"] ?? 0.0
                    let width = sizeData["width"] ?? 0.0
                    let diameter = sizeData["diameter"] ?? 0.0
                    let colors = doc.data()["availableColors"] as? [String] ?? []
                    
                    return ProductModel(
                        id: doc.documentID,
                        name: name,
                        description: description,
                        price: price,
                        imageName: imageName,
                        size: ProductSize(height: height, width: width, diameter: diameter),
                        quantity: 0,
                        material: material,
                        availableColors: colors,
                        category: category
                    )
                }
            }
        }
    }
    
    func fetchCategories() {
        firebaseService.fetchCategories { fetchedCategories, error in
            if let error = error {
                print("Error fetching categories: \(error.localizedDescription)")
            } else {
                self.categories = fetchedCategories
            }
        }
    }
    
    func deleteProduct(_ product: ProductModel) {
        guard let productId = product.id else { return }
        firebaseService.deleteProduct(productId) { error in
            if let error = error {
                print("Error deleting product: \(error.localizedDescription)")
            } else {
                // Xóa khỏi danh sách hiển thị
                if let index = products.firstIndex(where: { $0.id == productId }) {
                    products.remove(at: index)
                }
            }
        }
    }
    
    var filteredProducts: [ProductModel] {
        if filterCategory == "All" {
            return products
        } else {
            return products.filter { $0.category == filterCategory }
        }
    }
    
    var body: some View {
        VStack {
            Text("All Products")
                .font(.largeTitle)
                .padding()

            // Category Filter
            HStack {
                Menu {
                    ForEach(categories, id: \.name) { category in
                        Button(action: {
                            filterCategory = category.name
                        }) {
                            Text(category.name)
                        }
                    }
                } label: {
                    Label("Category: \(filterCategory)", systemImage: "arrow.down.circle.fill")
                        .font(.subheadline)
                        .padding()
                        .background(Capsule().fill(Color.gray.opacity(0.2)))
                }
                
                Spacer()

                Button(action: {
                    showAddProductView.toggle()
                }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title)
                        .foregroundColor(.blue)
                }
                .padding()
            }
            .padding(.horizontal)
            
            // Product List
            List(filteredProducts) { product in
                HStack {
                    AsyncImage(url: URL(string: product.imageName)) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFit()
                                .frame(width: 50, height: 50)
                        case .failure:
                            Image(systemName: "photo")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 50, height: 50)
                        @unknown default:
                            EmptyView()
                        }
                    }
                    
                    VStack(alignment: .leading) {
                        Text(product.name)
                            .font(.headline)
                        Text("$\(product.price, specifier: "%.2f")")
                            .font(.subheadline)
                            .foregroundColor(.green)
                    }
                    
                    Spacer()
                    
                    Menu {
                        Button(action: {
                            selectedProduct = product
                            showDetailView.toggle()
                        }) {
                            Label("Detail", systemImage: "info.circle")
                        }
                        
                        Button(action: {
                            selectedProduct = product
                            showEditProductView.toggle()
                        }) {
                            Label("Edit", systemImage: "pencil")
                        }
                        
                        Button(role: .destructive, action: {
                            deleteProduct(product)
                        }) {
                            Label("Delete", systemImage: "trash")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .font(.title)
                            .foregroundColor(.gray)
                    }
                }
            }
            .listStyle(PlainListStyle())
        }
        .onAppear {
            fetchProducts()
            fetchCategories()
        }
        .padding(.horizontal)
        .sheet(isPresented: $showDetailView) {
            if let selectedProduct = selectedProduct {
                ProductDetailView(product: selectedProduct)
            }
        }
        .sheet(isPresented: $showAddProductView) {
            AddProductView(products: $products)
        }
        .sheet(isPresented: $showEditProductView) {
            if let selectedProduct = selectedProduct {
                EditProductView(
                    products: $products,
                    selectedProduct: $selectedProduct
                )
            }
        }
    }
}

#Preview {
    AllProductView()
}
