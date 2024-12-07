//
//  ContentView.swift
//  FurnitureShop
//
//  Created by Đăng Nguyễn on 18/11/24.
//

import SwiftUI

struct ContentView: View {
    @StateObject var cartManager = CartManager()
    var body: some View {
        WelcomeScreen()
            .environmentObject(cartManager)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(CartManager())
    }
}
