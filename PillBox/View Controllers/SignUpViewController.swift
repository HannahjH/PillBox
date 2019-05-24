//
//  SignUpViewController.swift
//  PillBox
//
//  Created by Hannah Hoff on 5/16/19.
//  Copyright © 2019 Hannah Hoff. All rights reserved.
//

import UIKit

class SignUpViewController: UIViewController {
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }



@IBAction func signUpButtonTapped(_ sender: Any) {
    guard let email = emailTextField.text,
    let name = nameTextField.text,
    !email.isEmpty,
        !name.isEmpty else { return }
    
    UserController.shared.createUserWith(
    name: name, email: email) { (success) in
        if success {

        }
    }
}

/*
 // MARK: - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
 // Get the new view controller using segue.destination.
 // Pass the selected object to the new view controller.
 }
 */

}
