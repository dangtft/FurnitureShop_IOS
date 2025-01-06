//
//  UserDetailView.swift
//  Admin_DasboardUI
//
//  Created by haidangnguyen on 19/12/24.
//

import SwiftUI

struct UserDetailView: View {
    let user: UserModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("User detail")
                .font(.largeTitle)
                .padding(.top)
            
            HStack {
                Text("Name:")
                    .font(.headline)
                Text(user.name)
            }
            
            HStack {
                Text("Email:")
                    .font(.headline)
                Text(user.email)
            }
            
            HStack {
                Text("Address:")
                    .font(.headline)
                Text(user.address!)
            }
            
            HStack {
                Text("Phone:")
                    .font(.headline)
                Text(user.phoneNumber!)
            }
            
            Spacer()
        }
        .padding()
    }
}
