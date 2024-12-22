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
    @State private var shouldShowWelcomeScreen: Bool = false

    @Environment(\.presentationMode) var presentationMode
    @Environment(\.dismiss) var dismiss
    var body: some View {
        NavigationStack {
            if shouldShowWelcomeScreen {
                WelcomeScreen()
            } else {
                VStack(spacing: 20) {
                    if isLoading {
                        ProgressView("Đang tải...")
                            .padding()
                    } else {
                        
                        NavigationLink(
                            value: "editProfile"
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
                        .navigationDestination(for: String.self) { value in
                            if value == "editProfile" {
                                EditProfileView(
                                    userName: $userName,
                                    email: $email,
                                    address: $address,
                                    phoneNumber: $phoneNumber
                                )
                            }
                        }

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
                }
                .padding()
                .navigationTitle("Hồ sơ")
                .navigationBarBackButtonHidden(true)
                .onAppear {
                    fetchUserProfile()
                }
            }
        }
        .onChange(of: shouldShowWelcomeScreen) { newValue in
            if newValue {
                DispatchQueue.main.async {
                    self.dismiss()
                }
            }
        }
    }

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

    private func logOut() {
        do {
            try Auth.auth().signOut()
            print("Đã đăng xuất.")
            UserDefaults.standard.set(false, forKey: "isLoggedInUser")

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation {
                    self.shouldShowWelcomeScreen = true
                }
            }
        } catch let error {
            print("Lỗi khi đăng xuất: \(error.localizedDescription)")
        }
    }
}
