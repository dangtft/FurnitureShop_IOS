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
                        .padding(.vertical)

                    // Hiển thị danh sách tin tức
                    if newsArticles.isEmpty {
                        Text("No news available")
                            .font(.headline)
                            .foregroundColor(.gray)
                            .padding()
                    } else {
                        ScrollView {
                            LazyVGrid(columns: [
                                GridItem(.flexible(), spacing: 15),
                                GridItem(.flexible(), spacing: 15)
                            ], spacing: 15) {
                                ForEach(newsArticles) { article in
                                    NavigationLink(destination: DetailNewsScreen(newsArticle: article)) {
                                        NewsRow(newsArticle: article)
                                            .background(Color.white)
                                            .cornerRadius(10)
                                            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 5)
                                    }
                                }
                            }
                            .padding()
                        }
                    }
                }
                .navigationTitle("Latest News")
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
}

struct NewsRow: View {
    var newsArticle: NewsModel

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            AsyncImage(url: URL(string: newsArticle.image)) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                        .frame(width: 150, height: 120)
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(width: 150, height: 120)
                        .cornerRadius(10)
                        .clipped()
                case .failure:
                    Image(systemName: "photo")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 120)
                        .foregroundColor(.gray)
                @unknown default:
                    EmptyView()
                }
            }

            Text(newsArticle.title)
                .font(.headline)
                .foregroundColor(.black)
                .lineLimit(2)

            Text("By \(newsArticle.author)")
                .font(.subheadline)
                .foregroundColor(.gray)

            Text(formatTimestamp(newsArticle.postTime))
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding()
    }

    func formatTimestamp(_ timestamp: Timestamp) -> String {
        let date = timestamp.dateValue()
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
}

struct SearchNews: View {
    @Binding var search: String

    var body: some View {
        HStack {
            TextField("Search news", text: $search)
                .padding(10)
                .background(Color.white)
                .cornerRadius(10)
                .shadow(radius: 2)

            Button(action: {
                print("Searching for \(search)")
            }) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
            }
        }
        .padding(.horizontal)
    }
}

#Preview {
    NewsScreen()
}
