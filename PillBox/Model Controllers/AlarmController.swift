//
//  AlarmController.swift
//  PillBox
//
//  Created by Hannah Hoff on 5/20/19.
//  Copyright © 2019 Hannah Hoff. All rights reserved.
//

import Foundation
import UserNotifications
import CloudKit

class AlarmController: AlarmScheduler {
    
    static let shared = AlarmController()
    
    var alarms = [Alarm]()
    
    func saveAlarm(alarm: Alarm, completion: @escaping (Bool) -> ()) {
        let record = CKRecord(alarm: alarm)
        scheduleUserNotifications(for: alarm)
        CKContainer.default().publicCloudDatabase.save(record) { (record, error) in
            if let error = error {
                print("💩 There was an error in \(#function) ; \(error) ; \(error.localizedDescription) 💩")
                completion(false)
                return
            }
            guard let record = record,
                let alarm = Alarm(ckRecord: record) else { completion(false); return }
//            self.alarms.append(alarm)
            completion(true)
        }
    }
    
    func addAlarm(for medication: Medication, fireDate: Date, enabled: Bool, completion: @escaping (Alarm?) -> Void) {
        let alarm = Alarm(fireDate: fireDate, medReference: CKRecord.Reference(recordID: medication.recordID, action: .none))
            alarm.enabled = enabled
        saveAlarm(alarm: alarm) { (success) in
            if success {
                completion(alarm)
            }
        }
//            AlarmController.shared.alarms.append(alarm)
            self.scheduleUserNotifications(for: alarm)
    }
    
    func updateAlarm(alarm: Alarm, fireDate: Date, enabled: Bool, completion: @escaping ((Bool) -> Void)) {
        alarm.fireDate = fireDate
        alarm.enabled = enabled
        scheduleUserNotifications(for: alarm)
        
        CKContainer.default().publicCloudDatabase.fetch(withRecordID: alarm.recordID) { (record, error) in
            if let error = error {
                print("💩 There was an error in \(#function) ; \(error) ; \(error.localizedDescription) 💩")
                completion(false)
                return
            }
            guard let record = record else { completion(false); return }
            record[AlarmConstants.fireDateKey] = fireDate
            record[AlarmConstants.enabledKey] = fireDate
            
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
    
    func toggleEnabled(for alarm: Alarm) {
        alarm.enabled = !alarm.enabled
        
        if alarm.enabled {
            scheduleUserNotifications(for: alarm)
        } else {
            cancelUserNotifications(for: alarm)
        }
    }
    
    func fetchAlarm(completion: @escaping ([Alarm]?) -> Void) {
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: AlarmConstants.recordType, predicate: predicate)
        CKContainer.default().publicCloudDatabase.perform(query, inZoneWith: nil) { (records, error) in
            if let error = error {
                print("💩 There was an error in \(#function) ; \(error) ; \(error.localizedDescription) 💩")
//                completion(false)
                return
            }
            guard let records = records else { completion(nil); return }
            let alarms = records.compactMap{ Alarm(ckRecord: $0)}
            self.alarms = alarms
            completion(alarms)
        }
    }
    
    func deleteAlarm(alarm: Alarm, completion: @escaping (Bool) -> ()) {
        guard let index = AlarmController.shared.alarms.firstIndex(of: alarm) else { return }
        AlarmController.shared.alarms.remove(at: index)
        
        CKContainer.default().publicCloudDatabase.delete(withRecordID: alarm.recordID) { (_, error) in
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

protocol AlarmScheduler: class {
    
    func scheduleUserNotifications(for alarm: Alarm)
    func cancelUserNotifications(for alarm: Alarm)
}

extension AlarmScheduler {
    func scheduleUserNotifications(for alarm: Alarm) {
        let content = UNMutableNotificationContent()
        content.title = "Time to take your meds!"
        content.body = "\(MedicationController.shared.meds)"
        content.sound = UNNotificationSound.default
        
        let components = Calendar.current.dateComponents([.hour, .minute, .second], from: alarm.fireDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        let request = UNNotificationRequest(identifier: alarm.recordID.recordName, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request) { (error) in
            if let error = error {
                print("💩 There was an error in \(#function) ; \(error) ; \(error.localizedDescription) 💩")
            }
        }
    }
    
    func cancelUserNotifications(for alarm: Alarm) { UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [alarm.recordID.recordName])
    }
}
