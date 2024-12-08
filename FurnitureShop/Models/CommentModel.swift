import Foundation
import FirebaseFirestore

struct CommentModel: Identifiable, Codable {
    @DocumentID var id: String?
    var newsId: String
    var userId: String
    var userName : String
    var comment: String
    var timestamp: Timestamp

    func toDictionary() -> [String: Any] {
        return [
            "newsId": newsId,
            "userId": userId,
            "userName" : userName,
            "comment": comment,
            "timestamp": timestamp
        ]
    }
}
