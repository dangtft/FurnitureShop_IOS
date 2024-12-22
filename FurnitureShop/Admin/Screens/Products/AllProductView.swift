import SwiftUI

struct AllProductView: View {
    @State private var products: [ProductModel] = []
    @State private var selectedProduct: ProductModel?
    @State private var showDetailView = false
    @State private var showAddProductView = false
    @State private var showEditProductView = false
    @State private var filterCategory: String = "All"
    
    private var firebaseService = FirestoreService()
    
    enum FilterCategory: String, CaseIterable {
        case all = "All"
        case furniture = "Furniture"
        case lighting = "Lighting"
        case decor = "Decor"
    }
    
    var filteredProducts: [ProductModel] {
        if filterCategory == "All" {
            return products
        } else {
            return products.filter { $0.category == filterCategory }
        }
    }
    
    func fetchProducts() {
        firebaseService.fetchProducts { fetchedProducts, error in
            if let error = error {
                print("Error fetching products: \(error.localizedDescription)")
            } else if let fetchedProducts = fetchedProducts {
                self.products = fetchedProducts
            }
        }
    }
    
    var body: some View {
        VStack {
            Text("All Products")
                .font(.largeTitle)
                .padding()
            
            // Category Filter and Add Product Button
            
            List(filteredProducts) { product in
                HStack {
                    Text(product.name)
                    Spacer()
                    Button("View") {
                        selectedProduct = product
                        showDetailView.toggle()
                    }
                }
            }
            .listStyle(PlainListStyle())
            
            Button("Add Product") {
                showAddProductView.toggle()
            }
            .padding()
        }
        .onAppear {
            fetchProducts()
        }
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
                EditProductView(products: $products, selectedProduct: .constant(selectedProduct))
            }
        }
    }
}
