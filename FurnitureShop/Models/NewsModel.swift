import FirebaseFirestore

struct NewsModel: Identifiable, Codable {
    @DocumentID var id: String?
    var image: String
    var title: String
    var detail: String
    var author: String
    var postTime: Timestamp
    var comments: [CommentModel]?

}


