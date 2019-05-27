//
//  MedicationController.swift
//  PillBox
//
//  Created by Hannah Hoff on 5/15/19.
//  Copyright © 2019 Hannah Hoff. All rights reserved.
//

import Foundation
import CloudKit

class MedicationController {
    
    static let shared = MedicationController()
    
    var meds = [Medication]()
    
    let userTookMedsNotification = Notification.Name("userTookMeds")
    
    var medications: Medication? {
        didSet {
            NotificationCenter.default.post(name: userTookMedsNotification, object: nil)
        }
    }
    
    func saveMed(medication: Medication, completion: @escaping (Bool) -> ()) {
        let record = CKRecord(medication: medication)
        CKContainer.default().publicCloudDatabase.save(record) { (record, error) in
            if let error = error {
                print("💩 There was an error in \(#function) ; \(error) ; \(error.localizedDescription) 💩")
                completion(false)
                return
            }
            
            guard let record = record,
                let medication = Medication(ckRecord: record) else { completion(false); return }
            self.meds.append(medication)
            completion(true)
        }
    }
    
    func addMedicationWith(name: String, notes: String, completion: @escaping (Medication?) -> Void) {
        guard let currentUser = UserController.shared.currentUser else { completion(nil) ; return }
        let medication = Medication(name: name, notes: notes, userReference: CKRecord.Reference(recordID: currentUser.recordID, action: .none))
        saveMed(medication: medication) { (success) in
            if success {
                completion(medication)
            }
        }
        #warning("Call scheduleUserNotifications here? Might call the notification twice")
        // scheduleUserNotifications????
    }
    
    func updateMedications(medication: Medication, name: String, notes: String, completion: @escaping ((Bool) -> Void)) {
        medication.name = name
        medication.notes = notes
        
        CKContainer.default().publicCloudDatabase.fetch(withRecordID: medication.recordID) { (record, error) in
            if let error = error {
                print("💩 There was an error in \(#function) ; \(error) ; \(error.localizedDescription) 💩")
                completion(false)
                return
            }
            guard let record = record else { completion(false); return }
            record[MedicationConstants.nameKey] = name
            record[MedicationConstants.notesKey] = notes
            
            let operation = CKModifyRecordsOperation(recordsToSave: [record], recordIDsToDelete: nil)
            operation.savePolicy = .changedKeys
            operation.queuePriority = .high
            operation.qualityOfService = .userInitiated
            operation.modifyRecordsCompletionBlock = { (records, recirdsIDs, error) in
                completion(true)
            }
            CKContainer.default().publicCloudDatabase.add(operation)
        }
    }
    
    func fetchMedication(completion: @escaping ([Medication]?) -> Void) {
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: MedicationConstants.recordType, predicate: predicate)
        CKContainer.default().publicCloudDatabase.perform(query, inZoneWith: nil) { (records, error) in
            if let error = error {
                print("💩 There was an error in \(#function) ; \(error) ; \(error.localizedDescription) 💩")
//                completion(false)
                return
            }

            guard let records = records else { completion(nil); return }
            let medications = records.compactMap{ Medication(ckRecord: $0)}
            self.meds = medications
            completion(medications)
        }
    }
    
    func toggleEnabled(for medication: Medication) {
        medication.enabled = !medication.enabled
        
        if medication.enabled {
        }
    }
    
    func deleteMedication(medication: Medication, completion: @escaping (Bool) -> ()) {
        guard let index = MedicationController.shared.meds.firstIndex(of: medication) else { return }
        MedicationController.shared.meds.remove(at: index)
        
        CKContainer.default().publicCloudDatabase.delete(withRecordID: medication.recordID) { (_, error) in
            if let error = error {
                print("💩 There was an error in \(#function) ; \(error) ; \(error.localizedDescription) 💩")
                completion(false)
                return
            } else {
                completion(true)
            }
        }
    }
}

