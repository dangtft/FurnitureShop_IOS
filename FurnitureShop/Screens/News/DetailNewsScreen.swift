import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct DetailNewsScreen: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    var newsArticle: NewsModel
    @State private var userId: String = ""
    @State private var userName: String = ""
    @State private var commentText: String = ""
    @State private var comments: [CommentModel] = []
    private let db = Firestore.firestore()

    var body: some View {
        ZStack {
            Color("Bg").edgesIgnoringSafeArea(.all)
            
            VStack {
                // Hiển thị hình ảnh và nội dung bài viết
                ScrollView {
                    AsyncImage(url: URL(string: newsArticle.image)) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                                .frame(maxWidth: .infinity, maxHeight: 300)
                                .background(Color.gray.opacity(0.2))
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFit()
                                .frame(maxWidth: .infinity)
                                .edgesIgnoringSafeArea(.top)
                        case .failure:
                            Image(systemName: "photo")
                                .resizable()
                                .scaledToFit()
                                .foregroundColor(.gray)
                                .frame(maxWidth: .infinity, maxHeight: 300)
                                .background(Color.gray.opacity(0.2))
                        @unknown default:
                            EmptyView()
                        }
                    }
                    DescriptionNewsView(newsArticle: newsArticle)
                    
                    Divider()
                    
                    Spacer()
                    
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Comment")
                            .font(.headline)
                        
                        Divider()
                        
                        ForEach(comments) { comment in
                            VStack(alignment: .leading) {
                                Text(comment.comment)
                                    .font(.body)
                                Text("By \(comment.userName)")
                                    .font(.footnote)
                                    .foregroundColor(.gray)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                    .padding()

                }
                
            
                Divider()
                
                // Nhập bình luận mới
                HStack {
                    TextField("Enter your comment", text: $commentText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(minHeight: 44)
                    
                    Button(action: postComment) {
                        Text("Post")
                            .padding(.horizontal)
                            .padding(.vertical, 8)
                            .background(Color("Color"))
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                }
                .padding()
            }
            .onAppear {
                if let currentUser = Auth.auth().currentUser {
                    self.userId = currentUser.uid
                    fetchUserName()
                } else {
                    print("No user is signed in")
                }
                fetchComments()
            }
            .navigationBarBackButtonHidden(true)
            .navigationBarItems(
                leading: BackButton(action: { presentationMode.wrappedValue.dismiss() }),
                trailing: Image("threeDot")
            )
        }
    }
    
    private func fetchUserName() {
        db.collection("users").document(userId).getDocument { (document, error) in
            if let document = document, document.exists {
                let data = document.data()
                self.userName = data?["name"] as? String ?? "Anonymous"
            } else {
                print("User document does not exist")
            }
        }
    }
    
    private func postComment() {
        guard !commentText.isEmpty, !userId.isEmpty else { return }
        
        // Lấy tên người dùng từ Firestore
        db.collection("users").document(userId).getDocument { document, error in
            if let error = error {
                print("Error fetching user name: \(error)")
                return
            }

            guard let document = document, document.exists, let userName = document.data()?["name"] as? String else {
                print("User not found or missing name")
                return
            }
            
            let commentData: [String: Any] = [
                "newsId": newsArticle.id ?? "",
                "userId": userId,
                "userName": userName,
                "comment": commentText,
                "timestamp": FieldValue.serverTimestamp()
            ]
            
            // Thêm bình luận vào collection "comments"
            db.collection("comments").addDocument(data: commentData) { error in
                if let error = error {
                    print("Error posting comment: \(error)")
                } else {
                    // Cập nhật dữ liệu bình luận trong bài viết
                    if let newsId = newsArticle.id {
                        let newComment = CommentModel(newsId: newsId, userId: userId, userName: userName, comment: commentText, timestamp: Timestamp(date: Date()))
                        updateNewsWithNewComment(newComment)
                    } else {
                        print("newsId is nil, cannot create CommentModel")
                    }
                }
            }
        }
    }


    private func updateNewsWithNewComment(_ newComment: CommentModel) {
        guard let newsId = newsArticle.id else { return }

        db.collection("news").document(newsId).updateData([
            "comments": FieldValue.arrayUnion([newComment.toDictionary()])
        ]) { error in
            if let error = error {
                print("Error updating comments in news document: \(error)")
            } else {
                commentText = ""
                
                fetchComments()
            }
        }
    }

    private func fetchComments() {
        guard let newsId = newsArticle.id else { return }
        print("Fetching comments for newsId: \(newsId)")

        db.collection("comments")
            .whereField("newsId", isEqualTo: newsId)
            .order(by: "timestamp", descending: false)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Error fetching comments: \(error)")
                    return
                }

                if let snapshot = snapshot {
                    let commentsFromFirestore = snapshot.documents.compactMap { document -> CommentModel? in
                        do {
                            let comment = try document.data(as: CommentModel.self)
                            print("Fetched comment: \(comment)")
                            return comment
                        } catch {
                            print("Error decoding comment: \(error)")
                            return nil
                        }
                    }

                    DispatchQueue.main.async {
                        self.comments = commentsFromFirestore
                    }
                }
            }
    }

}

struct DescriptionNewsView: View {
    var newsArticle: NewsModel

    var body: some View {
        VStack(alignment: .leading) {
            Text(newsArticle.title)
                .font(.title)
                .fontWeight(.bold)

            Text("By \(newsArticle.author)")
                .font(.subheadline)
                .foregroundColor(.gray)

            // Định dạng và hiển thị thời gian
            Text(formatTimestamp(newsArticle.postTime))
                .font(.footnote)
                .foregroundColor(.gray)

            Divider()

            Text(newsArticle.detail)
                .font(.body)
                .foregroundColor(.black)
                .lineSpacing(8.0)
        }
        .padding()
        .padding(.top)
        .background(Color("Bg"))
        .cornerRadius(30, corners: [.topLeft, .topRight])
        .offset(x: 0, y: -30.0)
    }

    // Hàm định dạng Timestamp
    func formatTimestamp(_ timestamp: Timestamp) -> String {
        let date = timestamp.dateValue()
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}
