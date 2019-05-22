//
//  MedicationDetailViewController.swift
//  PillBox
//
//  Created by Hannah Hoff on 5/20/19.
//  Copyright © 2019 Hannah Hoff. All rights reserved.
//

import UIKit

protocol AlarmTableViewCellDelegate: class {
    func switchCellSwitchValueChanged(cell: SwitchTableViewCell)
}


class MedicationDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, AlarmTableViewCellDelegate, SwitchTableViewCellDelegate {
    
    var medication: Medication? {
        didSet {
            loadViewIfNeeded()
            updateViews()
        }
    }
    
    @IBOutlet weak var alarmTableView: UITableView!
    @IBOutlet weak var medicationTextField: UITextField!
    @IBOutlet weak var notesTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        alarmTableView.dataSource = self
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
    
    @IBAction func doneButtonTapped(_ sender: Any) {
        guard let name = medicationTextField.text,
            !name.isEmpty else { return }
        MedicationController.shared.addMedicationWith(name: name, notes: notesTextView.text, alarm: AlarmController.shared.alarms) { (true) in
            DispatchQueue.main.async {
                self.navigationController?.popViewController(animated: true)
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
        
        medicationTextField.text = medication.name
        notesTextView.text = medication.notes
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
        }
//     // Get the new view controller using segue.destination.
//     // Pass the selected object to the new view controller.
     }
 
}
