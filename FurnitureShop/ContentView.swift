import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct ContentView: View {
    @AppStorage("isLoggedInAdmin") private var isLoggedInAdmin: Bool = false
    @AppStorage("isLoggedInUser") private var isLoggedInUser: Bool = false
    @StateObject var cartManager = CartManager()

    var body: some View {
        Group {
            if isLoggedInAdmin {
                Ad_HomeScreen()
            } else if isLoggedInUser {
                HomeScreen()
            } else {
                WelcomeScreen()
                    .environmentObject(cartManager)
            }
        }
        .onAppear {
            checkLoginStatus()
        }
    }

    private func checkLoginStatus() {
        if let currentUser = Auth.auth().currentUser {
            checkUserRole(userId: currentUser.uid)
        } else {
            // Đảm bảo là khi không có người dùng nào đăng nhập, trạng thái sẽ được đặt lại
            DispatchQueue.main.async {
                isLoggedInAdmin = false
                isLoggedInUser = false
            }
        }
    }

    private func checkUserRole(userId: String) {
        let db = Firestore.firestore()
        db.collection("roles").whereField("userId", isEqualTo: userId).getDocuments { snapshot, error in
            if let error = error {
                print("Error getting user role: \(error.localizedDescription)")
                return
            }
            
            if let snapshot = snapshot, !snapshot.isEmpty {
                for document in snapshot.documents {
                    if let roleName = document.get("roleName") as? String {
                        // Cập nhật vai trò và kiểm tra xem đó có phải là admin không
                        DispatchQueue.main.async {
                            if roleName.lowercased() == "admin" {
                                isLoggedInAdmin = true
                                isLoggedInUser = false
                            } else {
                                isLoggedInUser = true
                                isLoggedInAdmin = false
                            }
                        }
                    }
                }
            } else {
                print("No role found for user.")
                // Nếu không tìm thấy vai trò, có thể đặt trạng thái là người dùng bình thường
                DispatchQueue.main.async {
                    isLoggedInUser = true
                    isLoggedInAdmin = false
                }
            }
        }
    }
}
