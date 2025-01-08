import SwiftUI
import FirebaseFirestore

struct HomeScreen: View {
    @State private var search: String = ""
    @State private var selectedIndex: String = "0"
    @State private var currentScreen: String = "Home"
    @State private var categories: [CategoryModel] = []
    @State private var products: [ProductModel] = []
    
    private let firestoreService = FirestoreService()
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGray6)
                    .ignoresSafeArea()
                
                VStack {
                    if currentScreen == "Home" {
                        ScrollView(showsIndicators: false) {
                            VStack(alignment: .leading) {
                                
                                AppBarView(currentScreen: $currentScreen)
                                
                                TagLineView()
                                    .padding()
                                
                                SearchView(search: $search)
                                
                                // Hiển thị danh mục
                                categoryScrollView
                                
                                // Hiển thị sản phẩm theo danh mục
                                categoryProductViews
                            }
                        }
                    } else if currentScreen == "Profile" {
                        UserProfileScreen()
                    } else if currentScreen == "Cart" {
                        CartScreen()
                    } else if currentScreen == "News" {
                        NewsScreen()
                    }
                    Spacer()
                    BottomNavBarView(currentScreen: $currentScreen)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            fetchCategories()
            fetchProducts()
            FirestoreService.shared.recordUserAccess()
        }
    }
    
    private var categoryScrollView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 16) {
                ForEach(categories) { category in
                    Button(action: { selectedIndex = category.id! }) {
                        CategoryView(isActive: selectedIndex == category.id, text: category.name)
                    }
                }
            }
            .padding(.horizontal)
        }
    }
    
    private var categoryProductViews: some View {
        ForEach(categories) { category in
            if selectedIndex == category.id || selectedIndex == "0" {
                VStack(alignment: .leading) {
                    Text(category.name)
                        .font(.title)
                        .fontWeight(.bold)
                        .padding(.horizontal)

                    if filteredProducts(for: category).isEmpty {
                        Text("No products available")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .padding(.horizontal)
                    } else {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 16) {
                                ForEach(filteredProducts(for: category)) { product in
                                    ProductCardView(size: 210, product: product)
                                }
                            }
                            .padding(.horizontal)
                        }
                        .padding(.bottom)
                    }
                }
            }
        }
    }

    
    private func filteredProducts(for category: CategoryModel) -> [ProductModel] {
        let filteredByCategory: [ProductModel]
        if category.id == "0" {
            filteredByCategory = products
        } else {
            filteredByCategory = products.filter { $0.category == category.name }
        }

        if search.isEmpty {
            return filteredByCategory
        } else {
            return filteredByCategory.filter { $0.name.lowercased().contains(search.lowercased()) }
        }
    }

    private func fetchCategories() {
        let db = Firestore.firestore()
        db.collection("categories").getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching categories: \(error)")
                return
            }
            
            if let snapshot = snapshot {
                self.categories = snapshot.documents.compactMap { doc in
                    if let name = doc.data()["name"] as? String, let image = doc.data()["image"] as? String {
                        return CategoryModel(id: doc.documentID, name: name, image: image)
                    } else {
                        print("Missing or invalid data in category document: \(doc.documentID)")
                        return nil
                    }
                }
            }
        }
    }

    
    private func fetchProducts() {
        let db = Firestore.firestore()
        db.collection("products").getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching products: \(error)")
                return
            }
            
            if let snapshot = snapshot {
                self.products = snapshot.documents.compactMap { doc in
                    guard let name = doc.data()["name"] as? String,
                          let description = doc.data()["description"] as? String,
                          let price = doc.data()["price"] as? Double,
                          let imageName = doc.data()["imageName"] as? String,
                          let material = doc.data()["material"] as? String,
                          let category = doc.data()["category"] as? String,
                          let sizeData = doc.data()["size"] as? [String: Double] else { return nil }
                    
                    let height = sizeData["height"] ?? 0.0
                    let width = sizeData["width"] ?? 0.0
                    let diameter = sizeData["diameter"] ?? 0.0
                    let colors = doc.data()["availableColors"] as? [String] ?? []
                    
                    return ProductModel(
                        id: doc.documentID,
                        name: name,
                        description: description,
                        price: price,
                        imageName: imageName,
                        size: ProductSize(height: height, width: width, diameter: diameter),
                        quantity: 0,
                        material: material,
                        availableColors: colors,
                        category: category
                    )
                }
            }
        }
    }
}


struct ProductCardView: View {
    let size: CGFloat
    let product: ProductModel
    
    var body: some View {
        NavigationLink(destination: DetailScreen(product: product)) {
            VStack {
                
                AsyncImage(url: URL(string: product.imageName)) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                            .frame(width: size, height: 200 * (size / 210))
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(20.0)
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(width: size, height: 200 * (size / 210))
                            .cornerRadius(20.0)
                    case .failure:
                        Image(systemName: "photo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: size, height: 200 * (size / 210))
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(20.0)
                    @unknown default:
                        EmptyView()
                    }
                }
                
                // Hiển thị tên sản phẩm
                Text(product.name)
                    .font(.title3)
                    .fontWeight(.bold)
                
                // Đánh giá sản phẩm
                HStack(spacing: 2) {
                    ForEach(0 ..< 5) { _ in
                        Image("star")
                    }
                    Spacer()
                    
                    // Hiển thị giá sản phẩm
                    Text("$\(Int(product.price))")
                        .font(.title3)
                        .fontWeight(.bold)
                }
                
                // Hiển thị màu sắc có sẵn
                HStack {
                    ForEach(product.availableColors, id: \.self) { color in
                        Circle()
                            .fill(Color(color))
                            .frame(width: 20, height: 20)
                    }
                    Spacer()
                }
                .padding(.top, 4)
                
                // Hiển thị kích thước sản phẩm
                VStack(alignment: .leading) {
                    Text("Size: \(product.size.height, specifier: "%.1f") x \(product.size.width, specifier: "%.1f") x \(product.size.diameter, specifier: "%.1f")")
                        .font(.footnote)
                        .foregroundColor(Color.gray)
                }
                .padding(.top, 4)
            }
            .frame(width: size)
            .padding()
            .background(Color.white)
            .cornerRadius(20.0)
            .navigationBarBackButtonHidden(true)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct CategoryView: View {
    let isActive: Bool
    let text: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(text)
                .font(.system(size: 18))
                .fontWeight(.medium)
                .foregroundColor(isActive ? Color("Color") : Color.black.opacity(0.5))
            if isActive {
                Color("Color")
                    .frame(width: 15, height: 2)
                    .clipShape(Capsule())
            }
        }
        .padding(.trailing)
    }
}

struct AppBarView: View {
    @Binding var currentScreen: String
    var body: some View {
        HStack {
            Text("Home")
                .font(.system(size: 30))
            
            Spacer()
            
            Button(action: {}) {
                Image("imageProfile")
                    .resizable()
                    .frame(width: 42, height: 42)
                    .cornerRadius(10.0)
            }
        }
        .padding(.horizontal)
    }
}

struct TagLineView: View {
    var body: some View {
        Text("Find the \nBest ")
            .font(.custom("PlayfairDisplay-Regular", size: 28))
            .foregroundColor(Color("Color"))
            + Text("Furniture")
            .font(.custom("PlayfairDisplay-Bold", size: 28))
            .fontWeight(.bold)
            .foregroundColor(Color("Color"))
    }
}

struct BottomNavBarView: View {
    @Binding var currentScreen: String
    
    var body: some View {
        HStack {
            BottomNavBarItem(
                image: Image("home 1"),
                isSelected: currentScreen == "Home",
                action: {
                    currentScreen = "Home"
                }
            )
            BottomNavBarItem(
                image: Image("news"),
                isSelected: currentScreen == "News",
                action: {
                    currentScreen = "News"
                }
            )
            BottomNavBarItem(
                image: Image("shopping-cart"),
                isSelected: currentScreen == "Cart",
                action: {
                    currentScreen = "Cart"
                }
            )
            BottomNavBarItem(
                image: Image("User"),
                isSelected: currentScreen == "Profile",
                action: {
                    currentScreen = "Profile"
                }
            )
        }
        .padding()
        .background(Color.white)
        .clipShape(Capsule())
        .padding(.horizontal)
        .shadow(color: Color.blue.opacity(0.15), radius: 8, x: 2, y: 6)
    }
}

struct BottomNavBarItem: View {
    let image: Image
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack {
                image
                   
                    .frame(maxWidth: .infinity)
                    .foregroundColor(isSelected ? Color("Color") : Color.black.opacity(0.5))
                if isSelected {
                    Color("PrimaryColor")
                        .frame(width: 15, height: 2)
                        .clipShape(Capsule())
                }
            }
        }
    }
}

struct HomeScreen_Previews: PreviewProvider {
    static var previews: some View {
        HomeScreen()
    }
}



struct SearchView: View {
    @Binding var search: String	
    var body: some View {
        HStack {
            HStack {
                Image("Search")
                    .padding(.trailing, 8)
                TextField("Search Furniture", text: $search)
                    .onChange(of: search) {
                        // Cập nhật khi người dùng nhập
                    }
            }
            .padding(.all, 20)
            .background(Color.white)
            .cornerRadius(10.0)
            .padding(.trailing, 8)
            
            Button(action: {}) {
                Image("icon-search")
                    .padding()
                    .background(Color("Color"))
                    .cornerRadius(10.0)
            }
        }
        .padding(.horizontal)
    }
}
