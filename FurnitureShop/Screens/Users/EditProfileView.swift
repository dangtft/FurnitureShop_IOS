import SwiftUI
import FirebaseAuth
import FirebaseFirestore

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

    // Hàm mã hóa hình ảnh thành chuỗi Base64
    private func encodeImageToBase64(_ image: UIImage) -> String? {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            return nil
        }
        return imageData.base64EncodedString()
    }

    // Hàm lưu thay đổi
    private func saveChanges() {
        guard let currentUser = Auth.auth().currentUser else {
            errorMessage = ErrorMessage(message: "Không tìm thấy người dùng hiện tại.")
            return
        }

        isLoading = true
        
        if let profileImage = profileImage {
            // Mã hóa ảnh thành chuỗi Base64
            if let base64String = encodeImageToBase64(profileImage) {
                profileImageURL = base64String
                updateUserData(userId: currentUser.uid)
            } else {
                isLoading = false
                errorMessage = ErrorMessage(message: "Không thể mã hóa ảnh thành Base64.")
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
