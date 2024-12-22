import SwiftUI
import FirebaseFirestore

struct EditCategoryView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var category: CategoryModel
    @Binding var categories: [CategoryModel]
    
    @State private var editCategoryName = ""
    @State private var editCategoryImage = ""
    
    private let firestoreService = FirestoreService()
    
    var body: some View {
        VStack {
            Text("Edit Category")
                .font(.largeTitle)
                .padding()
            
            TextField("Category Name", text: $editCategoryName)
                .padding()
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            TextField("Image URL", text: $editCategoryImage)
                            .padding()
                            .textFieldStyle(RoundedBorderTextFieldStyle())
            
            Button(action: {
                saveCategoryChanges()
            }) {
                Text("Save Changes")
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .padding()
            
            Button(action: {
                dismiss()
            }) {
                Text("Cancel")
                    .padding()
                    .background(Color.gray)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .padding()
        }
        .onAppear {
            editCategoryName = category.name
            editCategoryImage = category.image
        }
        .padding()
    }
    
    private func saveCategoryChanges() {
        category.name = editCategoryName
        category.image = editCategoryImage
        
        firestoreService.updateCategory(category: category) { success, error in
            if let error = error {
                print("Error updating category: \(error.localizedDescription)")
            } else {
                if let index = categories.firstIndex(where: { $0.id == category.id }) {
                    categories[index] = category
                }
                dismiss()
            }
        }
    }
}
