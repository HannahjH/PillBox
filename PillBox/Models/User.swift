//
//  User.swift
//  PillBox
//
//  Created by Hannah Hoff on 5/15/19.
//  Copyright © 2019 Hannah Hoff. All rights reserved.
//

import Foundation
import CloudKit

class User {
    var secondaryUser: [String]
//    var medication: [Medication : [Alarm]]
    /* Medication Model w/ name: String,  */
    var name: String
    var email: String
    let recordID: CKRecord.ID
    var appleUserRef: CKRecord.Reference
    
    init(secondaryUser: [String], name: String, email: String, recordID: CKRecord.ID = CKRecord.ID(recordName: UUID().uuidString), appleUserRef: CKRecord.Reference) {
        self.secondaryUser = secondaryUser
        self.name = name
        self.email = email
        self.recordID = recordID
        self.appleUserRef = appleUserRef
    }
    
    convenience init?(ckRecord: CKRecord) {
        guard let secondaryUser = ckRecord[UserConstants.secondaryUserKey] as? [String],
        let name = ckRecord[UserConstants.nameKey] as? String,
        let email = ckRecord[UserConstants.emailKey] as? String,
        let appleUserRef = ckRecord[UserConstants.appleUserRefKey] as? CKRecord.Reference else { return nil }
        
        self.init(secondaryUser: secondaryUser, name: name, email: email, recordID: ckRecord.recordID, appleUserRef: appleUserRef)
        
    }
    
}

extension CKRecord {
    convenience init(user: User) {
        self.init(recordType: UserConstants.recordType, recordID: user.recordID)
        self.setValue(user.secondaryUser, forKey: UserConstants.secondaryUserKey)
        self.setValue(user.name, forKey: UserConstants.nameKey)
        self.setValue(user.email, forKey: UserConstants.emailKey)
        self.setValue(user.appleUserRef, forKey: UserConstants.appleUserRefKey)
    }
}

struct UserConstants {
    static let recordType = "User"
    static let secondaryUserKey = "secondaryUser"
    static let nameKey = "name"
    static let emailKey = "email"
    static let appleUserRefKey = "appleUserRef"
}
