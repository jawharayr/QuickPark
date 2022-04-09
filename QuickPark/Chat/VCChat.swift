import UIKit
import InputBarAccessoryView
import Firebase
import MessageKit
import FirebaseFirestore

//MARK: -
class Chat {
    let users: [String]
    var dictionary: [String: Any] {
        return ["users": users]
    }
    
    var documentID:String?
    var otherUser : QPUser?
    var unreadCount : Int?
    
    init(dictionary: [String:Any]) {
        if let chatUsers = dictionary["users"] as? [String] {
            users = chatUsers
        }
        else {
            users = []
        }
    }
}

extension Chat {
    func loadOtherUser(_ complition:@escaping(QPUser)->()) {
        guard let uid = Auth.auth().currentUser?.uid, let otherUserID = (self.users.filter { $0 != uid}).last else {
            return
        }
        
        Firestore.firestore().collection("users").whereField("uid", isEqualTo: otherUserID).getDocuments { querySnapshot, error in
            if let e = error {
                print("Error:", e.localizedDescription)
            }else{
                guard let user = querySnapshot?.documents.first  else {return}
                //"users/\(user?.documentID)"
                let name = (user["name"] as? String) ?? ""
                let email = (user["email"] as? String) ?? ""
                let uid = (user["uid"] as? String) ?? ""
                let ou = QPUser(name: name, email: email, uid: uid)
                self.otherUser = ou
                complition(ou)
            }
        }
    }
    
    func unreadMessageCount(_ complition:@escaping(Int)->()) {
        guard let uid = Auth.auth().currentUser?.uid, let otherUserID = (self.users.filter { $0 != uid}).last else {
            return
        }
        
        Firestore.firestore().collection("Chats").whereField("uid", isEqualTo: otherUserID).getDocuments { querySnapshot, error in
            if let e = error {
                print("Error:", e.localizedDescription)
            }else{
                guard let user = querySnapshot?.documents.first  else {return}
                complition(0)
            }
        }
    }
}
//MARK: -
//struct User: Codable {
//    var uid: String
//    var name: String
//    var email : String
//}

//MARK: -
struct ChatUser: SenderType, Equatable {
    var senderId: String
    var displayName: String = ""
    var uid : String {return senderId}
}

//MARK: -
struct Message {
    var id: String
    var content: String
    var created: Timestamp
    var senderID: String
    var senderName: String
    var isRead : Bool
    var imagePath : String?
    
    var dictionary: [String: Any] {
        get {
            var d : [String : Any] = [
                "id": id,
                "content": content,
                "created": created,
                "senderID": senderID,
                "senderName":senderName,
                "isRead": isRead,
            ]
            if let ip = imagePath {
                d["imagePath"] = ip
            }
            return d
        }
        
    }

}

extension Message {
    init?(dictionary: [String: Any]) {
        guard let id = dictionary["id"] as? String,
              let content = dictionary["content"] as? String,
              let created = dictionary["created"] as? Timestamp,
              let senderID = dictionary["senderID"] as? String,
              let senderName = dictionary["senderName"] as? String,
              let isRead = dictionary["isRead"] as? Bool
        else {return nil}
        if let imagePath = dictionary["imagePath"] as? String {
            self.init(id: id, content: content, created: created, senderID: senderID, senderName:senderName, isRead  : isRead, imagePath:imagePath)
        } else {
            self.init(id: id, content: content, created: created, senderID: senderID, senderName:senderName, isRead  : isRead)
        }
    }
}

private struct ImageMediaItem: MediaItem {
    var url: URL?
    var image: UIImage?
    var placeholderImage: UIImage
    var size: CGSize

    init(image: UIImage) {
        self.image = image
        self.size = CGSize(width: 240, height: 240)
        self.placeholderImage = UIImage()
    }

    init(imageURL: URL) {
        self.url = imageURL
        self.size = CGSize(width: 240, height: 240)
        self.placeholderImage = UIImage(named: "angle-mask") ?? UIImage()
    }
}

//MARK: -
extension Message: MessageType {
    var sender: SenderType {
        return ChatUser(senderId: senderID, displayName: senderName)
    }
    
    var messageId: String {
        return id
    }
    var sentDate: Date {
        return created.dateValue()
    }
    var kind: MessageKind {
        get {
            //print()
            if let ip = imagePath, let u = URL(string: ip) {
                return .photo(ImageMediaItem(imageURL: u))
            }
            return .text(content)
        }
    }
}

extension UIImageView {
  func load(url: URL) {
    DispatchQueue.global().async { [weak self] in
        if let data = try? Data(contentsOf: url) {
            if let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    self?.image = image
                }
            }
        }
     }
   }
 }

//MARK: -
class ChatViewController: MessagesViewController, InputBarAccessoryViewDelegate, UIAdaptivePresentationControllerDelegate {
    var currentUser = FBAuth.currentUser!
    var otherUser : ChatUser!
    private var docReference: DocumentReference?
    var messages: [Message] = []
    var newMessageListner : ListenerRegistration?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = (otherUser.displayName.count > 0) ? otherUser.displayName : "User"
        
        navigationItem.largeTitleDisplayMode = .never
        maintainPositionOnKeyboardFrameChanged = true
        scrollsToLastItemOnKeyboardBeginsEditing = true
        
        messageInputBar.inputTextView.tintColor = .systemBlue
        messageInputBar.inputTextView.delegate = self
        messageInputBar.sendButton.setTitleColor(.systemTeal, for: .normal)
        messageInputBar.delegate = self
        
        let image = UIImage(systemName: "plus.circle")
        let button = InputBarButtonItem(frame: CGRect(origin: .zero, size: CGSize(width: 32, height: 32)))
        let action = #selector(showImagePickerControllerActionSheet)
        button.addTarget(self, action: action, for: .touchUpInside)
        button.image = image
        button.imageView?.contentMode = .scaleAspectFit

        messageInputBar.setStackViewItems([button], forStack: .left, animated: false)
        messageInputBar.setLeftStackViewWidthConstant(to: 50, animated: false)
        messageInputBar.setRightStackViewWidthConstant(to: 50, animated: false)

        messageInputBar.leftStackView.alignment = .center //HERE
        messageInputBar.rightStackView.alignment = .center //HERE

        reloadInputViews()
        
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        
        loadChat()
        
        if let mcl = messagesCollectionView.collectionViewLayout as? MessagesCollectionViewFlowLayout {
            mcl.textMessageSizeCalculator.outgoingAvatarSize = .zero
//            mcl.textMessageSizeCalculator.messae
            mcl.textMessageSizeCalculator.incomingAvatarSize = .zero
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.newMessageListner?.remove()
    }
    
    // MARK: - Custom messages handlers
    
    func createNewChat() {
        let users = [self.currentUser.uid, self.otherUser.uid]
        let data: [String: Any] = [
            "users":users
        ]
        
        let db = Firestore.firestore().collection("Chats")
        db.addDocument(data: data) { (error) in
            if let error = error {
                print("Unable to create chat! \(error)")
                return
            } else {
                self.loadChat()
            }
        }
    }
    
    func loadChat() {
        
        //Fetch all the chats which has current user in it
        let db = Firestore.firestore().collection("Chats")
            .whereField("users", arrayContains: currentUser.uid)
        
        
        db.getDocuments { (chatQuerySnap, error) in
            
            if let error = error {
                print("Error: \(error)")
                return
            } else {
                
                //Count the no. of documents returned
                guard let queryCount = chatQuerySnap?.documents.count else {
                    return
                }
                
                if queryCount == 0 {
                    //If documents count is zero that means there is no chat available and we need to create a new instance
                    self.createNewChat()
                }
                else if queryCount >= 1 {
                    //Chat(s) found for currentUser
                    for doc in chatQuerySnap!.documents {
                        
                        let chat = Chat(dictionary: doc.data())
                        
                        //Get the chat which has user2 id
                        if ((chat.users.contains(self.otherUser.uid))) {
                            self.docReference = doc.reference
                        
                            //fetch it's thread collection
                            self.newMessageListner = doc.reference.collection("thread")
                                .order(by: "created", descending: false)
                                .addSnapshotListener(includeMetadataChanges: true, listener: { (threadQuery, error) in
                                    if let error = error {
                                        print("Error: \(error)")
                                        return
                                    } else {
                                        self.messages.removeAll()
                                        if FBAuth.isAdmin == false {
                                            let initialMessage = Message(id: "OM1", content: "Support Team will contact you shortly!. Please specify your issue in detail.", created: Timestamp(date: Date()), senderID: self.otherUser.uid, senderName: "", isRead: true)
                                            self.messages.append(initialMessage)
                                            self.messagesCollectionView.reloadData()
                                        }
                                        for message in threadQuery!.documents {
                                            var msg = Message(dictionary: message.data())
                                            if msg?.senderID != self.currentUser.uid && msg?.isRead == false {
                                                msg?.isRead = true
                                                if let d = msg?.dictionary {
                                                    message.reference.updateData(d)
                                                }
                                            }
                                            self.messages.append(msg!)
                                        }
                                        self.messagesCollectionView.reloadData()
                                        self.messagesCollectionView.scrollToLastItem(at: .bottom, animated: true)
                                    }
                                })
                            //list.remove()
                            return
                        } //end of if
                    } //end of for
                    self.createNewChat()
                } else {
                    print("Let's hope this error never prints!")
                }
            }
        }
    }
    
    
    private func insertNewMessage(_ message: Message) {
        messages.append(message)
        DispatchQueue.main.async {
            self.messagesCollectionView.reloadData()
            self.messagesCollectionView.scrollToLastItem(at: .bottom, animated: true)
        }
    }
    
    private func save(_ message: Message) {
        docReference?.collection("thread").addDocument(data: message.dictionary, completion: { (error) in
            if let error = error {
                print("Error Sending message: \(error)")
                return
            }
            self.messagesCollectionView.scrollToLastItem(at: .bottom, animated: true)
            self.triggerNotification(message: message)
        })
    }
    
    func triggerNotification(message:Message)  {
        let db = Firestore.firestore()
        
        //
        db.collection("users").whereField("uid", isEqualTo: otherUser.uid).getDocuments { (querySnapshot, error) in
            if let error = error {
                //Display Error
                print(error)
            } else {
                guard let user = querySnapshot?.documents.first, let fcmToken = user["fcmToken"] as? String else {
                    return
                }
                PushNotificationSender.sendPushNotification(to: fcmToken, title: "", body: //"\(self.currentUser.displayName ?? "") send you a message")
                        " you have a new message")
            }
        }
    }
    
    // MARK: - InputBarAccessoryViewDelegate
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        let message = Message(id: UUID().uuidString, content: text, created: Timestamp(), senderID: currentUser.uid, senderName: currentUser.displayName ?? "_", isRead: false)
        
        //messages.append(message)
        insertNewMessage(message)
        save(message)
        
        inputBar.inputTextView.text = ""
        messagesCollectionView.reloadData()
        messagesCollectionView.scrollToBottom(animated: true)
    }
}

extension  ChatViewController:  UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        var updatedText = textView.text ?? ""
        if let textRange = Range(range, in:updatedText) {
            updatedText = updatedText.replacingCharacters(in: textRange, with: text)
        }
        if updatedText.count > 240 {return false}
        
        return true
    }
}

// MARK: - MessagesDisplayDelegate
extension ChatViewController : MessagesDisplayDelegate {
    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return isFromCurrentSender(message: message) ? #colorLiteral(red: 0.1039655283, green: 0.40598014, blue: 0.8277289271, alpha: 1) : #colorLiteral(red: 0.6924675703, green: 0.8397012353, blue: 0.9650663733, alpha: 1)
    }
    
    func messageStyle(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
        let corner : MessageStyle.TailCorner = isFromCurrentSender(message: message) ? .bottomRight : .bottomLeft
        return .bubbleTail(corner, .curved)
    }
    
    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        avatarView.isHidden = true
    }
}

// MARK: - MessagesLayoutDelegate
extension ChatViewController : MessagesLayoutDelegate {
    func avatarSize(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGSize {
        return .zero
    }
    
    func cellTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        return NSAttributedString(string: "\(self.messages[indexPath.section].sentDate.displayString())", attributes: [.font : UIFont.preferredFont(forTextStyle: .caption1),                         .foregroundColor: UIColor.lightGray])
    }
    
    func cellTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 24
    }
    
    func messageTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 20
    }
    
    func messageBottomLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 24
    }
}

// MARK: - MessagesDataSource
extension ChatViewController : MessagesDataSource {
    func currentSender() -> SenderType {
        return ChatUser(senderId: currentUser.uid, displayName: currentUser.displayName ?? "Chat")
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messages[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        if messages.count == 0 {
            print("No messages to display")
            return 0
        } else {
            return messages.count
        }
    }
    
    func messageBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        if isFromCurrentSender(message: message) {
            let m = self.messages[indexPath.section]
            let paragraph = NSMutableParagraphStyle()
            paragraph.alignment = .right
            print("-", m.content, m.isRead)
            return NSAttributedString(string: (m.isRead ? "Read" : "Sent" ), attributes: [.font : UIFont.preferredFont(forTextStyle: .caption1), .foregroundColor: (m.isRead ? #colorLiteral(red: 0.2745098174, green: 0.4862745106, blue: 0.1411764771, alpha: 1) : #colorLiteral(red: 0.1411764771, green: 0.3960784376, blue: 0.5647059083, alpha: 1)), .paragraphStyle:paragraph
            ])
        }
        return nil
    }
    
    func configureMediaMessageImageView(_ imageView: UIImageView,
                                        for message: MessageType,
                                        at indexPath: IndexPath,
                                        in messagesCollectionView: MessagesCollectionView) {
        /*acquire url for the image in my case i had a
        custom type Message which stored  the image url */
        guard
            let msg = message as? Message,
            let ip = msg.imagePath,
            let url = URL(string: ip)
        else { return }
        imageView.load(url: url)
    }
}


extension ChatViewController : UIImagePickerControllerDelegate , UINavigationControllerDelegate {
    @objc  func showImagePickerControllerActionSheet()  {
        let alertVC = UIAlertController(title: "Choose Your Image", message: nil, preferredStyle: .actionSheet)
        let photoLibraryAction = UIAlertAction(title: "Choose From Library", style: .default) { [weak self] action in
            self?.showImagePickerController(sourceType: .photoLibrary)
        }
        alertVC.addAction(photoLibraryAction)
        let cancelAction = UIAlertAction(title: "Cancel", style: .default , handler: nil)
        alertVC.addAction(cancelAction)
        self.present(alertVC, animated: true, completion: nil)
    }
    
    func showImagePickerController(sourceType: UIImagePickerController.SourceType){
        let imgPicker = UIImagePickerController()
        imgPicker.delegate = self
        imgPicker.allowsEditing = true
        imgPicker.sourceType = sourceType
        imgPicker.presentationController?.delegate = self
        inputAccessoryView?.isHidden = true
        self.present(imgPicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let editedImage = info[  UIImagePickerController.InfoKey.editedImage] as? UIImage {
            self.sendImageMessage(photo: editedImage)
        }
        else if let originImage = info[  UIImagePickerController.InfoKey.originalImage] as? UIImage {
            self.sendImageMessage(photo: originImage)
        }
        self.dismiss(animated: true, completion: nil)
        inputAccessoryView?.isHidden = false
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
        inputAccessoryView?.isHidden = false
    }
    
    func sendImageMessage( photo  : UIImage)  {
        let path = "chat/pictures/\(UUID()).jpeg"
        FBUploadManager.upload(photo, path: path) { path, error in
            guard let p = path else {
                print ("Error = ", error ?? "Error")
                return
            }
            let message = Message(id: UUID().uuidString, content: "", created: Timestamp(), senderID: self.currentUser.uid, senderName: self.currentUser.displayName ?? "_", isRead: false, imagePath: p)
            self.save(message)
            self.insertNewMessage(message)
        }
    }
}
