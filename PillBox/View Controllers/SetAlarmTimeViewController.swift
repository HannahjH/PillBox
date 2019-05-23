
//  SetAlarmTimeViewController.swift
//  PillBox
//
//  Created by Hannah Hoff on 5/20/19.
//  Copyright © 2019 Hannah Hoff. All rights reserved.


import UIKit
import CloudKit

protocol SetAlarmTimeViewControllerDelegate: class {
    func alarmSaved(alarm: Alarm?)
}

class SetAlarmTimeViewController: UIViewController {

    var alarm: Alarm? {
        didSet {
            loadViewIfNeeded()
            updateViews()
        }
    }
    
    var medication: Medication? {
        didSet {
            updateViews()
        }
    }
    
    weak var delegate: SetAlarmTimeViewControllerDelegate?
    var alarmIsOn: Bool = true

    @IBOutlet weak var datePicker: UIDatePicker!

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    private func updateViews() {
        guard let alarm = alarm else { return }
        datePicker.date = alarm.fireDate
    }
    
    @IBAction func saveButtonTapped(_ sender: Any) {
        if let alarm = alarm {
            AlarmController.shared.updateAlarm(alarm: alarm, fireDate: datePicker.date, enabled: alarmIsOn)
            navigationController?.popViewController(animated: true)
//            delegate?.alarmSaved(alarm: alarm)
        } else {
            AlarmController.shared.addAlarm(fireDate: datePicker.date, enabled: alarmIsOn) { (true) in
                guard let alarm = AlarmController.shared.alarms.last else { return }
                self.delegate?.alarmSaved(alarm: alarm)
                }
            DispatchQueue.main.async {
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
}

