//
//  Message.swift
//  Showupia
//
//  Created by Chaudhry Talha on 5/25/21.
//

import UIKit
import Firebase
import MessageKit

struct Message {
    var id: String
    var content: String
    var created: Timestamp
    var senderID: String
    var senderName: String
    var imagePath: String?

    var dictionary: [String: Any] {
        get {
            var d = [
                "id": id,
                "content": content,
                "created": created,
                "senderID": senderID,
                "senderName":senderName] as [String : Any]
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
              let senderName = dictionary["senderName"] as? String
        else {return nil}
        let imagePath = dictionary["imagePath"] as? String
        self.init(id: id, content: content, created: created, senderID: senderID, senderName:senderName, imagePath:imagePath)
    }
}

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
//        if let ip = imagePath, let url = URL(string: ip) {
//            return .photo(MediaItem.):
//        }
        
        return .text(content)
    }
}
