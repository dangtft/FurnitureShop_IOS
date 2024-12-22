import SwiftUI
import FirebaseFirestore

struct AddCategoryView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var categories: [CategoryModel]
    @State private var newCategoryName = ""
    @State private var newCategoryImage = ""
    
    private let firestoreService = FirestoreService()
    
    var body: some View {
        VStack {
            Text("Add New Category")
                .font(.largeTitle)
                .padding()
            
            TextField("Category Name", text: $newCategoryName)
                .padding()
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            TextField("Image URL", text: $newCategoryImage)
                            .padding()
                            .textFieldStyle(RoundedBorderTextFieldStyle())
            
            Button(action: {
                addCategory()
            }) {
                Text("Add Category")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .padding()
            
            Button("Cancel") {
                dismiss()
            }
            .padding()
        }
        .padding()
    }
    
    func addCategory() {
        guard !newCategoryName.isEmpty else {
            print("Category name is required")
            return
        }

        let newCategory = CategoryModel(name: newCategoryName, image: newCategoryImage)
        
        firestoreService.addCategory(category: newCategory) { success, error in
            if let error = error {
                print("Error adding category: \(error.localizedDescription)")
            } else {
                categories.append(newCategory)
                newCategoryName = ""
                newCategoryImage = ""
                dismiss()
            }
        }
    }
}
