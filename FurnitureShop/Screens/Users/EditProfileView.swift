import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct EditProfileView: View {
    @Binding var userName: String
    @Binding var email: String
    @Binding var address: String
    @Binding var phoneNumber: String
    @State private var profileImageURL: String = ""
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @State private var isLoading: Bool = false
    @State private var errorMessage: ErrorMessage? = nil

    var body: some View {
        VStack {
            if isLoading {
                ProgressView("Saving...")
                    .padding()
            } else {
                Form {
                    // Ảnh đại diện
                    Section(header: Text("Avatar")) {
                        if !profileImageURL.isEmpty {
                            AsyncImage(url: URL(string: profileImageURL)) { phase in
                                switch phase {
                                case .empty:
                                    ProgressView()
                                case .success(let image):
                                    image
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 100, height: 100)
                                        .clipShape(Circle())
                                case .failure:
                                    Image("profile_placeholder")
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 100, height: 100)
                                        .clipShape(Circle())
                                @unknown default:
                                    EmptyView()
                                }
                            }
                        } else {
                            Image("profile_placeholder")
                                .resizable()
                                .scaledToFill()
                                .frame(width: 100, height: 100)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(Color.gray, lineWidth: 2))
                                .shadow(radius: 5)
                        }
                        TextField("Image URL", text: $profileImageURL)
                            .keyboardType(.URL)
                            .autocapitalization(.none)
                    }

                    // Thông tin cá nhân
                    Section(header: Text("Information")) {
                        TextField("Name", text: $userName)
                            .autocapitalization(.words)
                        TextField("Email", text: $email)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                        TextField("Address", text: $address)
                            .autocapitalization(.words)
                        TextField("Phone", text: $phoneNumber)
                            .keyboardType(.phonePad)
                    }

                    // Nút lưu thay đổi
                    Button(action: saveChanges) {
                        Text("Save changes")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
                .alert(item: $errorMessage) { message in
                    Alert(title: Text("Error"), message: Text(message.message), dismissButton: .default(Text("OK")))
                }
            }
        }
        .padding()
        .navigationBarBackButtonHidden(true)
        .navigationTitle("Edit Profile")
        .navigationBarItems(leading: BackButton(action: { presentationMode.wrappedValue.dismiss() }))
        .onAppear(perform: fetchUserData)
    }

    // Lưu thay đổi
    private func saveChanges() {
        guard let currentUser = Auth.auth().currentUser else {
            errorMessage = ErrorMessage(message: "User not found.")
            return
        }

        isLoading = true
        updateUserData(userId: currentUser.uid)
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
                errorMessage = ErrorMessage(message: "Failed to update profile: \(error.localizedDescription)")
            } else {
                presentationMode.wrappedValue.dismiss()
            }
        }
    }

    // Tải dữ liệu người dùng từ Firestore
    private func fetchUserData() {
        guard let currentUser = Auth.auth().currentUser else { return }
        Firestore.firestore().collection("users").document(currentUser.uid).getDocument { snapshot, error in
            if let data = snapshot?.data() {
                self.userName = data["name"] as? String ?? ""
                self.email = data["email"] as? String ?? ""
                self.address = data["address"] as? String ?? ""
                self.phoneNumber = data["phoneNumber"] as? String ?? ""
                self.profileImageURL = data["image"] as? String ?? ""
            }
        }
    }
}
