import SwiftUI

struct AddOrderView: View {
    @Binding var orders: [OrderModel]
    @Environment(\.dismiss) var dismiss

    @State private var userName = ""
    @State private var productName = ""
    @State private var quantityText = ""
    @State private var priceText = ""
    @State private var address = ""
    @State private var paymentMethod = ""

    private let firestoreService = FirestoreService()

    var body: some View {
        VStack(spacing: 15) {
            Text("Add New Order")
                .font(.largeTitle)
                .bold()

            TextField("User Name", text: $userName)
                .textFieldStyle(RoundedBorderTextFieldStyle())

            TextField("Product Name", text: $productName)
                .textFieldStyle(RoundedBorderTextFieldStyle())

            TextField("Quantity", text: $quantityText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(.numberPad)

            TextField("Price", text: $priceText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(.decimalPad)

            TextField("Address", text: $address)
                .textFieldStyle(RoundedBorderTextFieldStyle())

            TextField("Payment Method", text: $paymentMethod)
                .textFieldStyle(RoundedBorderTextFieldStyle())

            Button("Add Order") {
                if let quantity = Int(quantityText), let price = Double(priceText) {
                    let newOrder = OrderModel(
                        id: UUID().uuidString,
                        orderDate: Date(),
                        totalAmount: Double(quantity) * price,
                        status: "Pending",
                        products: [
                            OrderProduct(productId: UUID().uuidString, productName: productName, quantity: quantity, price: price, productImage: nil)
                        ],
                        userId: UUID().uuidString,
                        userName: userName,
                        address: address,
                        paymentMethod: paymentMethod
                    )
                    
                    // Lưu đơn hàng vào Firestore
                    firestoreService.addOrder(order: newOrder) { success in
                        if success {
                            orders.append(newOrder)
                            dismiss()
                        } else {
                            print("Failed to add order.")
                        }
                    }
                } else {
                    print("Invalid input for quantity or price.")
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
    }
}
