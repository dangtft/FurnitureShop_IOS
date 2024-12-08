import Foundation
import SwiftUI
import FirebaseFirestore

struct NewsScreen: View {
    @State private var searchText = ""
    @State private var newsArticles: [NewsModel] = []
    private let db = Firestore.firestore()

    var filteredArticles: [NewsModel] {
        if searchText.isEmpty {
            return newsArticles
        } else {
            return newsArticles.filter { $0.title.lowercased().contains(searchText.lowercased()) }
        }
    }

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
                    if filteredArticles.isEmpty {
                        Text("No news available")
                            .font(.headline)
                            .foregroundColor(.gray)
                            .padding()
                    } else {
                        List(filteredArticles) { article in
                            NavigationLink(destination: DetailNewsScreen(newsArticle: article)) {
                                NewsRow(newsArticle: article)
                            }
                        }
                        .listStyle(PlainListStyle())
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
            .order(by: "postTime", descending: true)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Error fetching news: \(error)")
                } else if let snapshot = snapshot {
                    var fetchedArticles: [NewsModel] = []

                    for document in snapshot.documents {
                        if let news = try? document.data(as: NewsModel.self) {
                            fetchedArticles.append(news)
                        }
                    }

                    DispatchQueue.main.async {
                        self.newsArticles = fetchedArticles
                    }
                }
            }
    }

    // Hàm tải bình luận cho từng bài viết (nếu cần)
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
                     .frame(width: 80, height: 80)
                     .clipShape(Circle())
                     .shadow(radius: 5)
            } placeholder: {
                ProgressView()
                    .frame(width: 80, height: 80)
            }
            
            VStack(alignment: .leading, spacing: 5) {
                Text(newsArticle.title)
                    .font(.headline)
                    .foregroundColor(.black)
                    .lineLimit(2)
                
                Text("By \(newsArticle.author)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                Text(formatTimestamp(newsArticle.postTime))
                    .font(.footnote)
                    .foregroundColor(.gray)
            }
        }
        .padding(.vertical, 8)
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
                    .onChange(of: search) {
                       
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
    
}


