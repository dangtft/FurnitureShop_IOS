import SwiftUI
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth

struct LoginScreen: View {
    @AppStorage("isLoggedInAdmin") private var isLoggedInAdmin: Bool = false
    @AppStorage("isLoggedInUser") private var isLoggedInUser: Bool = false
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var showPassword: Bool = false
    @State private var isLoginInProgress: Bool = false
    @State private var showSignUpScreen: Bool = false
    @State private var errorMessage: String = ""
    @State private var showSuccessAlert: Bool = false
    @State private var userRole: String = ""
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            VStack {
                // Title
                Text("Login")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top, 50)

                Spacer()

                // Error Message
                if !errorMessage.isEmpty {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding(.bottom, 10)
                }

                // Email TextField
                TextField("Email", text: $email)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(10)
                    .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
                    .padding(.horizontal, 30)
                    .padding(.bottom, 30)

                // Password Field
                ZStack(alignment: .trailing) {
                    if showPassword {
                        TextField("Password", text: $password)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(10)
                            .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
                            .padding(.horizontal, 30)
                    } else {
                        SecureField("Password", text: $password)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(10)
                            .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
                            .padding(.horizontal, 30)
                    }

                    Button(action: {
                        showPassword.toggle()
                    }) {
                        Image(systemName: showPassword ? "eye.slash.fill" : "eye.fill")
                            .foregroundColor(Color.gray)
                            .padding(.trailing, 25)
                    }
                    .padding(.trailing, 15)
                }

                // Login Button
                Button(action: {
                    login(email: email, password: password)
                }) {
                    if isLoginInProgress {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color("Color"))
                            .cornerRadius(10)
                            .padding(.horizontal, 30)
                    } else {
                        Text("Login")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color("Color"))
                            .cornerRadius(10)
                            .padding(.horizontal, 30)
                    }
                }
                .padding(.top, 30)
                .padding(.horizontal, 50)

                Text("OR").padding(.top, 30)

                // Google Sign-In Button
                Button(action: {
                    signInWithGoogle(from: getRootViewController(), completion: { success, message in
                        if success {
                            isLoggedInUser = true
                            dismiss()
                        } else {
                            print("Error: \(message ?? "Unknown error")")
                        }
                    })
                }) {
                    HStack {
                        Image("google")
                            .foregroundColor(.black)
                        Text("Sign in with Google")
                            .foregroundColor(.black)
                            .fontWeight(.bold)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.white)
                    .cornerRadius(10)
                    .padding(.horizontal, 30)
                }
                .padding(.top, 20)

                // Register now link
                HStack {
                    Text("Don't have an account?")
                    Button(action: {
                        showSignUpScreen = true
                    }) {
                        Text("Register now")
                            .foregroundColor(.blue)
                    }
                }
                .padding(.top, 10)

                // Forgot Password Link
                HStack {
                    Spacer()
                    Button(action: {
                        // Forgot password action
                    }) {
                        Text("Forgot Password?")
                            .foregroundColor(.black)
                            .padding(.trailing, 30)
                    }
                }
            }
            .background(Color.gray.opacity(0.1).edgesIgnoringSafeArea(.all))
            .alert("Login Successful", isPresented: $showSuccessAlert) {
                Button("OK") {
                    navigateBasedOnRole()
                }
            }
            .navigationDestination(isPresented: $showSignUpScreen) {
                SignUpScreen()
            }
        }
    }

    private func navigateBasedOnRole() {
        // Điều hướng dựa trên vai trò của người dùng
        if userRole == "admin" {
            isLoggedInAdmin = true
            dismiss()  // Đóng màn hình login khi đăng nhập thành công
            // Điều hướng tới màn hình HomeScreen cho admin
        } else {
            isLoggedInUser = true
            dismiss()  // Đóng màn hình login khi đăng nhập thành công
            // Điều hướng tới màn hình HomeScreen cho user
        }
    }

}


extension LoginScreen {
    private func login(email: String, password: String) {
        errorMessage = ""

        guard !email.isEmpty else {
            errorMessage = "Please enter your email."
            return
        }

        guard !password.isEmpty else {
            errorMessage = "Please enter your password."
            return
        }

        isLoginInProgress = true
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            isLoginInProgress = false
            if let error = error {
                print("Login failed: \(error.localizedDescription)")
                errorMessage = error.localizedDescription
                return
            }

            guard let userId = result?.user.uid else {
                errorMessage = "Unable to fetch user ID."
                return
            }

            let db = Firestore.firestore()

            // Truy vấn vào collection "roles" để lấy thông tin vai trò của người dùng
            db.collection("roles").whereField("userId", isEqualTo: userId).getDocuments { snapshot, error in
                if let error = error {
                    print("Failed to fetch user role: \(error.localizedDescription)")
                    errorMessage = "Failed to fetch user role."
                    return
                }

                if let snapshot = snapshot, !snapshot.isEmpty {
                    for document in snapshot.documents {
                        if let userRole = document.get("roleName") as? String {
                            print("User role: \(userRole)")
                            self.userRole = userRole
                            showSuccessAlert = true
                        }
                    }
                } else {
                    errorMessage = "User role not found."
                }
            }
        }
    }
}
