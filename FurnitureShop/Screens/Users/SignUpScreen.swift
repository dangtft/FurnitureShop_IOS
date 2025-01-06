import SwiftUI
import GoogleSignIn
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth

struct SignUpScreen: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var name: String = ""
    @State private var address: String = "null"
    @State private var phoneNumber: String = "null"
    @State private var image: String = "null"
    @State private var showPassword: Bool = false
    @State private var showConfirmPassword: Bool = false
    @State private var isLoginInProgress: Bool = false
    @State private var isLoggedIn: Bool = false
    @State private var alertMessage: String = ""
    @State private var showAlert: Bool = false
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    var body: some View {
        NavigationStack {
            VStack {
                // Title
                Text("Sign Up")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top, 50)

                Spacer()

                // Input Fields
                inputField(title: "Name", text: $name)
                inputField(title: "Email", text: $email, isEmail: true)

                // Password and Confirm Password fields
                passwordField(title: "Password", text: $password, showText: $showPassword)
                passwordField(title: "Confirm Password", text: $confirmPassword, showText: $showConfirmPassword)

                // Sign Up Button
                Button(action: {
                    if name.isEmpty || email.isEmpty || password.isEmpty || confirmPassword.isEmpty {
                        alertMessage = "Please fill in all required fields."
                        showAlert = true
                        return
                    }

                    if password != confirmPassword {
                        alertMessage = "Passwords do not match."
                        showAlert = true
                        return
                    }

                    signUpAndSaveUserToFirestore(email: email, password: password, name: name)
                }) {
                    Text("Sign Up")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color("Color"))
                        .cornerRadius(10)
                        .padding(.horizontal, 30)
                }
                .padding(.top, 30)

                // Divider
                Text("OR")
                    .padding(.top, 30)

                // Sign in with Google Button
                Button(action: {
                    signUpWithGoogle(from: getRootViewController(), completion: { success, message in
                        if success {
                            isLoggedIn = true
                        } else {
                            alertMessage = "Error: \(message ?? "Unknown error")"
                            showAlert = true
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
            }
            .background(Color.gray.opacity(0.1).edgesIgnoringSafeArea(.all))
            .navigationBarBackButtonHidden(true)
            .navigationBarItems(leading: BackButton(action: { presentationMode.wrappedValue.dismiss() }))
            .navigationDestination(isPresented: $isLoggedIn) {
                LoginScreen().navigationBarBackButtonHidden(true)
            }
            .alert(isPresented: $showAlert) {
                if alertMessage == "Registration successful! You can now log in." {
                    return Alert(
                        title: Text("Success"),
                        message: Text(alertMessage),
                        dismissButton: .default(Text("OK")) {
                            presentationMode.wrappedValue.dismiss()
                        }
                    )
                } else {
                    return Alert(
                        title: Text("Notification"),
                        message: Text(alertMessage),
                        dismissButton: .default(Text("OK"))
                    )
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            // Configure Google Sign-In
            GIDSignIn.sharedInstance.restorePreviousSignIn { user, error in
                if let error = error {
                    print("Error restoring sign-in: \(error.localizedDescription)")
                } else if let user = user {
                    print("Signed in with Google: \(user.profile?.name ?? "")")
                }
            }
        }
    }

    // Reusable TextField for Name and Email
    private func inputField(title: String, text: Binding<String>, isEmail: Bool = false) -> some View {
        TextField(title, text: text)
            .autocapitalization(.none)
            .keyboardType(isEmail ? .emailAddress : .default)
            .padding()
            .background(Color.white)
            .cornerRadius(10)
            .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
            .padding(.horizontal, 30)
            .padding(.bottom, 30)
    }

    // Reusable password field view
    private func passwordField(title: String, text: Binding<String>, showText: Binding<Bool>) -> some View {
        ZStack(alignment: .trailing) {
            if showText.wrappedValue {
                TextField(title, text: text)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(10)
                    .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
                    .padding(.horizontal, 30)
            } else {
                SecureField(title, text: text)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(10)
                    .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
                    .padding(.horizontal, 30)
            }

            Button(action: {
                showText.wrappedValue.toggle()
            }) {
                Image(systemName: showText.wrappedValue ? "eye.slash.fill" : "eye.fill")
                    .foregroundColor(Color.gray)
                    .padding(.trailing, 25)
            }
            .padding(.trailing, 15)
        }
        .padding(.bottom, 30)
    }

    // Firebase Sign Up Function
    private func signUpAndSaveUserToFirestore(email: String, password: String, name: String) {
        isLoginInProgress = true
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let error = error {
                alertMessage = "Error signing up: \(error.localizedDescription)"
                showAlert = true
                isLoginInProgress = false
                return
            }

            guard let userId = authResult?.user.uid else {
                alertMessage = "Failed to retrieve user ID."
                showAlert = true
                isLoginInProgress = false
                return
            }

            // Save user details to Firestore
            let db = Firestore.firestore()
            let userDocument: [String: Any] = [
                "id": userId,
                "email": email,
                "name": name,
                "address": address,
                "phoneNumber": phoneNumber,
                "image": image,
                "createdAt": FieldValue.serverTimestamp()
            ]

            db.collection("users").document(userId).setData(userDocument) { error in
                if let error = error {
                    print("Error saving user to Firestore: \(error.localizedDescription)")
                    alertMessage = "Error saving user to Firestore: \(error.localizedDescription)"
                    showAlert = true
                    isLoginInProgress = false
                    return
                }

                // Save role information to Firestore
                let roleDocument: [String: Any] = [
                    "userId": userId,
                    "roleName": "user"
                ]

                db.collection("roles").addDocument(data: roleDocument) { error in
                    if let error = error {
                        print("Error saving role to Firestore: \(error.localizedDescription)")
                        alertMessage = "Error saving role to Firestore: \(error.localizedDescription)"
                        showAlert = true
                    } else {
                        alertMessage = "Registration successful! You can now log in."
                        showAlert = true
                        isLoggedIn = true
                    }
                    isLoginInProgress = false
                }
            }
        }
    }

}
