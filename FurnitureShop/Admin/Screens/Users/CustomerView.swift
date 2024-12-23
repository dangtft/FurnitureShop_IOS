import SwiftUI

struct CustomerView: View {
    @State private var users: [UserModel] = []
    private let firestoreService = FirestoreService()

    var body: some View {
        ScrollView{
            VStack {
                Text("Users")
                    .font(.largeTitle)
                
                List(users) { user in
                    UserViewCustom(user: user)
                }
                .listStyle(PlainListStyle())
                .padding(.horizontal)
                .onAppear {
                    firestoreService.fetchUsers { fetchedUsers in
                        users = fetchedUsers ?? []
                    }
                }
            }
        }
    }
}

struct UserViewCustom: View {
    let user: UserModel
    @State private var showingDetail = false
    @State private var showingEdit = false
    @State private var showingDeleteConfirmation = false
    private let firestoreService = FirestoreService()
    
    var body: some View {
        HStack {
            // Hình ảnh người dùng
            CircleImageProduct(imageProductName: user.image?.isEmpty ?? true ? "https://i.pinimg.com/736x/d9/7b/bb/d97bbb08017ac2309307f0822e63d082.jpg" : user.image!)
            
            Spacer()
            
            // Tên người dùng
            Text(user.name)
                .font(.headline)
            
            Spacer()
            
            Menu {
                Button(action: {
                    showingDetail.toggle()
                }) {
                    Label("Chi tiết", systemImage: "info.circle")
                }
                
                Button(action: {
                    showingEdit.toggle()
                }) {
                    Label("Sửa", systemImage: "pencil")
                }
                
                Button(role: .destructive, action: {
                    showingDeleteConfirmation.toggle()
                }) {
                    Label("Xóa", systemImage: "trash")
                }
            } label: {
                Image(systemName: "ellipsis.circle")
                    .font(.title)
                    .foregroundColor(.gray)
            }
            .sheet(isPresented: $showingDetail) {
                UserDetailView(user: user)
            }
            .sheet(isPresented: $showingEdit) {
                UserEditView(user: user)
            }
            .alert(isPresented: $showingDeleteConfirmation) {
                Alert(
                    title: Text("Xóa người dùng"),
                    message: Text("Bạn có chắc chắn muốn xóa người dùng này?"),
                    primaryButton: .destructive(Text("Xóa")) {
                        firestoreService.deleteUser(user: user) { success, error in
                            if success {
                                // Xử lý thành công, có thể cập nhật lại danh sách người dùng
                                print("User deleted successfully")
                            } else {
                                // Xử lý lỗi nếu có
                                if let error = error {
                                    print("Error deleting user: \(error.localizedDescription)")
                                }
                            }
                        }
                    },
                    secondaryButton: .cancel()
                )
            }
        }
        .padding()
    }
}


#Preview {
    CustomerView()
}

