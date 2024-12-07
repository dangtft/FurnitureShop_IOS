import Foundation

struct CategoryModel: Identifiable,Hashable, Decodable {
    var id: Int
    var name: String
}

//var categories = [
//    CategoryModel(id: 0, name: "All", imageName: "all"),
//    CategoryModel(id: 1, name: "Chair", imageName: "chair"),
//    CategoryModel(id: 2, name: "Sofa", imageName: "sofa"),
//    CategoryModel(id: 3, name: "Lamp", imageName: "lamp"),
//    CategoryModel(id: 4, name: "Kitchen", imageName: "kitchen"),
//    CategoryModel(id: 5, name: "Table", imageName: "table")
//]
