import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct UserProfileScreen: View {
    @State private var userName: String = ""
    @State private var email: String = ""
    @State private var profileImageURL: String = "" 
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
                        ProgressView("Loading...")
                            .padding()
                    } else {
                        
                        NavigationLink(
                            value: "editProfile"
                        ) {
                            VStack(spacing: 10) {
                                AsyncImage(url: URL(string: profileImageURL)) { phase in
                                    switch phase {
                                    case .empty:
                                        ProgressView() // Hiển thị vòng tròn chờ trong khi tải hình
                                            .frame(width: 100, height: 100)
                                    case .success(let image):
                                        image
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 100, height: 100)
                                            .clipShape(Circle())
                                            .overlay(Circle().stroke(Color.gray, lineWidth: 2))
                                            .shadow(radius: 5)
                                    case .failure:
                                        Image("profile_placeholder") // Hình mặc định khi không tải được
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 100, height: 100)
                                            .clipShape(Circle())
                                            .overlay(Circle().stroke(Color.gray, lineWidth: 2))
                                            .shadow(radius: 5)
                                    @unknown default:
                                        EmptyView()
                                    }
                                }

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
                                Text("Order history")
                                    .font(.headline)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color("Color"))
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                            }

                            Button(action: logOut) {
                                Text("Log out")
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
                .navigationTitle("User profile")
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
            print("Not found current user.")
            isLoading = false
            return
        }

        let userId = currentUser.uid
        let db = Firestore.firestore()
        db.collection("users").document(userId).getDocument { snapshot, error in
            if let error = error {
                print("Error when getting user information: \(error.localizedDescription)")
                isLoading = false
                return
            }

            guard let data = snapshot?.data() else {
                print("Not found user information.")
                isLoading = false
                return
            }

            DispatchQueue.main.async {
                self.userName = data["name"] as? String ?? "NoName"
                self.email = data["email"] as? String ?? "No Email"
                self.profileImageURL = data["image"] as? String ?? ""
                self.address = data["address"] as? String ?? ""
                self.phoneNumber = data["phoneNumber"] as? String ?? ""
                self.isLoading = false
            }
        }
    }

    private func logOut() {
        do {
            try Auth.auth().signOut()
            print("Logged out.")
            UserDefaults.standard.set(false, forKey: "isLoggedInUser")

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation {
                    self.shouldShowWelcomeScreen = true
                }
            }
        } catch let error {
            print("Error when logging out: \(error.localizedDescription)")
        }
    }
}
