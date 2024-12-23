import SwiftUI

struct EditProductView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var products: [ProductModel]
    @Binding var selectedProduct: ProductModel?
    
    private let firebaseService = FirestoreService()
    
    @State private var name: String = ""
    @State private var description: String = ""
    @State private var price: Double = 0.0
    @State private var imageName: String = ""
    @State private var category: String = ""
    @State private var sizeHeight: Double = 0.0
    @State private var sizeWidth: Double = 0.0
    @State private var sizeDiameter: Double = 0.0
    @State private var quantity: Int = 0
    @State private var material: String = ""
    @State private var availableColors: [String] = []
    @State private var categories: [CategoryModel] = []

    var body: some View {
        VStack {
            Text("Edit Product")
                .font(.largeTitle)
                .padding()
            
            Form {
                Section(header: Text("Product Details")) {
                    VStack(alignment: .leading) {
                        Text("Name")
                            .font(.headline)
                        TextField("Name", text: $name)
                    }

                    VStack(alignment: .leading) {
                        Text("Description")
                            .font(.headline)
                        TextField("Description", text: $description)
                    }

                    VStack(alignment: .leading) {
                        Text("Price")
                            .font(.headline)
                        TextField("Price", value: $price, formatter: NumberFormatter())
                            .keyboardType(.decimalPad)
                    }

                    VStack(alignment: .leading) {
                        Text("Image URL")
                            .font(.headline)
                        TextField("ImageUrl", text: $imageName)
                    }
                    
                    VStack(alignment: .leading) {
                        Text("Category")
                            .font(.headline)
                        Picker("Category", selection: $category) {
                            ForEach(categories, id: \.name) { category in
                                Text(category.name).tag(category.name)
                            }
                        }
                    }
                    
                    VStack(alignment: .leading) {
                        Text("Size")
                            .font(.headline)
                        HStack {
                            TextField("Height", value: $sizeHeight, formatter: NumberFormatter())
                                .keyboardType(.decimalPad)
                            TextField("Width", value: $sizeWidth, formatter: NumberFormatter())
                                .keyboardType(.decimalPad)
                            TextField("Diameter", value: $sizeDiameter, formatter: NumberFormatter())
                                .keyboardType(.decimalPad)
                        }
                    }
                    
                    VStack(alignment: .leading) {
                        Text("Quantity")
                            .font(.headline)
                        TextField("Quantity", value: $quantity, formatter: NumberFormatter())
                            .keyboardType(.numberPad)
                    }
                    
                    VStack(alignment: .leading) {
                        Text("Material")
                            .font(.headline)
                        TextField("Material", text: $material)
                    }
                    
                    VStack(alignment: .leading) {
                        Text("Available Colors")
                            .font(.headline)
                        TextField("Available Colors (comma separated)", text: Binding(
                            get: { availableColors.joined(separator: ", ") },
                            set: { availableColors = $0.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) } }
                        ))
                    }
                }
            }
            
            HStack {
                Button("Save Changes") {
                    let updatedProduct = ProductModel(
                        id: selectedProduct?.id ?? "",
                        name: name,
                        description: description,
                        price: price,
                        imageName: imageName,
                        size: ProductSize(height: sizeHeight, width: sizeWidth, diameter: sizeDiameter),
                        quantity: quantity,
                        material: material,
                        availableColors: availableColors,
                        category: category
                    )
                    
                    if let selectedProduct = selectedProduct {
                        firebaseService.updateProduct(selectedProduct.id ?? "", updatedProduct: updatedProduct) { error in
                            if let error = error {
                                print("Error updating product: \(error.localizedDescription)")
                            } else {
                                if let index = products.firstIndex(where: { $0.id == selectedProduct.id }) {
                                    products[index] = updatedProduct
                                    self.selectedProduct = updatedProduct
                                    dismiss()
                                }
                            }
                        }
                    }
                }
                
                Button("Cancel") {
                    dismiss()
                }
            }
        }
        .onAppear {
            if let selectedProduct = selectedProduct {
                name = selectedProduct.name
                description = selectedProduct.description
                price = selectedProduct.price
                imageName = selectedProduct.imageName
                category = selectedProduct.category
                sizeHeight = selectedProduct.size.height
                sizeWidth = selectedProduct.size.width
                sizeDiameter = selectedProduct.size.diameter
                quantity = selectedProduct.quantity
                material = selectedProduct.material
                availableColors = selectedProduct.availableColors
            }
            fetchCategories()
        }
    }
    
    private func fetchCategories() {
        firebaseService.fetchCategories { categories, error in
            if let error = error {
                print("Error fetching categories: \(error.localizedDescription)")
            } else {
                self.categories = categories
            }
        }
    }
}
