import SwiftUI

struct RecentOrdersView: View {
    let orders = [
        OrderModel(
            id: "1",
            orderDate: Date(timeIntervalSince1970: 1697800800), // 20/10/2024
            totalAmount: 32.0,
            status: "Delivered",
            products: [
                OrderProduct(productId: "1", productName: "Lamp", quantity: 1, price: 32.0, productImage: nil)
            ],
            userId: "101",
            userName: "John",
            address: "Dalat",
            paymentMethod: "Cash on Delivery"
        ),
        OrderModel(
            id: "2",
            orderDate: Date(timeIntervalSince1970: 1697721600), // 19/10/2024
            totalAmount: 45.0,
            status: "Shipped",
            products: [
                OrderProduct(productId: "2", productName: "Chair", quantity: 1, price: 45.0, productImage: nil)
            ],
            userId: "102",
            userName: "Alice",
            address: "Dalat",
            paymentMethod: "Cash on Delivery"
        ),
        OrderModel(
            id: "3",
            orderDate: Date(timeIntervalSince1970: 1734528000), // 19/12/2024
            totalAmount: 120.0,
            status: "Pending",
            products: [
                OrderProduct(productId: "4", productName: "Desk", quantity: 1, price: 120.0, productImage: nil)
            ],
            userId: "104",
            userName: "Emily",
            address: "Dalat",
            paymentMethod: "Cash on Delivery"
        ),
        OrderModel(
            id: "4",
            orderDate: Date(timeIntervalSince1970: 1734441600), // 18/12/2024
            totalAmount: 80.0,
            status: "Processing",
            products: [
                OrderProduct(productId: "5", productName: "Bookshelf", quantity: 1, price: 80.0, productImage: nil)
            ],
            userId: "105",
            userName: "Mike",
            address: "Dalat",
            paymentMethod: "Cash on Delivery"
        ),
        OrderModel(
            id: "5",
            orderDate: Date(timeIntervalSince1970: 1734355200), // 17/12/2024
            totalAmount: 50.0,
            status: "Delivered",
            products: [
                OrderProduct(productId: "6", productName: "Fan", quantity: 1, price: 50.0, productImage: nil)
            ],
            userId: "106",
            userName: "Sarah",
            address: "Dalat",
            paymentMethod: "Cash on Delivery"
        ),
        OrderModel(
            id: "6",
            orderDate: Date(timeIntervalSince1970: 1734268800), // 16/12/2024
            totalAmount: 25.0,
            status: "Delivered",
            products: [
                OrderProduct(productId: "7", productName: "Clock", quantity: 1, price: 25.0, productImage: nil)
            ],
            userId: "107",
            userName: "Tom",
            address: "Dalat",
            paymentMethod: "Cash on Delivery"
            
        )
    ]
    
    var sortedOrders: [OrderModel] {
        return Array(orders
            .sorted { $0.orderDate > $1.orderDate }
            .prefix(5)
        )
    }

    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Recent Orders")
                .font(.largeTitle)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding([.top, .leading])
            
            ScrollView {
                LazyVStack(spacing: 10) {
                    ForEach(sortedOrders) { order in
                        OrdersProductView(orders: order)
                            .padding(.horizontal)
                    }
                }
            }
        }
        .padding()
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

struct CircleImageProduct: View {
    var imageProductName: String
    
    var body: some View {
        Image(imageProductName)
            .clipShape(Circle())
            .frame(width: 60, height: 60)
            .overlay(
                Circle()
                    .stroke(lineWidth: 0.1)
            )
            .shadow(radius: 5)
    }
}

#Preview {
    RecentOrdersView()
}
