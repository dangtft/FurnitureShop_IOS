import SwiftUI

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
                            OrdersProductView(orders: order)
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
    let orders: OrderModel
    
    var body: some View {
        HStack {
            CircleImageProduct(imageProductName: "Users")
            
            Spacer()
            
            VStack(alignment: .leading) {
                Text(orders.products.map { $0.productName }.joined(separator: ", "))
                    .font(.headline)
                
                Text("Ordered by: \(orders.userName)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                Text("Order Date: \(formattedDate(orders.orderDate))")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                Text("Status: \(orders.status)")
                    .font(.subheadline)
                    .foregroundColor(orders.status == "Pending" ? .red : .green)
            }
            
            Spacer()
            
            Text("$ \(orders.totalAmount, specifier: "%.2f")")
                .font(.headline)
                .padding(.top, 5)
                .foregroundColor(.blue)
        }
        .padding([.top, .bottom], 10)
    }
}

#Preview {
    RecentOrdersView()
}
