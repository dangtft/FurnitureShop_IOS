import SwiftUI

struct EditProductView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var products: [ProductModel]
    @Binding var selectedProduct: ProductModel
    
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
    
    var body: some View {
        VStack {
            Text("Edit Product")
                .font(.largeTitle)
                .padding()
            
            Form {
                Section(header: Text("Product Details")) {
                    TextField("Name", text: $name)
                    TextField("Description", text: $description)
                    TextField("Price", value: $price, formatter: NumberFormatter())
                        .keyboardType(.decimalPad)
                    
                    TextField("Category", text: $category)
                    
                    HStack {
                        TextField("Height", value: $sizeHeight, formatter: NumberFormatter())
                            .keyboardType(.decimalPad)
                        TextField("Width", value: $sizeWidth, formatter: NumberFormatter())
                            .keyboardType(.decimalPad)
                        TextField("Diameter", value: $sizeDiameter, formatter: NumberFormatter())
                            .keyboardType(.decimalPad)
                    }
                    
                    TextField("Quantity", value: $quantity, formatter: NumberFormatter())
                        .keyboardType(.numberPad)
                    
                    TextField("Material", text: $material)
                    
                    TextField("Available Colors (comma separated)", text: Binding(
                        get: { availableColors.joined(separator: ", ") },
                        set: { availableColors = $0.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) } }
                    ))
                }
            }
            
            HStack {
                Button("Save Changes") {
                    let updatedProduct = ProductModel(
                        id: selectedProduct.id,
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
                    
                    firebaseService.updateProduct(selectedProduct.id ?? "", updatedProduct: updatedProduct) { error in
                        if let error = error {
                            print("Error updating product: \(error.localizedDescription)")
                        } else {
                            if let index = products.firstIndex(where: { $0.id == selectedProduct.id }) {
                                products[index] = updatedProduct
                                dismiss()
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
    }
}
