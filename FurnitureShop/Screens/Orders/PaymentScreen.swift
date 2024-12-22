import SwiftUI
import Firebase

struct PaymentScreen: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var selectedAddress: String = ""
    @State private var selectedPaymentMethod: String = "Credit Card"
    @EnvironmentObject var cartManager: CartManager
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var navigateToHome = false
    
    var body: some View {
        NavigationStack{
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
            .navigationBarBackButtonHidden(true)
            .navigationBarItems(
                leading: BackButton(action: { presentationMode.wrappedValue.dismiss() }))
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
            .navigationDestination(isPresented: $navigateToHome) {
                HomeScreen()
            }
        }
    }
    
    private func saveOrderToFirebase() {
        guard let userId = cartManager.getCurrentUserId() else {
            alertMessage = "User not found. Please log in."
            showAlert = true
            return
        }
        
        let db = Firestore.firestore()
        
        db.collection("users").document(userId).getDocument { document, error in
            if let error = error {
                alertMessage = "Failed to fetch user data: \(error.localizedDescription)"
                showAlert = true
                return
            }
            
            guard let document = document, document.exists,
                  let userData = document.data(),
                  let userName = userData["name"] as? String else {
                alertMessage = "User data not found."
                showAlert = true
                return
            }
            
            let orderProducts = cartManager.cart?.products.map { product in
                OrderProduct(
                    productId: product.productId,
                    productName: product.name,
                    quantity: product.quantity,
                    price: Double(product.price),
                    productImage: product.image)
            } ?? []
            
            let orderData: [String: Any] = [
                "userId": userId,
                "userName": userName,
                "orderDate": Date(),
                "products": orderProducts.map { product in
                    [
                        "productId": product.productId,
                        "productName" : product.productName,
                        "productImage" : product.productImage as Any,
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
                    navigateToHome = true
                }
            }
        }
    }
}

#Preview {
    PaymentScreen()
}