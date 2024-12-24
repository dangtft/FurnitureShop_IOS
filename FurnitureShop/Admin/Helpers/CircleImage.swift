import SwiftUI

struct CircleImage: View {
    var imageName: String
    var title: String
    var borderColor: Color
    
    var body: some View {
        VStack {
            Image(imageName)
                .resizable()
                .frame(width: 35, height: 35)
                .scaledToFit()
                .frame(width: 50, height: 50)
                .clipShape(Circle())
                .padding(15)
                .background(
                    Circle()
                        .fill(Color.white)
                )
                .overlay(
                    Circle()
                        .stroke(borderColor, lineWidth: 2)
                )
                .padding(4)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.black)
        }
    }
}

struct CircleImageList: View {
    let items: [(imageName: String, title: String, borderColor: Color, destination: AnyView)] = [
        ("Analytic", "Analytics", .blue, AnyView(AnalyticsView())),
        ("Users", "Customers", .green, AnyView(CustomerView())),
        ("Orders", "Orders", .orange, AnyView(AllOrdersView())),
        ("Message", "Message", .red, AnyView(MessageView())),
        ("Products", "Products", .yellow, AnyView(AllProductView())),
        ("Categories", "Categories", .gray, AnyView(AllCategoryView())),
        ("news", "News", .gray, AnyView(AllNewsScreen()))
    ]
    
    var body: some View {
        NavigationStack {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 20) {
                    ForEach(items, id: \.title) { item in
                        NavigationLink(destination: item.destination) {
                            CircleImage(
                                imageName: item.imageName,
                                title: item.title,
                                borderColor: item.borderColor
                            )
                        }
                    }
                }
                .padding()
            }
        }
        .tint(.black)
    }
}

#Preview {
    CircleImageList()
}
