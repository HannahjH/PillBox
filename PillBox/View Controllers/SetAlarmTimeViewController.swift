
//  SetAlarmTimeViewController.swift
//  PillBox
//
//  Created by Hannah Hoff on 5/20/19.
//  Copyright © 2019 Hannah Hoff. All rights reserved.


import UIKit

class SetAlarmTimeViewController: UIViewController {

    var alarm: Alarm? {
        didSet {
            loadViewIfNeeded()
            updateViews()
        }
    }

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
        } else {
            AlarmController.shared.addAlarm(fireDate: datePicker.date, enabled: alarmIsOn)
        }
        DispatchQueue.main.async {
            self.navigationController?.popViewController(animated: true)
            
        }
    }


    /*
     MARK: - Navigation

     In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
         Get the new view controller using segue.destination.
         Pass the selected object to the new view controller.
    }
    */

}

