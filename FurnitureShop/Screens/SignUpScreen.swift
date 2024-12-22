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
    @State private var showPassword: Bool = false
    @State private var showConfirmPassword: Bool = false
    @State private var isLoginInProgress: Bool = false
    @State private var isLoggedIn: Bool = false
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    var body: some View {
        NavigationView {
            VStack {
                // Title
                Text("Sign Up")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top, 50)
                
                Spacer()
                
                TextField("Name", text: $name)
                    .autocapitalization(.none)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(10)
                    .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
                    .padding(.horizontal, 30)
                    .padding(.bottom, 30)
                
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
                
                // Password TextField
                passwordField(title: "Password", text: $password, showText: $showPassword)
                
                // Confirm Password TextField
                passwordField(title: "Confirm Password", text: $confirmPassword, showText: $showConfirmPassword)
                
                // Sign In Button
                Button(action: {
                    if password == confirmPassword {
                        signUpAndSaveUserToFirestore(email: email, password: password, name: name)
                    } else {
                        print("Passwords do not match")
                    }
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
                .padding(.horizontal, 50)
                
                Text("OR").padding(.top, 30)
                
                Button(action: {
                    signUpWithGoogle(from: getRootViewController(), completion: { success, message in
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
            }
            .background(Color.gray.opacity(0.1).edgesIgnoringSafeArea(.all))
            .navigationBarBackButtonHidden(true)
            .navigationBarItems(leading: BackButton(action: { presentationMode.wrappedValue.dismiss() }), trailing: Image("threeDot"))
            .navigationDestination(isPresented: $isLoggedIn) {
                LoginScreen().navigationBarBackButtonHidden(true)
            }
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            // Configure Google Sign-In
            GIDSignIn.sharedInstance.restorePreviousSignIn { user, error in
                if let error = error {
                    print("Error restoring sign-in: \(error.localizedDescription)")
                } else if let user = user {
                    // Successfully signed in, handle user
                    print("Signed in with Google: \(user.profile?.name ?? "")")
                }
            }
        }
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
                print("Error signing up: \(error.localizedDescription)")
                isLoginInProgress = false
                return
            }
            
            guard let userId = authResult?.user.uid else {
                print("Failed to retrieve user ID")
                isLoginInProgress = false
                return
            }
            
            // Save user details to Firestore
            let db = Firestore.firestore()
            let userDocument: [String: Any] = [
                "email": email,
                "name": name,
                "createdAt": FieldValue.serverTimestamp()
            ]
            
            db.collection("users").document(userId).setData(userDocument) { error in
                if let error = error {
                    print("Error saving user to Firestore: \(error.localizedDescription)")
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
                    } else {
                        print("User and role saved successfully")
                        isLoggedIn = true
                    }
                    isLoginInProgress = false
                }
            }
        }
    }
}
