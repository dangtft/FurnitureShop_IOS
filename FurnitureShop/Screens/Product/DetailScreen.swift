import SwiftUI
import FirebaseAuth

struct DetailScreen: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @EnvironmentObject var cartManager: CartManager
    var product: ProductModel
    @State private var quantity: Int = 1
    @State private var navigateToCart = false
    @State private var userId: String = ""

    var body: some View {
        NavigationStack {
            ZStack {
                Color("Bg")
                
                ScrollView {
                    AsyncImage(url: URL(string: product.imageName)) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                                .frame(maxWidth: .infinity, maxHeight: 300)
                                .background(Color.gray.opacity(0.2))
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFit()
                                .frame(maxWidth: .infinity)
                                .edgesIgnoringSafeArea(.top)
                        case .failure:
                           
                            Image(systemName: "photo")
                                .resizable()
                                .scaledToFit()
                                .foregroundColor(.gray)
                                .frame(maxWidth: .infinity, maxHeight: 300)
                                .background(Color.gray.opacity(0.2))
                        @unknown default:
                            EmptyView()
                        }
                    }
                    // Mô tả sản phẩm
                    DescriptionView(product: product)
                }
                .edgesIgnoringSafeArea(.top)

                
                HStack {
                    Text("$\(Int(product.price))")
                        .font(.title)
                        .foregroundColor(.white)
                    Spacer()
                    
                    Button(action: {
                        let cartProduct = CartProduct(
                            id: UUID().uuidString,
                            productId: product.id ?? "unknown",
                            name: product.name,
                            category: product.category,
                            price: Int(product.price),
                            quantity: quantity,
                            image: product.imageName
                        )
                        
                        cartManager.addToCart(product: cartProduct, userId: userId)
                       
                        navigateToCart = true
                    }) {
                        Text("Add to Cart")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(Color("Color"))
                            .padding()
                            .padding(.horizontal, 8)
                            .background(Color.white)
                            .cornerRadius(10.0)
                    }
                }
                .padding()
                .padding(.horizontal)
                .background(Color("Color"))
                .cornerRadius(60.0, corners: .topLeft)
                .frame(maxHeight: .infinity, alignment: .bottom)
                .edgesIgnoringSafeArea(.bottom)
            }
            .navigationBarBackButtonHidden(true)
            .navigationBarItems(
                leading: BackButton(action: { presentationMode.wrappedValue.dismiss() }))
            
            .navigationDestination(isPresented: $navigateToCart) {
                CartScreen()
                    .environmentObject(cartManager)
            }
            .onAppear {
                if let currentUser = Auth.auth().currentUser {
                    self.userId = currentUser.uid
                } else {
                                
                    print("No user is signed in")
                }
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}





struct BackButton: View {
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            Image(systemName: "chevron.backward")
                .foregroundColor(.black)
                .padding(.all, 12)
                .background(Color.white)
                .cornerRadius(8.0)
        }
    }
}



struct RoundedCorner: Shape {

    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape( RoundedCorner(radius: radius, corners: corners) )
    }
}

struct ColorDotView: View {
    let color: String
    
    var body: some View {
        Circle()
            .fill(Color(hex: color))
            .frame(width: 24, height: 24)
            .overlay(
                Circle()
                    .stroke(Color.white, lineWidth: 1)
            )
            .shadow(radius: 1)
    }
}


struct DescriptionView: View {
    var product: ProductModel
    
    var body: some View {
        VStack (alignment: .leading) {
            // Tên sản phẩm
            Text(product.name)
                .font(.title)
                .fontWeight(.bold)
            
            // Đánh giá sản phẩm
            HStack (spacing: 4) {
                ForEach(0 ..< 5) { _ in
                    Image("star")
                }
                Text("(4.9)")
                    .opacity(0.5)
                    .padding(.leading, 8)
                Spacer()
            }
            
            // Mô tả sản phẩm
            Text("Description")
                .fontWeight(.medium)
                .padding(.vertical, 8)
            Text(product.description)
                .lineSpacing(8.0)
                .opacity(0.6)
            
            // Thông số kỹ thuật sản phẩm
            HStack (alignment: .top) {
                VStack (alignment: .leading) {
                    Text("Size")
                        .font(.system(size: 16))
                        .fontWeight(.semibold)
                    Text("Height: \(product.size.height) cm")
                        .opacity(0.6)
                    Text("Wide: \(product.size.width) cm")
                        .opacity(0.6)
                    Text("Diameter: \(product.size.diameter) cm")
                        .opacity(0.6)
                }
                
                Spacer()
                
                VStack (alignment: .leading) {
                    Text("Treatment")
                        .font(.system(size: 16))
                        .fontWeight(.semibold)
                    Text("\(product.material)")
                        .opacity(0.6)
                }
            }
            .padding(.vertical)
            
            // Màu sắc sản phẩm
            HStack {
                VStack (alignment: .leading) {
                    Text("Colors")
                        .fontWeight(.semibold)
                    HStack {
                        ForEach(product.availableColors, id: \.self) { color in
                            ColorDotView(color: color)
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                // Số lượng sản phẩm
                HStack {
                    // Nút trừ
                    Button(action: {}) {
                        Image(systemName: "minus")
                            .padding(.all, 8)
                    }
                    .frame(width: 30, height: 30)
                    .overlay(RoundedCorner(radius: 50).stroke())
                    .foregroundColor(.black)
                    
                    Text("1")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .padding(.horizontal, 8)
                    
                    // Nút cộng
                    Button(action: {}) {
                        Image(systemName: "plus")
                            .foregroundColor(.white)
                            .padding(.all, 8)
                            .background(Color("Color"))
                            .clipShape(Circle())
                    }
                }
            }
        }
        .padding()
        .padding(.top)
        .background(Color("Bg"))
        .cornerRadius(30, corners: [.topLeft, .topRight])
        .offset(x: 0, y: -30.0)
    }
}


extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
