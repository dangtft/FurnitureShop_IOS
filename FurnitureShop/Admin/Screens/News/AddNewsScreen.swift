import SwiftUI
import FirebaseCore

struct AddNewsScreen: View {
    @Environment(\.dismiss) var dismiss
    @Binding var newsList: [NewsModel]
    @State private var title: String = ""
    @State private var author: String = ""
    @State private var detail: String = ""
    
    private let firestoreService = FirestoreService()

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("News information")) {
                    TextField("Title", text: $title)
                    TextField("Author", text: $author)
                    TextField("Detail", text: $detail)
                }
                
                Button("Save") {
                    let newNews = NewsModel(id: UUID().uuidString, image: "", title: title, detail: detail, author: author, postTime: Timestamp(), comments: [])
                    
                    firestoreService.addNews(news: newNews) { result in
                        switch result {
                        case .success():
                            newsList.append(newNews)
                            title = ""
                            author = ""
                            detail = ""
                            dismiss()
                        case .failure(let error):
                            print("Error adding news: \(error.localizedDescription)")
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Add news")
            .navigationBarItems(trailing: Button("Cancel") {
                dismiss()
            })
        }
    }
}
