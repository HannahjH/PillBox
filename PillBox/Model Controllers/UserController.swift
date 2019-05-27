//
//  UserController.swift
//  PillBox
//
//  Created by Hannah Hoff on 5/15/19.
//  Copyright © 2019 Hannah Hoff. All rights reserved.
//

import Foundation
import CloudKit

class UserController {
    
    static let shared = UserController()
    
    var users = [User]()
    // var medication = [Medication]()?????
    
    let currentUserWasSetNotification = Notification.Name("currentUserWasSet")
    
    var currentUser: User? {
        didSet {
            NotificationCenter.default.post(name: currentUserWasSetNotification, object: nil)
        }
    }
    
    func save(user: User, completion: @escaping (Bool) -> ()) {
        let record = CKRecord(user: user)
        CKContainer.default().publicCloudDatabase.save(record) { (record, error) in
            if let error = error {
                print("💩 There was an error in \(#function) ; \(error) ; \(error.localizedDescription) 💩")
                completion(false)
                return
            }
            
            guard let record = record,
                let user = User(ckRecord: record) else { completion(false); return }
            self.users.append(user)
            completion(true)
        }
    }
    
    func createUserWith(name: String, email: String, completion: ((Bool) -> Void)?) {
        CKContainer.default().fetchUserRecordID { (recordID, error) in
            if let error = error {
                print("💩 There was an error in \(#function) ; \(error) ; \(error.localizedDescription) 💩")
                completion?(false)
                return
            }
            
            guard let recordID = recordID else { completion?(false); return }
            let appleUserRef = CKRecord.Reference(recordID: recordID, action: .deleteSelf)
            let user = User(name: name, email: email, appleUserRef: appleUserRef)
            let userRecord = CKRecord(user: user)
            CKContainer.default().publicCloudDatabase.save(userRecord, completionHandler: { (record, error) in
                if let error = error {
                    print("💩 There was an error in \(#function) ; \(error) ; \(error.localizedDescription) 💩")
                    completion?(false)
                    return
                }
            })
        }
    }
    
//    func createUserWithShared(name: String, email: String, completion: ((Bool) -> Void)?) {
//        let container = CKContainer.default()
//        let privateDatabase = container.privateCloudDatabase
//        let customZone = CKRecordZone(zoneName: "SharedZone")
//
//        privateDatabase.save(customZone) { (returnRecord, error) in
//            completion?(true)
//        }
//    }
    
    func fetchCurrentUser(completion: @escaping (Bool) -> Void) {
        CKContainer.default().fetchUserRecordID { (recordID, error) in
            if let error = error {
                print("💩 There was an error in \(#function) ; \(error) ; \(error.localizedDescription) 💩")
                completion(false)
                return
            }
            guard let appleUserRecordID = recordID else { completion(false); return }
            let applueUserReference = CKRecord.Reference(recordID: appleUserRecordID, action: .deleteSelf)
            
            let predicate = NSPredicate(format: "%K == %@", UserConstants.appleUserRefKey, applueUserReference)
            let query = CKQuery(recordType: UserConstants.recordType, predicate: predicate)
            CKContainer.default().publicCloudDatabase.perform(query, inZoneWith: nil, completionHandler: { (records, error) in
                if let error = error {
                    print("💩 There was an error in \(#function) ; \(error) ; \(error.localizedDescription) 💩")
                    completion(false)
                    return
                }
                
                guard let record = records?.first else { completion(false); return }
                let user = User(ckRecord: record)
                self.currentUser = user
                completion(true)
            })
        }
    }
}

//extension UserController {
//
//    func share() {
//    let share = CKShare(rootRecord: userRecord)
//    share[CKShareTitleKey] = "Some title" as CKRecordValue?share[CKShareTypeKey] = "Some type" as CKRecordValue?
//        let sharingController = cloudSharingController.self
//    (preparationHandler: {(UICloudSharingController, handler: @escaping (CKShare?, CKContainer?, Error?) -> Void) in
//    let modifyOp = CKModifyRecordsOperation(recordsToSave: [employeeRecord, share], recordIDsToDelete: nil)
//    modifyOp.modifyRecordsCompletionBlock = { (record, recordID, error) in
//    handler(share, CKContainer.default(), error)
//    }
//
//    CKContainer.default().privateCloudDatabase.add(modifyOp)
//    })
//
//    sharingController.availablePermissions = [.allowReadWrite, .allowPrivate]
//    sharingController.delegate = self
//    self.present(sharingController, animated:true, completion:nil)
//    }
//    func cloudSharingController(_ controller: UICloudSharingController, failedToSaveShareWithError error: Error) {
//        // Failed to save, handle the error better than I did :-)
//        // Also, this method is required!
//        print(error)
//    }
//    //    func itemThumbnailData(for: UICloudSharingController) -> Data? {
//    //        // This sets the image in the middle, nil is the default
//    //        //document image you see, this method is not required
//    //        return nil
//    //    }
//    func itemTitle(for: UICloudSharingController) -> String? {
//        // Set the title here, this method is required!
//        // returning nil or failing to implement delegate methods
//        //results in "Untitled"
//        return "Alice Campbell"
//    }
//}
