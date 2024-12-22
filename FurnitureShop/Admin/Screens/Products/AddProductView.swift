import SwiftUI

struct AddProductView: View {
    @Environment(\.dismiss) var dismiss
    @State private var name = ""
    @State private var description = ""
    @State private var price: Double = 0.0
    @State private var imageName = ""
    @State private var category = "Furniture"
    @State private var sizeHeight: Double = 0.0
    @State private var sizeWidth: Double = 0.0
    @State private var sizeDiameter: Double = 0.0
    @State private var quantity: Int = 0
    @State private var material = "Wood"
    @State private var availableColors: [String] = []
    
    private let firebaseService = FirestoreService()
    
    @Binding var products: [ProductModel]
    
    var body: some View {
        VStack {
            Text("Add Product")
                .font(.largeTitle)
                .padding()
            
            // Form Fields for Product
            
            Button("Add Product") {
                let newProduct = ProductModel(
                    id: nil,
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
                
                firebaseService.addProduct(newProduct) { error in
                    if let error = error {
                        print("Error adding product: \(error.localizedDescription)")
                    } else {
                        products.append(newProduct)
                        dismiss()
                    }
                }
            }
            .padding()
            
            Button("Cancel") {
                dismiss()
            }
            .padding()
        }
        .padding()
    }
}
