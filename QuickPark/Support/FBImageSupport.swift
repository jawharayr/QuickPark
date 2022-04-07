//
//  FBImageSupport.swift
//  QuickPark
//
//  Created by Ghaliah on 07/04/22.
//

import Firebase

struct FBUploadManager {
    public static func imageDataLessThan1MB(_ image:UIImage) -> Data? {
        return image.jpegData(compressionQuality: 0.35)
    }
    
    public static func upload(_ image : UIImage, path:String, complition:@escaping (_ path:String?, Error?) -> Void) {
        guard let imageData = imageDataLessThan1MB(image) else {
            complition(nil, nil)
            return}
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        let storage = Storage.storage()
        let imageRef = storage.reference().child(path)
        imageRef.putData(imageData, metadata: nil) { metaData, error in
            guard error == nil else {
                complition(nil, error)
                return
            }
            imageRef.downloadURL { url, error in
                guard let downloadURL = url else {
                    // Uh-oh, an error occurred!
                    return
                }
                complition(downloadURL.absoluteString, nil)
            }
        }
    }
}

struct FBDownloadImage {
    public static func downloadImage(_ url:String, complition:@escaping(UIImage?, Error?) -> Void) {
        Storage.storage().reference().child(url).getData(maxSize: 3*1024*1024) { imageData, error in
            if let d = imageData,  let i = UIImage(data: d) {
                complition(i, nil)
            } else{
                complition(nil, error)
            }
        }
    }
}
