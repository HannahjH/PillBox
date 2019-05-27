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

//protocol MedicationDetailViewControllerDelegate: class {
//    func medicationSaved(medication: Medication?)
//}

class MedicationDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, AlarmTableViewCellDelegate, SwitchTableViewCellDelegate {
    
    var medication: Medication? {
        didSet {
            loadViewIfNeeded()
            updateViews()
        }
    }
    var alarms: [Alarm] = []
//    var medications: [Medication] = []
    
    @IBOutlet weak var alarmTableView: UITableView!
    @IBOutlet weak var medicationTextField: UITextField!
    @IBOutlet weak var notesTextView: UITextView!
    @IBOutlet weak var addAlarmButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        alarmTableView.dataSource = self
        //        updateViews()
        //        alarmTableView.isHidden = true
        addAlarmButton.isHidden = true
        AlarmController.shared.fetchAlarm { (success) in
                DispatchQueue.main.async {
//                    self.alarms = AlarmController.shared.alarms
                    self.alarmTableView.reloadData()
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        self.alarms = AlarmController.shared.alarms
        alarmTableView.reloadData()
    }
    
    @IBAction func saveButtonTapped(_ sender: Any) {
        guard let name = medicationTextField.text,
            let notes = notesTextView.text
            else { return }
        
        if let medication = medication {
            MedicationController.shared.updateMedications(medication: medication, name: name, notes: notes) { (success) in
                if success {
                    DispatchQueue.main.async {
                        self.navigationController?.popViewController(animated: true)
                    }
                }
            }
        } else {
            MedicationController.shared.addMedicationWith(name: name, notes: notes) { (medication) in
                guard let medication = medication else { return }
                self.medication = medication
                AlarmController.shared.alarms.forEach { $0.medReference = CKRecord.Reference(recordID: medication.recordID, action: .none) }
                    DispatchQueue.main.async {
                        self.alertController()
                        
                    }
                }
            }
        }
    
    func switchCellSwitchValueChanged(cell: SwitchTableViewCell) {
        guard let indexPath = alarmTableView.indexPath(for: cell) else { return }
        let alarm = AlarmController.shared.alarms[indexPath.row]
        AlarmController.shared.toggleEnabled(for: alarm)
    }
    
    func updateViews() {
        guard let medication = medication else { return }
        DispatchQueue.main.async {
            self.medicationTextField.text = medication.name
            self.notesTextView.text = medication.notes
            
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return AlarmController.shared.alarms.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "alarmCell", for: indexPath) as? SwitchTableViewCell
        let alarm = AlarmController.shared.alarms[indexPath.row]
        
        cell?.delegate = self
        cell?.timeLabel.text = alarm.fireTimeAsString
        
        return cell ?? UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let alarm = AlarmController.shared.alarms[indexPath.row]
            AlarmController.shared.deleteAlarm(alarm: alarm) { (success) in
                if success {
                    DispatchQueue.main.async {
                        self.alarmTableView.deleteRows(at: [indexPath], with: .automatic)
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
        
        if segue.identifier == "toTimePicker" {
            let destinationVC = segue.destination as? SetAlarmTimeViewController
            destinationVC?.medication = medication
        }
    }
}

extension MedicationDetailViewController: SetAlarmTimeViewControllerDelegate {
    
    func alarmSaved(alarm: Alarm?) {

        if let alarm = alarm {
            AlarmController.shared.alarms.append(alarm)

        }
        DispatchQueue.main.async {
            self.alarmTableView.reloadData()
        }
    }
    
    func alertController() {
        let alertController = UIAlertController(title: "Set a reminder?", message: "You can add alarms later", preferredStyle: .alert)
        
        let noAction = UIAlertAction(title: "No", style: .cancel, handler: nil)
        let yesAction = UIAlertAction(title: "Yes", style: .default) { (_) in
            
            self.performSegue(withIdentifier: "toTimePicker", sender: self)
        }
        
        alertController.addAction(yesAction)
        alertController.addAction(noAction)
        present(alertController, animated: true, completion: nil)
        
        
    }
}
