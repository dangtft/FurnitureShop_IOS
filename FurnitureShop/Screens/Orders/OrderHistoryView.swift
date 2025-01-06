//
//  OrderHistoryView.swift
//  FurnitureShop
//
//  Created by haidangnguyen on 15/12/24.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct OrderHistoryView: View {
    @State private var orders: [OrderModel] = []
    private var db = Firestore.firestore()
    @EnvironmentObject var cartManager: CartManager
    @State private var isLoading = true
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    var body: some View {
        VStack {
            if isLoading {
                ProgressView("Đang tải...")
                    .padding()
            } else {
                List(orders) { order in
                    VStack(alignment: .leading) {
                        // Hiển thị thông tin thời gian đặt và tổng số tiền đơn hàng
                        Text("Order ID: \(order.id ?? "Unknown")")
                            .font(.headline)
                        
                        Text("Order Date: \(formattedDate(order.orderDate))")
                            .font(.subheadline)

                        Text("Total Amount: \(String(format: "$%.2f", order.totalAmount))")
                            .font(.subheadline)

                        Text("Status: \(order.status)")
                            .font(.subheadline)

                        // Hiển thị danh sách sản phẩm trong đơn hàng
                        ForEach(order.products, id: \.productId) { product in
                            VStack(alignment: .leading) {
                                // Hiển thị hình ảnh sản phẩm nếu có
                                if let imageUrl = product.productImage, let url = URL(string: imageUrl) {
                                    AsyncImage(url: url) { image in
                                        image.resizable()
                                             .scaledToFit()
                                             .frame(width: 50, height: 50)
                                             .cornerRadius(8)
                                    } placeholder: {
                                        Image(systemName: "photo.fill")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 50, height: 50)
                                            .cornerRadius(8)
                                    }
                                } else {
                                    // Hình ảnh mặc định nếu không có URL
                                    Image("product_default")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 50, height: 50)
                                        .cornerRadius(8)
                                }

                                Text("Product: \(product.productName)")
                                    .font(.body)
                                Text("Quantity: \(product.quantity)")
                                    .font(.subheadline)
                                Text("Price: \(String(format: "$%.2f", product.price))")
                                    .font(.subheadline)
                            }
                            .padding(.leading)
                            .padding(.bottom, 5)
                        }
                    }
                    .padding()
                }
            }
        }
        .padding()
        .navigationTitle("Orders history")
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: BackButton(action: { presentationMode.wrappedValue.dismiss() }))
        .onAppear {
            loadOrdersFromFirebase()
        }
    }

    // Hàm để định dạng ngày thành chuỗi
    func formattedDate(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        return dateFormatter.string(from: date)
    }

    // Hàm để tải dữ liệu đơn hàng từ Firestore
    func loadOrdersFromFirebase() {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("User is not logged in.")
            isLoading = false
            return
        }

        db.collection("orders")
            .whereField("userId", isEqualTo: userId)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Error fetching orders: \(error.localizedDescription)")
                    isLoading = false
                    return
                }

                if let snapshot = snapshot, !snapshot.isEmpty {
                    self.orders = snapshot.documents.compactMap { document in
                        try? document.data(as: OrderModel.self)
                    }
                } else {
                    print("No orders found.")
                    self.orders = []
                }
                isLoading = false
            }
    }
}

#Preview {
    OrderHistoryView()
}
