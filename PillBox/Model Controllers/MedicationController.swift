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
    
    var meds: [Medication] = []
    
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
    
    func addMedicationWith(name: String, notes: String, alarm: [Alarm], completion: @escaping (Medication?) -> Void) {
        guard let currentUser = UserController.shared.currentUser else { completion(nil) ; return }
        let medication = Medication(name: name, notes: notes, alarm: alarm, userReference: CKRecord.Reference(recordID: currentUser.recordID, action: .none))
        saveMed(medication: medication) { (success) in
            if success {
                completion(medication)
            }
        }
    }
    
    func toggleEnabled(for medication: Medication) {
        medication.enabled = !medication.enabled

        if medication.enabled {

        }
    }
    
    func fetchMedication(completion: @escaping (Bool) -> ()) {
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: MedicationConstants.recordType, predicate: predicate)
        CKContainer.default().publicCloudDatabase.perform(query, inZoneWith: nil) { (records, error) in
            if let error = error {
                print("💩 There was an error in \(#function) ; \(error) ; \(error.localizedDescription) 💩")
                completion(false)
                return
            }
            
            guard let records = records else { completion(false); return }
            let medications = records.compactMap{ Medication(ckRecord: $0)}
            self.meds = medications
            completion(true)
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

