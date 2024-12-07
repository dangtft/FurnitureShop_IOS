import SwiftUI
import GoogleSignIn
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth

struct SignInScreen: View {
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
                Text("Sign In")
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
                        signUpAndSaveUserToFirestore(email: email, password: password, name: name, address: "", phoneNumber: "", image: "")
                    } else {
                        print("Passwords do not match")
                    }
                }) {
                    Text("Sign In")
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
}






struct SignInScreen_Previews: PreviewProvider {
    static var previews: some View {
        SignInScreen()
    }
}
