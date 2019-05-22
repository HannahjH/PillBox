//
//  Alarm.swift
//  PillBox
//
//  Created by Hannah Hoff on 5/17/19.
//  Copyright © 2019 Hannah Hoff. All rights reserved.
//

import Foundation
import CloudKit

class Alarm {
    var fireDate: Date
    var enabled: Bool
    let recordID: CKRecord.ID
    
    var fireTimeAsString: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter.string(from: fireDate)
    }
    
    init(fireDate: Date, enabled: Bool = true, recordID: CKRecord.ID = CKRecord.ID(recordName: UUID().uuidString)){
        self.fireDate = fireDate
        self.enabled = enabled
        self.recordID = recordID
    }
    
    convenience init?(ckRecord: CKRecord) {
        guard let fireDate = ckRecord[AlarmConstants.fireDateKey] as? Date,
            let enabled = ckRecord[AlarmConstants.enabledKey] as? Bool else { return nil }
        
        self.init(fireDate: fireDate, enabled: enabled, recordID: ckRecord.recordID)
    }
}

extension CKRecord {
    convenience init(alarm: Alarm) {
        self.init(recordType: AlarmConstants.recordType, recordID: alarm.recordID)
        self.setValue(alarm.fireDate, forKey: AlarmConstants.fireDateKey)
        self.setValue(alarm.enabled, forKey: AlarmConstants.enabledKey)
    }
}

extension Alarm: Equatable {
    static func == (lhs: Alarm, rhs: Alarm) -> Bool {
        return lhs.fireDate == rhs.fireDate &&
        lhs.enabled == rhs.enabled
    }
}

struct AlarmConstants {
    static let recordType = "Alarm"
    static let fireDateKey = "fireDateKey"
    static let enabledKey = "enabled"
}
