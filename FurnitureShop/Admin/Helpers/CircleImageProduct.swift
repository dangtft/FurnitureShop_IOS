//
//  CircleImageProduct.swift
//  FurnitureShop
//
//  Created by haidangnguyen on 23/12/24.
//

import SwiftUI

struct CircleImageProduct: View {
    var imageProductName: String
    
    var body: some View {
        AsyncImage(url: URL(string: imageProductName.isEmpty ? "https://i.pinimg.com/736x/d9/7b/bb/d97bbb08017ac2309307f0822e63d082.jpg" : imageProductName)) { phase in
            switch phase {
            case .empty:
                // Khi hình ảnh đang được tải
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                    .frame(width: 60, height: 60)
                    .background(Circle().fill(Color.gray.opacity(0.2)))
                    .clipShape(Circle())
            case .success(let image):
                // Khi hình ảnh đã được tải thành công
                image
                    .resizable()
                    .scaledToFill()
                    .clipShape(Circle())
                    .frame(width: 60, height: 60)
                    .overlay(Circle().stroke(lineWidth: 0.1))
                    .shadow(radius: 5)
            case .failure:
                // Khi có lỗi trong việc tải hình ảnh
                Image(systemName: "photo")
                    .resizable()
                    .scaledToFill()
                    .clipShape(Circle())
                    .frame(width: 60, height: 60)
                    .overlay(Circle().stroke(lineWidth: 0.1))
                    .shadow(radius: 5)
            @unknown default:
                EmptyView()
            }
        }
    }
}

