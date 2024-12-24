import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct AllNewsScreen: View {
    @State private var newsList: [NewsModel] = []
    @State private var showAddNewsSheet = false
    @State private var selectedNews: NewsModel?
    @State private var showEditNewsSheet = false
    
    private var db = Firestore.firestore()
    private let firestoreService = FirestoreService()
    
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
                            
                            // Menu with options for each news item
                            Menu {
                                // Button for viewing details
                                Button(action: {
                                    selectedNews = news
                                }) {
                                    Label("Chi Tiết", systemImage: "info.circle")
                                }
                                
                                // Button for editing the news
                                Button(action: {
                                    selectedNews = news
                                    showEditNewsSheet.toggle()
                                }) {
                                    Label("Sửa", systemImage: "pencil")
                                }
                                
                                // Button for deleting the news
                                Button(role: .destructive, action: {
                                    deleteNews(news)
                                }) {
                                    Label("Xóa", systemImage: "trash")
                                }
                            } label: {
                                Image(systemName: "ellipsis.circle")
                                    .font(.title)
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding()
                    }
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
            .sheet(isPresented: $showEditNewsSheet) {
                if let news = selectedNews {
                    // Show EditNewsScreen if a news item is selected
                    EditNewsScreen(news: Binding(get: {
                        news
                    }, set: { newNews in
                        if let index = newsList.firstIndex(where: { $0.id == news.id }) {
                            newsList[index] = newNews
                        }
                        selectedNews = newNews
                    }), newsList: $newsList)
                }
            }
            .sheet(item: $selectedNews) { news in
                NewsDetailScreen(news: news, newsList: $newsList)
            }
            .onAppear {
                loadNewsFromFirebase()
            }
        }
    }
    
    // Tải tin tức từ Firebase
    func loadNewsFromFirebase() {
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
    
    // Xóa tin tức từ Firebase
    private func deleteNews(_ news: NewsModel) {
        guard let newsId = news.id else { return }
        firestoreService.deleteNews(newsId: newsId) { success in
            if success {
                if let index = newsList.firstIndex(where: { $0.id == newsId }) {
                    newsList.remove(at: index)
                }
            } else {
                print("Error deleting news from Firestore.")
            }
        }
    }
}

struct AllNewsScreen_Preview: PreviewProvider {
    static var previews: some View {
        AllNewsScreen()
    }
}
