import SwiftUI
import FirebaseAuth

struct Ad_HomeScreen: View {
    @State private var shouldShowWelcomeScreen: Bool = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading) {
                    HStack{
                        Text("Home")
                            .font(.largeTitle)
                            .padding([.top, .leading])

                        Button(action: logOut) {
                            Text("Logout")
                                .font(.headline)
                                .padding()
                                .background(Color("Color"))
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
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
            }
            .navigationDestination(for: String.self) { destination in
                if destination == "WelcomeScreen" {
                    WelcomeScreen()
                }
            }
        }

        .tint(.black)
    }

    private func logOut() {
        do {
            try Auth.auth().signOut()
            print("Logged out.")
            UserDefaults.standard.set(false, forKey: "isLoggedInAdmin")

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

#Preview {
    Ad_HomeScreen()
}
