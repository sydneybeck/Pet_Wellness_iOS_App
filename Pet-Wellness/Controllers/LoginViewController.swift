//
//  LoginViewController.swift
//  Pet-Wellness
//
//  Created by sydney beck on 11/14/22.
//

import UIKit
import Firebase
import FirebaseFirestore
import FirebaseAuth

class LoginViewController: UIViewController {
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func loginPressed(_ sender: UIButton) {
        guard let email = emailTextField.text, !email.isEmpty,
              let password = passwordTextField.text, !password.isEmpty else {
            Database.displayAlert(title: "Error", message: "Please enter email and password", viewController: self)
            return
        }
        
        Database.login(email: email, password: password, viewController: self) { error in
            if error == nil {
                self.performSegue(withIdentifier: "LoginToDashboard", sender: self)
            }
        }
    }
}
