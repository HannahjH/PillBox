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
