import SwiftUI

// Assuming definition of Post and NetworkManager are available elsewhere

struct ContentView: View {
    @ObservedObject var networkManager = NetworkManager()
    
    // Computed property to group posts by userId
    private var groupedPosts: [Int: [Post]] {
        Dictionary(grouping: networkManager.posts) { $0.userId }
    }
    
    var body: some View {
        NavigationView {
            List {
                ForEach(groupedPosts.keys.sorted(), id: \.self) { userId in
                    Section(header: Text("User \(userId)")) {
                        ForEach(groupedPosts[userId] ?? []) { post in
                            NavigationLink(destination: DualColumnView(post: post)) {
                                Text(post.title)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Posts")
            .onAppear {
                networkManager.fetchPosts()
            }
        }
    }
}

struct DualColumnView: View {
    let post: Post
    @State private var currentScale: CGFloat = 1.0
    @State private var showModal: Bool = false
    @State private var selectedSquareIndex: Int?
    @State private var temporaryImageName: String = "default" // Initialize with a default image name
    
    // Update to use image names (assuming these are image asset names)
    @State private var squareImages: [Int: String] = [0: "API Gateway", 1: "EC2", 2: "Service Holder", 3: "Simple Storage Service"]

    var body: some View {
        GeometryReader { geometry in
            HStack(spacing: 0) {
                DetailView(post: post)
                    .frame(width: geometry.size.width / 2)
                    .background(Color.gray.opacity(0.2))

                ScrollView([.horizontal, .vertical], showsIndicators: true) {
                    VStack {
                        ForEach(squareImages.keys.sorted(), id: \.self) { index in
                            if let imageName = squareImages[index] {
                                Image(imageName)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 100, height: 100)
                                    .onTapGesture {
                                        selectedSquareIndex = index
                                        temporaryImageName = imageName
                                        showModal = true
                                    }
                                    .padding()
                            }
                        }
                    }
                    .scaleEffect(currentScale)
                }
                .frame(width: geometry.size.width / 2)
                .background(Color.blue.opacity(0.2))
            }
        }
        .sheet(isPresented: $showModal) {
            if let selectedIndex = selectedSquareIndex {
                ImageSelectionModalView(selectedSquareIndex: selectedIndex, temporaryImageName: $temporaryImageName, squareImages: $squareImages)
            }
        }
    }
}

// Image Selection Modal
// A new modal view for selecting images
struct ImageSelectionModalView: View {
    var selectedSquareIndex: Int
    @Binding var temporaryImageName: String
    @Binding var squareImages: [Int: String]
    
    let availableImages: [String] = ["API Gateway", "EC2", "Service Holder", "Simple Storage Servce"] // Example images
    
    var body: some View {
        VStack {
            Text("Select an Image").font(.headline).padding()
            Divider()
            ScrollView(.horizontal) {
                HStack {
                    ForEach(availableImages, id: \.self) { imageName in
                        Image(imageName)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100, height: 100)
                            .onTapGesture {
                                self.temporaryImageName = imageName
                                self.squareImages[selectedSquareIndex] = imageName
                            }
                    }
                }
            }
        }
    }
}


struct ClickableSquare: View {
    @Binding var color: Color
    let action: () -> Void
    
    var body: some View {
        Rectangle()
            .frame(width: 100, height: 100)
            .foregroundColor(color)
            .onTapGesture(perform: action)
    }
}

struct DetailView: View {
    let post: Post

    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                Text(post.title)
                    .font(.title)
                    .padding()
                Text(post.body)
                    .font(.body)
                    .padding()
            }
        }
    }
}

struct ModalView: View {
    var title: String
    @Binding var squareColor: Color
    
    var body: some View {
        VStack {
            Text(title)
                .font(.headline)
                .padding()
            
            Divider()
            
            HStack {
                ForEach([Color.red, Color.green, Color.blue, Color.orange], id: \.self) { color in
                    Rectangle()
                        .frame(width: 50, height: 50)
                        .foregroundColor(color)
                        .onTapGesture {
                            self.squareColor = color
                        }
                }
            }
            .padding()
        }
        .frame(width: 300, height: 200)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(radius: 10)
    }
}
