import SwiftUI

struct ProductDetailView: View {
    var product: ProductModel
    
    var body: some View {
        VStack {
            // Product Name
            Text(product.name)
                .font(.largeTitle)
                .padding(.top)
            
            // Product Image
            Image(systemName: product.imageName)
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
            
            // Product Price
            Text("Price: $\(product.price, specifier: "%.2f")")
                .font(.headline)
                .padding(.top)
            
            // Product Description
            Text("Description: \(product.description)")
                .padding()
            
            // Product Category
            Text("Category: \(product.category)")
                .padding(.bottom)
            
            // Available Colors
            Text("Available Colors: \(product.availableColors.joined(separator: ", "))")
                .padding(.bottom)
            
            // Product Size
            Text("Size: Height: \(String(format: "%.2f", product.size.height)) cm, Width: \(String(format: "%.2f", product.size.width)) cm")
            
            // Product Material
            Text("Material: \(product.material)")
                .padding(.bottom)
            
            // Product Quantity
            Text("Quantity Available: \(product.quantity)")
                .padding(.bottom)
            
            Spacer()
        }
        .padding()
    }
}
