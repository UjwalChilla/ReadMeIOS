//
//  ContentView.swift
//  Read Me
//
//  Created by Ujwal Chilla on 2/8/22.
//

import AVFoundation
import SwiftUI
import SDWebImageSwiftUI
import Firebase
import GoogleSignIn
import SceneKit
import LocalAuthentication

class AuthenticationService {
    
    func authenticateUsingTouchId(completion: @escaping (Bool, Error?) -> Void) {
        
        let context = LAContext()
        var error: NSError?
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            
            let reason = "TouchId authentication is required!"
            
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { (success, error) in
                
                DispatchQueue.main.async {
                    completion(success, error)
                }
                
            }
            
        }
        
    }
}

final class ApplicationUtility {
    
    static var rootViewController: UIViewController {
        
        guard let screen = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
            
            return .init()
            
        }
        
        guard let root = screen.windows.first?.rootViewController else {
            
            return .init()
            
        }
        
        return root
        
    }
    
}

class SignUpViewModel: ObservableObject {
    
    @Published var isLogin: Bool = false
    @Published var userEmail: String = ""
    @Published var userPassword: String = ""
    @Published var userDisplayName:String = ""
    @Published var userPFP: URL = (URL(string: "https://media.wired.com/photos/5ed67e71b818b223fd84195f/1:1/w_1600,h_1600,c_limit/Blackout-hashtag-activism.jpg")!)
                                   
    func signUpWithGoogle(){
        
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        let config = GIDConfiguration(clientID: clientID)
        
        GIDSignIn.sharedInstance.signIn(with: config, presenting: ApplicationUtility.rootViewController) {
            
            user, err in
            
            if let error = err {
                
                print(error.localizedDescription)
                return
                
            }
            
            guard
                let authentication = user?.authentication,
                let idToken = authentication.idToken
            else {return}
            
            let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: authentication.accessToken)
            
            Auth.auth().signIn(with: credential) {result, error in
                
                if err != nil {
                    
                    print(err?.localizedDescription ?? "")
                    return
                    
                }
                
                guard let user = result?.user else {return}
                
                print(user.displayName ?? "")
                self.userEmail = user.email ?? ""
                self.userDisplayName = user.displayName ?? ""
                self.userPFP = user.photoURL ?? URL(string: "https://media.wired.com/photos/5ed67e71b818b223fd84195f/1:1/w_1600,h_1600,c_limit/Blackout-hashtag-activism.jpg")!
                
                self.isLogin.toggle()
                
            }
            
        }
        
    }
    
}

var utterence = AVSpeechUtterance.self()

struct TextView: View {
    
    @State private var showScannerSheet = false
    @State var text: String
    let synthesizer = AVSpeechSynthesizer()
    var utterence: AVSpeechUtterance
    @State private var speed: Float = 0.5
    @State var wordToDefine = ""
    @State var definition = ""
    @State var examples = ""
    @State var showDef = false
    @State var showDictionary = false
    
    var body: some View {
        
        ScrollView{
            
            VStack{
                
                Menu("Change Voice") {
                    
                    Button {
                    
                        synthesizer.stopSpeaking(at: AVSpeechBoundary.immediate)
                        utterence.voice = AVSpeechSynthesisVoice(language: "en-US")

                        guard synthesizer.isSpeaking else{
                            synthesizer.speak(utterence)
                            return
                        }
                        
                    } label: {
                        Text("American Female")
                    }
                    Button {
                    
                        synthesizer.stopSpeaking(at: AVSpeechBoundary.immediate)
                        utterence.voice = AVSpeechSynthesisVoice(language: "en-GB")
                        guard synthesizer.isSpeaking else{
                            synthesizer.speak(utterence)
                            return
                        }

                    } label: {
                        Text("British Male")
                    }

                    Button {
                    
                        synthesizer.stopSpeaking(at: AVSpeechBoundary.immediate)
                        utterence.voice = AVSpeechSynthesisVoice(language: "en-AU")
                        guard synthesizer.isSpeaking else{
                            synthesizer.speak(utterence)
                            return
                        }

                    } label: {
                        Text("Australian Female")
                    }
                    
                }
                    
                Button {
                    
                    utterence.rate = speed
                    synthesizer.speak(utterence)
                    
                } label: {
                    Text("Read Text")
                }.padding()
                
                Button {
                
                    synthesizer.continueSpeaking()
                    
                } label: {
                    Text("Play")
                }.padding()
                
                Button {
                
                    synthesizer.pauseSpeaking(at: AVSpeechBoundary.immediate)
                    
                } label: {
                    Text("Pause")
                }.padding()
                                
                Button {
                    
                    synthesizer.stopSpeaking(at: AVSpeechBoundary.immediate)
 
                } label: {
                    Text("Stop")
                }.padding()
                
                Text("Change reading speed")
                    
                Slider(value: $speed, in: 0...1)
                    .padding()
                
                Button {
                    
                    synthesizer.pauseSpeaking(at: AVSpeechBoundary.immediate)
                    showDictionary = true
                    
                } label: {
                    Text("Dictionary")
                }
                .padding()
                .popover(isPresented: $showDictionary) {
                 
                    VStack {
                    
                        Text("Dictionary")
                            .fontWeight(.bold)
                            .padding()
                        
                        TextField("Type in word...", text: $wordToDefine)
                            .padding()
                        
                        Button {
                            
                            handleDef()
                            
                        } label: {
                            
                            Text("Get Definition")
                            
                        }
                        .padding()
                        
                        Text("Definition: \(definition)")
                            .padding()
                        
                        Text("Examples: \(examples)")
                            .padding()
                        
                        HStack {
                            
                            Spacer()
                            
                            Button(action: {
                                
                                showDictionary = false
                                definition = ""
                                examples = ""
                                wordToDefine = ""
                                synthesizer.continueSpeaking()
                                showDictionary = false
                                
                            }, label: {
                                
                                Text("Done")
                                
                            })
                            .frame(width: 80, height: 36)
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            
                        }
                    
                    }
                    
                }
                
                Text(text)
                
            }
            .navigationBarItems(trailing: Button(action: {
                self.showScannerSheet = true
            }, label: {
                Image(systemName: "doc.text.viewfinder")
                    .font(.title)
            }).sheet(isPresented: $showScannerSheet, content: {
                makeScannerView()
            })
            
            )
            
        }
        
    }
    
    private func handleDef(){
        
        if wordToDefine == "hello" {
            
            definition = "A greeting (salutation) said when meeting someone or acknowledging someone’s arrival or presence."
            examples = "Hello, everyone."
            
        } else if wordToDefine == "excited" {
            
            definition = "To stir the emotions of."
            examples = "The fireworks which opened the festivities excited anyone present."
            
        }
        
    }
    
    private func changeVoice(lang: String) {
        
        print(lang)
        
    }
    
    private func makeScannerView()-> ScannerView {
        
        ScannerView(completion: {
        
            textPerPage in
            
            let outputText = textPerPage?.joined(separator: "\n").trimmingCharacters(in: .whitespacesAndNewlines)
            
            text.append(" \(outputText ?? "")")
            
            
            self.showScannerSheet = false
        
        })
        
    }
    
}

class AppDelegate: NSObject, UIApplicationDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        return true
        
    }
    
    func application(_ application: UIApplication, open url: URL,
                     options: [UIApplication.OpenURLOptionsKey: Any])
      -> Bool {
      return GIDSignIn.sharedInstance.handle(url)
    }
    
}
 
struct MainView: View {
    
    var body: some View {
        
        TabView {
            
            LibraryView()
                .tabItem {
                    
                    Label("Library", systemImage: "list.dash")
                    
                }
            ForumView(isPresented: false)
                .tabItem {
                    
                    Label("Forum", systemImage: "square.and.pencil")
                    
                }
            
        }
        
    }
    
}
 
class ForumViewModel: ObservableObject {
    
    @Published var errorMessage = ""
    @Published var chatUser: ChatUser?
    @Published var postMessages = [postMessage]()
    
    init() {
        
        DispatchQueue.main.async {
            
            self.isUserCurrentlyLoggedOut = FirebaseManager.shared.auth.currentUser?.uid == nil
            
        }
        
        fetchCurrentUser()
        fetchPosts()
        
    }
    
    func fetchCurrentUser() {
                
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid
            
            else {
                
            self.errorMessage = "Could not find firebase uid"
            
            return
            
        }
        
        self.errorMessage = "\(uid)"
 
        FirebaseManager.shared.firestore.collection("users").document(uid).getDocument { snapshot, error in
            
            if let error = error {
                
                self.errorMessage = "failed to fetch current user: \(error)"
                return
                
            }
            
            guard let data = snapshot?.data() else {
                
                self.errorMessage = "no data found"
                return
                
            }
            
            self.chatUser = .init(data: data)
                        
        }
        
    }
    
    @Published var isUserCurrentlyLoggedOut = false
    
    func handleSignOut() {
        
        isUserCurrentlyLoggedOut.toggle()
        try? FirebaseManager.shared.auth.signOut()
        
    }
    
    @Published var posts = [postMessage]()

    let db = Firestore.firestore()
    
    func fetchPosts() {
        
        if filterOption == "all"{
 
            db.collection("posts").addSnapshotListener { (querySnapshot, error) in
                
                guard let documents = querySnapshot?.documents else { return }
                        
                    self.posts = documents.map { (queryDocumentSnapshot) -> postMessage in
                        
                        let data = queryDocumentSnapshot.data()
                        let ProfileImageUrl = data["ProfileImageUrl"] as? String ?? ""
                        let description = data["description"] as? String ?? ""
                        let title = data["title"] as? String ?? ""
                        let email = data["email"] as? String ?? ""
                        let genre = data["genre"] as? String ?? ""
    //                    let likes = data["likes"] as? Int ?? 0
    //                    let dislikes = data["dislikes"] as? Int ?? 0

                        return postMessage(ProfileImageUrl: ProfileImageUrl, Title: title, Description: description, Email: email, Genre: genre)
                        
                    }
                    
            }
            
        } else if filterOption == "fiction"{
 
            db.collection("posts").addSnapshotListener { (querySnapshot, error) in
                
                guard let documents = querySnapshot?.documents else { return }
                        
                    self.posts = documents.map { (queryDocumentSnapshot) -> postMessage in
                        
                        let data = queryDocumentSnapshot.data()
                        let ProfileImageUrl = data["ProfileImageUrl"] as? String ?? ""
                        let description = data["description"] as? String ?? ""
                        let title = data["title"] as? String ?? ""
                        let email = data["email"] as? String ?? ""
                        let genre = "fiction"
    //                    let likes = data["likes"] as? Int ?? 0
    //                    let dislikes = data["dislikes"] as? Int ?? 0

                        return postMessage(ProfileImageUrl: ProfileImageUrl, Title: title, Description: description, Email: email, Genre: genre)
                        
                    }
                    
            }
            
        } else if filterOption == "nonfiction"{
 
            db.collection("posts").addSnapshotListener { (querySnapshot, error) in
                
                guard let documents = querySnapshot?.documents else { return }
                        
                    self.posts = documents.map { (queryDocumentSnapshot) -> postMessage in
                        
                        let data = queryDocumentSnapshot.data()
                        let ProfileImageUrl = data["ProfileImageUrl"] as? String ?? ""
                        let description = data["description"] as? String ?? ""
                        let title = data["title"] as? String ?? ""
                        let email = data["email"] as? String ?? ""
                        let genre = "nonfiction"
    //                    let likes = data["likes"] as? Int ?? 0
    //                    let dislikes = data["dislikes"] as? Int ?? 0

                        return postMessage(ProfileImageUrl: ProfileImageUrl, Title: title, Description: description, Email: email, Genre: genre)
                        
                    }
                    
            }
            
        }
        
    }
    
    @Published var comments = [commentMessage]()
    
    func fetchComments() {
 
        db.collection("comments").addSnapshotListener { (querySnapshot, error) in
            
            guard let documents = querySnapshot?.documents else { return }
                    
                self.comments = documents.map { (queryDocumentSnapshot) -> commentMessage in
                    
                    let data = queryDocumentSnapshot.data()
                    let ProfileImageUrl = data["ProfileImageUrl"] as? String ?? ""
                    let description = data["description"] as? String ?? ""
                    let email = data["email"] as? String ?? ""
//                    let likes = data["likes"] as? Int ?? 0
//                    let dislikes = data["dislikes"] as? Int ?? 0
                    
                    return commentMessage(ProfileImageUrl: ProfileImageUrl, Description: description, Email: email)
                    
                }
                
        }
 
    }
 
    
    struct FirebaseConstants {
        
        static let email = "email"
        static let title = "title"
        static let description = "description"
        static let profileImage = "ProfileImageUrl"
        static let genre = "genre"
        static let likes = "likes"
        static let dislikes = "dislikes"
        
    }
    
    struct postMessage: Identifiable {
        
        var id: String = UUID().uuidString
        
        var ProfileImageUrl: String
        var Title: String
        var Description: String
        var Email: String
        var Genre: String
//        var Likes: Int
//        var Dislikes: Int
 
    }
    
    struct commentMessage: Identifiable {
        
        var id: String = UUID().uuidString
        
        var ProfileImageUrl: String
        var Description: String
        var Email: String
//        var Likes: Int
//        var Dislikes: Int
    }
    
    @Published var titleofPost = ""
    @Published var descriptionOfPost = ""
    @Published var genreOfPost = ""
    @Published var likeOnPost = 0
    @Published var dislikeOnPost = 0
    
    func handleUpdateForum(title: String, description: String, genre: String) {
        
        titleofPost = title
        descriptionOfPost = description
        genreOfPost = genre
//        likeOnPost = likes
//        dislikeOnPost = dislikes
        
        guard let email = chatUser?.email else { return }
        guard let profileImage = chatUser?.profileImageUrl else { return }
 
        let document = FirebaseManager.shared.firestore
            .collection("posts")
            .document(email)
        
        let postData = [FirebaseConstants.profileImage: profileImage, FirebaseConstants.email: email, FirebaseConstants.title: titleofPost, FirebaseConstants.description: descriptionOfPost, FirebaseConstants.genre: genreOfPost, "timestamp": Timestamp()] as [String : Any]
        
        document.setData(postData) { error in
            
            if let error = error {
            
                self.errorMessage = "Failed to save post into Firestore: \(error)"
                return
                
            }
            
        }
        
        fetchPosts()
        
    }
    
    @Published var descriptionOfComment = ""
    @Published var likeOnComment = 0
    @Published var dislikeOnComment = 0
    
    func handleUpdateComment(description: String) {
    
        descriptionOfPost = description
//        likeOnComment = likes
//        dislikeOnComment = dislikes
        
        guard let email = chatUser?.email else { return }
        guard let profileImage = chatUser?.profileImageUrl else { return }
 
        let document = FirebaseManager.shared.firestore
            .collection("comments")
            .document(email)
        
        let commentData = [FirebaseConstants.profileImage: profileImage, FirebaseConstants.email: email, FirebaseConstants.description: descriptionOfPost, "timestamp": Timestamp()] as [String : Any]
        
        document.setData(commentData) { error in
            
            if let error = error {
            
                self.errorMessage = "Failed to save post into Firestore: \(error)"
                return
                
            }
            
        }
        
        fetchComments()
        
    }
    
}
 
struct commentsView: View {
 
    let username: String
    let profilePicUrl: String
    let description: String
    @State var likesComment = 0
    @State var dislikesComment = 0
    
    @State var descriptionOfComment = ""
    @State var newCommentBtnIsPressed = false
    @State var isPresented = false
    
    @ObservedObject private var signUpVm = SignUpViewModel()
    @ObservedObject private var vm = ForumViewModel()
    
    var body: some View{
 
        NavigationView {
            
            VStack {
            
                commentsView
                
            }
            .overlay(newCommentButton, alignment: .bottom)
            .navigationBarHidden(true)
            .popover(isPresented: $newCommentBtnIsPressed) {
                
                VStack(alignment: .leading, spacing: 16) {
                    
                    HStack {
                        
                        Text("Create New Comment")
                            .font(.system(size: 25, weight: .bold, design: .default))
                        
                        Spacer()
                        
                        Button(action: {
                        
                            isPresented = false
                        
                        }, label: {
                        
                            Image(systemName: "xmark")
                                .imageScale(.small)
                                .frame(width: 32, height: 32)
                                .background(Color.black.opacity(0.06))
                                .cornerRadius(16)
                                .foregroundColor(.black)
                    
                        })
                    
                    }
                    
                    TextField("Description of Comment", text: $descriptionOfComment)
                        .frame(height: 36)
                        .padding([.leading, .trailing], 10)
                        .background(Color.gray.opacity(0.3))
                        .cornerRadius(10)
                    
                    HStack {
                        
                        Spacer()
                        
                        Button(action: {
                            
                            isPresented = false
                            vm.handleUpdateComment(description: self.descriptionOfComment)
                            
                        }, label: {
                            
                            Text("Done")
                            
                        })
                        .frame(width: 80, height: 36)
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        
                    }
                    
                }
                .padding()
                
            }
            
        }
 
    }
    
    private var commentsView: some View {
        
        ScrollView {
            
            ForEach(vm.comments) { comment in
                
                let username = comment.Email.replacingOccurrences(of: "@gmail.com", with: "")
                
                VStack {
                        
                    HStack (spacing: 16){
                                                    
                        if !signedInWithGoogle {
                            
                            WebImage(url: URL(string: comment.ProfileImageUrl))
                                .resizable()
                                .scaledToFill()
                                .frame(width: 30, height: 30)
                                .clipped()
                                .cornerRadius(30)
                                .overlay(RoundedRectangle(cornerRadius: 44)
                                            .stroke(Color(.label), lineWidth: 1))
                            
                        } else{
                            
                            WebImage(url: signUpVm.userPFP)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 50, height: 50)
                                .clipped()
                                .cornerRadius(50)
                                .overlay(RoundedRectangle(cornerRadius: 44)
                                            .stroke(Color(.label), lineWidth: 1))
                            
                        }
                            
                            VStack {
                                
                                Text(username)
                                    .font(.system(size: 16, weight: .bold))
                                
                            }
                            
                            Spacer()
//
//                            Text("22d")
//                                .font(.system(size: 14, weight: .semibold))
                            
                    }
                        
                    Text(comment.Description)
                    
                    HStack {

                        Button {

                            likesComment = likesComment + 1

                        } label: {

                            Text("Like \(likesComment)")

                        }
                        Button {

                            dislikesComment = dislikesComment + 1

                        } label: {

                            Text("Disike \(dislikesComment)")

                        }

                    }
 
                    Divider()
                        .padding(.vertical, 8)
                    
                }.padding(.horizontal)
                
            }.padding(.bottom, 50)
            
        }
        .onAppear() {
 
            vm.fetchComments()
 
        }
        
    }
    
    private var newCommentButton: some View {
        
        Button {
                         
            newCommentBtnIsPressed = true
            
        } label: {
            
            HStack {
                
                Spacer()
                
                Text("New Comment")
                    .font(.system(size: 16, weight: .bold))
                
                Spacer()
                
            }
            .foregroundColor(.white)
            .padding(.vertical)
                .background(Color.blue)
                .cornerRadius(32)
                .padding(.horizontal)
                .shadow(radius: 15)
            
        }
        
    }
 
}

struct UserService {
    
    func fetchUser(withUid uid : String){
        
        print("Debug: fetch user info")
        
    }
    
}

var filterOption = "all"

struct ForumView: View {
    
    @State var shouldShowLogOutOptions = false
    @State var header = ""
    @State var description = ""
    @State var newPostBtnIsPressed = false
    @State var isPresented: Bool
    @State var title = ""
    @State var likes = 0
    @State var dislikes = 0
    @State var genre = ""
//    @State var filterOption = "all"
    @State private var searchText = ""

    @ObservedObject private var signUpVm = SignUpViewModel()
    @ObservedObject private var vm = ForumViewModel()

    var body: some View{
 
        NavigationView {
            
            VStack {
                                                
                customNavBar
                
                HStack{
                    
                    Spacer()
                    
                    Menu("Filter Posts") {
                        
                        Button("All", action: filterAll)
                        Button("Nonfiction", action: filterNonfic)
                        Button("Fiction", action: filterFic)
                        Button("History", action: filterFic)
                        Button("Fantasy", action: filterFic)
                        Button("Anime", action: filterFic)
                        
                    }.padding()
                    
                }
                
                postsView
                
            }
            .overlay(newMessageButton, alignment: .bottom)
            .navigationBarHidden(true)
            .popover(isPresented: $newPostBtnIsPressed) {
                
                VStack(alignment: .leading, spacing: 16) {
                    
                    HStack {
                        
                        Text("Create New Post")
                            .font(.system(size: 25, weight: .bold, design: .default))
                        
                        Spacer()
                        
                        Button(action: {
                        
                            isPresented = false
                        
                        }, label: {
                        
                            Image(systemName: "xmark")
                                .imageScale(.small)
                                .frame(width: 32, height: 32)
                                .background(Color.black.opacity(0.06))
                                .cornerRadius(16)
                                .foregroundColor(.black)
                    
                        })
                    
                    }
                    
                    TextField("Title of Post", text: $title)
                        .frame(height: 36)
                        .padding([.leading, .trailing], 10)
                        .background(Color.gray.opacity(0.3))
                        .cornerRadius(10)
                    
                    TextField("Description of Post", text: $description)
                        .frame(height: 36)
                        .padding([.leading, .trailing], 10)
                        .background(Color.gray.opacity(0.3))
                        .cornerRadius(10)
                    
                    Menu("Choose genre of post"){
                        
                        
                        Button("Fiction", action: genreFic)
                        Button("Non Fiction", action: genreNonFic)
                        Button("History", action: genreNonFic)
                        Button("Fantasy", action: genreNonFic)
                        Button("Anime", action: genreNonFic)

                    }
                    
                    HStack {
                        
                        Spacer()
                        
                        Button(action: {
                            
                            isPresented = false
                            vm.handleUpdateForum(title: self.title, description: self.description, genre: self.genre)
                            
                        }, label: {
                            
                            Text("Done")
                            
                        })
                        .frame(width: 80, height: 36)
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        
                    }
                    
                }
                .padding()
                
            }
            
        }
 
    }
    
    private func filterAll(){
        
        filterOption = "all"
        vm.fetchPosts()
        
    }
    
    private func filterNonfic(){
        
        filterOption = "nonfiction"
        vm.fetchPosts()
//        vm.posts.removeAll()
//        vm.handleUpdateForum(title: "Any new recommendations?", description: "I am mostly interested in fiction.", genre: "nonfiction")
        
    }
    
    private func filterFic(){
        
        filterOption = "fiction"
        vm.fetchPosts()
//        vm.posts.removeAll()
//        vm.handleUpdateForum(title: "Testing", description: "Posts", genre: "fiction")
        
    }
    
    private func genreFic(){
        
        genre = "fiction"
        
    }
    
    private func genreNonFic(){
        
        genre = "nonfiction"
        
    }
    
    private var customNavBar: some View {
        
        HStack (spacing: 16){
            
            if !signedInWithGoogle {
                
                WebImage(url: URL(string: vm.chatUser?.profileImageUrl ?? ""))
                    .resizable()
                    .scaledToFill()
                    .frame(width: 50, height: 50)
                    .clipped()
                    .cornerRadius(50)
                    .overlay(RoundedRectangle(cornerRadius: 44)
                                .stroke(Color(.label), lineWidth: 1))
                
            } else {
                
                WebImage(url: signUpVm.userPFP)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 50, height: 50)
                    .clipped()
                    .cornerRadius(50)
                    .overlay(RoundedRectangle(cornerRadius: 44)
                                .stroke(Color(.label), lineWidth: 1))
                
            }
            VStack (alignment: .leading, spacing: 4){
                
                if !signedInWithGoogle {
                    
                    let email = vm.chatUser?.email.replacingOccurrences(of: "@gmail.com", with: "") ?? ""
                    
                    Text(email)
                        .font(.system(size: 24, weight: .bold))
                
                } else {
                    
                    Text(signUpVm.userEmail)
                        .font(.system(size: 24, weight: .bold))
                    
                }
                
            }
 
            Spacer()
            
            Button {
                
                shouldShowLogOutOptions.toggle()
                
            } label: {
                
                Image(systemName: "gear")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(Color(.label))
                
            }
            
        }
        .padding()
        .actionSheet(isPresented: $shouldShowLogOutOptions) {
            
            .init(title: Text("Settings"), message: Text("What do you want to do"), buttons: [
                .destructive(Text("Sign Out"), action: {
                    
                    vm.handleSignOut()
                    signedInWithGoogle = false
                    
                }),
                .cancel()
                
            ])
            
        }
        .fullScreenCover(isPresented: $vm.isUserCurrentlyLoggedOut, onDismiss: nil) {
            
            ContentView(didCompleteLoginProcess: {
                
                self.vm.isUserCurrentlyLoggedOut = false
                self.vm.fetchCurrentUser()
                
            })
            
        }
        
    }
    
    private var postsView: some View {

        VStack{

            ScrollView {
                
                ZStack {
                    
                    Rectangle()
                        .foregroundColor(Color("White"))
                    
                    HStack {
                        
                        Image(systemName: "magnifyingglass")
                        TextField("Search...", text: $searchText)
                        
                    }.foregroundColor(.gray).padding(.leading, 13)
                    
                }
                .frame(height: 40)
                .cornerRadius(13)
                .padding()
                    
                if searchText == "" {
                
                    ForEach(vm.posts) { post in
                        
                        let username = post.Email.replacingOccurrences(of: "@gmail.com", with: "")
             
                        VStack {
                                
                            NavigationLink {
                                    
                                commentsView(username: username, profilePicUrl: post.ProfileImageUrl, description: post.Description)
                                    
                            } label: {
                                    
                                VStack {
                                    
                                    HStack (spacing: 16){
                                        
                                        WebImage(url: URL(string: post.ProfileImageUrl))
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 30, height: 30)
                                            .clipped()
                                            .cornerRadius(30)
                                            .overlay(RoundedRectangle(cornerRadius: 44)
                                                        .stroke(Color(.label), lineWidth: 1))
                                                
                                                    
                                        Text(username)
                                            .font(.system(size: 16, weight: .bold))
                                            
                                        Spacer()
    //
    //                                    Text("22d")
    //                                        .font(.system(size: 14, weight: .semibold))
                                                
                                    }
                                        
                                    Text("\(post.Title) (\(post.Genre))")
                                        .font(.system(size: 24))
                                        .foregroundColor(Color(.lightGray))
                                        
                                    Spacer()
                                            
                                    Text(post.Description)
                                        
                                    HStack {

                                        Button {

                                            likes = likes + 1

            //                                    post.Likes = likes

                                        } label: {

                                            Text("Like \(likes)")

                                        }
                                        Button {

                                            dislikes = dislikes + 1

            //                                    post.Dislikes = dislikes

                                        } label: {

                                            Text("Disike \(dislikes)")

                                        }

                                    }
                                        
                                }
                                    
                            }
             
                            Divider()
                                .padding(.vertical, 8)
                                
                        }.padding(.horizontal)
                            
                    }.padding(.bottom, 50)
                
                } else {
                    
                    ForEach(vm.posts) { post in
                        
                        if post.Description.contains(searchText){
                        
                            let username = post.Email.replacingOccurrences(of: "@gmail.com", with: "")
                 
                            VStack {
                                    
                                NavigationLink {
                                        
                                    commentsView(username: username, profilePicUrl: post.ProfileImageUrl, description: post.Description)
                                        
                                } label: {
                                        
                                    VStack {
                                        
                                        HStack (spacing: 16){
                                            
                                            WebImage(url: URL(string: post.ProfileImageUrl))
                                                .resizable()
                                                .scaledToFill()
                                                .frame(width: 30, height: 30)
                                                .clipped()
                                                .cornerRadius(30)
                                                .overlay(RoundedRectangle(cornerRadius: 44)
                                                            .stroke(Color(.label), lineWidth: 1))
                                                    
                                                        
                                            Text(username)
                                                .font(.system(size: 16, weight: .bold))
                                                
                                            Spacer()
        //
        //                                    Text("22d")
        //                                        .font(.system(size: 14, weight: .semibold))
                                                    
                                        }
                                            
                                        Text("\(post.Title) (\(post.Genre))")
                                            .font(.system(size: 24))
                                            .foregroundColor(Color(.lightGray))
                                            
                                        Spacer()
                                                
                                        Text(post.Description)
                                            
                                        HStack {

                                            Button {

                                                likes = likes + 1

                //                                    post.Likes = likes

                                            } label: {

                                                Text("Like \(likes)")

                                            }
                                            Button {

                                                dislikes = dislikes + 1

                //                                    post.Dislikes = dislikes

                                            } label: {

                                                Text("Disike \(dislikes)")

                                            }

                                        }
                                            
                                    }
                                        
                                }
                 
                                Divider()
                                    .padding(.vertical, 8)
                                    
                            }.padding(.horizontal)
                            
                        }
                            
                    }.padding(.bottom, 50)
                    
                }
                
            }
            .onAppear() {
         
                vm.fetchPosts()
         
            }
                
        }
        
    }
    
    private var newMessageButton: some View {
        
        Button {
                         
            newPostBtnIsPressed = true
            
        } label: {
            
            HStack {
                
                Spacer()
                
                Text("New Post")
                    .font(.system(size: 16, weight: .bold))
                
                Spacer()
                
            }
            .foregroundColor(.white)
            .padding(.vertical)
                .background(Color.blue)
                .cornerRadius(32)
                .padding(.horizontal)
                .shadow(radius: 15)
            
        }
        
    }
 
}
 
struct LibraryView: View {
    
    let userDefaults = UserDefaults()
    
    @State private var showScannerSheet = false
    @State private var texts:[ScanData] = []
    @State private var titleOfText = "Untitled"
    @State private var numOfTexts = 0
    @State private var renameText = false
        
    var body: some View {
        
        NavigationView{
            
            VStack{
            
                if texts.count > 0{
                
                    List{
                            
                        ForEach(texts){text in
                            
                            NavigationLink( destination: TextView(text: text.content, utterence: AVSpeechUtterance(string: text.content)),
                                
                                label: {
     
                                    Text(titleOfText)
                                
                                })
                                .swipeActions (edge: .trailing, allowsFullSwipe: false) {
                                    
                                    Button {
                                        
                                        print("edit text name")
//                                        renameText = true
                                        
                                    } label: {
                                        Label("Edit Text", systemImage: "pencil")
                                    }
                                    .tint(.blue)
//                                    .popover(isPresented: $renameText) {
//                                        VStack{
//                                            Text("Popover Content")
//                                                .padding()
//                                        }
//                                    }
//
                                    Button(role: .destructive) {
                                        
                                        texts.removeLast()
                                        
                                    } label: {
                                        Label("Delete Text", systemImage: "trash")
                                    }
                                
                                }
                                .swipeActions(edge: .leading, allowsFullSwipe: false) {
                                    Button {
                                        
                                        texts.append(texts[0])
                                        texts[0] = texts[1]
                                        texts.remove(at: 1)
                                        
                                    } label: {
                                        Label("Pin Text", systemImage: "pin")
                                    }.tint(.orange)
                                
                                }
                                            
                        }
                    
                    }
                    
                }
                else{
                    
                    Text("No scan yet").font(.title)
                
                }
                
                Button {
                    
                    renameText = true
                    
                } label: {
                    
                    Text("                                  ")
                    
                }
                .popover(isPresented: $renameText) {
                    
                    VStack {
                        
                        Text("Change Title").font(.title).padding()

                        TextField("Change title...", text: $titleOfText).padding()
                        
                        HStack {
                            
                            Spacer()
                            
                            Button(action: {
                                
                                renameText = false
                                
                            }, label: {
                                
                                Text("Done")
                                
                            })
                            .frame(width: 80, height: 36)
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .padding()
                            
                        }
                        
                    }
                    
                }
                                
            }
            .navigationTitle("Scan Text")
            .navigationBarItems(trailing: Button(action: {
                self.showScannerSheet = true
            }, label: {
                Image(systemName: "doc.text.viewfinder")
                    .font(.title)
            }).sheet(isPresented: $showScannerSheet, content: {
                self.makeScannerView()
            })
            
            )
            
        }
        
    }
    
//    private func updateTexts(){
//
//        userDefaults.setValue(texts, forKey: "texts")
//
//    }
    
    private func makeScannerView()-> ScannerView {
        
        ScannerView(completion: {
        
            textPerPage in
            
            if let outputText = textPerPage?.joined(separator: "\n").trimmingCharacters(in: .whitespacesAndNewlines){
            
                let newScanData = ScanData(content: outputText, nameOfText: "Unnamed Text")
                self.texts.append(newScanData)
            
            }
            
            self.showScannerSheet = false
        
        })
        
    }
    
}

var signedInWithGoogle:Bool = false

struct ContentView: View {
    
    @EnvironmentObject var signUpVM: SignUpViewModel
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    let didCompleteLoginProcess: () -> ()
    
    @State private var isLoginMode = false
    @State private var email = ""
    @State private var password = ""
    @State private var shouldShowImagePicker = false
    @State private var userIsLoggedIn = false
    @State private var primaryEmail = ""
    @State private var primaryPassword = ""
    @State private var showAlert = false
    
    @ObservedObject private var vm = ForumViewModel()
    
    var body: some View {
        
        NavigationView{
            
            ScrollView{
                
                VStack(spacing: 16) {
                    
                    Picker(selection: $isLoginMode, label: Text("Picker Here")){
                        
                        Text("Login")
                            .tag(true)
                        Text("Create Account")
                            .tag(false)
                    }.pickerStyle(SegmentedPickerStyle())
                    
                    if !isLoginMode {
                        
                        Text("Choose a Profile Pic")
                        
                        Button {
                            
                            shouldShowImagePicker
                                .toggle()
                            
                        } label: {
                            
                            VStack {
                                
                                if let image = self.image {
                                    
                                    Image(uiImage: image)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 128, height: 128)
                                        .cornerRadius(64)
                                    
                                } else {
                                    
                                    Image(systemName: "person.fill")
                                        .font(.system(size: 64))
                                        .padding()
                                        .foregroundColor(Color(.label))
                                    
                                }
                                
                            }
                            .overlay(RoundedRectangle(cornerRadius: 64)
                                        .stroke(Color.black, lineWidth: 3))
                            
                        }
                        
                    }
            
                    TextField("Email", text: $email)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .padding(12)
                        .background(Color(.black))
                    
                    SecureField("Password", text: $password)
                        .padding(12)
                        .background(Color(.black))
                    
                    Button{
                        
                        handleAction()
                        
                    } label: {
                        HStack {
                            
                            Spacer()
                            
                            Text("Go")
                                .foregroundColor(.black)
                                .padding(.vertical, 10)
                                .font(.system(size: 14, weight: .semibold))
                            
                            Spacer()
                        
                        }.background(Color.blue)
                        
                    }
//                    .alert("Is this your main account?", isPresented: $showAlert) {
//
//                        Button("Yes") {setPrimaries()}
//                        Button("No", role: .cancel) { }
//
//                    }
                    
                    Button{
                        
                        signInWithTouchId()
                        
                    } label: {
                        HStack {
                            
                            Spacer()
                            
                            Text("Sign In With TouchID")
                                .foregroundColor(.black)
                                .padding(.vertical, 10)
                                .font(.system(size: 14, weight: .semibold))
                            
                            Spacer()
                        
                        }.background(Color.blue)
                        
                    }
                    
                    Button{

                        signUpVM.signUpWithGoogle()

                        signedInWithGoogle = true

                        FirebaseManager.shared.auth.signIn(withEmail: signUpVM.userEmail, password: "") { result, err in

                            if let err = err {

                                self.loginStatusMessage = "Failed to log in user: \(err)"
                                return

                            }

                            self.loginStatusMessage = "Successfully logged in as user: \(result?.user.uid ?? "")"

                            self.didCompleteLoginProcess()

                        }

                        userIsLoggedIn = true

                    }label: {

                        Image("signInWithGoogleImage")
                            .resizable()
                            .aspectRatio(contentMode: .fit)

                    }
                    
                    Text(self.loginStatusMessage)
                        .foregroundColor(.red)
                    
                }
                .padding()
            }
            
        }
        .navigationTitle(isLoginMode ? "Log In" : "Create Account")
        .navigationViewStyle(StackNavigationViewStyle())
        .fullScreenCover(isPresented: $shouldShowImagePicker, onDismiss: nil) {
            
            ImagePicker(image: $image)
            
        }
        .fullScreenCover(isPresented: $userIsLoggedIn, onDismiss: nil) {
            
            MainView()
            
        }
        
    }
    
    @State var image: UIImage?
    
    func authenticate(){
        
        let context = LAContext()
        var error: NSError?
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            
            let reason = "Need Touch ID to use biometric authentication"
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, authenticationError in
                
                if success {
                    print("ran auth")
                    print(primaryEmail)
                    print(primaryPassword)
                    FirebaseManager.shared.auth.signIn(withEmail: "ujwalychilla@gmail.com", password: "123123") { result, err in

                        if let err = err {
                            
                            self.loginStatusMessage = "Failed to log in user: \(err)"
                            return
                            
                        }
                        
                        self.loginStatusMessage = "Successfully logged in as user: \(result?.user.uid ?? "")"
                        
                        self.didCompleteLoginProcess()
                        
                    }
                    
                    userIsLoggedIn = true
                    
                }
                
            }
            
        }
        
    }
    
    private func signInWithTouchId(){
        
        authenticate()
        
    }
    
    private func handleAction() {
        
        if isLoginMode {
            
            showAlert = true
            loginUser()
            
        } else {
            
            createNewAccount()
                        
        }
        
    }
    
    private func loginUser() {
                
        FirebaseManager.shared.auth.signIn(withEmail: email, password: password) { result, err in
            
            if let err = err {
                
                self.loginStatusMessage = "Failed to log in user: \(err)"
                return
                
            }
            
            self.loginStatusMessage = "Successfully logged in as user: \(result?.user.uid ?? "")"
            
            self.didCompleteLoginProcess()
            
        }
        
        userIsLoggedIn = true
        
    }
    
    private func setPrimaries(){
        
        primaryEmail = email
        primaryPassword = password
        
        showAlert = false
        userIsLoggedIn = true
        print("ran")
        print(primaryEmail)
        print(primaryPassword)
        
    }
    
    @State var loginStatusMessage = ""
    
    private func createNewAccount() {
        
        if self.image == nil{
            
            self.loginStatusMessage = "You must select a profile picture"
            return
            
        }
        
        FirebaseManager.shared.auth.createUser(withEmail: email, password: password) { result, err in
            
            if let err = err {
                
                self.loginStatusMessage = "Failed to create user: \(err)"
                return
                
            }
            
            self.loginStatusMessage = "Successfully created user: \(result?.user.uid ?? "")"
         
            self.persistImageToStorage()
            
        }
 
    }
    
    private func persistImageToStorage() {
        
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else { return }
        
        let ref = FirebaseManager.shared.storage.reference(withPath: uid)
        guard let imageData = self.image?.jpegData(compressionQuality: 0.5) else { return }
        
        ref.putData(imageData, metadata: nil) { metadata, err in
            
            if let err = err {
                
                self.loginStatusMessage = "Failed to push image to storage: \(err)"
                return
                
            }
            
            ref.downloadURL { url, err in
                
                if let err = err {
                    
                    self.loginStatusMessage = "Failed to retrieve downloadURL: \(err)"
                    return
                    
                }
                
                self.loginStatusMessage = "Successfully stored image with url: \(url?.absoluteString ?? "")"
                
                guard let url = url else { return }
                self.storeUserInformation(imageProfileUrl: url)
                
            }
            
        }
        
    }
    
    private func storeUserInformation(imageProfileUrl: URL){
        
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else { return }
        let userData = ["email": self.email, "uid": uid, "profileImageUrl": imageProfileUrl.absoluteString]
        
        FirebaseManager.shared.firestore.collection("users")
            .document(uid).setData(userData) { err in
                
                if let err = err {
                    
                    self.loginStatusMessage = "\(err)"
                    return
                    
                }
                
                self.didCompleteLoginProcess()
                
            }
        
    }
        
}
 
struct ContentView_Previews: PreviewProvider {
    
    static var previews: some View {
     
        ContentView(didCompleteLoginProcess: {
            
        })
    
    }
 
}
