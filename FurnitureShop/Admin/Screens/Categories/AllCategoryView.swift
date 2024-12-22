import SwiftUI
import FirebaseFirestore

struct AllCategoryView: View {
    @State private var categories: [CategoryModel] = []
    @State private var newCategoryName = ""
    @State private var editCategoryName = ""
    @State private var isEditing = false
    @State private var selectedCategory: CategoryModel?
    @State private var showAddCategoryView = false
    @State private var showEditCategoryView = false
    @State private var showDetailView = false
    
    private let firestoreService = FirestoreService()
    
    var body: some View {
        VStack {
            Text("All Categories")
                .font(.largeTitle)
                .padding()

            HStack {
                Button(action: {
                    showAddCategoryView.toggle()
                }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title)
                        .foregroundColor(.blue)
                }
                .padding()
            }
            .padding(.horizontal)
            
            List(categories) { category in
                HStack {
                    // Hiển thị hình ảnh danh mục nếu có
                    if let url = URL(string: category.image) {
                        AsyncImage(url: url) { phase in
                            switch phase {
                            case .empty:
                                ProgressView()
                                    .frame(width: 50, height: 50)
                            case .success(let image):
                                image.resizable()
                                     .scaledToFill()
                                     .frame(width: 50, height: 50)
                                     .clipShape(Circle())
                            case .failure:
                                Image(systemName: "heart") 
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 50, height: 50)
                                    .clipShape(Circle())
                            @unknown default:
                                EmptyView()
                            }
                        }
                    }
                    
                    Text(category.name)
                        .font(.headline)
                    
                    Spacer()
                    
                    Menu {
                        Button(action: {
                            selectedCategory = category
                            showDetailView.toggle()
                        }) {
                            Label("Chi tiết", systemImage: "info.circle")
                        }
                        
                        Button(action: {
                            selectedCategory = category
                            editCategoryName = category.name
                            showEditCategoryView.toggle()
                        }) {
                            Label("Sửa", systemImage: "pencil")
                        }
                        
                        Button(role: .destructive, action: {
                            // Xóa danh mục
                            deleteCategory(category)
                        }) {
                            Label("Xóa", systemImage: "trash")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .font(.title)
                            .foregroundColor(.gray)
                    }
                }
            }
            .listStyle(PlainListStyle())
            .onAppear(perform: loadCategories)
        }
        .padding(.horizontal)
        .sheet(isPresented: $showDetailView) {
            if let selectedCategory = selectedCategory {
                CategoryDetailView(category: selectedCategory)
            }
        }
        .sheet(isPresented: $showAddCategoryView) {
            AddCategoryView(categories: $categories)
                .onDisappear {
                    loadCategories()
                }
        }
        .sheet(isPresented: $showEditCategoryView) {
            if let selectedCategory = selectedCategory {
                EditCategoryView(category: Binding(get: {
                    selectedCategory
                }, set: { newCategory in
                    self.selectedCategory = newCategory
                    // Cập nhật danh sách categories sau khi sửa
                    if let index = categories.firstIndex(where: { $0.id == newCategory.id }) {
                        categories[index] = newCategory
                    }
                }), categories: $categories)
            }
        }
    }
    
    // Load categories from Firestore
    private func loadCategories() {
        firestoreService.fetchCategories { categories, error in
            if let error = error {
                print("Error fetching categories: \(error.localizedDescription)")
            } else {
                self.categories = categories
            }
        }
    }
    
    // Xóa category Firestore
    private func deleteCategory(_ category: CategoryModel) {
        firestoreService.deleteCategory(category) { success, error in
            if let error = error {
                print("Error deleting category: \(error.localizedDescription)")
            } else if success {
                self.categories.removeAll { $0.id == category.id }
            }
        }
    }
}
