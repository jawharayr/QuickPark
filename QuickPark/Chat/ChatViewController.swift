import UIKit
import InputBarAccessoryView
import Firebase
import MessageKit
import FirebaseFirestore
import SDWebImage

class VCChat: MessagesViewController, InputBarAccessoryViewDelegate, MessagesDataSource, MessagesLayoutDelegate, MessagesDisplayDelegate {
    var currentUser: User = Auth.auth().currentUser!
    var user2Name: String?
    var user2ImgUrl: String?
    var user2UID: String?
    
    private var docReference: DocumentReference?
    
    var messages: [Message] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = user2Name ?? "Chat"

        navigationItem.largeTitleDisplayMode = .never
        maintainPositionOnKeyboardFrameChanged = true
        scrollsToLastItemOnKeyboardBeginsEditing = true

        messageInputBar.inputTextView.tintColor = .systemBlue
        messageInputBar.sendButton.setTitleColor(.systemTeal, for: .normal)
        
        messageInputBar.delegate = self
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        
        loadChat()
        
    }
