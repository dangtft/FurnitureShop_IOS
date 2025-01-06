import SwiftUI
import FirebaseFirestore

struct EditNewsScreen: View {
    @Binding var news: NewsModel
    @Binding var newsList: [NewsModel]
    @State private var title: String
    @State private var detail: String
    @State private var image: String

    private let firestoreService = FirestoreService()

    init(news: Binding<NewsModel>, newsList: Binding<[NewsModel]>) {
        self._news = news
        self._newsList = newsList
        self._title = State(initialValue: news.wrappedValue.title)
        self._detail = State(initialValue: news.wrappedValue.detail)
        self._image = State(initialValue: news.wrappedValue.image)
    }

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading) {
                Text("Edit news")
                    .font(.title)
                    .padding(.bottom, 20)

                TextField("Title", text: $title)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.bottom, 10)

                TextField("Link Image", text: $image)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.bottom, 10)

                TextEditor(text: $detail)
                    .frame(height: 200)
                    .border(Color.gray, width: 1)
                    .cornerRadius(5)
                    .padding(.bottom, 20)

                HStack {
                    Spacer()
                    Button(action: saveChanges) {
                        Text("Save change")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .foregroundColor(.white)
                            .background(Color.blue)
                            .cornerRadius(8)
                    }
                    Spacer()
                }
                .padding(.top, 20)

                Spacer()
            }
            .padding()
            .navigationTitle("Edit news")
        }
    }

    private func saveChanges() {
        guard let newsId = news.id else { return }

        let updatedNews = NewsModel(
            id: newsId,
            image: image,
            title: title,
            detail: detail,
            author: news.author,
            postTime: news.postTime,
            comments: news.comments
        )

        firestoreService.updateNews(newsId: newsId, updatedNews: updatedNews) { result in
            switch result {
            case .success():
                if let index = newsList.firstIndex(where: { $0.id == news.id }) {
                    newsList[index] = updatedNews
                }
                news = updatedNews
                print("News updated successfully!")
            case .failure(let error):
                print("Error updating news: \(error.localizedDescription)")
            }
        }
    }
}
