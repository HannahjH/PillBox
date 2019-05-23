//
//  MedicationListTableViewCell.swift
//  PillBox
//
//  Created by Hannah Hoff on 5/21/19.
//  Copyright © 2019 Hannah Hoff. All rights reserved.
//

import UIKit

protocol MedsSwitchTableViewCellDelegate: class {
    func medsSwitchCellSwitchValueChanged(cell: MedicationListTableViewCell)
}

class MedicationListTableViewCell: UITableViewCell {
    
    var switchOn: Bool = true
    
    var medication: Medication? {
        didSet {
            updateViews()
        }
    }
    
    weak var delegate: MedsSwitchTableViewCellDelegate?
    
    @IBOutlet weak var medicationLabel: UILabel!
    @IBOutlet weak var numOfAlarmsLabel: UILabel!
    @IBOutlet weak var medicationSwitch: UISwitch!
    
    func updateViews() {
        guard let medication = medication else { return }
        medicationLabel.text = medication.name
        numOfAlarmsLabel.text = "\(AlarmController.shared.alarms.count)"
        medicationSwitch.isOn = medication.enabled
    }
    
    @IBAction func medsSwitchValueChanged(_ sender: Any) {
        delegate?.medsSwitchCellSwitchValueChanged(cell: self)
        
        //check status of medSwitch
        if medicationSwitch.isOn {
            switchOn = true
        }
        if medicationSwitch.isOn == false {
            medication?.enabled = false
            
        }
    }
}
