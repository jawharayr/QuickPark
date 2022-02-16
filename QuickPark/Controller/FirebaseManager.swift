//
//  FirebaseManager.swift
//  QuickPark
//
//  Created by manar . on 16/02/2022.
//

import Foundation
import FirebaseDatabase
import FirebaseStorage

typealias FirebaseCompletion = (_ reference: DatabaseReference, _ error: Error?) -> Void
typealias FirebaseObserverCompletion = (_ key: String, _ value: Any) -> Void
typealias FirebaseStorageCompletion = (_ url: String, _ error: Error?) -> Void
typealias FirebaseUserExistsCompletion = (_ exists : Bool) -> Void


class FirebaseManager: NSObject {
    
    
    var databaseQueryRef: DatabaseQuery?
    var databaseRef : DatabaseReference {
        return Database.database().reference()
    }
    
    static var shared = FirebaseManager()
    
    
    override fileprivate init() {
    }

    
    
    
    
    //Firebase Storage:
    func uploadImageToFirebaseStorage(imageName : String, imageToUpload : UIImage,  withCompletion handler: FirebaseStorageCompletion? = nil){
        var data = NSData()
        data = imageToUpload.jpegData(compressionQuality: 0.5)! as NSData
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpg"
        let storageRef = Storage.storage().reference().child(imageName)
        storageRef.putData(data as Data, metadata: metaData){(metaData,error) in
            if let error = error {
                print(error.localizedDescription)
                return
            }else{
                storageRef.downloadURL(completion: { (url, error) in
                    if (url?.absoluteString) != nil {
                        DispatchQueue.main.async {
                            handler?(url?.absoluteString ?? "not available", error)
                        }
                    }
                })
            }
        }.observe(.progress) { (snapshot) in
            let progress = Float(snapshot.progress?.completedUnitCount ?? 0) / Float(snapshot.progress?.totalUnitCount ?? 1)
            var percent = Int(progress * 100.0)
            percent = (percent > 100) ? 100 : percent
        }
    }
    
}

