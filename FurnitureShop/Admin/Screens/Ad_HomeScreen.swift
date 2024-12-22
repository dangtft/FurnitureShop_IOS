import SwiftUI
import FirebaseAuth

struct Ad_HomeScreen: View {

    @State private var isLoggedOut = false
    @Environment(\.presentationMode) private var presentationMode
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading) {
                    Text("Home")
                        .font(.largeTitle)
                        .padding([.top, .leading])
                    
                    Button(action: logOut) {
                        Text("Đăng xuất")
                            .font(.headline)
                            .padding()
                            .background(Color("Color"))
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    
                    Divider()
                    
                    HStack {
                        CircleImageList()
                    }
                    
                    Divider()
                    
                    HStack {
                        Text("Overview")
                            .font(.largeTitle)
                        
                        Spacer()
                        
                        HStack {
                            Text("Today")
                        }
                    }
                    .padding()
                    
                    Divider()
                    
                    BarChartView()
                        .padding(.horizontal)
                    
                    RecentOrdersView()
                }
                .padding(.bottom)
                
                .navigationDestination(isPresented: $isLoggedOut) {
                    WelcomeScreen()
                }
            }
        }
        .tint(.black)
    }

    private func logOut() {
        do {
            try FirebaseAuth.Auth.auth().signOut()
            isLoggedOut = true
            // Đóng tất cả màn hình trước đó khi đăng xuất
            presentationMode.wrappedValue.dismiss()
        } catch {
            print("Error during logout: \(error.localizedDescription)")
        }
    }
}
