import Foundation
import SwiftUI
import FirebaseFirestore

struct NewsScreen: View {
    @State private var searchText = ""
    @State private var newsArticles: [NewsModel] = []
    private let db = Firestore.firestore()

    init(newsArticles: [NewsModel] = []) {
        _newsArticles = State(initialValue: newsArticles)
    }

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
                    SearchNews(search: $searchText)
                        .padding(.top)
                    
                    List(filteredArticles) { article in
                        NavigationLink(destination: DetailNewsScreen(newsArticle: article)) {
                            NewsRow(newsArticle: article)
                        }
                    }
                    .listStyle(PlainListStyle())
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
                    print("Error fetching news: \(error.localizedDescription)")
                } else {
                    if let snapshot = snapshot {
                        do {
                            newsArticles = try snapshot.documents.map { document in
                                try document.data(as: NewsModel.self)
                            }
                        } catch {
                            print("Error decoding news: \(error)")
                        }
                    }
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
    let sampleArticles = [
        NewsModel(
            id: "1",
            image: "https://i.pinimg.com/736x/fe/a4/bc/fea4bc6cf91b5868621b176e457f51d8.jpg",
            title: "Breaking News 1",
            detail: "This is a detailed description of breaking news 1.",
            author: "Author 1",
            postTime: Timestamp(date: Date())
        ),
        NewsModel(
            id: "2",
            image: "https://i.pinimg.com/736x/1a/5c/92/1a5c921f7e13fc10409a64db166f542c.jpg",
            title: "Breaking News 2",
            detail: "This is a detailed description of breaking news 2.",
            author: "Author 2",
            postTime: Timestamp(date: Date().addingTimeInterval(-3600))
        )
    ]

    return NewsScreen(newsArticles: sampleArticles)
}


