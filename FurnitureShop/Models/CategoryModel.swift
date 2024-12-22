import Foundation
import FirebaseFirestore

struct CategoryModel: Identifiable, Codable {
    @DocumentID var id: String?
    var name: String
    var image : String
    
    init(id: String? = nil, name: String, image: String) {
        self.id = id
        self.name = name
        self.image = image
    }
}
