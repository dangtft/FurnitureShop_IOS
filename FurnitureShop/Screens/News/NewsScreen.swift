import Foundation
import SwiftUI
import FirebaseFirestore

struct NewsScreen: View {
    @State private var searchText = ""
    @State private var newsArticles: [NewsModel] = []
    private let db = Firestore.firestore()

    var body: some View {
        NavigationView {
            ZStack {
                Color(.systemGray6)
                    .ignoresSafeArea()

                VStack {
                    // Thanh tìm kiếm
                    SearchNews(search: $searchText)
                        .padding(.top)

                    // Hiển thị danh sách tin tức
                    if newsArticles.isEmpty {
                        Text("No news available")
                            .font(.headline)
                            .foregroundColor(.gray)
                            .padding()
                    } else {
                        ScrollView {
                            LazyVGrid(columns: [
                                GridItem(.flexible(), spacing: 10),
                                GridItem(.flexible(), spacing: 10)
                            ], spacing: 10) {
                                ForEach(newsArticles) { article in
                                    NavigationLink(destination: DetailNewsScreen(newsArticle: article)) {
                                        NewsRow(newsArticle: article)
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                }
                .navigationTitle("News")
                .onAppear {
                    fetchNews()
                }
            }
        }
    }

    func fetchNews() {
        db.collection("news")
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Error fetching news: \(error.localizedDescription)")
                    return
                }
                
                if let snapshot = snapshot {
                    newsArticles = snapshot.documents.compactMap { document in
       
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

    func fetchComments(for newsId: String, completion: @escaping ([CommentModel]) -> Void) {
        db.collection("comments")
            .whereField("newsId", isEqualTo: newsId)
            .order(by: "timestamp", descending: false)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Error fetching comments for newsId \(newsId): \(error)")
                    completion([])
                    return
                }

                if let snapshot = snapshot {
                    let comments = snapshot.documents.compactMap { document -> CommentModel? in
                        try? document.data(as: CommentModel.self)
                    }
                    completion(comments)
                }
            }
    }
}

struct NewsRow: View {
    var newsArticle: NewsModel

    var body: some View {
        HStack(alignment: .top, spacing: 15) {
            AsyncImage(url: URL(string: newsArticle.image)) { image in
                image.resizable()
                     .scaledToFill()
                     .frame(width: 180, height: 120)
                     .clipShape(RoundedRectangle(cornerRadius: 10))
                     .shadow(radius: 5)
            } placeholder: {
                ProgressView()
                    .frame(width: 180, height: 120)
            }

            Text(newsArticle.title)
                .font(.headline)
                .lineLimit(2)
                .foregroundColor(.black)
                .padding(.top, 5)

            Text("By \(newsArticle.author)")
                .font(.subheadline)
                .foregroundColor(.gray)
                .padding(.top, 2)

            Text(formatTimestamp(newsArticle.postTime))
                .font(.footnote)
                .foregroundColor(.gray)
                .padding(.top, 2)
        }
        .padding(.bottom, 10)
    }

    func formatTimestamp(_ timestamp: Timestamp) -> String {
        let date = timestamp.dateValue()
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

struct SearchNews: View {
    @Binding var search: String

    var body: some View {
        HStack {
            HStack {
                Image("Search")
                    .padding(.trailing, 8)
                TextField("Search news", text: $search)
                    .onChange(of: search) { _ in
                        
                    }
            }
            .padding(.all, 20)
            .background(Color.white)
            .cornerRadius(10.0)
            .padding(.trailing, 8)

            Button(action: {}) {
                Image("icon-search")
                    .padding()
                    .background(Color("Color"))
                    .cornerRadius(10.0)
            }
        }
        .padding(.horizontal)
    }
}

#Preview {
    NewsScreen()
}
