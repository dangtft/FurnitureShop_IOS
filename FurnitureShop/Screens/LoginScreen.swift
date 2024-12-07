import SwiftUI
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth

struct LoginScreen: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var showPassword: Bool = false
    @State private var isLoginInProgress: Bool = false
    @State private var isLoggedIn: Bool = false
    @State private var showSignUpScreen: Bool = false
    @State private var errorMessage: String = ""
    @State private var showSuccessAlert: Bool = false

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

                Button(action: {
                    signInWithGoogle(from: getRootViewController(), completion: { success, message in
                        if success {
                            isLoggedIn = true
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
            .navigationDestination(isPresented: $isLoggedIn) {
                HomeScreen()
            }
            .navigationDestination(isPresented: $showSignUpScreen) {
                SignInScreen() 
            }
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
            print("Login successful!")
            isLoggedIn = true
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginScreen()
    }
}
