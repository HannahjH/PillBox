//
//  MedicationDetailViewController.swift
//  PillBox
//
//  Created by Hannah Hoff on 5/20/19.
//  Copyright © 2019 Hannah Hoff. All rights reserved.
//

import UIKit
import CloudKit

protocol AlarmTableViewCellDelegate: class {
    func switchCellSwitchValueChanged(cell: SwitchTableViewCell)
}

protocol MedicationDetailViewControllerDelegate: class {
    func medicationSaved(medication: Medication?)
}

class MedicationDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, AlarmTableViewCellDelegate, SwitchTableViewCellDelegate {
    
    var medication: Medication? {
        didSet {
            loadViewIfNeeded()
            updateViews()
        }
    }
    weak var delegate: MedicationDetailViewControllerDelegate?
    var alarms: [Alarm] = []
//    var medications: [Medication] = []
    
    @IBOutlet weak var alarmTableView: UITableView!
    @IBOutlet weak var medicationTextField: UITextField!
    @IBOutlet weak var notesTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        alarmTableView.dataSource = self
        updateViews()
        AlarmController.shared.fetchAlarm { (success) in
            if success {
                DispatchQueue.main.async {
                    self.alarmTableView.reloadData()
                }
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        alarmTableView.reloadData()
    }
    
//    func medSaved(medication: Medication?) {
//        if let medication = medication {
//            medications.append(medication)
//        }
////        DispatchQueue.main.async {
////            self.tableView.reloadData()
////        }
//    }
    
    @IBAction func doneButtonTapped(_ sender: Any) {
        guard let name = medicationTextField.text,
            !name.isEmpty else { return }
        MedicationController.shared.addMedicationWith(name: name, notes: notesTextView.text, alarm: alarms) { (medication) in
            guard let medication = medication else { return }
            self.delegate?.medicationSaved(medication: medication)
            self.alarms.forEach{ $0.medReference = CKRecord.Reference(recordID: medication.recordID, action: .none) }
        }
            self.navigationController?.popViewController(animated: true)
    }
    
    func switchCellSwitchValueChanged(cell: SwitchTableViewCell) {
        guard let indexPath = alarmTableView.indexPath(for: cell) else { return }
        let alarm = AlarmController.shared.alarms[indexPath.row]
        AlarmController.shared.toggleEnabled(for: alarm)
    }
    
    func updateViews() {
        guard let medication = medication else { return }
        
        medicationTextField.text = medication.name
        notesTextView.text = medication.notes
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return alarms.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "alarmCell", for: indexPath) as? SwitchTableViewCell
        let alarm = alarms[indexPath.row]
        
        cell?.delegate = self
        cell?.timeLabel.text = alarm.fireTimeAsString
        
        return cell ?? UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let alarm = alarms[indexPath.row]
            AlarmController.shared.deleteAlarm(alarm: alarm) { (success) in
                if success {
                    DispatchQueue.main.async {
                        self.alarmTableView.deleteRows(at: [indexPath], with: .fade)
                    }
                }
            }
        }
    }
    
     // MARK: - Navigation
      
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toEditSetAlarmTime" {
            let destinationVC = segue.destination as? SetAlarmTimeViewController
            guard let indexPath = alarmTableView.indexPathForSelectedRow else { return }
            let alarm = AlarmController.shared.alarms[indexPath.row]
            destinationVC?.alarm = alarm
            destinationVC?.delegate = self
        }
        
        if segue.identifier == "toSelectTimeVC" {
            let destinationVC = segue.destination as? SetAlarmTimeViewController
            destinationVC?.delegate = self
        }
//     // Get the new view controller using segue.destination.
//     // Pass the selected object to the new view controller.
     }
}

extension MedicationDetailViewController: SetAlarmTimeViewControllerDelegate {
    
    func alarmSaved(alarm: Alarm?) {
        if let alarm = alarm {
            alarms.append(alarm)
        }
        DispatchQueue.main.async {
            self.alarmTableView.reloadData()            
        }
    }
}
