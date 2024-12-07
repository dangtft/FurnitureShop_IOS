import SwiftUI
import Firebase

struct PaymentScreen: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var selectedAddress: String = ""
    @State private var selectedPaymentMethod: String = "Credit Card"
    @EnvironmentObject var cartManager: CartManager
    @State private var showAlert = false
    @State private var alertMessage = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Delivery Address")
                .font(.headline)

            TextField("Enter your address", text: $selectedAddress)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.bottom)

            Text("Payment Method")
                .font(.headline)

            Picker("Select Payment Method", selection: $selectedPaymentMethod) {
                Text("Credit Card").tag("Credit Card")
                Text("PayPal").tag("PayPal")
                Text("Cash on Delivery").tag("Cash on Delivery")
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.bottom)

            Spacer()

            Button {
                saveOrderToFirebase()
            } label: {
                Text("Confirm Payment")
                    .frame(maxWidth: .infinity)
                    .frame(height: 60)
                    .background(Color("Color"))
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.white)
                    .clipShape(Capsule())
                    .padding()
            }
        }
        .padding()
        .navigationTitle("Payment")
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Order Status"),
                message: Text(alertMessage),
                dismissButton: .default(Text("OK")) {
                    if alertMessage == "Order placed successfully!" {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            )
        }
    }

    private func saveOrderToFirebase() {
        guard let userId = cartManager.getCurrentUserId() else {
            alertMessage = "User not found. Please log in."
            showAlert = true
            return
        }

        let db = Firestore.firestore()

        let orderProducts = cartManager.cart?.products.map { product in
            OrderProduct(productId: product.productId, productName: product.name, quantity: product.quantity, price: Double(product.price))
        } ?? []

        let orderData: [String: Any] = [
            "userId": userId,
            "orderDate": Date(),
            "products": orderProducts.map { product in
                [
                    "productId": product.productId,
                    "productName" : product.productName,
                    "quantity": product.quantity,
                    "price": product.price
                ]
            },
            "totalAmount": cartManager.total,
            "status": "Pending",
            "address": selectedAddress,
            "paymentMethod": selectedPaymentMethod
        ]

        db.collection("orders").addDocument(data: orderData) { error in
            if let error = error {
                alertMessage = "Failed to save order: \(error.localizedDescription)"
                showAlert = true
            } else {
                alertMessage = "Order placed successfully!"
                showAlert = true
                cartManager.clearCart()
            }
        }
    }
}

#Preview {
    PaymentScreen()
}
