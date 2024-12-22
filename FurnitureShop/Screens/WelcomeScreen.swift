import SwiftUI

struct WelcomeScreen: View {
    var body: some View {
        NavigationStack{
            ZStack {
                // Hình nền
                Image("welcom")
                    .resizable()
                    .scaledToFill()
                    .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                    .clipped()
                    .ignoresSafeArea()
                
                VStack {
                    Spacer()
                    Text("WELCOME")
                        .font(.system(size: 60))
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Spacer()
                    Text("Finding the Perfect \nFurniture for Your Home")
                        .font(.system(size: 40))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                    
                    Spacer()
                    NavigationLink(destination: LoginScreen().navigationBarBackButtonHidden(true)) {
                        Text("Get Started")
                            .font(.title)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity,maxHeight: 70)
                            .background(Color("Color"))
                            .cornerRadius(30)
                            .padding(.horizontal, 50)
                    }
                    Spacer()
                }
            }
        }
    }
}

#Preview {
    WelcomeScreen()
}
