import SwiftUI

struct OrderDetailView: View {
    var order: OrderModel

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Order Details")
                .font(.largeTitle)
                .bold()

            Text("Order ID: \(String(describing: order.id))")
            Text("User: \(order.userName)")
            Text("Status: \(order.status)")
                .foregroundColor(order.status == "Pending" ? .red : .green)

            Text("Products:")
                .font(.headline)

            ForEach(order.products, id: \.productId) { product in
                VStack(alignment: .leading) {
                    Text("- \(product.productName)")
                    Text("Quantity: \(product.quantity)")
                    Text("Price: $\(product.price, specifier: "%.2f")")
                }
                .padding(.bottom, 5)
            }

            Text("Total Amount: $\(order.totalAmount, specifier: "%.2f")")
                .font(.headline)

            Spacer()
        }
        .padding()
    }
}
