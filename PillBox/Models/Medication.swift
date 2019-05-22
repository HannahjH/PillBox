//
//  Medication.swift
//  PillBox
//
//  Created by Hannah Hoff on 5/15/19.
//  Copyright © 2019 Hannah Hoff. All rights reserved.
//

import Foundation
import CloudKit

class Medication {
    var name: String
    var notes: String
    var enabled: Bool = true
    var wasTaken: Bool = false
    var alarm: [Alarm]
    let recordID: CKRecord.ID
    
    init(name: String, notes: String, wasTaken: Bool = false, enabled: Bool = true, alarm: [Alarm], recordID: CKRecord.ID = CKRecord.ID(recordName: UUID().uuidString)){
        self.name = name
        self.notes = notes
        self.enabled = enabled
        self.wasTaken = wasTaken
        self.alarm = alarm
        self.recordID = recordID
    }
    
    convenience init?(ckRecord: CKRecord) {
        guard let name = ckRecord[MedicationConstants.nameKey] as? String,
        let notes = ckRecord[MedicationConstants.notesKey] as? String,
        let enabled = ckRecord[MedicationConstants.enabledKey] as? Bool,
        let wasTaken = ckRecord[MedicationConstants.wasTakenKey] as? Bool,
            let alarm = ckRecord[MedicationConstants.alarmKey] as? [Alarm] else { return nil}
        
        self.init(name: name, notes: notes, wasTaken: wasTaken, enabled: enabled, alarm: alarm, recordID: ckRecord.recordID)
    }
    
}

extension CKRecord {
    convenience init(medication: Medication) {
        self.init(recordType: MedicationConstants.recordType, recordID: medication.recordID)
        self.setValue(medication.name, forKey: MedicationConstants.nameKey)
        self.setValue(medication.notes, forKey: MedicationConstants.notesKey)
        self.setValue(medication.enabled, forKey: MedicationConstants.enabledKey)
        self.setValue(medication.wasTaken, forKey: MedicationConstants.wasTakenKey)
        self.setValue(medication.alarm, forKey: MedicationConstants.alarmKey)
    }
}

extension Medication: Equatable {
    static func == (lhs: Medication, rhs: Medication) -> Bool {
        return lhs.name == rhs.name &&
        lhs.notes == rhs.notes &&
        lhs.enabled == rhs.enabled &&
        lhs.wasTaken == rhs.wasTaken
//        lhs.alarm == rhs.alarm
    }
}

struct MedicationConstants {
    static let recordType = "Medication"
    static let nameKey = "name"
    static let notesKey = "notes"
    static let enabledKey = "enabled"
    static let wasTakenKey = "wasTaken"
    static let alarmKey = "alarm"
}
