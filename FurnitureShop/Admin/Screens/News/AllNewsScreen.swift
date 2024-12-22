import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct AllNewsScreen: View {
    @State private var newsList: [NewsModel] = []
    @State private var showAddNewsSheet = false
    @State private var selectedNews: NewsModel?
    
    private var db = Firestore.firestore()

    var body: some View {
        NavigationStack {
            VStack {
                List {
                    ForEach(newsList) { news in
                        VStack(alignment: .leading) {
                            Text(news.title)
                                .font(.headline)
                            Text(news.author)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            Button("Xem Chi Tiết") {
                                selectedNews = news
                            }
                        }
                        .padding()
                    }
                    .onDelete(perform: deleteNews)
                }
                .listStyle(PlainListStyle())
                .navigationTitle("Tất Cả Tin Tức")
                .navigationBarItems(
                    leading: Button("Thêm Tin Tức") {
                        showAddNewsSheet.toggle()
                    },
                    trailing: EditButton()
                )
            }
            .sheet(isPresented: $showAddNewsSheet) {
                AddNewsScreen(newsList: $newsList)
            }
            .sheet(item: $selectedNews) { news in
                NewsDetailScreen(news: news, newsList: $newsList)
            }
            .onAppear {
                loadNewsFromFirebase()
            }
        }
    }
    
    private func loadNewsFromFirebase() {
        // Lấy dữ liệu tin tức từ Firestore
        db.collection("news")
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Error fetching news: \(error.localizedDescription)")
                    return
                }
                
                if let snapshot = snapshot {
                    newsList = snapshot.documents.compactMap { document in
       
                        let data = document.data()
                        let id = document.documentID
                        let title = data["title"] as? String ?? ""
                        let image = data["image"] as? String ?? ""
                        let detail = data["detail"] as? String ?? ""
                        let author = data["author"] as? String ?? ""
                        
                        let postTime = data["postTime"] as? Timestamp ?? Timestamp()
                        
                        let commentsData = data["comments"] as? [[String: Any]] ?? []
                        let comments = commentsData.compactMap { commentData -> CommentModel? in
                            guard let userId = commentData["userId"] as? String,
                                  let userName = commentData["userName"] as? String,
                                  let comment = commentData["comment"] as? String,
                                  let timestamp = commentData["timestamp"] as? Timestamp else {
                                return nil
                            }
                            return CommentModel(id: UUID().uuidString, newsId: id, userId: userId, userName: userName, comment: comment, timestamp: timestamp)
                        }
                        
                        return NewsModel(id: id, image: image, title: title, detail: detail, author: author, postTime: postTime, comments: comments)
                    }
                }
            }
    }

    private func deleteNews(at offsets: IndexSet) {
        // Xóa tin tức từ Firestore
        if let index = offsets.first {
            let news = newsList[index]
            db.collection("news").document(news.id!).delete { error in
                if let error = error {
                    print("Error deleting news: \(error.localizedDescription)")
                } else {
                    newsList.remove(atOffsets: offsets)
                }
            }
        }
    }
}

#Preview {
    AllNewsScreen()
}

