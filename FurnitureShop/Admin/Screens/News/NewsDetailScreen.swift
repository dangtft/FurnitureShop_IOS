import SwiftUI
import FirebaseFirestore

struct NewsDetailScreen: View {
    var news: NewsModel
    @Binding var newsList: [NewsModel]
    @State private var newComment: String = ""
    
    private let firestoreService = FirestoreService()

    var body: some View {
        NavigationStack {
            VStack {
                Text(news.title)
                    .font(.title)
                    .padding()
                Text(news.detail)
                    .padding()
                
                List {
                    ForEach(news.comments ?? []) { comment in
                        VStack(alignment: .leading) {
                            Text(comment.userName)
                                .font(.headline)
                            
                            Text(comment.comment)
                                .font(.body)
                                .padding(.bottom, 5)
                            
                            Menu {
                                Button("Trả Lời") {
                                    // Implement reply functionality here
                                }
                                .padding()
                                
                                Button("Xóa Bình Luận") {
                                    deleteComment(comment)
                                }
                                .foregroundColor(.red)
                                .padding()
                            } label: {
                                Image(systemName: "ellipsis.circle")
                                    .foregroundColor(.gray)
                                    .imageScale(.large)
                            }
                        }
                    }
                }
                .listStyle(PlainListStyle())
                
                HStack {
                    TextField("Thêm bình luận", text: $newComment)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    Button("Gửi") {
                        let comment = CommentModel(id: UUID().uuidString, newsId: news.id ?? "", userId: "user123", userName: "User", comment: newComment, timestamp: Timestamp())
                        firestoreService.addComment(to: news.id ?? "", comment: comment) { result in
                            switch result {
                            case .success():
                                var updatedNews = news
                                updatedNews.comments?.append(comment)
                                if let index = newsList.firstIndex(where: { $0.id == news.id }) {
                                    newsList[index] = updatedNews
                                }
                                newComment = ""
                            case .failure(let error):
                                print("Error adding comment: \(error.localizedDescription)")
                            }
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Chi Tiết Tin Tức")
        }
    }
    
    private func deleteComment(_ comment: CommentModel) {
        firestoreService.deleteComment(from: news.id ?? "", commentId: comment.id!) { result in
            switch result {
            case .success():
                if let index = newsList.firstIndex(where: { $0.id == news.id }) {
                    var updatedNews = newsList[index]
                    updatedNews.comments?.removeAll { $0.id == comment.id }
                    newsList[index] = updatedNews
                }
            case .failure(let error):
                print("Error deleting comment: \(error.localizedDescription)")
            }
        }
    }
}