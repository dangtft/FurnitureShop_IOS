//
//  ContentView.swift
//  FurnitureShop
//
//  Created by Đăng Nguyễn on 18/11/24.
//

import SwiftUI
import FirebaseAuth

struct ContentView: View {
    @AppStorage("isLoggedIn") private var isLoggedIn: Bool = false
    @StateObject var cartManager = CartManager()

    var body: some View {
        Group {
            if isLoggedIn {
                HomeScreen()
                    
            } else {
                WelcomeScreen()
                    .environmentObject(cartManager)
            }
        }
        .onAppear {
            checkLoginStatus()
        }
    }

    private func checkLoginStatus() {
        // Kiểm tra nếu người dùng đã đăng nhập trước đó
        if Auth.auth().currentUser != nil {
            isLoggedIn = true
        } else {
            isLoggedIn = false
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(CartManager())
    }
}
