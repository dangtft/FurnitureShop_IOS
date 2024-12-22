import SwiftUI

struct CategoryDetailView: View {
    var category: CategoryModel
    
    var body: some View {
        VStack {
            Text(category.name)
                .font(.largeTitle)

            if let url = URL(string: category.image) {
                AsyncImage(url: url) { image in
                    image.resizable()
                        .scaledToFit()
                        .frame(height: 200)
                } placeholder: {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                }
            }
            
            Spacer()
        }
        .padding()
    }
}
