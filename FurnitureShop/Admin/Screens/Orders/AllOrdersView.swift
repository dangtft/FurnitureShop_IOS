import SwiftUI

struct AllOrdersView: View {
    @State private var orders: [OrderModel] = []
    @State private var sortOption: SortOption = .none
    @State private var filterStatus: OrderStatus = .all
    @State private var showAddOrderView = false
    @State private var errorMessage: String?

    enum SortOption: String, CaseIterable, Identifiable {
        case none = "None"
        case dateAscending = "Date Ascending"
        case dateDescending = "Date Descending"
        case nameAscending = "Name A-Z"
        case nameDescending = "Name Z-A"

        var id: String { self.rawValue }
    }

    enum OrderStatus: String, CaseIterable, Identifiable {
        case all = "All"
        case pending = "Pending"
        case accepted = "Accepted"
        case delivered = "Delivered"

        var id: String { self.rawValue }
    }

    var filteredOrders: [OrderModel] {
        let filtered = filterStatus == .all ? orders : orders.filter { $0.status == filterStatus.rawValue }
        switch sortOption {
        case .dateAscending:
            return filtered.sorted { $0.orderDate < $1.orderDate }
        case .dateDescending:
            return filtered.sorted { $0.orderDate > $1.orderDate }
        case .nameAscending:
            return filtered.sorted { $0.userName.localizedCompare($1.userName) == .orderedAscending }
        case .nameDescending:
            return filtered.sorted { $0.userName.localizedCompare($1.userName) == .orderedDescending }
        case .none:
            return filtered
        }
    }

    var body: some View {
        VStack {
            HStack {
                Text("All Orders")
                    .font(.largeTitle)
                Spacer()
                Button(action: {
                    showAddOrderView.toggle()
                }) {
                    Label("Add Order", systemImage: "plus")
                        .padding(10)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
            .padding()

            HStack {
                Menu {
                    ForEach(SortOption.allCases) { option in
                        Button(action: {
                            sortOption = option
                        }) {
                            Text(option.rawValue)
                        }
                    }
                } label: {
                    Label("Sort By: \(sortOption.rawValue)", systemImage: "arrow.up.arrow.down")
                        .font(.subheadline)
                        .padding()
                        .background(Capsule().fill(Color.gray.opacity(0.2)))
                }

                Spacer()

                Menu {
                    ForEach(OrderStatus.allCases) { status in
                        Button(action: {
                            filterStatus = status
                        }) {
                            Text(status.rawValue)
                        }
                    }
                } label: {
                    Label("Filter: \(filterStatus.rawValue)", systemImage: "line.horizontal.3.decrease.circle")
                        .font(.subheadline)
                        .padding()
                        .background(Capsule().fill(Color.gray.opacity(0.2)))
                }
            }
            .padding()

            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding()
            }

            List {
                ForEach(filteredOrders) { order in
                    OrderViewCustom(order: order, orders: $orders)
                }
            }
            .listStyle(PlainListStyle())
            .onAppear {
                loadOrders()
            }
        }
        .padding(.horizontal)
        .sheet(isPresented: $showAddOrderView) {
            AddOrderView(orders: $orders)
        }
    }

    // Fetch orders from Firestore
    private func loadOrders() {
        FirestoreService().fetchOrders { orders, error in
            if let error = error {
                self.errorMessage = "Failed to load orders: \(error.localizedDescription)"
            } else {
                self.orders = orders ?? []
            }
        }
    }
}

struct OrderViewCustom: View {
    let order: OrderModel
    @Binding var orders: [OrderModel]
    @State private var showDetailView = false
    @State private var showEditOrderView = false

    var body: some View {
        HStack {
            CircleImageProduct(imageProductName: "Users")

            Spacer()

            VStack(alignment: .leading) {
                Text(order.products.map { $0.productName }.joined(separator: ", "))
                    .font(.headline)

                Text("Ordered by: \(order.userName)")
                    .font(.subheadline)
                    .foregroundColor(.gray)

                Text("Order Date: \(formattedDate(order.orderDate))")
                    .font(.subheadline)
                    .foregroundColor(.gray)

                Text("Status: \(order.status)")
                    .font(.subheadline)
                    .foregroundColor(order.status == "Pending" ? .red : .green)
            }

            Spacer()

            VStack {
                Text("$ \(order.totalAmount, specifier: "%.2f")")
                    .font(.headline)
                    .foregroundColor(.blue)

                if order.status == "Pending" {
                    Button(action: {
                        acceptOrder()
                    }) {
                        Text("Accept")
                            .font(.subheadline)
                            .padding(5)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(5)
                    }
                }
            }

            Spacer()

            Menu {
                Button(action: {
                    showDetailView.toggle()
                }) {
                    Label("Chi tiết", systemImage: "info.circle")
                }

                Button(action: {
                    showEditOrderView.toggle()
                }) {
                    Label("Sửa", systemImage: "pencil")
                }

                Button(role: .destructive, action: deleteOrder) {
                    Label("Xóa", systemImage: "trash")
                }
            } label: {
                Image(systemName: "ellipsis.circle")
                    .font(.title)
                    .foregroundColor(.gray)
            }
        }
        .padding(.vertical, 10)
        .sheet(isPresented: $showDetailView) {
            OrderDetailView(order: order)
        }
        .sheet(isPresented: $showEditOrderView) {
            if let selectedOrderIndex = orders.firstIndex(where: { $0.id == order.id }) {
                EditOrderView(orders: $orders, selectedOrder: $orders[selectedOrderIndex])
            }
        }
    }

    private func acceptOrder() {
        if let index = orders.firstIndex(where: { $0.id == order.id }) {
            orders[index].status = "Accepted"
        }
    }

    private func deleteOrder() {
        if let index = orders.firstIndex(where: { $0.id == order.id }) {
            orders.remove(at: index)
        }
    }
}

#Preview {
    AllOrdersView()
}

