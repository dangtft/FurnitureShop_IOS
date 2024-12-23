import SwiftUI

struct UserEditView: View {
    @State var user: UserModel
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var successMessage: String?
    private let firestoreService = FirestoreService()
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Chỉnh sửa người dùng")
                    .font(.largeTitle)
                    .padding(.top)
                
                TextField("Tên", text: $user.name)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                TextField("Image", text: Binding(
                    get: { user.image ?? "" },
                    set: { user.image = $0 }
                ))
                .textFieldStyle(RoundedBorderTextFieldStyle())
                
                TextField("Email", text: $user.email)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                TextField("Password", text: Binding(
                    get: { user.password ?? "" },
                    set: { user.password = $0 }
                ))
                .textFieldStyle(RoundedBorderTextFieldStyle())

                
                TextField("Địa chỉ", text: Binding(
                    get: { user.address ?? "" },
                    set: { user.address = $0 }
                ))
                .textFieldStyle(RoundedBorderTextFieldStyle())

                TextField("Số điện thoại", text: Binding(
                    get: { user.phoneNumber ?? "" }, 
                    set: { user.phoneNumber = $0 }
                ))
                .textFieldStyle(RoundedBorderTextFieldStyle())

                
                Spacer()
                
                // Button to save user data
                Button(action: {
                    updateUser()
                }) {
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                    } else {
                        Text("Lưu")
                            .fontWeight(.bold)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
                .padding()
                
                // Error and Success Messages
                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding(.top)
                }
                
                if let successMessage = successMessage {
                    Text(successMessage)
                        .foregroundColor(.green)
                        .padding(.top)
                }
            }
            .padding()
        }
    }
    
    // Function to update user data
    private func updateUser() {
        isLoading = true
        errorMessage = nil
        successMessage = nil
        
        firestoreService.updateUser(user: user) { success, error in
            isLoading = false
            
            if success {
                successMessage = "Thông tin người dùng đã được cập nhật thành công!"
            } else {
                errorMessage = error?.localizedDescription ?? "Có lỗi xảy ra khi cập nhật thông tin người dùng."
            }
        }
    }
}
