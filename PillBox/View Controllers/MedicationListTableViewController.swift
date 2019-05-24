//
//  MedicationListTableViewController.swift
//  PillBox
//
//  Created by Hannah Hoff on 5/21/19.
//  Copyright © 2019 Hannah Hoff. All rights reserved.
//

import UIKit

protocol MedicationTableViewCellDelegate: class {
    func medsSwitchCellSwitchValueChanged(cell: MedicationListTableViewCell)
}

class MedicationListTableViewController: UITableViewController, MedsSwitchTableViewCellDelegate  {
    
    let enabled: Bool = false
    
//    var medications: [Medication] = []
    
    func medsSwitchCellSwitchValueChanged(cell: MedicationListTableViewCell) {
        //check status of alarm switches
        
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        let medication = MedicationController.shared.meds[indexPath.row]
        MedicationController.shared.toggleEnabled(for: medication)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        UserController.shared.fetchCurrentUser { (success) in
            if success {
                MedicationController.shared.fetchMedication(completion: { (success) in
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                })
            }
        }
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return MedicationController.shared.meds.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "medicationCell", for: indexPath) as? MedicationListTableViewCell
        let medication = MedicationController.shared.meds[indexPath.row]
        
        cell?.delegate = self
        cell?.medicationLabel.text = medication.name
//        cell?.numOfAlarmsLabel.text = medication.
        
        return cell ?? UITableViewCell()
    }

    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }

  
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toEditVC" {
            let destinationVC = segue.destination as? MedicationDetailViewController
            guard let indexPath = tableView.indexPathForSelectedRow else { return }
            let medication = MedicationController.shared.meds[indexPath.row]
            destinationVC?.medication = medication
        }
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
}

//extension MedicationListTableViewController: MedicationDetailViewControllerDelegate {
//    
//    func medicationSaved(medication: Medication?) {
//        if let medication = medication {
//            medications.append(medication)
//            
//        }
//        DispatchQueue.main.async {
//            self.tableView.reloadData()
//        }
//    }
//}

