//
//  RegisterViewController.swift
//  Pet-Wellness
//
//  Created by sydney beck on 11/14/22.
//

import UIKit
import Firebase
import FirebaseFirestore
import FirebaseAuth

class RegisterViewController: UIViewController {
    
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var nameTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func registerPressed(_ sender: UIButton) {
        guard let email = emailTextField.text, !email.isEmpty,
              let password = passwordTextField.text, !password.isEmpty,
              let name = nameTextField.text, !name.isEmpty,
              let phone = phoneTextField.text, !phone.isEmpty else {
            Database.displayAlert(title: "Error", message: "Please fill out all fields", viewController: self)
            return
        }
        
        Database.register(email: email, password: password, name: name, phone: phone, viewController: self) { error in
            if error == nil {
                self.performSegue(withIdentifier: "RegisterToDashboard", sender: self)
            }
        }
    }
}


