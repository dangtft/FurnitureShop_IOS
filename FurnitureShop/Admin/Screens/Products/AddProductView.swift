import SwiftUI

struct AddProductView: View {
    @Environment(\.dismiss) var dismiss
    @State private var name = ""
    @State private var description = ""
    @State private var price: Double = 0.0
    @State private var imageName = ""
    @State private var category = ""
    @State private var sizeHeight: Double = 0.0
    @State private var sizeWidth: Double = 0.0
    @State private var sizeDiameter: Double = 0.0
    @State private var quantity: Int = 0
    @State private var material = "Wood"
    @State private var availableColors: String = ""
    @State private var categories: [CategoryModel] = []
    @State private var isLoadingCategories = true
    
    private let materials = ["Wood", "Metal", "Plastic", "Glass"]
    private let firebaseService = FirestoreService()
    
    @Binding var products: [ProductModel]
    
    var body: some View {
        ScrollView{
            VStack(alignment: .leading, spacing: 15) {
                if isLoadingCategories {
                    ProgressView("Loading Categories...")
                        .padding()
                } else {
                    Text("Add Product")
                        .font(.largeTitle)
                        .padding(.bottom, 20)
                    
                    Text("Product Name:")
                        .font(.headline)
                    TextField("Enter product name", text: $name)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    Text("Description:")
                        .font(.headline)
                    TextField("Enter product description", text: $description)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    Text("Price ($):")
                        .font(.headline)
                    TextField("Enter product price", value: $price, format: .number)
                        .keyboardType(.decimalPad)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    Text("Image URL:")
                        .font(.headline)
                    TextField("Enter image URL", text: $imageName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    // Category
                    Text("Category:")
                        .font(.headline)
                    Picker("Category", selection: $category) {
                        ForEach(categories, id: \.name) { category in
                            Text(category.name).tag(category.name)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    
                    Text("Size:")
                        .font(.headline)
                    HStack {
                        VStack {
                            Text("Height:")
                            TextField("Height", value: $sizeHeight, format: .number)
                                .keyboardType(.decimalPad)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }
                        VStack {
                            Text("Width:")
                            TextField("Width", value: $sizeWidth, format: .number)
                                .keyboardType(.decimalPad)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }
                        VStack {
                            Text("Diameter:")
                            TextField("Diameter", value: $sizeDiameter, format: .number)
                                .keyboardType(.decimalPad)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }
                    }
                    
                    Text("Quantity:")
                        .font(.headline)
                    Stepper(value: $quantity, in: 0...100) {
                        Text("Quantity: \(quantity)")
                    }
                    
                    // Material
                    Text("Material:")
                        .font(.headline)
                    Picker("Select a material", selection: $material) {
                        ForEach(materials, id: \.self) { material in
                            Text(material)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    
                    Text("Available Colors (comma-separated):")
                        .font(.headline)
                    TextField("Enter colors (e.g., Red, Blue)", text: $availableColors)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    HStack {
                        Button("Add Product") {
                            let colors = availableColors.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
                            let newProduct = ProductModel(
                                id: nil,
                                name: name,
                                description: description,
                                price: price,
                                imageName: imageName,
                                size: ProductSize(height: sizeHeight, width: sizeWidth, diameter: sizeDiameter),
                                quantity: quantity,
                                material: material,
                                availableColors: colors,
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
                        .buttonStyle(.borderedProminent)
                        .padding()
                        
                        Button("Cancel") {
                            dismiss()
                        }
                        .buttonStyle(.bordered)
                        .padding()
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                }
            }
            .padding()
            .onAppear {
                fetchCategories()
            }
        }
    }
    
    private func fetchCategories() {
        isLoadingCategories = true
        firebaseService.fetchCategories { fetchedCategories, error in
            if let error = error {
                print("Error fetching categories: \(error.localizedDescription)")
                isLoadingCategories = false
            } else {
                categories = fetchedCategories
                if let firstCategory = fetchedCategories.first {
                    category = firstCategory.name
                }
                isLoadingCategories = false
            }
        }
    }
}
