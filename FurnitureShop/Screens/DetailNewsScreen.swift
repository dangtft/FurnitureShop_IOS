import SwiftUI
import FirebaseCore
import FirebaseAuth

struct DetailNewsScreen: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    var newsArticle: NewsModel
    @State private var userId: String = ""
    @State private var navigateToComments = false

    var body: some View {
        NavigationView {
            ZStack {
                Color("Bg").edgesIgnoringSafeArea(.all)

                ScrollView {
                    AsyncImage(url: URL(string: newsArticle.image)) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                                .frame(maxWidth: .infinity, maxHeight: 300)
                                .background(Color.gray.opacity(0.2))
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFit()
                                .frame(maxWidth: .infinity)
                                .edgesIgnoringSafeArea(.top)
                        case .failure:
                            Image(systemName: "photo")
                                .resizable()
                                .scaledToFit()
                                .foregroundColor(.gray)
                                .frame(maxWidth: .infinity, maxHeight: 300)
                                .background(Color.gray.opacity(0.2))
                        @unknown default:
                            EmptyView()
                        }
                    }

                    // Nội dung bài viết
                    DescriptionNewsView(newsArticle: newsArticle)
                }
                .edgesIgnoringSafeArea(.top)

                HStack {
                    Spacer()
                    Button(action: {
                        navigateToComments = true
                    }) {
                        Text("Comments")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(Color("Color"))
                            .padding()
                            .padding(.horizontal, 8)
                            .background(Color.white)
                            .cornerRadius(10.0)
                    }
                }
                .padding()
                .padding(.horizontal)
                .background(Color("Color"))
                .cornerRadius(60.0, corners: .topLeft)
                .frame(maxHeight: .infinity, alignment: .bottom)
                .edgesIgnoringSafeArea(.bottom)
            }
            .navigationBarBackButtonHidden(true)
            .navigationBarItems(
                leading: BackButton(action: { presentationMode.wrappedValue.dismiss() }),
                trailing: Image("threeDot")
            )
            .navigationDestination(isPresented: $navigateToComments) {
                //CommentsScreen(newsId: newsArticle.id)
            }
            .onAppear {
                if let currentUser = Auth.auth().currentUser {
                    self.userId = currentUser.uid
                } else {
                    print("No user is signed in")
                }
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}

struct DescriptionNewsView: View {
    var newsArticle: NewsModel

    var body: some View {
        VStack(alignment: .leading) {
            Text(newsArticle.title)
                .font(.title)
                .fontWeight(.bold)

            Text("By \(newsArticle.author)")
                .font(.subheadline)
                .foregroundColor(.gray)

            // Định dạng và hiển thị thời gian
            Text(formatTimestamp(newsArticle.postTime))
                .font(.footnote)
                .foregroundColor(.gray)

            Divider()

            Text(newsArticle.detail)
                .font(.body)
                .foregroundColor(.black)
                .lineSpacing(8.0)
        }
        .padding()
        .padding(.top)
        .background(Color("Bg"))
        .cornerRadius(30, corners: [.topLeft, .topRight])
        .offset(x: 0, y: -30.0)
    }

    // Hàm định dạng Timestamp
    func formatTimestamp(_ timestamp: Timestamp) -> String {
        let date = timestamp.dateValue()
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

#Preview {
    DetailNewsScreen(newsArticle: NewsModel(
        id: "1",
        image: "https://i.pinimg.com/736x/fe/a4/bc/fea4bc6cf91b5868621b176e457f51d8.jpg",
        title: "Sample News",
        detail: "This is a detailed description of the news article.",
        author: "John Doe",
        postTime: Timestamp(date: Date().addingTimeInterval(-3600)) 
    ))
}

