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
    var enabled: Bool
    var wasTaken: Bool
    var fireTime: Date
    let recordID: CKRecord.ID
    
    var fireTimeAsString: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter.string(from: fireTime)
    }
    
    init(name: String, notes: String, enabled: Bool, wasTaken: Bool, fireTime: Date, recordID: CKRecord.ID = CKRecord.ID(recordName: UUID().uuidString)){
        self.name = name
        self.notes = notes
        self.enabled = enabled
        self.wasTaken = wasTaken
        self.fireTime = fireTime
        self.recordID = recordID
    }
    
    convenience init?(ckRecord: CKRecord) {
        guard let name = ckRecord[MedicationConstants.nameKey] as? String,
        let notes = ckRecord[MedicationConstants.notesKey] as? String,
        let enabled = ckRecord[MedicationConstants.enabledKey] as? Bool,
        let wasTaken = ckRecord[MedicationConstants.wasTakenKey] as? Bool,
            let fireTime = ckRecord[MedicationConstants.fireTimeKey] as? Date else { return nil}
        
        self.init(name: name, notes: notes, enabled: enabled, wasTaken: wasTaken, fireTime: fireTime, recordID: ckRecord.recordID)
    }
    
}

extension CKRecord {
    convenience init(medication: Medication) {
        self.init(recordType: MedicationConstants.recordType, recordID: medication.recordID)
        self.setValue(medication.name, forKey: MedicationConstants.nameKey)
        self.setValue(medication.notes, forKey: MedicationConstants.notesKey)
        self.setValue(medication.enabled, forKey: MedicationConstants.enabledKey)
        self.setValue(medication.wasTaken, forKey: MedicationConstants.wasTakenKey)
        self.setValue(medication.fireTime, forKey: MedicationConstants.fireTimeKey)
    }
}

extension Medication: Equatable {
    static func == (lhs: Medication, rhs: Medication) -> Bool {
        return lhs.name == rhs.name &&
        lhs.notes == rhs.notes &&
        lhs.enabled == rhs.enabled &&
        lhs.wasTaken == rhs.wasTaken &&
        lhs.fireTime == rhs.fireTime
    }
}

struct MedicationConstants {
    static let recordType = "Medication"
    static let nameKey = "name"
    static let notesKey = "notes"
    static let enabledKey = "enabled"
    static let wasTakenKey = "wasTaken"
    static let fireTimeKey = "fireTime"
}
