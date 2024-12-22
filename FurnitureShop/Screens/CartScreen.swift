import SwiftUI
import FirebaseAuth

struct CartScreen: View {
    @EnvironmentObject var cartManager: CartManager
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @State private var navigateToPaymentScreen = false
    @State private var userId: String = ""
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack {
                    HStack {
                        Text("Cart")
                            .font(.system(size: 36, weight: .bold))
                            .padding(.trailing)

                        Spacer()

                        Button {
                            // Logic
                        } label: {
                            Text("\(cartManager.cartItemCount)")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .padding()
                                .background(Color("Color"))
                                .clipShape(Capsule())
                        }
                    }
                    .padding(30)

                    VStack {
                        if cartManager.cart?.products.isEmpty ?? true {
                            Text("Your cart is empty.")
                                .font(.title2)
                                .foregroundColor(.gray)
                        } else {
                            ForEach(cartManager.cart?.products ?? [], id: \.id) { product in
                                CartProductCard(product: product, userId: userId)
                            }
                        }
                    }
                    .padding(.horizontal)

                    VStack {
                        Button {
                            cartManager.clearCart()
                        } label: {
                            Text("Clear All")
                                .foregroundColor(.white)
                                .padding()
                        }
                        .background(Color("Color"))
                        .clipShape(Capsule())
                    }

                    VStack {
                        HStack {
                            Text("Delivery Amount")
                                .foregroundColor(.white)
                            Spacer()
                            Text("Free")
                                .font(.system(size: 22, weight: .semibold))
                                .foregroundColor(.white)
                        }

                        Divider()
                            .background(Color.gray.opacity(0.5))

                        Text("Total Amount")
                            .font(.system(size: 24))
                            .fontWeight(.bold)
                            .foregroundColor(.white)

                        Text("USD \(cartManager.total)")
                            .font(.system(size: 36, weight: .semibold))
                            .foregroundColor(.white)
                    }
                    .padding(30)
                    .background(Color("Color"))
                    .padding()

                    Button {
                        
                        navigateToPaymentScreen = true
                    } label: {
                        Text("Make Payment")
                            .frame(maxWidth: .infinity)
                            .frame(height: 60)
                            .background(Color("Color"))
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.white)
                            .clipShape(Capsule())
                            .padding()
                    }
                }
                .background(Color.white.opacity(0.9))
            }
            .navigationBarBackButtonHidden(true)
            .navigationBarItems(
                leading: BackButton(action: { presentationMode.wrappedValue.dismiss() }),
                trailing: Image("threeDot")
            )
            .navigationDestination(isPresented: $navigateToPaymentScreen) {
                PaymentScreen()
            }
            .onAppear {
                if let userId = cartManager.getCurrentUserId (){
                    cartManager.loadCartFromFirebase(userId: userId)
                }
            }
            .onDisappear {
                // Lưu giỏ hàng khi màn hình biến mất
                if let userId = cartManager.getCurrentUserId (){
                    cartManager.saveCartToFirebase(userId: userId)
                }
                
            }
        }
        .padding()
        .navigationBarBackButtonHidden(true)
    }
}

struct CartProductCard: View {
    var product: CartProduct
    
    @EnvironmentObject var cartManager: CartManager
    var userId: String

    var body: some View {
        HStack(alignment: .center, spacing: 15) {

            AsyncImage(url: URL(string: product.image)) { phase in
                switch phase {
                case .empty:

                    ProgressView()
                        .frame(width: 60, height: 60)
                        .background(Color.gray.opacity(0.1))
                        .clipShape(Circle())
                        .shadow(radius: 3)
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFit()
                        .frame(width: 60, height: 60)
                        .background(Color.gray.opacity(0.1))
                        .clipShape(Circle())
                        .shadow(radius: 3)
                case .failure:

                    Image(systemName: "photo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 60, height: 60)
                        .background(Color.gray.opacity(0.1))
                        .clipShape(Circle())
                        .shadow(radius: 3)
                @unknown default:
                    EmptyView()
                }
            }

            VStack(alignment: .leading, spacing: 5) {
                Text(product.name)
                    .font(.headline)
                    .foregroundColor(.black)
                
                Text(product.category)
                    .font(.callout)
                    .foregroundColor(.gray)
            }
            
            HStack {
                Button {
                    if let userId = cartManager.getCurrentUserId() {
                        cartManager.removeFromCart(product: product, userId: userId)
                    } else {
                        print("User ID không hợp lệ.")
                    }
                } label: {
                    Image(systemName: "minus.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.black)
                }
                Text("\(product.quantity)")
                    .font(.system(size: 20))
                    .foregroundColor(.black)

                Button {
                    if let userId = cartManager.getCurrentUserId() {
                            cartManager.addToCart(product: product, userId: userId)
                        }
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.black)
                }
            }
            
            Text("$\(product.totalPrice)")
                .font(.system(size: 20))
                .foregroundColor(.black)
                .padding(10)
                .clipShape(Capsule())
            
            Button {
                if let userId = cartManager.getCurrentUserId() {
                    cartManager.removeAllFromCart(productId:  product.productId, userId: userId)
                } else {
                    print("User ID không hợp lệ.")
                }
               
            } label: {
                Image(systemName: "trash")
                    .font(.system(size: 20))
                    .foregroundColor(.black)
            }
        }
        .padding(.vertical, 8)
        .background(Color.white)
    }
}


//struct CartScreen_Previews: PreviewProvider {
//
//    static var previews: some View {
//        @State var userId: String = ""
//        let cartManager = CartManager()
//
//
//        let cartProduct = CartProduct(
//            id: cartManager.generateNewProductId(),
//            productId: "1",
//            name: "Luxury Chair",
//            category: "Chair",
//            price: 1299,
//            quantity: 1,
//            image: "https://i.pinimg.com/736x/fe/a4/bc/fea4bc6cf91b5868621b176e457f51d8.jpg"
//        )
//
//        cartManager.addToCart(product: cartProduct,userId: userId)
//
//        return CartScreen()
//            .environmentObject(cartManager)
//    }
//}
