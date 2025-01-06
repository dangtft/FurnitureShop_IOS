import SwiftUI

import SwiftUI

struct CustomerView: View {
    @State private var users: [UserModel] = []
    @State private var isLoading = true
    @State private var errorMessage: String?
    private let firestoreService = FirestoreService()

    var body: some View {
        VStack {
            Text("Users")
                .font(.largeTitle)
                .padding()

            if isLoading {
                ProgressView("Loading...")
                    .padding()
            } else if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding()
            } else if users.isEmpty {
                Text("No users found.")
                    .foregroundColor(.gray)
                    .padding()
            } else {
                List(users) { user in
                    UserViewCustom(user: user)
                }
                .listStyle(PlainListStyle())
            }
        }
        .onAppear {
            loadUsers()
        }
        .padding()
    }

    private func loadUsers() {
        isLoading = true
        firestoreService.fetchAllUsers { fetchedUsers, error in
            DispatchQueue.main.async {
                isLoading = false
                if let error = error {
                    errorMessage = error
                } else {
                    users = fetchedUsers ?? []
                    errorMessage = users.isEmpty ? "No users found." : nil
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
                    Label("Detail", systemImage: "info.circle")
                }
                
                Button(action: {
                    showingEdit.toggle()
                }) {
                    Label("Edit", systemImage: "pencil")
                }
                
                Button(role: .destructive, action: {
                    showingDeleteConfirmation.toggle()
                }) {
                    Label("Delete", systemImage: "trash")
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
                    title: Text("Delete user"),
                    message: Text("Are you sure you want to delete this user?"),
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

