import Foundation
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth
import GoogleSignIn

struct UserModel: Identifiable, Codable {
    @DocumentID var id: String?
    var name: String
    var image : String?
    var email: String
    var password: String?
    var address: String?
    var phoneNumber: String?
}

func signUpAndSaveUserToFirestore(email: String, password: String, name: String, address: String? = nil, phoneNumber: String? = nil, image: String? = nil) {
    // Đăng ký người dùng với Firebase Authentication
    Auth.auth().createUser(withEmail: email, password: password) { result, error in
        if let error = error {
            print("Registration sussessful: \(error.localizedDescription)")
            return
        }
        
        // Sau khi đăng ký thành công, lưu thông tin người dùng vào Firestore
        guard let userId = result?.user.uid else { return }
        
        // Tạo đối tượng UserModel với thông tin người dùng
        let userModel = UserModel(
            id: userId,
            name: name,
            image: image,
            email: email,
            password: password,
            address: address,
            phoneNumber: phoneNumber
        )
        
        let db = Firestore.firestore()
        // Lưu thông tin người dùng vào Firestore
        db.collection("users").document(userId).setData([
            "id": userModel.id ?? "",
            "name": userModel.name,
            "image": userModel.image ?? "Null",
            "email": userModel.email,
            "password": userModel.password ?? "Null",
            "address": userModel.address ?? "Null",
            "phoneNumber": userModel.phoneNumber ?? "Null"
        ]) { error in
            if let error = error {
                print("Error saving user data: \(error.localizedDescription)")
            } else {
                print("User data saving sussessfully!")
            }
        }
    }
}

func updateUserInformation(userId: String, name: String? = nil, image: String? = nil, address: String? = nil, phoneNumber: String? = nil, completion: @escaping (Bool, String?) -> Void) {
    let db = Firestore.firestore()
    var updateData: [String: Any] = [:]
    
    if let name = name {
        updateData["name"] = name
    }
    if let image = image {
        updateData["image"] = image
    }
    if let address = address {
        updateData["address"] = address
    }
    if let phoneNumber = phoneNumber {
        updateData["phoneNumber"] = phoneNumber
    }
    
    // Nếu không có gì để cập nhật, thoát hàm
    guard !updateData.isEmpty else {
        completion(false, "No fields to update.")
        return
    }
    
    // Cập nhật tài liệu của người dùng trong Firestore
    db.collection("users").document(userId).updateData(updateData) { error in
        if let error = error {
            completion(false, "Error updating user data: \(error.localizedDescription)")
        } else {
            completion(true, nil)
        }
    }
}

// Đăng xuất
func signOut(completion: @escaping (Bool, String?) -> Void) {
    do {
        try Auth.auth().signOut()
        completion(true, nil)
    } catch let error {
        completion(false, "Error signing out: \(error.localizedDescription)")
    }
}

func signUpWithGoogle(from viewController: UIViewController, completion: @escaping (Bool, String?) -> Void) {
    guard let clientID = FirebaseApp.app()?.options.clientID else {
        completion(false, "Firebase ClientID not found.")
        return
    }

    // Tạo cấu hình Google Sign-In
    let config = GIDConfiguration(clientID: clientID)
    GIDSignIn.sharedInstance.configuration = config

    // Bắt đầu quy trình đăng nhập!
    GIDSignIn.sharedInstance.signIn(withPresenting: viewController) { result, error in
        // Kiểm tra lỗi đăng nhập
        guard error == nil else {
            completion(false, "Google Sign-In failed: \(error!.localizedDescription)")
            return
        }

        guard let user = result?.user,
              let idToken = user.idToken?.tokenString else {
            completion(false, "Failed to get user information.")
            return
        }

        // Tạo credential từ Google
        let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                       accessToken: user.accessToken.tokenString)

        // Đăng nhập Firebase
        Auth.auth().signIn(with: credential) { authResult, error in
            if let error = error {
                completion(false, "Firebase Sign-In failed: \(error.localizedDescription)")
                return
            }

            // Lưu thông tin người dùng vào Firestore
            guard let userId = authResult?.user.uid else {
                completion(false, "User ID not found.")
                return
            }

            let userModel = UserModel(
                id: userId,
                name: user.profile?.name ?? "",
                image: user.profile?.imageURL(withDimension: 200)?.absoluteString ?? "",
                email: user.profile?.email ?? "",
                password: "", 
                address: "",
                phoneNumber: ""
            )

            let db = Firestore.firestore()
            db.collection("users").document(userId).setData([
                "id": userModel.id as Any,
                "name": userModel.name,
                "image": userModel.image as Any,
                "email": userModel.email,
                "address": userModel.address as Any,
                "phoneNumber": userModel.phoneNumber as Any
            ]) { error in
                if let error = error {
                    completion(false, "Error saving user data to Firestore: \(error.localizedDescription)")
                } else {
                    completion(true, nil)  
                }
            }
        }
    }
}

func signInWithGoogle(from viewController: UIViewController, completion: @escaping (Bool, String?) -> Void) {
    guard let clientID = FirebaseApp.app()?.options.clientID else {
        completion(false, "Firebase ClientID not found.")
        return
    }

    // Tạo cấu hình Google Sign-In
    let config = GIDConfiguration(clientID: clientID)
    GIDSignIn.sharedInstance.configuration = config

    // Bắt đầu quy trình đăng nhập!
    GIDSignIn.sharedInstance.signIn(withPresenting: viewController) { result, error in
        guard error == nil else {
            completion(false, "Google Sign-In failed: \(error!.localizedDescription)")
            return
        }

        guard let user = result?.user, let idToken = user.idToken?.tokenString else {
            completion(false, "Failed to get user information.")
            return
        }

        // Tạo credential từ Google
        let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: user.accessToken.tokenString)

        // Đăng nhập Firebase
        Auth.auth().signIn(with: credential) { authResult, error in
            if let error = error {
                completion(false, "Firebase Sign-In failed: \(error.localizedDescription)")
                return
            }

            // Kiểm tra thông tin người dùng và đăng nhập thành công
            completion(true, nil)
        }
    }
}


// Kiểm tra nếu người dùng hiện tại đã đăng nhập
func checkIfUserLoggedIn() -> Bool {
    return Auth.auth().currentUser != nil
}

// Lấy thông tin người dùng hiện tại
func getCurrentUserInfo() -> UserModel? {
    guard let user = Auth.auth().currentUser else { return nil }

    let userModel = UserModel(
        id: user.uid,
        name: user.displayName ?? "",
        image: user.photoURL?.absoluteString ?? "",
        email: user.email ?? "",
        password: "",
        address: "",
        phoneNumber: user.phoneNumber ?? ""
    )
    return userModel
}

func getRootViewController() -> UIViewController {
    if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
        if let window = scene.windows.first {
            return window.rootViewController!
        }
    }
    return UIViewController()
}

