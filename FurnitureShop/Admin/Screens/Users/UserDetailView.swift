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
            Text("Chi tiết người dùng")
                .font(.largeTitle)
                .padding(.top)
            
            HStack {
                Text("Tên:")
                    .font(.headline)
                Text(user.name)
            }
            
            HStack {
                Text("Email:")
                    .font(.headline)
                Text(user.email)
            }
            
            HStack {
                Text("Địa chỉ:")
                    .font(.headline)
                Text(user.address!)
            }
            
            HStack {
                Text("Số điện thoại:")
                    .font(.headline)
                Text(user.phoneNumber!)
            }
            
            Spacer()
        }
        .padding()
    }
}


#Preview {
    UserDetailView(user: UserModel(id: "1",
                                   name: "John Doe",
                                   image: "Users",
                                   email: "john.doe@example.com",
                                   password: "password123",
                                   address: "123 Main Street",
                                   phoneNumber: "123-456-7890"))
}
