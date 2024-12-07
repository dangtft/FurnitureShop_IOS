import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct UserProfileScreen: View {
    @State private var userName: String = ""
    @State private var email: String = ""
    @State private var profileImage: String = "profile_placeholder"
    @State private var address: String = ""
    @State private var phoneNumber: String = ""
    @State private var isLoading: Bool = false
    @State private var isLoggedOut = false

    var body: some View {
        NavigationStack {
            if isLoading {
                ProgressView("Đang tải...")
                    .padding()
            } else {
                VStack(spacing: 20) {
                    NavigationLink(
                        destination: EditProfileView(
                            userName: $userName,
                            email: $email,
                            address: $address,
                            phoneNumber: $phoneNumber
                        )
                    ) {
                        VStack(spacing: 10) {
                            Image(profileImage)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 100, height: 100)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(Color.gray, lineWidth: 2))
                                .shadow(radius: 5)

                            Text(userName)
                                .font(.title)
                                .fontWeight(.bold)

                            Text(email)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                    }
                    .buttonStyle(PlainButtonStyle())

                    Spacer()

                    VStack(spacing: 15) {
                        NavigationLink(destination: OrderHistoryView()) {
                            Text("Lịch sử đơn hàng")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color("Color"))
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }

                        Button(action: logOut) {
                            Text("Đăng xuất")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color("Color"))
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                    }
                    .padding(.horizontal, 20)

                    Spacer()
                }
                .padding()
                .navigationTitle("Hồ sơ")
                .onAppear {
                    fetchUserProfile()
                }

                if isLoggedOut {
                    LoginScreen()
                }
            }
        }
        .navigationBarBackButtonHidden(true)
    }



    // Hàm lấy thông tin hồ sơ người dùng
    private func fetchUserProfile() {
        guard let currentUser = Auth.auth().currentUser else {
            print("Không có người dùng hiện tại.")
            isLoading = false
            return
        }

        let userId = currentUser.uid
        let db = Firestore.firestore()
        db.collection("users").document(userId).getDocument { snapshot, error in
            if let error = error {
                print("Lỗi khi lấy thông tin người dùng: \(error.localizedDescription)")
                isLoading = false
                return
            }

            guard let data = snapshot?.data() else {
                print("Không tìm thấy dữ liệu người dùng.")
                isLoading = false
                return
            }

            DispatchQueue.main.async {
                self.userName = data["name"] as? String ?? "Không rõ tên"
                self.email = data["email"] as? String ?? "Không rõ email"
                let profileImageName = data["image"] as? String ?? "profile_placeholder"
                self.profileImage = profileImageName == "ImageProfile" ? "profile_placeholder" : profileImageName
                self.address = data["address"] as? String ?? ""
                self.phoneNumber = data["phoneNumber"] as? String ?? ""
                self.isLoading = false
            }
        }
    }

    // Hàm đăng xuất
    private func logOut() {
        do {
            try Auth.auth().signOut()
            print("Đã đăng xuất.")
            isLoggedOut = true
        } catch let error {
            print("Lỗi khi đăng xuất: \(error.localizedDescription)")
        }
    }
}

struct EditProfileView: View {
    @Binding var userName: String
    @Binding var email: String
    @Binding var address: String
    @Binding var phoneNumber: String
    @State private var profileImage: UIImage? = nil
    @State private var profileImageURL: String = ""
    @State private var isImagePickerPresented: Bool = false
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @State private var isLoading: Bool = false
    @State private var errorMessage: ErrorMessage? = nil
    
    var body: some View {
        VStack {
            if isLoading {
                ProgressView("Đang lưu thay đổi...")
                    .padding()
            } else {
                Form {
                    // Ảnh đại diện
                    Section(header: Text("Ảnh đại diện")) {
                        if let profileImage = profileImage {
                            Image(uiImage: profileImage)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 100, height: 100)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(Color.gray, lineWidth: 2))
                                .shadow(radius: 5)
                        } else {
                            Image("profile_placeholder")
                                .resizable()
                                .scaledToFill()
                                .frame(width: 100, height: 100)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(Color.gray, lineWidth: 2))
                                .shadow(radius: 5)
                        }
                        Button("Chọn ảnh từ thiết bị") {
                            isImagePickerPresented = true
                        }
                    }
                    
                    // Thông tin cá nhân
                    Section(header: Text("Thông tin cá nhân")) {
                        TextField("Họ và tên", text: $userName)
                            .autocapitalization(.words)
                        TextField("Email", text: $email)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                        TextField("Địa chỉ", text: $address)
                            .autocapitalization(.words)
                        TextField("Số điện thoại", text: $phoneNumber)
                            .keyboardType(.phonePad)
                    }
                    
                    // Nút lưu thay đổi
                    Button(action: saveChanges) {
                        Text("Lưu thay đổi")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color("Color"))
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
                .sheet(isPresented: $isImagePickerPresented) {
                    ImagePicker(selectedImage: $profileImage)
                }
                .alert(item: $errorMessage) { message in
                    Alert(title: Text("Lỗi"), message: Text(message.message), dismissButton: .default(Text("OK")))
                }
            }
        }
        .padding()
        .navigationBarBackButtonHidden(true)
        .navigationTitle("Chỉnh sửa hồ sơ")
        .navigationBarItems(leading: BackButton(action: { presentationMode.wrappedValue.dismiss() }))
    }

    // Hàm lưu thay đổi
    private func saveChanges() {
        guard let currentUser = Auth.auth().currentUser else {
            errorMessage = ErrorMessage(message: "Không tìm thấy người dùng hiện tại.")
            return
        }

        isLoading = true
        
        if let profileImage = profileImage {
            // Upload ảnh trước
            uploadImage(profileImage) { result in
                switch result {
                case .success(let url):
                    profileImageURL = url
                    updateUserData(userId: currentUser.uid)
                case .failure(let error):
                    isLoading = false
                    errorMessage = ErrorMessage(message: error.localizedDescription)
                }
            }
        } else {
            // Chỉ cập nhật thông tin cá nhân nếu không chọn ảnh
            updateUserData(userId: currentUser.uid)
        }
    }
    
    // Cập nhật dữ liệu người dùng trong Firestore
    private func updateUserData(userId: String) {
        var updateData: [String: Any] = [
            "name": userName,
            "email": email,
            "address": address,
            "phoneNumber": phoneNumber
        ]
        
        if !profileImageURL.isEmpty {
            updateData["image"] = profileImageURL
        }
        
        Firestore.firestore().collection("users").document(userId).updateData(updateData) { error in
            isLoading = false
            if let error = error {
                errorMessage = ErrorMessage(message: "Lỗi khi cập nhật thông tin: \(error.localizedDescription)")
            } else {
                presentationMode.wrappedValue.dismiss()
            }
        }
    }
}

struct ErrorMessage: Identifiable {
    let id = UUID()
    let message: String
}

struct OrderHistoryView: View {
    @State private var orders: [OrderModel] = []
    private var db = Firestore.firestore()
    @EnvironmentObject var cartManager: CartManager
    @State private var isLoading = true

    var body: some View {
        NavigationView {
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
            .navigationTitle("Lịch sử đơn hàng")
            .onAppear {
                loadOrdersFromFirebase()
            }
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

struct UserProfileScreen_Previews: PreviewProvider {
    static var previews: some View {
        UserProfileScreen()
    }
}
