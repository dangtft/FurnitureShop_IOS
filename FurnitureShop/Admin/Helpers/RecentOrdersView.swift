import SwiftUI
import FirebaseFirestore
import Foundation

struct RecentOrdersView: View {
    @State private var orders: [OrderModel] = []
    @State private var isLoading = true
    @State private var errorMessage: String?

    func loadOrders() {
        FirestoreService().fetchRecentOrders { fetchedOrders, error in
            if let error = error {
                errorMessage = "Failed to load orders: \(error.localizedDescription)"
                isLoading = false
            } else {
                orders = fetchedOrders ?? []
                isLoading = false
            }
        }
    }

    var body: some View {
        VStack(alignment: .leading) {
            Text("Recent Orders")
                .font(.largeTitle)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding([.top, .leading])
            
            if isLoading {
                ProgressView("Loading...")
                    .padding()
            } else if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding()
            } else {
                ScrollView {
                    LazyVStack(spacing: 10) {
                        ForEach(orders) { order in
                            OrdersProductView(order: order)
                                .padding(.horizontal)
                        }
                    }
                }
            }
        }
        .padding()
        .onAppear {
            loadOrders()
        }
    }
}

struct OrdersProductView: View {
    let order: OrderModel

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Order ID: \(order.id ?? "N/A")")
                .font(.headline)
                .padding(.bottom, 5)
            
            Text("Ordered by: \(order.userName)")
                .font(.subheadline)
                .foregroundColor(.gray)
            
            Text("Order Date: \(formattedDate(order.orderDate))")
                .font(.subheadline)
                .foregroundColor(.gray)
            
            Text("Status: \(order.status)")
                .font(.subheadline)
                .foregroundColor(order.status == "Pending" ? .red : .green)
            
            Text("Address: \(order.address)")
                .font(.subheadline)
                .foregroundColor(.gray)
            
            Text("Payment Method: \(order.paymentMethod)")
                .font(.subheadline)
                .foregroundColor(.gray)

            // Danh sách các sản phẩm
            VStack(alignment: .leading, spacing: 5) {
                ForEach(order.products, id: \.productId) { product in
                    HStack {
                        if let productImage = product.productImage {
                            CircleImageProduct(imageProductName: productImage)
                        } else {
                            CircleImageProduct(imageProductName: "Placeholder")
                        }

                        VStack(alignment: .leading) {
                            Text(product.productName)
                                .font(.subheadline)
                                .foregroundColor(.primary)

                            Text("Quantity: \(product.quantity)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }

                        Spacer()

                        Text("$ \(product.price, specifier: "%.2f")")
                            .font(.subheadline)
                            .foregroundColor(.blue)
                    }
                }
            }

            Text("Total: $ \(order.totalAmount, specifier: "%.2f")")
                .font(.headline)
                .padding(.top, 5)
                .foregroundColor(.blue)
        }
        .padding([.top, .bottom], 10)
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(10)
        .shadow(radius: 2)
    }
}

#Preview {
    RecentOrdersView()
}
