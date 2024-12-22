import SwiftUI

struct EditOrderView: View {
    @Binding var orders: [OrderModel]
    @Binding var selectedOrder: OrderModel
    @Environment(\.dismiss) var dismiss

    @State private var userName = ""
    @State private var status = ""
    @State private var address = ""
    @State private var paymentMethod = ""
    @State private var quantityText = ""
    @State private var priceText = ""

    private let firestoreService = FirestoreService()

    var body: some View {
        VStack(spacing: 15) {
            Text("Edit Order")
                .font(.largeTitle)
                .bold()

            TextField("User Name", text: $userName)
                .textFieldStyle(RoundedBorderTextFieldStyle())

            Picker("Status", selection: $status) {
                Text("Pending").tag("Pending")
                Text("Accepted").tag("Accepted")
                Text("Delivered").tag("Delivered")
            }
            .pickerStyle(.segmented)

            TextField("Address", text: $address)
                .textFieldStyle(RoundedBorderTextFieldStyle())

            TextField("Payment Method", text: $paymentMethod)
                .textFieldStyle(RoundedBorderTextFieldStyle())

            if selectedOrder.products.first != nil {
                TextField("Quantity", text: $quantityText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.numberPad)

                TextField("Price", text: $priceText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.decimalPad)
            }

            Button("Save Changes") {
                if let index = orders.firstIndex(where: { $0.id == selectedOrder.id }) {
                    // Cập nhật thông tin đơn hàng
                    orders[index].userName = userName
                    orders[index].status = status
                    orders[index].address = address
                    orders[index].paymentMethod = paymentMethod

                    // Cập nhật thông tin sản phẩm nếu nhập đúng định dạng
                    if let quantity = Int(quantityText), let price = Double(priceText) {
                        orders[index].products[0].quantity = quantity
                        orders[index].products[0].price = price
                        orders[index].totalAmount = Double(quantity) * price
                    }

                    // Cập nhật đơn hàng vào Firestore
                    firestoreService.updateOrder(order: orders[index]) { success in
                        if success {
                            dismiss()
                        } else {
                            print("Failed to update order.")
                        }
                    }
                }
            }
            .buttonStyle(.borderedProminent)
            
            Button("Cancel") {
                dismiss()
            }
            .padding()

            Spacer()
        }
        .padding()
        .onAppear {
            // Gán giá trị ban đầu khi hiển thị
            userName = selectedOrder.userName
            status = selectedOrder.status
            address = selectedOrder.address
            paymentMethod = selectedOrder.paymentMethod

            if let product = selectedOrder.products.first {
                quantityText = String(product.quantity)
                priceText = String(format: "%.2f", product.price)
            }
        }
    }
}
